class_name UnderwaterEffect
extends CanvasLayer


@export var fade_duration: float = 0.3

@onready var overlay: ColorRect = $ColorRect

var fade_tween: Tween


func _ready() -> void:
	overlay.modulate.a = 0.0
	fade_in()


func fade_in() -> void:
	_fade_to(1.0)


func fade_out() -> void:
	_fade_to(0.0)
	fade_tween.finished.connect(queue_free, CONNECT_ONE_SHOT)


func _fade_to(target_opacity: float) -> void:
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()
	
	fade_tween = create_tween()
	fade_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	fade_tween.tween_property(overlay, "modulate:a", target_opacity, fade_duration)
