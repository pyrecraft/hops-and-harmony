extends Node2D

var rise_rate = 150
var shrink_rate = 25
var x_movement_rate = 0
var current_radius = 25
var current_position = Vector2(0, 0)
var smoke_color = Color.whitesmoke

func _ready():
	current_position = position

func _process(delta):
	current_position.y -= rise_rate * delta
	current_position.x += x_movement_rate * delta * current_radius
	current_radius -= shrink_rate * delta
	update()
	if current_radius <= 1:
		queue_free()

func set_position(position):
	current_position = position

func set_x_movement_rate(rate):
	x_movement_rate = rate

func _draw():
	draw_circle_custom(current_position, current_radius, smoke_color)

func draw_circle_arc(center, radius, angle_from, angle_to, color):
	var nb_points = Constants.CIRCLE_NB_POINTS
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)

func draw_circle_custom(pos, rad, col):
	draw_circle_arc(pos, rad, 0, 180, col)
	draw_circle_arc(pos, rad, 180, 360, col)