@tool
extends Node3D

@export_group("Nodes")
@export var cannon: Node3D
@export var target: Node3D

@export_group("Config")
@export var turn_speed := 5.0


func _process(delta: float) -> void:
	if not target:
		return
	
	var offset := target.global_position - cannon.global_position
	if offset.length_squared() == 0.0:
		return
	
	var original_basis := cannon.global_basis
	var current_basis := original_basis.orthonormalized()
	var current_rotation := current_basis.get_rotation_quaternion()
	
	var up_axis := Vector3.UP
	var z_axis := -offset.normalized()
	if abs(z_axis.dot(up_axis)) > 0.999:
		up_axis = Vector3.FORWARD
	var x_axis := up_axis.cross(z_axis).normalized()
	var y_axis := z_axis.cross(x_axis).normalized()
	
	var desired_rotation := Basis(x_axis, y_axis, z_axis).get_rotation_quaternion()
	var weight := 1.0 - exp(-turn_speed * delta)
	var new_rotation := current_rotation.slerp(desired_rotation, weight)
	
	cannon.global_basis = Basis(new_rotation).scaled(original_basis.get_scale())
