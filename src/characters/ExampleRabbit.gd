extends Node2D

const eye_color = Color('#2a363b')
const pink_color = Color('#f78dae')
const primary_color = Color(220.0/255.0, 182.0/255.0, 182.0/255.0, 225.0/255.0)

export var body_radius = 40
export var head_radius = 25
var curviness = 1.0
var curviness_rate = .1
var is_curving_up = true

func _process(delta):
	if is_curving_up:
		curviness += curviness_rate * delta
	else:
		curviness -= curviness_rate * delta
	if curviness < .9:
		is_curving_up = true
	elif curviness > 1.1:
		is_curving_up = false
	update()

func _draw():
	draw_body()
	draw_head()

var face_offset_x = 0
func draw_head():
	var screen_center = get_viewport().size / 2
	var head_offset_y = 50 * curviness
	var head_center = Vector2(screen_center.x + face_offset_x / 2, screen_center.y - head_offset_y)
	draw_circular_arc(head_center, head_radius, \
		0, 180, primary_color, 1.0, 8)
	draw_circular_arc(head_center, head_radius, \
		180, 360, primary_color, 1.0, 8)
	if is_walking_right():
		face_offset_x = 5
	if is_walking_left():
		face_offset_x = -5
	draw_face(head_center, face_offset_x)
	draw_ears(head_center, face_offset_x)

func is_walking_left():
	return Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A)

func is_walking_right():
	return Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D)

func draw_ears(head_vec, head_offset_x):
	var ear_between_distance := 11.0
	var ear_distance_y := 35.0
	var ear_radius := 8.0
	var inner_ear_radius := 4.0
	var ear_offset_x = head_offset_x
	
	var left_ear_pos = Vector2(head_vec.x - ear_between_distance - head_offset_x, head_vec.y - ear_distance_y)
	var right_ear_pos = Vector2(head_vec.x + ear_between_distance - head_offset_x, head_vec.y - ear_distance_y)
	
	# Draw outer ear
	draw_circle_arc_custom_ears(left_ear_pos, ear_radius, 0, 180, primary_color)
	draw_circle_arc_custom_ears(left_ear_pos, ear_radius, 180, 360, primary_color)
	draw_circle_arc_custom_ears(right_ear_pos, ear_radius, 0, 180, primary_color)
	draw_circle_arc_custom_ears(right_ear_pos, ear_radius, 180, 360, primary_color)
	
	draw_ear_head_connection(left_ear_pos, right_ear_pos, ear_radius, ear_distance_y, ear_offset_x)
	
	# Draw inner ear
	draw_circular_arc(left_ear_pos, inner_ear_radius, 0, 180, pink_color, curviness, 8)
	draw_circular_arc(left_ear_pos, inner_ear_radius, 180, 360, pink_color, curviness, 8)
	draw_circular_arc(right_ear_pos, inner_ear_radius, 0, 180, pink_color, curviness, 8)
	draw_circular_arc(right_ear_pos, inner_ear_radius, 180, 360, pink_color, curviness, 8)

# Maxes the ear_scale to .95
func draw_circle_arc_custom_ears(center, radius, angle_from, angle_to, color):
	var nb_points = Constants.CIRCLE_NB_POINTS
	var points_arc = PoolVector2Array()
	var colors = PoolColorArray([color])

	var ear_scale = max(curviness, .95)

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point) * 1 / ear_scale, sin(angle_point) * ear_scale) * radius)

	draw_polygon(points_arc, colors)

func draw_ear_head_connection(left_ear, right_ear, radius, height, offset_x):
	radius *= (1.0 - max(curviness, 1)) + 1.0
		
	var left_ear_points = [
		Vector2(left_ear.x + radius, left_ear.y),
		Vector2(left_ear.x - radius, left_ear.y),
		Vector2(left_ear.x - (radius/2.0) + offset_x, left_ear.y + (height * 2.0/3.0)),
		Vector2(left_ear.x + (radius/2.0) + offset_x, left_ear.y + (height * 2.0/3.0))
	]
	var right_ear_points = [
		Vector2(right_ear.x + radius, right_ear.y),
		Vector2(right_ear.x - radius, right_ear.y),
		Vector2(right_ear.x - (radius/2.0) + offset_x, right_ear.y + (height * 2.0/3.0)),
		Vector2(right_ear.x + (radius/2.0) + offset_x, right_ear.y + (height * 2.0/3.0))
	]
	var right_ear_shape = PoolVector2Array(right_ear_points)
	var left_ear_shape = PoolVector2Array(left_ear_points)
	draw_colored_polygon(right_ear_shape, primary_color)
	draw_colored_polygon(left_ear_shape, primary_color)

func draw_face(head_vec, head_offset_x):
	var eye_height := 5.0
	var eye_between_width := 9.0
	var eye_radius := 3.5
	var left_eye = Vector2(head_vec.x - eye_between_width + head_offset_x, head_vec.y - eye_height)
	var right_eye = Vector2(head_vec.x + eye_between_width + head_offset_x, head_vec.y - eye_height)
	draw_circle_custom(left_eye, eye_radius, eye_color)
	draw_circle_custom(right_eye, eye_radius, eye_color)
	
	var nose_radius := 4.0
	var nose_offset_y := 2.0
	draw_circle_custom(Vector2(head_vec.x + head_offset_x, head_vec.y + nose_offset_y), nose_radius, pink_color)

func draw_body():
	var screen_center = get_viewport().size / 2
	draw_circular_arc(screen_center, body_radius, \
		0, 180, primary_color, curviness, 8)
	draw_circular_arc(screen_center, body_radius, \
		180, 360, primary_color, curviness, 8)

func draw_circle_custom(pos, rad, col):
	draw_circular_arc(pos, rad, 0, 180, col, 1.0, 5)
	draw_circular_arc(pos, rad, 180, 360, col, 1.0, 5)

func draw_circular_arc(center, radius, angle_from, angle_to, color, curviness, nb_points):
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		var next_point = Vector2(cos(angle_point) * 1 / curviness, \
			sin(angle_point) * curviness) * radius
		points_arc.push_back(center + next_point)
#		draw_circle(center + next_point, 5, Color.white)

	draw_colored_polygon(points_arc, color)