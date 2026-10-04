extends RigidBody3D

@export_group("Nodes")
@export var area: InteractableArea

@export_group("Resources")
@export var item: Item

func _ready() -> void:
	item.item_scene = load(scene_file_path) as PackedScene
	area.item = item
