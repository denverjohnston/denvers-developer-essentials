class_name UnderwaterEffect
extends Node3D


@onready var fullscreen_quad: MeshInstance3D = $FullscreenQuad

var effect_material: ShaderMaterial


func _ready() -> void:
	effect_material = fullscreen_quad.material_override.duplicate() as ShaderMaterial
	fullscreen_quad.material_override = effect_material
	effect_material.set_shader_parameter("light_level", _estimate_light_level())


# The fullscreen quad can't be lit by the engine, so approximate scene brightness instead.
func _estimate_light_level() -> float:
	var level := 0.0
	var env := get_world_3d().environment
	if env:
		var ambient := env.ambient_light_color if env.ambient_light_source == Environment.AMBIENT_SOURCE_COLOR else Color.WHITE
		level += ambient.get_luminance() * env.ambient_light_energy * 0.3
	for node in get_tree().root.find_children("*", "DirectionalLight3D", true, false):
		var light := node as DirectionalLight3D
		if light.is_visible_in_tree():
			level += light.light_color.get_luminance() * light.light_energy
	return clampf(level, 0.0, 1.0)


func set_water_plane(point: Vector3, normal: Vector3) -> void:
	effect_material.set_shader_parameter("water_plane_point", point)
	effect_material.set_shader_parameter("water_plane_normal", normal.normalized())
