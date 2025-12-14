extends Node

@export var test_unit: UnitResource

func _ready():
	if test_unit:
		print("Name:", test_unit.display_name)
		print("HP:", test_unit.max_hp)
	else:
		print("No UnitResource assigned")
