extends AudioStreamPlayer3D


@export var timer: Timer
@export var ray_cast_3d: RayCast3D

const STONE = preload("uid://dnk13byr4jyn1") # Red vertex
const GRASS = preload("uid://b8r7blalwpp7x") # Green vertex
const WATER = preload("uid://77ejutgwai2l")  # Blue vertex


func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)


func _on_timer_timeout() -> void:
	ray_cast_3d.force_raycast_update()
	if ray_cast_3d.is_colliding():
		var collider = ray_cast_3d.get_collider().owner
		var collision_point = ray_cast_3d.get_collision_point()
		var vertex_color: Color = collider.get_color_at_world_pos(collision_point)
		if vertex_color.r > 0.8:
			stream = STONE
			print("stone")
			play()
		elif vertex_color.g > 0.8:
			stream = GRASS
			play()
		elif vertex_color.b > 0.8:
			stream = WATER
			play()
		else:
			stop()
