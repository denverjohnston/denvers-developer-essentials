# The camera rig, which rotates with a child-camera.
# Adjust the z-position of child-camera for zooming in and out.
class_name PlayerCamera
extends Node3D

enum Mode {
	FIRST,
	THIRD
}

var yaw_input: float = 0.0
var pitch_input: float = 0.0

@export_group("Nodes")
@export var camera: Camera3D

@export_group("Settings")
@export_subgroup("Sensitivity")
@export var mouse_sensitivity: float = 0.1
@export var controller_sensitivity: float = 200.0
@export_subgroup("Zoom")
@export var current_mode: Mode
@export var first_person: Vector3 = Vector3.ZERO
@export var third_person: Vector3 = Vector3(0, 0, 10)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Capture mouse.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Handle controller and keyboard input.
	yaw_input -= Input.get_axis("ui_left", "ui_right") * controller_sensitivity * delta
	pitch_input -= Input.get_axis("ui_up", "ui_down") * controller_sensitivity * delta
	
	# Update basis of camera.
	var yaw_q = Quaternion(Vector3.UP, deg_to_rad(yaw_input))
	var pitch_q = Quaternion(Vector3.RIGHT, deg_to_rad(pitch_input))
	basis = Basis(yaw_q * pitch_q)


func _unhandled_input(event: InputEvent) -> void:
	# Handle mouse input.
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			yaw_input -= event.relative.x * mouse_sensitivity
			pitch_input -= event.relative.y * mouse_sensitivity
			pitch_input = clampf(pitch_input, -89, 89)
