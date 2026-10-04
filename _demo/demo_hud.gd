@tool
extends CanvasLayer

@onready var back_to_demos: Button = %BackToDemos
@onready var instructions: Label = %Instructions
@onready var description: Label = %Description

@export var instructions_text: String:
	set(value):
		instructions_text = value
		if instructions:
			instructions.text = value
@export var description_text: String:
	set(value):
		description_text = value
		if description:
			description.text = value


func _ready() -> void:
	back_to_demos.pressed.connect(func():get_tree().change_scene_to_file("uid://cv5yqpjbxk81f"))
	instructions.text = instructions_text
	description.text = description_text
