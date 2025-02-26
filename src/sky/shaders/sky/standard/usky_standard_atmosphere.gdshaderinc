#ifndef USKY_STANDARD_ATMOSPHERE
#define USKY_STANDARD_ATMOSPHERE

#include "res://addons/universal-sky/src/sky/shaders/common/usky_const.gdshaderinc"
#include "res://addons/universal-sky/src/sky/shaders/common/usky_color.gdshaderinc"
#include "res://addons/universal-sky/src/sky/shaders/common/usky_variables.gdshaderinc"

// Rayleigh.
uniform float atm_sunE = 15.0;
uniform float atm_darkness = 0.1;
uniform float atm_thickness = 1.0;
uniform float atm_rayleigh_level = 1.0;
uniform vec4 atm_day_tint: source_color = vec4(1.0);
uniform vec4 atm_night_tint: source_color = vec4(0.255, 0.337, 0.447, 1.0);
uniform vec3 atm_beta_ray;

// Mie.
uniform vec3 atm_beta_mie;
uniform vec3 atm_sun_partial_mie_phase;
uniform vec3 atm_moon_partial_mie_phase;
uniform vec4 atm_ground_color: source_color = vec4(0.255, 0.337, 0.447, 1.0);

uniform float sun_uMuS;

const float RAYLEIGH_ZENITH_LENGTH = 8.4e3;
const float MIE_ZENITH_LENGTH = 1.25e3;

float rayleighPhase(float mu){
	return k3PI16 * (1.0 + mu * mu);
}

float miePhasePartial(float mu, vec3 partial){
	return kPI4 * partial.x * (pow(partial.y - partial.z * mu, -1.5));
}

float miePhase(float mu, float g){
	float g2 = g*g;
	return kPI4 * ((1.0 - g2) / (2.0 + g2)) *
		(pow((1.0 + g2) - (2.0 * g) * mu, -1.5));
}

float miePhaseSimplified(float mu, float g){
	float g2 = g*g;
	return kPI4 * (1.0 - g2) *
		(pow((1.0 + g2) - (2.0 * g) * mu, -1.5));
}

float betaMie(float mie, float turbidity){
	const float k = 434e-6;
	return 1.0 * mie * turbidity * k;
}

void opticalDepth(float y, out vec3 sr, out vec3 sm){
	vec3 zenith = max(0.03, y + 0.03) + (max(0.0, -y) * atm_ground_color.xyz);
	zenith = 1.0 / zenith;
	sr = vec3(zenith * RAYLEIGH_ZENITH_LENGTH * atm_rayleigh_level);
	sm = vec3(zenith * MIE_ZENITH_LENGTH);
}

vec3 atmosphericScattering(vec3 pos, vec3 horizonBlend){
	vec3 scatter = vec3(0.0);
	vec3 sr, sm;
	opticalDepth(pos.y+horizon_level, sr, sm);

	vec3 betaMie = atm_beta_mie;
	vec3 betaRay = atm_beta_ray * atm_thickness;

	float sunMus = sun_uMuS - 0.4;
	float sunset = mix(sunMus, sunMus * 0.05, atm_thickness - 1.0);
	sunset = saturate(sunset);

	// Paper
	vec3 extinction = saturate(exp(-betaRay * sr + betaMie * sm));

	// Hack
	vec3 extincH = (1.0 -(extinction * 0.75)) * sr * 0.00002;
	vec3 finalExtc = mix((1.0-extinction), extinction * extincH, 1.0-sunset);

	float sunMu = dot(sun_direction[0], pos);
	float rayleighPhase = rayleighPhase(sunMu);

	vec3 BRT = betaRay * rayleighPhase ;
	vec3 BMT = betaMie * miePhasePartial(sunMu,
		atm_sun_partial_mie_phase) * horizonBlend;

	BMT *= atm_sun_mie_intensity[0] * atm_sun_mie_color[0].rgb;
	vec3 BRMT = (BRT+BMT) / (betaRay + betaMie);
	BRMT = mix(BRMT, BRMT * (1.0 - extinction), atm_darkness);

	vec3 Lin = atm_sunE * (BRMT * finalExtc)  * saturate(sun_uMuS -0.2);
	Lin *= atm_day_tint.rgb;

	// Night
	float moonMu = dot(moon_direction[0], pos);
	vec3 nLin = (1.0 - extinction) * atm_night_tint.rgb;
	nLin += miePhasePartial(moonMu, atm_moon_partial_mie_phase)
		* atm_moon_mie_color[0].rgb * (atm_moon_mie_intensity[0] * 0.001) * horizonBlend;

	scatter = Lin + nLin;

	return scatter;
}

#endif