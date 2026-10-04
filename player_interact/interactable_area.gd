class_name InteractableArea
extends Area3D

@export var item: Item # Set by parent InteractableItem

func get_item() -> Item:
	return item
