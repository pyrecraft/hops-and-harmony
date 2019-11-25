extends Node2D

const rabbit = preload("res://src/characters/Rabbit.tscn")

var primary_color = Color('8f4426')
var game_start_rabbit_position = Vector2(0, 0)
var falling_down_rabbit_position = Vector2(-490, -485)

# Called when the node enters the scene tree for the first time.
func _ready():
	$BackgroundCanvas/Background.set_is_home(true)
	set_rabbit()

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