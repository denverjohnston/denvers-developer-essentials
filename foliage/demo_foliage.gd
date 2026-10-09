@tool
extends MultiMeshInstance3D

@export_range(0, 10000, 1) var grass_count := 1000:
	set(value):
		grass_count = value
		_rebuild_if_ready()

@export var area_size := Vector2(9.6, 9.6):
	set(value):
		area_size = value
		_rebuild_if_ready()

@export var random_seed := 1:
	set(value):
		random_seed = value
		_rebuild_if_ready()

func _ready() -> void:
	_rebuild()

func _rebuild_if_ready() -> void:
	if is_inside_tree():
		_rebuild()

func _rebuild() -> void:
	if multimesh == null or multimesh.mesh == null:
		push_error("FoliageDemo requires a MultiMesh with a mesh assigned.")
		return

	var rng := RandomNumberGenerator.new()
	rng.seed = random_seed
	if multimesh.transform_format != MultiMesh.TRANSFORM_3D:
		multimesh.instance_count = 0
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = grass_count

	for i in range(grass_count):
		var size := rng.randf_range(0.7, 1.3)
		var position := Vector3(
			rng.randf_range(-area_size.x * 0.5, area_size.x * 0.5),
			size,
			rng.randf_range(-area_size.y * 0.5, area_size.y * 0.5)
		)
		var rotation := rng.randf_range(0.0, TAU)
		var basis := Basis(Vector3.UP, rotation).scaled(Vector3.ONE * size)
		multimesh.set_instance_transform(i, Transform3D(basis, position))
