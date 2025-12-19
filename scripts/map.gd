extends Node2D
@onready var tilemap: TileMapLayer = $TileMapLayer

var debug_start_tile: Vector2i = Vector2i(-1, -1)
var debug_end_tile: Vector2i = Vector2i(-1, -1)
var debug_path: Array[Vector2i] = []

func world_to_tile(world_pos: Vector2) -> Vector2i:
	return tilemap.local_to_map(tilemap.to_local(world_pos))

func tile_to_world(tile_pos: Vector2i) -> Vector2:
	return tilemap.to_global(tilemap.map_to_local(tile_pos))

# DEBUG - remove later
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var world_pos = get_global_mouse_position()
		var tile = world_to_tile(world_pos)

		# First click = start
		if debug_start_tile == Vector2i(-1, -1):
			debug_start_tile = tile
			print("Start tile set:", tile)
			debug_path.clear()

		# Second click = end + pathfind
		else:
			debug_end_tile = tile
			debug_path = find_path(debug_start_tile, debug_end_tile)
			print("End tile set:", tile)
			print("Path:", debug_path)

			# Reset for next test
			debug_start_tile = Vector2i(-1, -1)

		queue_redraw()

func is_tile_walkable(tile_pos: Vector2i) -> bool:
	var tile_data = tilemap.get_cell_tile_data(tile_pos)
	if tile_data == null:
		return false
	return tile_data.get_custom_data("walkable") == true

# AStarGrid2D 
var astar := AStarGrid2D.new()

func _ready():
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
