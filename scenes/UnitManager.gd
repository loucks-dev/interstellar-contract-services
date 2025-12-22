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
	
	var map = get_tree().get_first_node_in_group("map")
	
	if map:
		var tile = map.world_to_tile(unit.global_position)
		map.reachable_tiles = map.get_reachable_tiles(tile, unit.move_range)
		map.queue_redraw()
	else:
		print("ERROR: MAP NOT FOUND")
		
	emit_signal("active_unit_changed", active_unit)
	print("Active unit:", active_unit.name)
	
