extends Node
@onready var turn_manager = get_tree().get_first_node_in_group("turn_manager")

signal active_unit_changed(unit)

@export var player_faction := "player"
var units: Array = []
var active_unit = null

func register_unit(unit):
	print("Registering unit:", unit.name)
	units.append(unit)
	unit.unit_selected.connect(_on_unit_selected)
	
func _on_unit_selected(unit) -> void:
	
	if turn_manager == null:
		print("TurnManager not found")
		return
	if turn_manager.current_phase != turn_manager.phase.PLAYER:
		print("error: not player turn phase")
		return
	if unit.unit_faction != unit.faction.PLAYER:
		print ("error: unit not in player faction")
		return
	if active_unit == unit:
		print ("error: already selected")
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
	
func deselect_active_unit():
	if active_unit:
		active_unit.set_selected(false)
		active_unit = null
		emit_signal("active_unit_changed", null)
		print("Active unit cleared")
