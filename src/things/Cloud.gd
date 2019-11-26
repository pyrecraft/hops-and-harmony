extends Node2D

var color_primary = Color(215.0/255.0, 209.0/255.0, 201.0/255.0, 220.0/255.0)

var base_circle_points = PoolVector2Array()
var base_radius = 20 + randi() % 25
var base_trig = 0.4 + (((randi() % 6) + 1) / 10.0)
var base_nb_points = 6 + randi() % 5
var cloud_movement_rate = 15.0 + randi() % 10

var base_circle_radiuses = []
var base_circle_trigs = []

# Called when the node enters the scene tree for the first time.
func _ready():
	base_circle_points = generate_random_base_circle()
#	color_primary.a = (150 + (randi() % 100)) / 255.0
	for i in range(0, base_circle_points.size() - 1):
		randomize()
		base_circle_radiuses.push_back(get_random_radius())
		base_circle_trigs.push_back(get_random_trig_value())

func _process(delta):
	position.x += cloud_movement_rate * delta
	if position.x > 10000:
		queue_free()

func set_position(pos):
	position = pos

func draw_circle_custom(circle_center, radius, trig):
	draw_circle_arc_custom(circle_center, radius, 0, 180, trig, color_primary)
	draw_circle_arc_custom(circle_center, radius, 180, 360, trig, color_primary)

func get_random_radius():
	return 30 + (randi() % 10)

func get_random_trig_value():
	return 0.5 + (((randi() % 5) + 1) / 10.0)

func _draw():
	draw_circle_custom(position, base_radius, base_trig)
	for i in range(0, base_circle_points.size() - 1):
		draw_circle_custom(base_circle_points[i], base_circle_radiuses[i], base_circle_trigs[i])

func generate_random_base_circle():
	return get_arc_points(position, base_radius, 0, 360, base_trig, base_nb_points)

func get_arc_points(center, radius, angle_from, angle_to, trig_multiplier, nb_points):
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point) * 1 / trig_multiplier, sin(angle_point) * trig_multiplier) * radius)
	
	return points_arc

func draw_circle_arc_custom(center, radius, angle_from, angle_to, trig_multiplier, color):
	var nb_points = Constants.CIRCLE_NB_POINTS
	var points_arc = PoolVector2Array()
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point) * 1 / trig_multiplier, \
			sin(angle_point) * trig_multiplier) * radius)

	draw_polygon(points_arc, colors)