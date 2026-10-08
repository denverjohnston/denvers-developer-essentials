class_name UnderwaterEffect
extends Node3D


@onready var fullscreen_quad: MeshInstance3D = $FullscreenQuad

var effect_material: ShaderMaterial


func _ready() -> void:
	effect_material = fullscreen_quad.material_override.duplicate() as ShaderMaterial
	fullscreen_quad.material_override = effect_material


func set_water_plane(point: Vector3, normal: Vector3) -> void:
	effect_material.set_shader_parameter("water_plane_point", point)
	effect_material.set_shader_parameter("water_plane_normal", normal.normalized())
