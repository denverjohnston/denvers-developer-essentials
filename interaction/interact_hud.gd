extends CanvasLayer


var container_origin: Vector2

@export var interact_label: Label
@export var interact_container: Control


func _ready() -> void:
	container_origin = interact_container.position


func display(item: Item, _world_pos: Vector3) -> void:
	#var camera = get_viewport().get_camera_3d()
	#var screen_pos = camera.unproject_position(world_pos)
	
	if !visible:
		interact_label.text = item.item_name
		interact_label.modulate.a = 0.0
		interact_container.position = container_origin + Vector2(0, -25)
		show()

	var tween := create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(interact_label, "modulate:a", 1.0, 0.25)
	tween.tween_property(interact_container, "position", container_origin, 0.25)


func clear() -> void:
	if visible:
		var tween := create_tween().set_parallel(true)
		tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(interact_label, "modulate:a", 0.0, 0.25)
		tween.tween_property(interact_container, "position", container_origin + Vector2(0, -25), 0.25)
		tween.chain().tween_callback(hide)
