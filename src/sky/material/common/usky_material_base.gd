# Universal Sky
# Description:
# - Sky material base.
# License:
# - J. Cuéllar 2025 MIT License
# - See: LICENSE File.
@tool
class_name USkyMaterialBase extends Resource

#region Shader Param names
const SUN_DIRECTION_PARAM:= &"sun_direction"
const SUN_COLOR_PARAM:= &"sun_color"
const SUN_INTENSITY_PARAM:= &"sun_intensity"
const SUN_SIZE_PARAM:= &"sun_size"
const MOON_MATRIX_PARAM:= &"moon_matrix"
const SUN_MIE_COLOR_PARAM:= &"atm_sun_mie_color"
const SUN_MIE_INTENSITY_PARAM:= &"atm_sun_mie_intensity"
const SUN_MIE_ANISOTROPY_PARAM:= &"atm_sun_mie_anisotropy"

const MOON_DIRECTION_PARAM:= &"moon_direction"
const MOON_COLOR_PARAM:= &"moon_color"
const MOON_INTENSITY_PARAM:= &"moon_intensity"
const MOON_SIZE_PARAM:= &"moon_size"
const MOON_TEXTURE_PARAM:=&"moon_texture"
const MOON_MIE_COLOR_PARAM:= &"atm_moon_mie_color"
const MOON_MIE_INTENSITY_PARAM:= &"atm_moon_mie_intensity"
const MOON_MIE_ANISOTROPY_PARAM:= &"atm_moon_mie_anisotropy"
#endregion

const SUNS_SIZE:= 4
const MOONS_SIZE:= 4

var _material:= ShaderMaterial.new()
var material: ShaderMaterial:
	get: return _material

var _refl_material:= ShaderMaterial.new()
var refl_material: ShaderMaterial:
	get: return _refl_material

var _suns_data:= USkyCelestialsData.new()
var suns_data: USkyCelestialsData:
	get: return _suns_data

var _moons_data:= USkyMoonData.new()
var moons_data: USkyMoonData:
	get: return _moons_data

func _init() -> void:
	_on_init()

func _on_init() -> void:
	_material.render_priority = -128
	_setup_data_array_size()

func material_is_valid() -> bool:
	return false

#region Setup
func reset_sun_default_data() -> void:
	_suns_data.clear_data()
	_setup_suns_params_array_size(SUNS_SIZE)

func reset_moon_default_data() -> void:
	_moons_data.clear_data()
	_setup_moons_params_array_size(MOONS_SIZE)

func _setup_data_array_size() -> void:
	_setup_suns_params_array_size(SUNS_SIZE)
	_setup_moons_params_array_size(MOONS_SIZE)

func _setup_suns_params_array_size(p_size: int) -> void:
	for i in range(p_size):
		_suns_data.direction.push_back(Vector3())
		_suns_data.size.push_back(0)
		_suns_data.color.push_back(Color())
		_suns_data.intensity.push_back(0)
		_suns_data.mie_color.push_back(Color())
		_suns_data.mie_intensity.push_back(0)
		_suns_data.mie_anisotropy.push_back(0)

func _setup_moons_params_array_size(p_size: int) -> void:
	for i in range(p_size):
		_moons_data.direction.push_back(Vector3())
		_moons_data.size.push_back(0)
		_moons_data.color.push_back(Color())
		_moons_data.intensity.push_back(0)
		_moons_data.texture.push_back(Texture2D.new())
		_moons_data.mie_color.push_back(Color())
		_moons_data.mie_intensity.push_back(0)
		_moons_data.mie_anisotropy.push_back(0)
		_moons_data.matrix.push_back(Basis())
		_moons_data.moon_phases_mul.push_back(1)
#endregion

#region Update Suns
func update_suns_direction() -> void:
	RenderingServer.material_set_param(
		material.get_rid(), SUN_DIRECTION_PARAM, _suns_data.direction
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), SUN_DIRECTION_PARAM, _suns_data.direction
	)
	emit_changed()

