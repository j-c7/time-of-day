#ifndef USKY_VARIABLES
#define USKY_VARIABLES

// Sun.
uniform vec3 sun_direction[4];
uniform vec4 sun_color[4]: source_color;
uniform float sun_intensity[4];
uniform float sun_size[4];

// Moon.
uniform vec3 moon_direction[4];
uniform vec4 moon_color[4]: source_color;
uniform float moon_intensity[4];
uniform float moon_size[4];
uniform sampler2D moon_texture[4];
uniform mat3 moon_matrix[4];

// Atmosphere.
uniform bool atm_enable_night_scatter;
///uniform float atm_night_intensity;

uniform float exposure = 1.0;
uniform float tonemap_level = 0.0;
uniform float horizon_level = 0.0;

// Sun Mie
uniform float[4] atm_sun_mie_anisotropy;
uniform vec4[4] atm_sun_mie_color: source_color;
uniform float[4] atm_sun_mie_intensity;

// Moon Mie
uniform float[4] atm_moon_mie_anisotropy;
uniform vec4[4] atm_moon_mie_color: source_color;
uniform float[4] atm_moon_mie_intensity;

#endif