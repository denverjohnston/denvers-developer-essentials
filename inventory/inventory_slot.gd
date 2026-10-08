class_name InventorySlot
extends TextureButton


@export_group("Resources")
@export var inventory_item: InventoryItem

@export_group("Nodes")
@export var item_icon: TextureRect
@export var item_count_label: Label


func refresh_ui() -> void:
	var icon: CompressedTexture2D
	var quantity: int = 0
	#
	#if inventory_item:
		#icon = load(ItemData.item_icon_path[inventory_item.item])
		#quantity = inventory_item.item_quantity
	#else:
		#icon = null
		#quantity = 0
	#
	#item_icon.texture = icon if inventory_item != null else null
	#item_count_label.text = str(quantity) if quantity >= 1 else ""
