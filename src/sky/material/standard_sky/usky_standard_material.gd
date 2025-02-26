# Universal Sky
# Description:
# - Standard sky material.
# License:
# - J. Cuéllar 2025 MIT License
# - See: LICENSE File.
@tool
class_name USkyStandandMaterial extends USkyMaterialBase

#region Resources
const SHADER:= preload("res://addons/universal-sky/src/sky/shaders/sky/standard/usky_standard.gdshader")
#endregion

#region Shader params
const TONEMAP_LEVEL_PARAM:= &"tonemap_level"
const EXPOSURE_PARAM:= &"exposure"
const HORIZON_LEVEL_PARAM:= &"horizon_level"

const ATM_DARKNESS_PARAM:= &"atm_darkness"
const ATM_SUN_E_PARAM:= &"atm_sunE"
const ATM_RAYLEIGH_LEVEL_PARAM:= &"atm_rayleigh_level"
const ATM_THICKNESS_PARAM:= &"atm_thickness"

const ATM_BETA_RAY_PARAM:= &"atm_beta_ray"
const ATM_BETA_MIE_PARAM:= &"atm_beta_mie"
const ATM_GROUND_COLOR_PARAM:= &"atm_ground_color"

const SUN_UMUS_PARAM:= &"sun_uMuS"
const SUN_PARTIAL_MIE_PHASE_PARAM:= &"atm_sun_partial_mie_phase"
const MOON_PARTIAL_MIE_PHASE_PARAM:= &"atm_moon_partial_mie_phase"

const DAY_TINT_PARAM:= &"atm_day_tint"
const NIGHT_TINT_PARAM:= &"atm_night_tint"
#endregion

#region General Settings
@export_group("General Settings")
@export
var tonemap_level: float = 0.0:
	get: return tonemap_level
	set(value):
		tonemap_level = value
		RenderingServer.material_set_param(
			material.get_rid(), TONEMAP_LEVEL_PARAM, tonemap_level
		)
		
		RenderingServer.material_set_param(
			refl_material.get_rid(), TONEMAP_LEVEL_PARAM, tonemap_level
		)
		emit_changed()

@export
var exposure: float = 1.0:
	get: return exposure
	set(value):
		exposure = value
		RenderingServer.material_set_param(
			material.get_rid(), EXPOSURE_PARAM, exposure
		)
		
		RenderingServer.material_set_param(
			refl_material.get_rid(), EXPOSURE_PARAM, exposure
		)
		emit_changed()

@export_range(-1.0, 1.0)
var horizon_level: float = 0.0:
	get: return horizon_level
	set(value):
		horizon_level = value
		RenderingServer.material_set_param(
			material.get_rid(), HORIZON_LEVEL_PARAM, horizon_level
		)
		
		RenderingServer.material_set_param(
			refl_material.get_rid(), HORIZON_LEVEL_PARAM, horizon_level
		)
		emit_changed()
#endregion

#region Atmosphere
@export_group("Atmosphere", "atm_")
@export_enum("PerPixel", "PerVertex")
var atm_quality: int = 0:
	get: return atm_quality
	set(value):
		atm_quality = value
		# TODO: Cambiar el macro o el shader.
		emit_changed()

@export_range(0.0, 1.0)
var atm_darkness: float = 0.1:
	get: return atm_darkness
	set(value):
		atm_darkness = value
		RenderingServer.material_set_param(
			material.get_rid(), ATM_DARKNESS_PARAM, atm_darkness
		)
		
		RenderingServer.material_set_param(
			refl_material.get_rid(), ATM_DARKNESS_PARAM, atm_darkness
		)
		emit_changed()

@export_subgroup("Rayleigh", "atm_")
@export
var atm_wavelenghts:= Vector3(680.0, 550.0, 440.0):
	get: return atm_wavelenghts
	set(value):
		atm_wavelenghts = value
		_set_beta_ray()

# TODO: Añadir una curva para controlar la densidad dependiendo del algulo del sol o un parametro.
@export
var atm_rayleigh_level: float = 1.0:
	get: return atm_rayleigh_level
	set(value):
		atm_rayleigh_level = value
		RenderingServer.material_set_param(
			material.get_rid(), ATM_RAYLEIGH_LEVEL_PARAM, atm_rayleigh_level
		)
		
		RenderingServer.material_set_param(
			refl_material.get_rid(), ATM_RAYLEIGH_LEVEL_PARAM, atm_rayleigh_level
		)
		emit_changed()

@export
var atm_thickness: float = 1.0:
	get: return atm_thickness
	set(value):
		atm_thickness = value
		RenderingServer.material_set_param(
			material.get_rid(), ATM_THICKNESS_PARAM, atm_thickness
		)
		
		RenderingServer.material_set_param(
			refl_material.get_rid(), ATM_THICKNESS_PARAM, atm_thickness
		)
		emit_changed()

@export_subgroup("Mie", "atm_")
@export
var atm_mie: float = 0.07:
	get: return atm_mie
	set(value):
		atm_mie = value
		_set_beta_mie()
		emit_changed()

