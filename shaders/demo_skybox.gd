extends Node3D


@export_category("Config")
@export var world_environment: WorldEnvironment
@export_range(0.0, 1.0) var time_of_day: float = 0.2730000129675
@export_range(0.5, 3600.0, 0.5) var day_duration_seconds: float = 120.0
@export_range(0.5, 3600.0, 0.5) var night_duration_seconds: float = 60.0

@onready var stars: Node3D = $Stars
@onready var sun_light: DirectionalLight3D = %Sun
@onready var moon_light: DirectionalLight3D = %Moon
@onready var sky_material: ShaderMaterial = world_environment.environment.sky.sky_material as ShaderMaterial


func _ready() -> void:
	_sync_time_of_day()


func _process(delta: float) -> void:
	_advance_time(delta)
	_sync_time_of_day()


func _advance_time(delta: float) -> void:
	var phase := fposmod(time_of_day, 1.0)
	var seconds_left := delta
	while seconds_left > 0.0:
		var is_day := phase >= 0.25 and phase < 0.75
		var boundary := 0.75 if is_day else 0.25
		var duration := day_duration_seconds if is_day else night_duration_seconds
		var phase_rate := 0.5 / duration
		var phase_distance := fposmod(boundary - phase, 1.0)
		var seconds_to_boundary := phase_distance / phase_rate
		
		if seconds_left < seconds_to_boundary:
			phase = fposmod(phase + seconds_left * phase_rate, 1.0)
			seconds_left = 0.0
		else:
			phase = fposmod(phase + phase_distance, 1.0)
			seconds_left -= seconds_to_boundary
	
	time_of_day = phase


func _sync_time_of_day() -> void:
	var phase := fposmod(time_of_day, 1.0)
	sky_material.set_shader_parameter("time_of_day", phase)
	stars.quaternion = Quaternion(Vector3.RIGHT, TAU * phase)
