extends Node3D


@export var area: Area3D
@export var underwater_effect_scene: PackedScene


func _ready() -> void:
	# Connect signals.
	area.area_entered.connect(_on_area_entered)
	area.area_exited.connect(_on_area_exited)
	
	# Set collision mask to collide with camera areas.
	area.collision_layer = DemoCamera.WATER_TRIGGER_LAYER
	area.collision_mask = DemoCamera.WATER_TRIGGER_LAYER


func _on_area_entered(camera_area: Area3D) -> void:
	var camera := camera_area.get_parent() as Camera3D
	if not camera:
		return
	
	var effect := camera.get_node_or_null("UnderwaterEffect") as UnderwaterEffect
	if effect:
		_configure_underwater_effect(effect)
		return
	
	effect = underwater_effect_scene.instantiate() as UnderwaterEffect
	if not effect:
		return
	effect.name = "UnderwaterEffect"
	camera.add_child(effect)
	_configure_underwater_effect(effect)


func _on_area_exited(camera_area: Area3D) -> void:
	var effect := camera_area.get_parent().get_node_or_null("UnderwaterEffect") as UnderwaterEffect
	if effect:
		effect.queue_free()


func _configure_underwater_effect(effect: UnderwaterEffect) -> void:
	var water_surface := area.get_parent() as Node3D
	if water_surface:
		effect.set_water_plane(water_surface.global_position, water_surface.global_basis.y)