@export
var atm_turbidity: float = 0.001:
	get: return atm_turbidity
	set(value):
		atm_turbidity = value
		_set_beta_mie()
		emit_changed()

@export_subgroup("Day", "atm_")
@export
var atm_sun_intensity: float = 15.0:
	get: return atm_sun_intensity
	set(value):
		atm_sun_intensity = value
		RenderingServer.material_set_param(
			material.get_rid(), ATM_SUN_E_PARAM, atm_sun_intensity
		)
		
		RenderingServer.material_set_param(
			refl_material.get_rid(), ATM_SUN_E_PARAM, atm_sun_intensity
		)
		emit_changed()

@export
var atm_day_gradient: Gradient:
	get: return atm_day_gradient
	set(value):
		atm_day_gradient = value
		if is_instance_valid(value):
			_disconnect_changed_atm_day_gradient()
			_connect_changed_atm_day_gradient()
		
		_set_atm_day_tint()
		emit_changed()

@export_subgroup("Night", "atm_")
@export
var atm_night_intensity: float = 1.0:
	get: return atm_night_intensity
	set(value):
		atm_night_intensity = value
		_set_atm_night_tint()
		emit_changed()

@export
var atm_enable_night_scattering: bool = false:
	get: return atm_enable_night_scattering
	set(value):
		atm_enable_night_scattering = value
		update_suns_direction()
		update_moons_direction()
		emit_changed()

@export
var atm_night_tint:= Color(0.254902, 0.337255, 0.447059):
	get: return atm_night_tint
	set(value):
		atm_night_tint = value
		_set_atm_night_tint()
		emit_changed()

@export_subgroup("Ground", "atm_")
@export
var atm_ground_color:= Color(0.543, 0.543, 0.543): # Color(0.204, 0.345, 0.467):
	get: return atm_ground_color
	set(value):
		atm_ground_color = value
		RenderingServer.material_set_param(
			material.get_rid(), ATM_GROUND_COLOR_PARAM, atm_ground_color * 5.0
		)
		
		RenderingServer.material_set_param(
			refl_material.get_rid(), ATM_GROUND_COLOR_PARAM, atm_ground_color * 5.0
		)
		emit_changed()
#endregion

#region Atmospheric scattering const
# Index of the air refraction.
const n: float = 1.0003

# Index of the air refraction ˆ 2.
const n2: float = 1.00060009

# Molecular Density.
const N: float = 2.545e25

# Depolatization factor for standard air.
const pn: float = 0.035
#endregion

#region Setup
func material_is_valid() -> bool:
	return true

func _on_init() -> void:
	super()
	material.shader = SHADER
	
	tonemap_level = tonemap_level
	exposure = exposure
	horizon_level = horizon_level
	
	atm_darkness = atm_darkness
	atm_wavelenghts = atm_wavelenghts
	atm_rayleigh_level = atm_rayleigh_level
	atm_thickness = atm_thickness
	
	atm_mie = atm_mie
	atm_turbidity = atm_turbidity
	
	atm_sun_intensity = atm_sun_intensity
	atm_day_gradient = atm_day_gradient
	
	atm_night_intensity = atm_night_intensity
	atm_enable_night_scattering = atm_enable_night_scattering
	atm_night_tint = atm_night_tint
	
	atm_ground_color = atm_ground_color
	

func _connect_changed_atm_day_gradient() -> void:
	if !atm_day_gradient.changed.is_connected(_set_atm_day_tint):
		atm_day_gradient.changed.connect(_set_atm_day_tint)

func _disconnect_changed_atm_day_gradient() -> void:
	if atm_day_gradient.changed.is_connected(_set_atm_day_tint):
		atm_day_gradient.changed.disconnect(_set_atm_day_tint)
#endregion

#region Celestials
func update_suns_direction() -> void:
	super()
	_set_sun_uMus()
	_set_atm_day_tint()
	_set_atm_night_tint()

func update_moons_direction() -> void:
	super()
	_set_sun_uMus()
	_set_atm_night_tint()
#endregion

#region Atmospheric scattering
func get_celestial_uMus(dir: Vector3) -> float:
	return 0.015 + (atan(max(dir.y, - 0.1975) * tan(1.386))
		* 0.9090 + 0.74) * 0.5 * (0.96875);

func compute_wavelenghts_lambda(value: Vector3) -> Vector3:
	return value * 1e-9

func compute_wavelenghts(value: Vector3, computeLambda: bool = false) -> Vector3:
	var k: float = 4.0
	var ret: Vector3 = value
	if computeLambda:
		ret = compute_wavelenghts_lambda(ret)
	
	ret.x = pow(ret.x, k)
	ret.y = pow(ret.y, k)
	ret.z = pow(ret.z, k)
	return ret

func compute_beta_ray(wavelenghts: Vector3) -> Vector3:
	var kr: float =  (8.0 * pow(PI, 3.0) * pow(n2 - 1.0, 2.0) * (6.0 + 3.0 * pn))
	var ret: Vector3 = 3.0 * N * wavelenghts * (6.0 - 7.0 * pn)
	ret.x = kr / ret.x
	ret.y = kr / ret.y
	ret.z = kr / ret.z
	return ret

