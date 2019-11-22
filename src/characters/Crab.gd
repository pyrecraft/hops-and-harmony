extends Node2D

export var color_primary = Color('#f26860')
const color_secondary = Color('da1c11')
const eye_color = Color('2a363b')

var starting_pos = Vector2(0, -20)
var head_nb_points = 4

# Animation
var scale_rate = .04
var current_scale = .9
var scale_polarity = 1 # +1 or -1

func _ready():
	pass

func _process(delta):
	current_scale += scale_rate * delta * scale_polarity
	if current_scale < .9: # Fatter
		scale_polarity = 1
	elif current_scale > 1.1: # Thinner
		scale_polarity = -1
	update()

func _draw():
	draw_legs()
	draw_head()
	draw_eyes()

func draw_legs():
	var left_leg_center_offset = Vector2(0, 35)
	var each_leg_offset = Vector2(-10, -1)
	var leg_radius = 15
	var next_crab_leg_pos = Vector2(starting_pos.x + left_leg_center_offset.x, \
			starting_pos.y + left_leg_center_offset.y)
	var left_leg_points = get_arc_points(next_crab_leg_pos, leg_radius, 0, -180, \
			1.0 + (1.0 - current_scale), 2)
	draw_polyline(left_leg_points, color_primary, 8)
	next_crab_leg_pos.x += each_leg_offset.x * 1.2
	next_crab_leg_pos.y += each_leg_offset.y * 1.2
	draw_circle_arc_custom(left_leg_points[left_leg_points.size()-1], \
		8, -45, 125, 1.0, color_secondary)
	draw_circle_arc_custom(left_leg_points[left_leg_points.size()-1], \
		8, -45, -200, 1.0, color_secondary)
	var crab_arm_point = left_leg_points[left_leg_points.size()-1]
	draw_circle(Vector2(crab_arm_point.x - 3, crab_arm_point.y * .9), 4, color_secondary)
	for i in range(0, 3):
		left_leg_points = get_arc_points(next_crab_leg_pos, leg_radius, 0, -180, \
			1.1 + (1.0 - current_scale), 2)
		draw_polyline(left_leg_points, color_primary, 5)
		next_crab_leg_pos.x += each_leg_offset.x
		next_crab_leg_pos.y += each_leg_offset.y
	
	var right_leg_center_offset = Vector2(25, 30)
	next_crab_leg_pos = Vector2(starting_pos.x + right_leg_center_offset.x, \
			starting_pos.y + right_leg_center_offset.y)
	var right_leg_points = get_arc_points(next_crab_leg_pos, leg_radius, 0, 180, \
			1.0 + (1.0 - current_scale), 2)
	each_leg_offset = Vector2(-10, -3)
	draw_polyline(right_leg_points, color_primary, 8)
	next_crab_leg_pos.x += each_leg_offset.x * 1.2
	next_crab_leg_pos.y += each_leg_offset.y * 1.2
	draw_circle_arc_custom(right_leg_points[right_leg_points.size()-1], \
		10, 45, -125, 1.0, color_secondary)
	draw_circle_arc_custom(right_leg_points[right_leg_points.size()-1], \
		10, 45, 200, 1.0, color_secondary)
	crab_arm_point = right_leg_points[left_leg_points.size()-1]
	draw_circle(Vector2(crab_arm_point.x + 3, crab_arm_point.y * .9), 4, color_secondary)
	for i in range(0, 3):
		right_leg_points = get_arc_points(next_crab_leg_pos, leg_radius, 0, 180, \
			1.0 + (1.0 - current_scale), 2)
		draw_polyline(right_leg_points, color_secondary, 4)
		next_crab_leg_pos.x += each_leg_offset.x
		next_crab_leg_pos.y += each_leg_offset.y

func draw_eyes():
	var left_eye_offset = Vector2(-5, 1)
	var right_eye_offset = Vector2(20, 3)
	var eye_holder_radius = 5
	var eye_holder_nb_points = 8
	var left_eye_holder_points = get_arc_points(Vector2(starting_pos.x + left_eye_offset.x, \
		starting_pos.y + left_eye_offset.y), \
		eye_holder_radius, -45, 90, 1.0, eye_holder_nb_points)
	var right_eye_holder_points = get_arc_points(Vector2(starting_pos.x + right_eye_offset.x, \
		starting_pos.y + right_eye_offset.y), \
		eye_holder_radius, -45, 90, 1.0, eye_holder_nb_points)
	draw_polyline(left_eye_holder_points, color_secondary, 4)
	draw_polyline(right_eye_holder_points, color_secondary, 4)
	
	var eye_radius = 5
	draw_circle_custom(left_eye_holder_points[left_eye_holder_points.size() - 1], eye_radius, 1.0, eye_color)
	draw_circle_custom(right_eye_holder_points[right_eye_holder_points.size() - 1], eye_radius, 1.0, eye_color)

func draw_head():
	var head_radius = 35
	var head_trig = .8
	var next_head_pos = Vector2(starting_pos.x, starting_pos.y * current_scale)
	draw_circle_custom(next_head_pos, head_radius, head_trig, color_primary)

func get_arc_points(center, radius, angle_from, angle_to, trig_multiplier, nb_points):
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point) * 1 / trig_multiplier, \
			sin(angle_point) * trig_multiplier) * radius)
	
	return points_arc

func draw_circle_custom(circle_center, radius, trig, color):
	draw_circle_arc_custom(circle_center, radius, 0, 180, trig, color)
	draw_circle_arc_custom(circle_center, radius, 180, 360, trig, color)

func draw_circle_arc_custom(center, radius, angle_from, angle_to, trig_multiplier, color):
	var nb_points = head_nb_points
	var points_arc = PoolVector2Array()
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point) * 1 / trig_multiplier, \
			sin(angle_point) * trig_multiplier) * radius)

	draw_polygon(points_arc, colors)

