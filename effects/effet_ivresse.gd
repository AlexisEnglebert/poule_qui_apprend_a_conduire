@tool
class_name EffetIvresse
extends CompositorEffect
## Effet "bourré" discret, en compute shader (Godot 4, rendu Forward+).
##
## Activer / désactiver : case « Enabled » de l'effet dans l'inspecteur,
## ou en code : effet.enabled = true / false

## 0 = aucun effet, 1 = bien bourré (ça reste discret)
@export_range(0.0, 1.0, 0.01) var intensite: float = 0.6

const CONTEXT := &"EffetIvresse"
const COPY_TEX := &"copie"

const SHADER_CODE := """
#version 450
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform image2D color_image; // l'écran
layout(rgba16f, set = 0, binding = 1) uniform image2D copy_image;  // copie de l'écran

layout(push_constant, std430) uniform Params {
	vec2 size;
	float time;
	float intensity;
	float mode;   // 0 = copie, 1 = effet
	float pad0;
	float pad1;
	float pad2;
} p;

// Lecture lissée de la copie (filtrage bilinéaire)
vec4 load_bilinear(vec2 px) {
	vec2 s = p.size - 1.0;
	px = clamp(px - 0.5, vec2(0.0), s);
	ivec2 i0 = ivec2(floor(px));
	ivec2 i1 = min(i0 + 1, ivec2(s));
	vec2 f = fract(px);
	vec4 a = imageLoad(copy_image, i0);
	vec4 b = imageLoad(copy_image, ivec2(i1.x, i0.y));
	vec4 c = imageLoad(copy_image, ivec2(i0.x, i1.y));
	vec4 d = imageLoad(copy_image, i1);
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void main() {
	ivec2 pix = ivec2(gl_GlobalInvocationID.xy);
	if (pix.x >= int(p.size.x) || pix.y >= int(p.size.y)) {
		return;
	}

	// Passe 1 : on copie l'écran
	if (p.mode < 0.5) {
		imageStore(copy_image, pix, imageLoad(color_image, pix));
		return;
	}

	// Passe 2 : l'effet
	float k = p.intensity;
	float t = p.time;
	float aspect = p.size.x / p.size.y;
	vec2 uv = (vec2(pix) + 0.5) / p.size;

	// Léger balancement + petit zoom pour cacher les bords
	vec2 q = uv - 0.5;
	q.x *= aspect;
	float ang = sin(t * 0.6) * 0.012 * k;
	q = mat2(cos(ang), sin(ang), -sin(ang), cos(ang)) * q;
	q /= 1.0 + 0.02 * k;
	q.x /= aspect;
	uv = q + 0.5;

	// Ondulation lente
	uv.x += sin(uv.y * 6.0 + t * 0.9) * 0.002 * k;
	uv.y += sin(uv.x * 5.0 + t * 0.7) * 0.002 * k;

	// Vision double discrète qui va et vient
	float d = (0.5 + 0.5 * sin(t * 0.5)) * 0.006 * k;
	vec2 off = vec2(d, 0.0);
	vec4 col = mix(load_bilinear((uv - off) * p.size),
	               load_bilinear((uv + off) * p.size), 0.5);

	// Vignette douce
	vec2 v = (vec2(pix) + 0.5) / p.size - 0.5;
	v.x *= aspect;
	col.rgb *= 1.0 - smoothstep(0.4, 1.1, length(v)) * 0.35 * k;

	imageStore(color_image, pix, col);
}
"""

var rd: RenderingDevice
var shader: RID
var pipeline: RID
var last_size := Vector2i.ZERO


func _init() -> void:
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	RenderingServer.call_on_render_thread(_init_compute)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and shader.is_valid():
		RenderingServer.free_rid(shader) # libère aussi le pipeline


func _init_compute() -> void:
	rd = RenderingServer.get_rendering_device()
	if rd == null:
		return
	var src := RDShaderSource.new()
	src.language = RenderingDevice.SHADER_LANGUAGE_GLSL
	src.source_compute = SHADER_CODE
	var spirv := rd.shader_compile_spirv_from_source(src)
	if spirv.compile_error_compute != "":
		push_error(spirv.compile_error_compute)
		return
	shader = rd.shader_create_from_spirv(spirv)
	if shader.is_valid():
		pipeline = rd.compute_pipeline_create(shader)


func _render_callback(callback_type: int, render_data: RenderData) -> void:
	if rd == null or not pipeline.is_valid() or callback_type != EFFECT_CALLBACK_TYPE_POST_TRANSPARENT:
		return
	var buffers := render_data.get_render_scene_buffers() as RenderSceneBuffersRD
	if buffers == null:
		return
	var size := buffers.get_internal_size()
	if size.x == 0 or size.y == 0:
		return

	var views := buffers.get_view_count()
	if size != last_size and buffers.has_texture(CONTEXT, COPY_TEX):
		buffers.clear_context(CONTEXT)
	last_size = size
	if not buffers.has_texture(CONTEXT, COPY_TEX):
		buffers.create_texture(CONTEXT, COPY_TEX,
			RenderingDevice.DATA_FORMAT_R16G16B16A16_SFLOAT,
			RenderingDevice.TEXTURE_USAGE_STORAGE_BIT,
			RenderingDevice.TEXTURE_SAMPLES_1, size, views, 1, true, false)

	var groups_x := ceili(size.x / 8.0)
	var groups_y := ceili(size.y / 8.0)
	var time := Time.get_ticks_msec() / 1000.0

	for view in views:
		var u_color := RDUniform.new()
		u_color.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		u_color.binding = 0
		u_color.add_id(buffers.get_color_layer(view))

		var u_copy := RDUniform.new()
		u_copy.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		u_copy.binding = 1
		u_copy.add_id(buffers.get_texture_slice(CONTEXT, COPY_TEX, view, 0, 1, 1))

		var uniform_set := UniformSetCacheRD.get_cache(shader, 0, [u_color, u_copy])

		for mode in [0.0, 1.0]: # passe copie, puis passe effet
			var pc := PackedFloat32Array([size.x, size.y, time, intensite, mode, 0.0, 0.0, 0.0]).to_byte_array()
			var list := rd.compute_list_begin()
			rd.compute_list_bind_compute_pipeline(list, pipeline)
			rd.compute_list_bind_uniform_set(list, uniform_set, 0)
			rd.compute_list_set_push_constant(list, pc, pc.size())
			rd.compute_list_dispatch(list, groups_x, groups_y, 1)
			rd.compute_list_end()
