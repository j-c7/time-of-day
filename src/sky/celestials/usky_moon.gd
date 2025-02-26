# Universal Sky
# Description:
# - Moon celestial body.
# License:
# - J. Cuéllar 2025 MIT License
# - See: LICENSE File.
@tool @icon("res://addons/universal-sky/assets/icons/moon.svg")
extends USkyCelestial
class_name USkyMoon

#region Resources
const _SUN_MOON_CURVE_FADE:=preload(
	"res://addons/universal-sky/data/SunMoonLightFade.tres"
)

const _DEFAULT_MOON_TEXTURE:= preload(
	"res://addons/universal-sky/assets/textures/moon/MoonMap.png"
)
#endregion

#region Mie
@export
var enable_mie_phases: bool = false:
	get: return enable_mie_phases
	set(value):
		enable_mie_phases = value


#endregion

#region Body
@export_group("Body")
@export
var use_custom_texture: bool = false:
	get: return use_custom_texture
	set(value):
		use_custom_texture = value
		if value:
			texture = texture
		else:
			texture = _DEFAULT_MOON_TEXTURE
		notify_property_list_changed()

@export
var texture: Texture = null:
	get: return texture
	set(value):
		texture = value
		emit_signal(VALUE_CHANGED, BodyValueType.TEXTURE)
#endregion

#region Light Source
@export_group("Light Source")
@export
var enable_moon_phases: bool = false:
	get: return enable_moon_phases
	set(value):
		enable_moon_phases = value
		_update_light_energy()

@export
var _suns: Array[USkySun]
#endregion

var phases_mul: float:
	get:
		if _suns.any(func(x): return is_instance_valid(x)):
			return _get_phases_mul()
		return 1.0

func _get_phases_mul() -> float:
	if _suns.size() < 1:
		return 1.0
	
	var acc:= Vector3.ZERO
	for i in len(_suns):
		acc += _suns[i].direction / _suns.size()
	
	return clamp(-acc.dot(direction) + 0.50, 0.0, 1.0)

var clamped_matrix: Basis:
	get: return Basis(
		-(basis * Vector3.FORWARD),
		-(basis * Vector3.UP),
		-(basis * Vector3.RIGHT)
	).transposed()

func _init() -> void:
	super()
	# Default moon values
	body_size =  0.02
	body_intensity = 1.0
	lighting_color = Color(0.54, 0.7, 0.9)
	lighting_energy = 0.3
	mie_color = Color(0.165, 0.533, 1)
	mie_intensity = 0.5
	
	# Initialize moon params.
	use_custom_texture = use_custom_texture
	texture = texture
	enable_moon_phases = enable_moon_phases

#func _notification(what: int) -> void:
	#if what == NOTIFICATION_PREDELETE:
		#_disconnect_suns_list_changed()

func _on_enter_tree() -> void:
	super()
	_add_to_parent()

func _on_exit_tree() -> void:
	_suns = []
	_remove_from_parent()

func _validate_property(property: Dictionary) -> void:
	if not use_custom_texture && property.name == "texture":
		property.usage &= ~PROPERTY_USAGE_EDITOR

func _get_light_energy() -> float:
	var energy = super()
	if enable_moon_phases:
		energy *= phases_mul
	
	if _suns.size() > 0 && is_instance_valid(_suns[0]):
		var fade: float = (1.0 - _suns[0].direction.y) - 0.5
		return energy * _SUN_MOON_CURVE_FADE.sample_baked(fade)
	
	return energy

func _on_parented() -> void:
	super()
	_add_to_parent()
	_get_suns()

func _add_to_parent() -> void:
	if is_instance_valid(parent):
		if parent.has_method(&"add_moon"):
			parent.add_moon(self)

func _get_suns() -> void:
	if is_instance_valid(parent):
		if  parent.has_method(&"get_all_suns"):
			_suns = parent.get_all_suns()

func _remove_from_parent() -> void:
	if is_instance_valid(parent):
		if parent.has_method(&"remove_moon"):
			parent.remove_moon(self)

func _connect_sun_signals() -> void:
	for s in len(_suns):
		if !_suns[s].direction_changed.is_connected(_on_sun_direction_changed):
			_suns[s].direction_changed.connect(_on_sun_direction_changed)

func _disconnect_sun_signals() -> void:
	for s in len(_suns):
		if _suns[s].direction_changed.is_connected(_on_sun_direction_changed):
			_suns[s].direction_changed.disconnect(_on_sun_direction_changed)

func _on_sun_direction_changed() -> void:
	_update_light_energy()

func _connect_suns_list_changed() -> void:
	if !parent.suns_list_changed.is_connected(_on_suns_list_changed):
		parent.suns_list_changed.connect(_on_suns_list_changed)

func _disconnect_suns_list_changed() -> void:
	if parent.suns_list_changed.is_connected(_on_suns_list_changed):
		parent.suns_list_changed.disconnect(_on_suns_list_changed)

func _on_suns_list_changed() -> void:
	_get_suns()
