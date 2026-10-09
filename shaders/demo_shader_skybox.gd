@tool
class_name DemoSkybox
extends WorldEnvironment


const SKY_SHADER: Shader = preload("res://shaders/sky.gdshader")


@export_category("Config")
@export var enabled: bool = false

@export_range(0.0, 1.0) var time_of_day: float = 0.2730000129675
@export_range(0.5, 3600.0, 0.5) var day_duration_seconds: float = 120.0
@export_range(0.5, 3600.0, 0.5) var night_duration_seconds: float = 60.0

var stars: Node3D
var sun_light: DirectionalLight3D
var moon_light: DirectionalLight3D
var sky_material: ShaderMaterial


func _ready() -> void:
	_setup_environment()
	_setup_celestials()
	_sync_time_of_day()


func _process(delta: float) -> void:
	if enabled:
		_advance_time(delta)
	_sync_time_of_day()


# Creates any missing Environment, Sky and sky shader material; existing ones are kept.
func _setup_environment() -> void:
	if not environment:
		environment = Environment.new()
		environment.background_mode = Environment.BG_SKY
	
	if not environment.sky:
		environment.sky = Sky.new()
	
	sky_material = environment.sky.sky_material as ShaderMaterial
	if not sky_material or sky_material.shader != SKY_SHADER:
		sky_material = ShaderMaterial.new()
		sky_material.shader = SKY_SHADER
		environment.sky.sky_material = sky_material


# Creates any missing Stars/Sun/Moon nodes; existing ones are left as authored.
func _setup_celestials() -> void:
	stars = get_node_or_null("Stars") as Node3D
	if not stars:
		stars = Node3D.new()
		stars.name = "Stars"
		add_child(stars)
	
	# At zero rotation the sun points up and the moon down; the stars' rotation swaps them.
	sun_light = stars.get_node_or_null("Sun") as DirectionalLight3D
	if not sun_light:
		sun_light = DirectionalLight3D.new()
		sun_light.name = "Sun"
		sun_light.rotation_degrees.x = 90.0
		sun_light.light_color = Color(1.0, 0.92156863, 0.8666667)
		sun_light.shadow_enabled = true
		stars.add_child(sun_light)
	
	moon_light = stars.get_node_or_null("Moon") as DirectionalLight3D
	if not moon_light:
		moon_light = DirectionalLight3D.new()
		moon_light.name = "Moon"
		moon_light.rotation_degrees.x = -90.0
		moon_light.light_color = Color(0.5882353, 0.7764706, 1.0)
		moon_light.light_energy = 0.02
		moon_light.shadow_enabled = true
		stars.add_child(moon_light)


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
	if sky_material:
		sky_material.set_shader_parameter("time_of_day", phase)
	if stars:
		stars.quaternion = Quaternion(Vector3.RIGHT, TAU * phase)
