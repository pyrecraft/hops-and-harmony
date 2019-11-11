extends Node2D

# Declare member variables here. Examples:
var rise_rate = 150
var shrink_rate = 25
var x_movement_rate = 0
var current_radius = 25
var current_position = Vector2(0, 0)
var smoke_color = Color.whitesmoke

# Called when the node enters the scene tree for the first time.
func _ready():
	current_position = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	current_position.y -= rise_rate * delta
	current_position.x += x_movement_rate * delta * current_radius
	current_radius -= shrink_rate * delta
	update()
	if current_radius <= 0:
		queue_free()

func set_position(position):
	current_position = position

func set_x_movement_rate(rate):
	x_movement_rate = rate

func _draw():
	draw_circle(current_position, current_radius, smoke_color)