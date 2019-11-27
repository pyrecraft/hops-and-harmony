extends Node2D

const cloud = preload("res://src/things/Cloud.tscn")
const rabbit = preload("res://src/characters/Rabbit.tscn")

const land_color = Color('#f9d5bb')
const hill_color = Color('#5f6769')

var land_start_pos = Vector2(150, 450)
var land_end_pos = Vector2(3900, 450)
var cloud_spawn_location = Vector2(-1000, 50)

export var spawn_main_island = true
var rabbit_main_island_pos = Vector2(875, 400)
var rabbit_mini_island_pos = Vector2(6600, 400)

# State Tree
var game_progress_L = Globals.GameProgress.GAME_START
var has_set_game_progress = false

# Called when the node enters the scene tree for the first time.
func _ready():
	store.subscribe(self, "_on_store_changed")
	set_rabbit()
	game_progress_L = Globals.get_state_value('game', 'progress')
	if game_progress_L == Globals.GameProgress.TALKED_TO_DAD or game_progress_L == Globals.GameProgress.GAME_START:
		store.dispatch(actions.game_set_progress(Globals.GameProgress.WENT_OUTSIDE))
		print('Went outside!')

func _process(delta):
	if !has_set_game_progress:
		if game_progress_L == Globals.GameProgress.TALKED_TO_DAD or \
			game_progress_L == Globals.GameProgress.GAME_START:
			store.dispatch(actions.game_set_progress(Globals.GameProgress.WENT_OUTSIDE))
		has_set_game_progress = true

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['game']['progress'] != null:
		game_progress_L = store.get_state()['game']['progress']

func set_rabbit():
	var player_rabbit = rabbit.instance()
	if spawn_main_island:
		player_rabbit.set_position(rabbit_main_island_pos)
	else:
		player_rabbit.set_position(rabbit_mini_island_pos)
	add_child(player_rabbit)

func _draw():
#	draw_background()
	draw_land()
	draw_hills()

func draw_hills():
	draw_circle(Vector2(1246, 454), 115, hill_color)
	draw_circle(Vector2(1802, 450), 95, hill_color)
	draw_circle(Vector2(2768, 461), 155, hill_color)

func draw_land():
	draw_circle(Vector2(land_start_pos.x, land_start_pos.y + 50), 50, land_color)
	draw_circle(Vector2(land_end_pos.x, land_end_pos.y + 50), 50, land_color)
	draw_circle(Vector2(land_start_pos.x, land_start_pos.y + 150), 150, land_color)
	draw_circle(Vector2(land_end_pos.x, land_end_pos.y + 150), 150, land_color)
	draw_rect(Rect2(land_start_pos, Vector2(land_end_pos.x - land_start_pos.x, 300)), land_color)

func _on_CloudTimer_timeout():
	var next_cloud_spawn_location = Vector2(cloud_spawn_location.x, cloud_spawn_location.y + randi() % 30)
	var cloud_inst = cloud.instance()
	cloud_inst.set_position(next_cloud_spawn_location)
	add_child(cloud_inst)
	$CloudTimer.wait_time = 35