func compute_beta_mie(mie: float, turbidity: float) -> Vector3:
	var k: float = 434e-6
	return Vector3.ONE * mie * turbidity * k

func get_partial_mie_phase(g: float) -> Vector3:
	var g2 = g * g
	var ret: Vector3
	ret.x = ((1.0 - g2) / (2.0 + g2))
	ret.y = 1.0 + g2
	ret.z = 2.0 * g
	return ret

func _set_beta_ray() -> void:
	var wls:= compute_wavelenghts(atm_wavelenghts, true)
	var br:= compute_beta_ray(wls)
	RenderingServer.material_set_param(
		material.get_rid(), ATM_BETA_RAY_PARAM, br
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), ATM_BETA_RAY_PARAM, br
	)
	emit_changed()

func _set_beta_mie() -> void:
	var bm:= compute_beta_mie(atm_mie, atm_turbidity)
	RenderingServer.material_set_param(
		material.get_rid(), ATM_BETA_MIE_PARAM, bm
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), ATM_BETA_MIE_PARAM, bm
	)
	emit_changed()

func _set_sun_uMus() -> void:
	if suns_data.direction.size() < 1:
		return
	#var dirSum: Vector3 = suns_data.direction.reduce(func(a,b): return a+b) \
	#if suns_data.direction.size() < 2 else suns_data.direction[0]
	
	var acc:= Vector3.ZERO
	for i in len(suns_data.direction):
		acc += suns_data.direction[i] / suns_data.direction.size()
	
	RenderingServer.material_set_param(
		material.get_rid(), SUN_UMUS_PARAM, get_celestial_uMus(acc)
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), SUN_UMUS_PARAM, get_celestial_uMus(acc)
	)
	emit_changed()

func update_suns_mie_anisotropy() -> void:
	suns_data.mie_anisotropy[0] = clamp(suns_data.mie_anisotropy[0], 0.0, 0.999)
	var partial:= get_partial_mie_phase(suns_data.mie_anisotropy[0])
	RenderingServer.material_set_param(
		material.get_rid(), SUN_PARTIAL_MIE_PHASE_PARAM, partial
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), SUN_PARTIAL_MIE_PHASE_PARAM, partial
	)
	emit_changed()

func update_moons_mie_anisotropy() -> void:
	moons_data.mie_anisotropy[0] = clamp(moons_data.mie_anisotropy[0], 0.0, 0.999)
	var partial:= get_partial_mie_phase(moons_data.mie_anisotropy[0])
	RenderingServer.material_set_param(
		material.get_rid(), MOON_PARTIAL_MIE_PHASE_PARAM, partial
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), MOON_PARTIAL_MIE_PHASE_PARAM, partial
	)
	emit_changed()

func _set_atm_day_tint() -> void:
	if suns_data.direction.size() < 1:
		return
	#var sunsSum: Vector3 = suns_data.direction.reduce(func(a,b): return a+b) \
	#if suns_data.direction.size() < 2 else suns_data.direction[0]
	
	var acc:= Vector3.ZERO
	for i in len(suns_data.direction):
		acc += suns_data.direction[i] / suns_data.direction.size()
	
	RenderingServer.material_set_param(
		material.get_rid(), DAY_TINT_PARAM,
		atm_day_gradient.sample(USkyUtil.interpolate_by_above(acc.y))
		if is_instance_valid(atm_day_gradient) else Color.WHITE
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), DAY_TINT_PARAM,
		atm_day_gradient.sample(USkyUtil.interpolate_by_above(acc.y))
		if is_instance_valid(atm_day_gradient) else Color.WHITE
	)

func get_atm_night_intensity() -> float:
	if moons_data.direction.size() < 1:
		return 1.0
	
	var acc := 0.0
	for i in len(moons_data.direction):
		acc += get_celestial_uMus(moons_data.direction[i] / moons_data.direction.size())
		
	var ret: float
	if !atm_enable_night_scattering:
		if _suns_data.direction.size() > 0:
			var sunAcc: float
			for i in len(suns_data.direction):
				sunAcc += suns_data.direction[i].y / suns_data.direction.size()
			ret = clamp(-sunAcc + 0.50, 0.0, 1.0)
	else:
		ret = acc

	return ret * atm_night_intensity * get_atm_moon_phases_mul()

func get_atm_moon_phases_mul() -> float:
	if moons_data.direction.size() < 1:
		return 1.0
	
	if atm_enable_night_scattering:
		var acc: float = 0.0
		for i in len(moons_data.direction):
			acc += moons_data.moon_phases_mul[i] / moons_data.moon_phases_mul.size()
		return acc
	
	return 1.0;

func _set_atm_night_tint() -> void:
	var tint:= atm_night_tint * get_atm_night_intensity()
	RenderingServer.material_set_param(
		material.get_rid(), NIGHT_TINT_PARAM, tint
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), NIGHT_TINT_PARAM, tint
	)
	update_moons_mie_intensity()
	emit_changed()
#endregion
