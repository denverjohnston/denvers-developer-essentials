# The camera rig, which rotates with a child-camera.
# Adjust the z-position of child-camera for zooming in and out.
class_name DemoCamera
extends Node3D

enum Mode {
	FIRST,
	THIRD
}

# Physics layer 5, shared by the camera area and water triggers.
const WATER_TRIGGER_LAYER: int = 1 << 4

var yaw_input: float = 0.0
var pitch_input: float = 0.0

@export_group("Nodes")
@export var camera: Camera3D
@export var camera_area: Area3D

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
	
	# Add child camera if it doesn't exist.
	if not get_node_or_null("Camera3D"):
		camera = Camera3D.new()
		add_child(camera)
		push_warning("PlayerCamera did not have child Camera3D, adding new")
	if not camera:
		camera = get_node("Camera3D") as Camera3D
	
	# Add child Area3D to the camera if it doesn't exist.
	if not camera_area:
		camera_area = camera.get_node_or_null("CameraArea") as Area3D
	if not camera_area:
		camera_area = Area3D.new()
		camera_area.name = "CameraArea"
		var shape := CollisionShape3D.new()
		var sphere := SphereShape3D.new()
		sphere.radius = 0.1
		shape.shape = sphere
		camera_area.add_child(shape)
		camera.add_child(camera_area)
	
	# Match the water area trigger's collision layer/mask.
	camera_area.collision_layer = WATER_TRIGGER_LAYER
	camera_area.collision_mask = WATER_TRIGGER_LAYER


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
