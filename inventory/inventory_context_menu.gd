extends PanelContainer


signal item_dropped(inventory_slot: InventorySlot)

@export_group("Resources")
@export var inventory_slot: InventorySlot
@export var inventory_item: InventoryItem

@export_group("Nodes")
@export var button_container: VBoxContainer
@export var drop: Button


func _ready() -> void:
	hide()
	
	for button: Button in button_container.get_children():
		button.pressed.connect(hide)
	
	drop.pressed.connect(_on_drop_pressed)


func _on_drop_pressed() -> void:
	item_dropped.emit(inventory_slot)
