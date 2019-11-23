extends Node2D

export var color_primary = Color.white

var start_pos = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _draw():
	draw_head()

func draw_head():
	var head_pos = Vector2(start_pos.x, start_pos.y - 50)
	var head_radius = 25
	draw_circle(head_pos, head_radius, color_primary)