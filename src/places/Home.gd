extends Node2D

const rabbit = preload("res://src/characters/Rabbit.tscn")

var primary_color = Color('8f4426')
var game_start_rabbit_position = Vector2(0, 0)
var falling_down_rabbit_position = Vector2(-490, -485)

var game_progress_L = Globals.GameProgress.GAME_START
var game_song_L = ''

# Called when the node enters the scene tree for the first time.
func _ready():
	store.subscribe(self, "_on_store_changed")
	game_song_L = Globals.get_state_value('game', 'song')
	game_progress_L = Globals.get_state_value('game', 'progress')
	$BackgroundCanvas/Background.set_is_home(true)
	set_rabbit()

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['game']['progress'] != null:
		game_progress_L = store.get_state()['game']['progress']
	if store.get_state()['game']['song'] != null:
		var prev_song = game_song_L
		game_song_L = store.get_state()['game']['song']
		update_song_playing(prev_song, game_song_L)

func update_song_playing(prev_song, curr_song):
	if curr_song == '' and prev_song != '':
		$AudioStreamPlayer.play()
	elif curr_song != '' and prev_song == '':
		$AudioStreamPlayer.stop()

func set_rabbit():
	var player_rabbit = rabbit.instance()
	if store.get_state() != null and !store.get_state().empty() and store.get_state()['game']['progress'] != null:
		var game_progress = store.get_state()['game']['progress']
		if game_progress != Globals.GameProgress.GAME_START:
			player_rabbit.set_position(falling_down_rabbit_position)
	else:
		player_rabbit.set_position(game_start_rabbit_position)
	add_child(player_rabbit)

func _draw():
	draw_livable_area()

func draw_livable_area():
	var offset = $Floor/CollisionShape2D.shape.extents.x
	var radius = offset / 2.0
	draw_line(Vector2(-offset, 0), Vector2(offset, 0), primary_color, radius * 2.0)
	draw_circle(Vector2(-offset, 0), radius, primary_color)
	draw_circle(Vector2(offset, 0), radius, primary_color)
	draw_line(Vector2(-offset - radius/2.0, 0), Vector2(-offset - radius/2.0, -1500), primary_color, radius)