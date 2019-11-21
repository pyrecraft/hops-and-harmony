extends Node2D

export var color_primary = Color('#5f6769')

var starting_pos = Vector2(0, -50)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	draw_head()

func draw_head():
	var head_radius = 50
	var head_trig = .8
	draw_circle_custom(starting_pos, head_radius, head_trig)

func get_arc_points(center, radius, angle_from, angle_to, trig_multiplier, nb_points):
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point) * 1 / trig_multiplier, sin(angle_point) * trig_multiplier) * radius)
	
	return points_arc

func draw_circle_custom(circle_center, radius, trig):
	draw_circle_arc_custom(circle_center, radius, 0, 180, trig, color_primary)
	draw_circle_arc_custom(circle_center, radius, 180, 360, trig, color_primary)

func draw_circle_arc_custom(center, radius, angle_from, angle_to, trig_multiplier, color):
	var nb_points = Constants.CIRCLE_NB_POINTS
	var points_arc = PoolVector2Array()
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point) * 1 / trig_multiplier, \
			sin(angle_point) * trig_multiplier) * radius)

	draw_polygon(points_arc, colors)