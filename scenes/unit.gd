extends Node2D


signal unit_selected(unit)
signal unit_died(unit)

enum faction { PLAYER, ENEMY }

@export var max_hp := 10
@export var move_range := 6
@export var max_action_points := 2
@export var unit_faction: faction = faction.PLAYER

var current_hp := max_hp
var action_points := max_action_points
var is_alive := true
var is_selected := false

func _ready():
	var unit_manager = get_tree().get_first_node_in_group("unit_manager")
	if unit_manager:
		unit_manager.register_unit(self)

func start_turn():
	action_points = max_action_points
	print(name, "start turn")

func end_turn():
	print(name, "end turn")

func set_selected(value: bool):
	is_selected = value
	queue_redraw()
	
func _draw():
	if is_selected:
		draw_circle(Vector2.ZERO, 20, Color(0.0, 0.609, 0.859, 0.302))
		
func _on_area_2d_input_event(viewport, event, shape_idx): # move to unitmanager later and flesh out
	if event is InputEventMouseButton and event.pressed:
		emit_signal("unit_selected", self)
		
func take_damage(amount: int):
	current_hp -= amount
	if current_hp <= 0:
		die()
		
func die():
	is_alive = false
	emit_signal ("unit_died", self)
	queue_free()
	
