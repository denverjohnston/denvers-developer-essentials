extends Control


@export_group("Nodes")
@export var inventory_slot_scene: PackedScene
@export var grid_container: GridContainer
@export var context_menu: PanelContainer

@export_group("Data")
@export var inventory_contents: Array[InventoryItem] = []

var inventory_slots: Array[InventorySlot] = []
var inventory_size: int = 24


func _ready() -> void:
	# Initialize properties.
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Connect signals.
	context_menu.item_dropped.connect(drop_item)
	
	# Add inventory slot nodes.
	for i in inventory_size:
		inventory_contents.append(null)
		var slot: InventorySlot = inventory_slot_scene.instantiate()
		slot.inventory_item = inventory_contents[i]
		slot.pressed.connect(_on_slot_pressed.bind(slot))
		grid_container.add_child(slot)
		inventory_slots.append(slot)
	
	# Refresh UI of inventory slot nodes.
	for i in inventory_slots.size():
		var slot = inventory_slots[i]
		if slot:
			inventory_slots[i].refresh_ui()


# On inventory slot pressed.
func _on_slot_pressed(slot: InventorySlot) -> void:
	# Open context menu.
	context_menu.inventory_slot = slot
	context_menu.inventory_item = slot.inventory_item
	context_menu.global_position = slot.global_position
	context_menu.position.x += slot.size.x
	context_menu.show()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# Close context menu if clicking outside region.
		context_menu.hide()


# Set inventory contents to null and refresh UI.
func drop_item(target_slot: InventorySlot) -> void:
	# Get index of inventory contents, which is the index of slots.
	var idx = 0
	for i in inventory_slots.size():
		var slot = inventory_slots[i]
		if slot == target_slot:
			idx = i
	
	# TODO Instantiate item scene into game world.
	#var item_data = target_slot.inventory_item.item
	#var item_scene_path = ItemData.item_scene_path[item_data]
	
	# Set inventory contents to null at correct index.
	inventory_contents[idx] = null
	target_slot.inventory_item = null
	
	# Update GUI.
	target_slot.refresh_ui()
