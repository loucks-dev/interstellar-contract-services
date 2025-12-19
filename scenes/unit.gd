extends Node2D


signal unit_selected(unit)
signal unit_died(unit)

@export var max_hp := 10
@export var move_range := 5
@export var max_action_points := 2

var current_hp := max_hp
var action_points := max_action_points
var is_alive := true
var is_selected := false

func start_turn():
	action_points = max_action_points
	print(name, "start turn")

func end_turn():
	print(name, "end turn")

func set_selected(value: bool):
	is_selected = value
	if is_selected:
		emit_signal("unit_selected")
	queue_redraw()
	
func _draw():
	if is_selected:
		draw_circle(Vector2.ZERO, 20, Color(0.0, 0.364, 0.522, 0.302))
		
func _on_area_2d_input_event(viewport, event, shape_idx): # move to unitmanager later and flesh out
	if event is InputEventMouseButton and event.pressed:
		set_selected(true)
		
func take_damage(amount: int):
	current_hp -= amount
	if current_hp <= 0:
		die()
		
func die():
	is_alive = false
	emit_signal ("unit died", self)
	queue_free()
	
