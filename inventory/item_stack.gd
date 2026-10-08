class_name ItemStack
extends Resource

@export var item: ItemData
@export var count: int = 1


static func create(item_data: ItemData, amount: int) -> ItemStack:
	var stack := ItemStack.new()
	stack.item = item_data
	stack.count = amount
	return stack
