extends Button

@export var demo_scene: PackedScene

func _ready() -> void:
	pressed.connect(func(): get_tree().change_scene_to_packed(demo_scene))
