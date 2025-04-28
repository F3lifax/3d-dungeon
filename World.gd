extends Node3D

const Cell_Scene = preload("res://Cell.tscn")
const Trap_Cell = preload("res://TrapCell.tscn")

@export var Map : PackedScene
@export var player : Node3D

var cells = []
func _ready():
	var tree = get_tree()
	var root = tree.root
	var world = root.world_3d
	var environment = world.environment
	if (environment == null) : environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color.BLACK
	environment.ambient_light_color = Color("432d6d")
	world.environment = environment
	generate_map()

func generate_map():
	if not Map is PackedScene: return
	var map = Map.instantiate()
	add_child(map)
	var tileMap = map.get_tilemap()
	var used_tiles = tileMap.get_used_cells(0)
	#map.queue_free() # We don't need it now that we have the tile data
	for tile in used_tiles:
		var tileid = tileMap.get_cell_source_id(0, tile)
		if tileid == 0:
			var cell0 = Cell_Scene.instantiate()
			add_child(cell0)
			cell0.position = Vector3(tile.x*Globals.GRID_SIZE, 0, tile.y*Globals.GRID_SIZE)
			cells.append(cell0)
		if tileid == 1:
			var cell1 = Trap_Cell.instantiate()
			add_child(cell1)
			cell1.position = Vector3(tile.x*Globals.GRID_SIZE, 0, tile.y*Globals.GRID_SIZE)
			cells.append(cell1)
			
		map.queue_free()
	for cell in cells:
		cell.update_faces(used_tiles)

func _process(delta):
	check_player_tile()

func check_player_tile():
	if player == null:
		return

	var player_pos = Vector2(player.position.x / Globals.GRID_SIZE, player.position.z / Globals.GRID_SIZE)
	player_pos = Vector2i(player_pos.round())

	for cell in cells:
		if cell is TrapCell:
			var cell_pos = Vector2i(cell.position.x / Globals.GRID_SIZE, cell.position.z / Globals.GRID_SIZE)
			if player_pos == cell_pos:
				on_player_died()

func on_player_died():
	var death_screen = $DeathScreen  # assuming you made the CanvasLayer as before
	death_screen.visible = true
	var death_anim_player = death_screen.get_node("DeathAnimPlayer")
	death_anim_player.play("DeathFadeIn")
	get_tree().create_timer(3.0).timeout.connect(_on_death_timeout)
	

func _on_death_timeout():
	get_tree().reload_current_scene()