func update_suns_color() -> void:
	RenderingServer.material_set_param(
		material.get_rid(), SUN_COLOR_PARAM, _suns_data.color
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), SUN_COLOR_PARAM, _suns_data.color
	)
	emit_changed()

func update_suns_intensity() -> void:
	RenderingServer.material_set_param(
		material.get_rid(), SUN_INTENSITY_PARAM, _suns_data.intensity
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), SUN_INTENSITY_PARAM, _suns_data.intensity
	)
	emit_changed()

func update_suns_size() -> void:
	RenderingServer.material_set_param(
		material.get_rid(), SUN_SIZE_PARAM, _suns_data.size
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), SUN_SIZE_PARAM, _suns_data.size
	)
	emit_changed()

func update_suns_mie_color() -> void:
	RenderingServer.material_set_param(
		material.get_rid(), SUN_MIE_COLOR_PARAM, _suns_data.mie_color
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), SUN_MIE_COLOR_PARAM, _suns_data.mie_color
	)
	emit_changed()

func update_suns_mie_intensity() -> void:
	RenderingServer.material_set_param(
		material.get_rid(), SUN_MIE_INTENSITY_PARAM, _suns_data.mie_intensity
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), SUN_MIE_INTENSITY_PARAM, _suns_data.mie_intensity
	)
	emit_changed()

func update_suns_mie_anisotropy() -> void:
	RenderingServer.material_set_param(
		material.get_rid(), SUN_MIE_ANISOTROPY_PARAM, _suns_data.mie_anisotropy
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), SUN_MIE_ANISOTROPY_PARAM, _suns_data.mie_anisotropy
	)
	emit_changed()
#endregion

#region Update Moons
func update_moons_direction() -> void:
	RenderingServer.material_set_param(
		material.get_rid(), MOON_DIRECTION_PARAM, _moons_data.direction
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), MOON_DIRECTION_PARAM, _moons_data.direction
	)
	emit_changed()

func update_moons_matrix() -> void:
	RenderingServer.material_set_param(
		material.get_rid(), MOON_MATRIX_PARAM, _moons_data.matrix
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), MOON_MATRIX_PARAM, _moons_data.matrix
	)
	emit_changed()

func update_moons_color() -> void:
	RenderingServer.material_set_param(
		material.get_rid(), MOON_COLOR_PARAM, _moons_data.color
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), MOON_COLOR_PARAM, _moons_data.color
	)
	emit_changed()

func update_moons_intensity() -> void:
	RenderingServer.material_set_param(
		material.get_rid(), MOON_INTENSITY_PARAM, _moons_data.intensity
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), MOON_INTENSITY_PARAM, _moons_data.intensity
	)
	emit_changed()

func update_moons_size() -> void:
	RenderingServer.material_set_param(
		material.get_rid(),MOON_SIZE_PARAM, _moons_data.size
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), MOON_SIZE_PARAM, _moons_data.size
	)
	emit_changed()

func update_moons_texture() -> void:
	RenderingServer.material_set_param(
		material.get_rid(),MOON_TEXTURE_PARAM, _moons_data.texture
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), MOON_TEXTURE_PARAM, _moons_data.texture
	)
	emit_changed()

func update_moons_mie_color() -> void:
	RenderingServer.material_set_param(
		material.get_rid(), MOON_MIE_COLOR_PARAM, _moons_data.mie_color
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), MOON_MIE_COLOR_PARAM, _moons_data.mie_color
	)
	emit_changed()

func update_moons_mie_intensity() -> void:
	RenderingServer.material_set_param(
		material.get_rid(), MOON_MIE_INTENSITY_PARAM, _moons_data.mie_intensity
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), MOON_MIE_INTENSITY_PARAM, _moons_data.mie_intensity
	)
	emit_changed()

func update_moons_mie_anisotropy() -> void:
	RenderingServer.material_set_param(
		material.get_rid(), MOON_MIE_ANISOTROPY_PARAM, _moons_data.mie_anisotropy
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), MOON_MIE_ANISOTROPY_PARAM, _moons_data.mie_anisotropy
	)
	emit_changed()
#endregion
