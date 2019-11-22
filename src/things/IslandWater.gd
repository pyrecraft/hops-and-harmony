extends Node2D

const water_line_color = Color(249.0/255.0, 249.0/255.0, 249.0/255.0, 200.0/255.0)
const water_color = Color(94.0/255.0, 223.0/255.0, 1.0, 125.0/255.0)

var start_pos = Vector2(-1500, 550)
var end_pos = Vector2(6000, 550)
var wave_start_x = 0
var wave_rate = 10
var current_scale = 1.0
var scale_rate = .1
var scale_polarity = 1 # +1 or -1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	current_scale += scale_rate * delta * scale_polarity
	if current_scale < .9: # Fatter
		scale_polarity = 1
	elif current_scale > 1.1: # Thinner
		scale_polarity = -1
	
	wave_start_x += delta * wave_rate
	if wave_start_x > 120.0:
		wave_start_x = 0
	update()

func _draw():
	var wave_polyline_radius = 5
	var wave_circle_radius = 30
	var current_pos = Vector2(start_pos.x + wave_start_x, start_pos.y)
	while (current_pos.x < end_pos.x):
		draw_left_wave(Vector2(current_pos.x , current_pos.y), \
			wave_polyline_radius, wave_circle_radius)
		current_pos.x += (4 * wave_circle_radius)
	current_pos = Vector2(start_pos.x + wave_start_x, start_pos.y)
	while (current_pos.x < end_pos.x):
		draw_right_wave(Vector2(current_pos.x, current_pos.y), \
			wave_polyline_radius, wave_circle_radius)
		current_pos.x += (4 * wave_circle_radius)
	
	draw_rect(Rect2(Vector2(start_pos.x, start_pos.y + 60), \
		Vector2(end_pos.x - start_pos.x, 2000)), water_color)

func draw_left_wave(starting_pos, polyline_radius, circle_radius):
	# Left Wave
	var current_scale_L = current_scale
	var arc_points = get_arc_points(starting_pos, circle_radius, -90, 90, current_scale_L, \
		Constants.CIRCLE_NB_POINTS)
	draw_circle_arc_custom(Vector2(starting_pos.x, starting_pos.y), \
		circle_radius - (polyline_radius / 2), -90, 90, water_color)
	draw_polyline(arc_points, water_line_color, polyline_radius)
	draw_rect(Rect2(arc_points[0], Vector2((arc_points[arc_points.size()-1].x - arc_points[0].x), \
		circle_radius * 2)), water_color)
	draw_circle(arc_points[0], polyline_radius / 2, water_line_color)
	draw_circle(arc_points[arc_points.size()-1], polyline_radius / 2, water_line_color)
	

func draw_right_wave(starting_pos, polyline_radius, circle_radius):
	# Right Wave
	var inverse_current_scale_L = 1.0 + (1.0 - current_scale)
	var arc_points = get_arc_points(Vector2(starting_pos.x + (2 * circle_radius), starting_pos.y), \
		circle_radius, 90, 270, \
		inverse_current_scale_L, Constants.CIRCLE_NB_POINTS)
	var arc_points_negative_fill = arc_points
	arc_points_negative_fill.append(Vector2(arc_points[arc_points.size()-1].x, \
		arc_points[arc_points.size()-1].y + (2 * circle_radius)))
	arc_points_negative_fill.append(Vector2(arc_points[0].x, arc_points[0].y + (2 * circle_radius)))
	draw_colored_polygon(arc_points_negative_fill, water_color)
	draw_polyline(arc_points, water_line_color, polyline_radius)

func draw_wave(starting_pos, polyline_radius, circle_radius):
	# Left Wave
	var current_scale_L = current_scale
	var arc_points = get_arc_points(starting_pos, circle_radius, -90, 90, current_scale_L, \
		Constants.CIRCLE_NB_POINTS)
	draw_circle_arc_custom(Vector2(starting_pos.x, starting_pos.y), \
		circle_radius - (polyline_radius / 2), -90, 90, water_color)
	draw_polyline(arc_points, water_line_color, polyline_radius)
	draw_rect(Rect2(arc_points[0], Vector2((arc_points[arc_points.size()-1].x - arc_points[0].x), \
		circle_radius * 2)), water_color)
	
	# Right Wave
	var inverse_current_scale_L = 1.0 + (1.0 - current_scale)
	arc_points = get_arc_points(Vector2(starting_pos.x + (2 * circle_radius), starting_pos.y), \
		circle_radius, 90, 270, \
		inverse_current_scale_L, Constants.CIRCLE_NB_POINTS)
	var arc_points_negative_fill = arc_points
	arc_points_negative_fill.append(Vector2(arc_points[arc_points.size()-1].x, \
		arc_points[arc_points.size()-1].y + (2 * circle_radius)))
	arc_points_negative_fill.append(Vector2(arc_points[0].x, arc_points[0].y + (2 * circle_radius)))
	draw_colored_polygon(arc_points_negative_fill, water_color)
	draw_polyline(arc_points, water_line_color, polyline_radius)

func duplicate_vector_pool(vec_pool):
	var result_vec_pool = PoolVector2Array()
	for i in range(0, vec_pool.size()):
		result_vec_pool.push_back(vec_pool[i])
	
	return result_vec_pool

# Uses current_scale
func draw_circle_arc_custom(center, radius, angle_from, angle_to, color):
	var nb_points = Constants.CIRCLE_NB_POINTS
	var points_arc = PoolVector2Array()
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point) * 1 / current_scale, sin(angle_point) * current_scale) * radius)

	draw_polygon(points_arc, colors)

func get_arc_points(center, radius, angle_from, angle_to, trig_multiplier, nb_points):
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point) * 1 / trig_multiplier, sin(angle_point) * trig_multiplier) * radius)
	
	return points_arc