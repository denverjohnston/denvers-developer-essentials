extends Node3D


@export var area: Area3D


func _ready() -> void:
	# Connect signals.
	area.area_entered.connect(_on_area_entered)
	area.area_exited.connect(_on_area_exited)
	
	# Set collision mask to collide with camera areas.
	area.collision_layer = DemoCamera.WATER_TRIGGER_LAYER
	area.collision_mask = DemoCamera.WATER_TRIGGER_LAYER


func _on_area_entered(camera_area: Area3D) -> void:
	var effect := _get_effect(camera_area)
	var water_surface := area.get_parent() as Node3D
	if effect and water_surface:
		effect.enter_water(water_surface.global_position, water_surface.global_basis.y)


func _on_area_exited(camera_area: Area3D) -> void:
	var effect := _get_effect(camera_area)
	if effect:
		effect.exit_water()


func _get_effect(camera_area: Area3D) -> UnderwaterEffect:
	return camera_area.get_parent().get_node_or_null("UnderwaterEffect") as UnderwaterEffect
