extends Node3D


var mdt: MeshDataTool

@export var mesh_instance: MeshInstance3D


func _ready() -> void:
	if mesh_instance.mesh: # Cache the vertex colors.
		mdt = MeshDataTool.new()
		mdt.create_from_surface(mesh_instance.mesh, 0)


func get_color_at_world_pos(world_pos: Vector3) -> Color:
	if not mdt:
		return Color.BLACK
	
	var closest_vertex_idx: int = -1
	var min_distance: float = INF
	for i in range(mdt.get_vertex_count()):
		var vertex_position: Vector3 = mdt.get_vertex(i)
		var vertex_distance: float = world_pos.distance_squared_to(vertex_position)
		if vertex_distance < min_distance:
			min_distance = vertex_distance
			closest_vertex_idx = i
	
	if closest_vertex_idx != -1:
		return mdt.get_vertex_color(closest_vertex_idx)
	
	return Color.BLACK
