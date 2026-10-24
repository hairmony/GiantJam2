shader_type canvas_item;

// Width is in screen pixels, including when the fishing camera zooms in.
uniform float outline_width : hint_range(0.0, 6.0) = 1.5;
varying vec4 sprite_tint;

void vertex() {
	sprite_tint = COLOR;
	mat4 screen_transform = CANVAS_MATRIX * MODEL_MATRIX;
	vec2 screen_scale = vec2(length(screen_transform[0].xy), length(screen_transform[1].xy));
	vec2 margin = vec2(outline_width) / max(screen_scale, vec2(0.0001));
	vec2 direction = UV * 2.0 - 1.0;
	// Expand the quad so the outline is not clipped at the texture edges.
	VERTEX += direction * margin;
	UV += direction * margin * TEXTURE_PIXEL_SIZE;
}

float inside_texture(vec2 uv) {
	return float(all(greaterThanEqual(uv, vec2(0.0))) && all(lessThanEqual(uv, vec2(1.0))));
}

void fragment() {
	vec2 dx = dFdx(UV) * outline_width;
	vec2 dy = dFdy(UV) * outline_width;
	float edge_alpha = 0.0;
	for (int i = 0; i < 8; i++) {
		float angle = float(i) * 0.78539816339;
		vec2 sample_uv = UV + cos(angle) * dx + sin(angle) * dy;
		float sample_alpha = texture(TEXTURE, clamp(sample_uv, vec2(0.0), vec2(1.0))).a * inside_texture(sample_uv);
		edge_alpha = max(edge_alpha, sample_alpha);
	}
	vec4 sprite = texture(TEXTURE, clamp(UV, vec2(0.0), vec2(1.0))) * sprite_tint;
	sprite.a *= inside_texture(UV);
	float border_alpha = edge_alpha * sprite_tint.a * (1.0 - sprite.a);
	float combined_alpha = sprite.a + border_alpha;
	vec3 combined_rgb = (sprite.rgb * sprite.a + vec3(1.0) * border_alpha) / max(combined_alpha, 0.0001);
	COLOR = vec4(combined_rgb, combined_alpha);
}
