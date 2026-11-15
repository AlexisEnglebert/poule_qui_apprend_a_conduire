shader_type spatial;
render_mode unshaded, cull_disabled, blend_add, depth_draw_never;

uniform vec4 color : source_color = vec4(0.2, 0.8, 1.0, 0.8);
uniform float box_height = 0.48;    // Doit être identique à BoxMesh -> Size -> Y
uniform float fade_power = 2.0;    // Intensité du dégradé
uniform float pulse_speed = 2.0;
uniform float pulse_amount = 0.15;

varying float v_height_ratio;
varying vec3 v_local_normal;

void vertex() {
    v_height_ratio = 1.0 - clamp((VERTEX.y / box_height) + 0.5, 0.2, 1.0);
    
    // On récupère la normale locale (indépendante de la rotation de l'objet dans le monde)
    v_local_normal = NORMAL;
}

void fragment() {
    // Masque le plafond et le sol du BoxMesh
    if (abs(v_local_normal.y) > 0.5) {
        discard;
    }

    float vertical_fade = pow(v_height_ratio, fade_power);
    float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_amount;
    
    float fresnel = pow(1.0 - abs(dot(NORMAL, VIEW)), 1.5);
    float edge_boost = mix(0.6, 1.3, fresnel);

    ALBEDO = color.rgb * pulse * edge_boost;
    ALPHA = clamp(color.a * vertical_fade, 0.0, 1.0);
}