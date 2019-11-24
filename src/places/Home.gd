extends Node2D

var primary_color = Color('8f4426')

# Called when the node enters the scene tree for the first time.
func _ready():
	$BackgroundCanvas/Background.set_is_home(true)
	
func _draw():
	draw_livable_area()

func draw_livable_area():
	var offset = $Floor/CollisionShape2D.shape.extents.x
	var radius = offset / 2.0
	draw_line(Vector2(-offset, 0), Vector2(offset, 0), primary_color, radius * 2.0)
	draw_circle(Vector2(-offset, 0), radius, primary_color)
	draw_circle(Vector2(offset, 0), radius, primary_color)
	draw_line(Vector2(-offset - radius/2.0, 0), Vector2(-offset - radius/2.0, -1500), primary_color, radius)