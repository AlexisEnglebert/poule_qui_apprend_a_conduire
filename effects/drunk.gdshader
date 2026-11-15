shader_type canvas_item;

// =====================================================================
//  Effet "bourré" plein écran (Godot 4)
// ---------------------------------------------------------------------
//  À mettre sur un ColorRect qui couvre tout l'écran, dans un
//  CanvasLayer. Le script ivresse.gd s'en occupe tout seul.
//
//  intensity :  0.0 = sobre (image intacte)
//               0.5 = pompette
//               1.0 = bourré
//               2.0 = ivre mort
// =====================================================================

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

/** 0 = sobre, 0.5 = pompette, 1 = bourré, 2 = ivre mort */
uniform float intensity : hint_range(0.0, 3.0, 0.01) = 1.0;

mat2 rot(float a) {
	float c = cos(a);
	float s = sin(a);
	return mat2(vec2(c, -s), vec2(s, c));
}

// Flou doux : le centre + 6 échantillons en cercle.
// radius est une fraction de la hauteur de l'écran.
vec3 blur_sample(vec2 uv, float radius, float aspect, float t) {
	vec2 r = radius * vec2(1.0 / aspect, 1.0);
	vec3 col = texture(screen_texture, uv).rgb;
	for (int i = 0; i < 6; i++) {
		float a = float(i) * (TAU / 6.0) + t * 0.5;
		col += texture(screen_texture, uv + vec2(cos(a), sin(a)) * r).rgb;
	}
	return col / 7.0;
}

// Flou + aberration chromatique (rouge et bleu décalés en sens opposés).
vec3 drunk_sample(vec2 uv, vec2 ca, float blur, float aspect, float t) {
	float r = blur_sample(uv + ca, blur, aspect, t).r;
	float g = blur_sample(uv,      blur, aspect, t).g;
	float b = blur_sample(uv - ca, blur, aspect, t).b;
	return vec3(r, g, b);
}

void fragment() {
	float k      = max(intensity, 0.0);
	float t      = TIME;
	float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x; // largeur / hauteur

	// --- 1. La tête qui tangue : rotation + zoom qui respire ----------
	vec2 p = SCREEN_UV - 0.5;
	p.x *= aspect;                                       // rotation ronde, pas ovale
	float sway = (sin(t * 0.7) * 0.035 + sin(t * 1.9) * 0.010) * k;
	p = rot(sway) * p;
	float zoom = 1.0 + k * (0.06 + 0.03 * sin(t * 1.1)); // > 1 pour cacher les bords
	p /= zoom;
	p.x /= aspect;
	vec2 uv = p + 0.5;

	// Le regard qui glisse lentement
	uv += vec2(sin(t * 0.43), cos(t * 0.31)) * 0.012 * k;

	// --- 2. Ondulations, comme à travers un verre ----------------------
	uv.x += sin(uv.y * 9.0 + t * 1.6) * 0.005 * k;
	uv.y += sin(uv.x * 7.0 + t * 1.2) * 0.005 * k;

	// --- 3. Vision double : l'écart s'ouvre et se referme -------------
	float split = 0.5 + 0.5 * sin(t * 0.9);
	vec2 ghost  = vec2(cos(t * 0.5), sin(t * 0.8)) * (0.006 + 0.018 * split) * k;

	// --- 4. Flou + aberration chromatique ------------------------------
	vec2  ca   = (uv - 0.5) * 0.015 * k;
	float blur = 0.004 * k;

	vec3 col = mix(drunk_sample(uv + ghost, ca, blur, aspect, t),
	               drunk_sample(uv - ghost, ca, blur, aspect, t), 0.5);

	// --- 5. Couleurs : plus chaudes, un peu plus saturées --------------
	float kc   = clamp(k, 0.0, 1.0);
	float luma = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(col, col * vec3(1.06, 1.0, 0.90), 0.6 * kc); // teinte chaude
	col = mix(vec3(luma), col, 1.0 + 0.15 * kc);           // saturation +15 %

	// --- 6. Vignette qui pulse (vision tunnel) -------------------------
	vec2  vq    = (SCREEN_UV - 0.5) * vec2(aspect, 1.0);
	float pulse = 0.5 + 0.5 * sin(t * 2.2);
	float vig   = smoothstep(0.30, 0.95, length(vq) + 0.05 * pulse * k);
	col *= 1.0 - vig * 0.8 * clamp(k / 2.0, 0.0, 1.0);

	COLOR = vec4(clamp(col, 0.0, 1.0), 1.0);
}
