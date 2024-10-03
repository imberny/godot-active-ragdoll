shader_type spatial;
render_mode ambient_light_disabled;

uniform sampler2D albedo: source_color;
uniform vec3 emission_ambient_tweak: source_color = vec3(0.1, 0.2, 0.3);

group_uniforms Rim;
uniform vec3 rim_color: source_color = vec3(0.0);
uniform float rim_threshold: hint_range(0.0, 1.0, 0.02) = 0.5;
group_uniforms;

group_uniforms Lighting;
uniform sampler2D shadow_color_ramp: source_color, repeat_disable, filter_nearest, hint_default_black;
uniform vec3 light_tweak: source_color = vec3(0.0);
group_uniforms;

float when_gt(float x, float y) {
  return max(sign(x - y), 0.0);
}

void fragment() {
	vec4 albedo_color = texture(albedo, UV);
    
    float n_dot_v = dot(NORMAL, VIEW);
    float rim_factor = when_gt(rim_threshold, n_dot_v); 
    
    ALBEDO = albedo_color.rgb * (1.0 - rim_factor) + rim_factor * rim_color;
    EMISSION = ALBEDO * emission_ambient_tweak;
}

void light() {
    float n_dot_l = dot(NORMAL, LIGHT);
    //vec4 shadow_color = texture(shadow_color_ramp, vec2(n_dot_l));
    //DIFFUSE_LIGHT += ALBEDO * shadow_color.rgb * LIGHT_COLOR;
    // This clamp prevents an ugly wraparound of the shadow ramp
    float light_value = clamp(n_dot_l * ATTENUATION * ATTENUATION, 0.02, 0.98);
    // use diffuse light as an accumulator of total light
    DIFFUSE_LIGHT += light_value * LIGHT_COLOR * ALBEDO;
    
    float light_level = length(DIFFUSE_LIGHT);
    vec4 shadow_color = texture(shadow_color_ramp, vec2(light_level));
    SPECULAR_LIGHT = (shadow_color.rgb + light_tweak) * ALBEDO;
    //SPECULAR_LIGHT = DIFFUSE_LIGHT + ALBEDO;
    //
    // Cancel out diffuse light's contribution
    SPECULAR_LIGHT -= DIFFUSE_LIGHT * ALBEDO;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
