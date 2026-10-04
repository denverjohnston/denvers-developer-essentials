class_name Interactor
extends Node3D


const RAY_LENGTH: float = 1000.0

var hovered_interactable: Node3D

@export_group("Nodes")
@export var hud: CanvasLayer


func _process(_delta: float) -> void:
	# Shoot raycast.
	var camera: Camera3D = get_viewport().get_camera_3d()
	var screen_center: Vector2 = get_viewport().get_visible_rect().size * 0.5
	var ray_origin: Vector3 = global_position
	var ray_target: Vector3 = camera.project_ray_normal(screen_center) * RAY_LENGTH
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_target)
	query.collide_with_areas = true # In case interactables are Area3Ds.
	
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	var interactable: Node3D = hit.collider if not hit.is_empty() and hit.collider is InteractableArea else null
	if hit and hit.collider is InteractableArea:
		hud.display(interactable.get_item(), interactable.global_position)
	else:
		hud.clear()
