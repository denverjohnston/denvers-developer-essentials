class_name UnderwaterEffect
extends Node3D


# Height above the surface where the effect still draws; must exceed the camera near plane.
const SURFACE_MARGIN: float = 0.15


@onready var fullscreen_quad: MeshInstance3D = $FullscreenQuad

var effect_material: ShaderMaterial
var water_count: int = 0
var water_point: Vector3
var water_normal: Vector3 = Vector3.UP


func _ready() -> void:
	effect_material = fullscreen_quad.material_override.duplicate() as ShaderMaterial
	fullscreen_quad.material_override = effect_material
	effect_material.set_shader_parameter("surface_margin", SURFACE_MARGIN)
	effect_material.set_shader_parameter("light_level", _estimate_light_level())


func _process(_delta: float) -> void:
	if not visible:
		return
	effect_material.set_shader_parameter("light_level", _estimate_light_level())
	# Hide by camera height, not area exit, so it doesn't depend on where the area's edge sits.
	if water_count == 0:
		if (global_position - water_point).dot(water_normal) >= SURFACE_MARGIN:
			visible = false


# Counted so overlapping water bodies don't hide the effect early.
func enter_water(point: Vector3, normal: Vector3) -> void:
	water_count += 1
	set_water_plane(point, normal)
	effect_material.set_shader_parameter("light_level", _estimate_light_level())
	visible = true


func exit_water() -> void:
	water_count = maxi(water_count - 1, 0)


# The fullscreen quad can't be lit by the engine, so approximate scene brightness instead.
func _estimate_light_level() -> float:
	var level := 0.0
	var env := get_world_3d().environment
	if env:
		# Sky ambient brightness is unknown to scripts, so use a small fixed share.
		if env.ambient_light_source == Environment.AMBIENT_SOURCE_COLOR:
			level += env.ambient_light_color.get_luminance() * env.ambient_light_energy
		else:
			level += 0.05 * env.ambient_light_energy
	for node in get_tree().root.find_children("*", "DirectionalLight3D", true, false):
		var light := node as DirectionalLight3D
		if light.is_visible_in_tree():
			# Lights pointing up (e.g. the sun at night) don't light anything from above.
			var facing_down := clampf(light.global_basis.z.y, 0.0, 1.0)
			level += light.light_color.get_luminance() * light.light_energy * facing_down
	return clampf(level, 0.0, 1.0)


func set_water_plane(point: Vector3, normal: Vector3) -> void:
	water_point = point
	water_normal = normal.normalized()
	effect_material.set_shader_parameter("water_plane_point", point)
	effect_material.set_shader_parameter("water_plane_normal", normal.normalized())
