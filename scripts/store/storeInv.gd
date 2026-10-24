extends Node
var storeInventory = {}

class storeEntry:
	var name: String
	var price: float
	var amount: int
	
	func _init(_name: String, _price: float, _amount: int):
		self.name = _name
		self.price = _price
		self.amount = _amount

func addStoreEntry(name: String, price: float, amount: int = 1):
	# adds an entry to the inventory dictionary.
	storeInventory[name] = storeEntry.new(name, price, amount)
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
