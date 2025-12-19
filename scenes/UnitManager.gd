extends Node


signal active_unit_changed(unit)

var units: Array = []
var active_unit = null

func register_unit(unit):
	print("Registering unit:", unit.name)
	units.append(unit)
	unit.unit_selected.connect(_on_unit_selected)
	
func _on_unit_selected(unit):
	if active_unit == unit:
		return
	if active_unit:
		active_unit.set_selected(false)
		
	active_unit = unit
	active_unit.set_selected(true)
	
	emit_signal("active_unit_changed", active_unit)
	print("Active unit:", active_unit.name)
	
	
