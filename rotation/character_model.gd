# Topics covered:
# atan2
# atan is used when you have coordinates/lengths, but want angle.
# Because it doesn't handle +/- signs, we use atan2.
# angle = atan2(length_x, length_y)
# exponential decay
# Lerping by weight of delta is not enough.
# Instead, using exponential decay is better.
extends Node3D

@export var character_body_3d: CharacterBody3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Only rotate if the body is moving.
	var vel = character_body_3d.velocity
	if vel.length_squared() > 0.001:
		# Set origin and target.
		var origin = global_position
		var target = origin + character_body_3d.velocity
		# Calculate length.
		var length_x = origin.x - target.x
		var length_y = origin.z - target.z
		# Calculate angle.
		var angle = atan2(length_x, length_y)
		# Lerp angle.
		var exp_decay = 1.0 - exp(-10.0 * delta)
		#exp_decay = 10.0 * delta
		var result_lerp = lerp_angle(global_rotation.y, angle, exp_decay)
		global_rotation.y = result_lerp
