extends Node2D

export var color_primary = Color.white
export var color_eyes = Color('#2a363b')

var start_pos = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	$Body.supershape_color = color_primary

func _draw():
	draw_head()

func draw_head():
	var head_pos = Vector2(start_pos.x, start_pos.y - 32)
	var head_radius = 18
	draw_circle(head_pos, head_radius, color_primary)
	
	var eyes_offset = Vector2(-5, -4)
	var eye_radius = 3
	var eye_pos = Vector2(head_pos.x + eyes_offset.x, head_pos.y + eyes_offset.y)
	draw_circle_custom(eye_pos, eye_radius, 1.0, color_eyes)

func draw_circle_custom(circle_center, radius, trig, color):
	draw_circle_arc_custom(circle_center, radius, 0, 180, trig, color)
	draw_circle_arc_custom(circle_center, radius, 180, 360, trig, color)

func draw_circle_arc_custom(center, radius, angle_from, angle_to, trig_multiplier, color):
	var nb_points = Constants.CIRCLE_NB_POINTS
	var points_arc = PoolVector2Array()
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point) * 1 / trig_multiplier, \
			sin(angle_point) * trig_multiplier) * radius)

	draw_polygon(points_arc, colors)
