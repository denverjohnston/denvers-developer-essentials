class_name PlayerController
extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export_group("Nodes")
@export var player_camera: PlayerCamera


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var forward = -player_camera.global_basis.z
	forward.y = 0
	var right = player_camera.global_basis.x
	right.y = 0
	var direction: Vector3 = ((input_dir.x * right) + (input_dir.y * -forward)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
