extends Node2D

var island_color = Color('#f9d5bb')
var current_pos = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	current_pos = position

func _draw():
	var offset = $StaticBody2D/CollisionShape2D.shape.height / 2.0
	var radius = $StaticBody2D/CollisionShape2D.shape.radius
	draw_line(Vector2(-offset, 0), Vector2(offset, 0), island_color, radius * 2.0)
	draw_circle(Vector2(-offset, 0), radius, island_color)
	draw_circle(Vector2(offset, 0), radius, island_color)