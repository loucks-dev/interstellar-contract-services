extends Node2D
@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var unit_manager = get_tree().get_first_node_in_group("unit_manager")

var debug_start_tile: Vector2i = Vector2i(-1, -1)
var debug_end_tile: Vector2i = Vector2i(-1, -1)
var debug_path: Array[Vector2i] = []

var hover_tile: Vector2i = Vector2i(-1, -1)
var preview_path: Array[Vector2i] = []

func world_to_tile(world_pos: Vector2) -> Vector2i:
	return tilemap.local_to_map(tilemap.to_local(world_pos))

func tile_to_world(tile: Vector2i) -> Vector2:
	return tilemap.map_to_local(tile)


# DEBUG
# change for this: if unit_selected = true
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var world_pos = get_global_mouse_position()
		var tile = world_to_tile(world_pos)

		# first click = start
		if debug_start_tile == Vector2i(-1, -1):
			debug_start_tile = tile
			print("Start tile set:", tile)
			debug_path.clear()

		# second click = end + pathfind
		else:
			debug_end_tile = tile
			debug_path = find_path(debug_start_tile, debug_end_tile)
			print("End tile set:", tile)
			print("Path:", debug_path)

			# reset for next test
			debug_start_tile = Vector2i(-1, -1)

		queue_redraw()

func is_tile_walkable(tile_pos: Vector2i) -> bool:
	var tile_data = tilemap.get_cell_tile_data(tile_pos)
	if tile_data == null:
		return false
	return tile_data.get_custom_data("walkable") == true

var astar := AStarGrid2D.new()

func _ready():
	print("TileMap pos:", tilemap.position)
	print("Map pos:", position)

	if unit_manager:
		unit_manager.active_unit_changed.connect(_on_active_unit_changed)
	astar.cell_size = tilemap.tile_set.tile_size # for visualization later
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER

	var used_rect = tilemap.get_used_rect()
	astar.region = used_rect
	astar.update()

	for x in range(used_rect.position.x, used_rect.position.x + used_rect.size.x):
		for y in range(used_rect.position.y, used_rect.position.y + used_rect.size.y):
			var pos = Vector2i(x, y)
			astar.set_point_solid(pos, not is_tile_walkable(pos))

func find_path(from_tile: Vector2i, to_tile: Vector2i) -> Array[Vector2i]:
	if astar.is_point_solid(to_tile):
		return []
	return astar.get_id_path(from_tile, to_tile)

func get_reachable_tiles(from_tile: Vector2i, max_cost: int) -> Array[Vector2i]:
	var reachable: Array[Vector2i] = []
	for x in range(astar.region.position.x, astar.region.position.x + astar.region.size.x):
		for y in range(astar.region.position.y, astar.region.position.y + astar.region.size.y):
			var tile := Vector2i(x, y)
			if astar.is_point_solid(tile):
				continue

			var path := astar.get_id_path(from_tile, tile)
			if path.size() == 0:
				continue

			var cost := path.size() - 1
			if cost <= max_cost:
				reachable.append(tile)
	
	return reachable
var reachable_tiles: Array[Vector2i] = []

func _draw():
	for tile in reachable_tiles:
		var center := tile_to_world(tile)
		draw_rect(
			Rect2(center - Vector2(8, 8), Vector2(16, 16)),
			Color(0.086, 0.322, 1.0, 0.396)
		)

	for tile in preview_path:
		var center := tile_to_world(tile)
		draw_circle(center, 6, Color(1, 1, 0, 0.8))

func _on_active_unit_changed(unit):
	if unit == null:
		# Clear all selection-related visuals
		reachable_tiles.clear()
		debug_path.clear() # or path_preview if renamed later
		queue_redraw()
	pass

func _process(_delta):
	var unit_manager = get_tree().get_first_node_in_group("unit_manager")
	if unit_manager == null or unit_manager.active_unit == null:
		return
	if unit_manager.active_unit.is_moving:
		return
	var mouse_world := get_global_mouse_position()
	var tile := world_to_tile(mouse_world)

	if tile == hover_tile:
		return

	hover_tile = tile

	# Only preview paths inside reachable area
	if tile in reachable_tiles:
		var unit_tile = world_to_tile(unit_manager.active_unit.global_position)
		preview_path = find_path(unit_tile, tile)
	else:
		preview_path.clear()

	queue_redraw()

func _unhandled_input(event):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		
		if preview_path.is_empty():
			return

		var unit = unit_manager.active_unit
		if unit == null:
			return

		if unit.action_points <= 0:
			print("Insufficient AP, cannot move!")
			return

		# await movement
		await unit.move_along_path(preview_path)

		# spend movement AFTER animation
		unit.spend_movement(1)
		
		# deselect unit (optional, unsure yet if want(i.e action after move))
		unit.set_selected(false)
		unit_manager.active_unit = null

		# Clear visuals
		preview_path.clear()
		reachable_tiles.clear()
		queue_redraw()
