# Universal Sky
# Description:
# - Moon data arrays.
# License:
# - J. Cuéllar 2025 MIT License
# - See: LICENSE File.
extends USkyCelestialsData
class_name USkyMoonData

var texture: Array[Texture2D]
var matrix: Array[Basis]
var moon_phases_mul: PackedFloat32Array

func clear_data() -> void:
	super()
	texture.clear()
	matrix.clear()
	moon_phases_mul.clear()
