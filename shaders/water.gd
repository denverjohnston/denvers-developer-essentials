extends Node3D


@export var area: Area3D
@export var underwater_effect_scene: PackedScene


func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	var player_camera := body.get_node_or_null("PlayerCamera") as Node3D
	if not player_camera:
		return
	
	var effect := player_camera.get_node_or_null("UnderwaterEffect") as UnderwaterEffect
	if effect:
		effect.fade_in()
		return
	
	effect = underwater_effect_scene.instantiate() as UnderwaterEffect
	if not effect:
		return
	effect.name = "UnderwaterEffect"
	player_camera.add_child(effect)


func _on_body_exited(body: Node3D) -> void:
	var effect := body.get_node_or_null("PlayerCamera/UnderwaterEffect") as UnderwaterEffect
	if effect:
		effect.fade_out()
