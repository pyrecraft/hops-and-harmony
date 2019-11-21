extends Node2D

export var valley_color = Color('#5f6769')
#var valley_color = get_color(100,196,237, 150)

var land_start_pos = Vector2(150, 450)
var land_end_pos = Vector2(3900, 450)
export var valley_trig = 1.4
export var valley_radius = 100
export var valley_nb_points = Constants.CIRCLE_NB_POINTS
export var y_offset = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	draw_valley()

func get_color(r, g, b, a):
	return Color(float(r)/255.0, float(g)/255.0, float(b)/255.0, float(a)/255.0)

func draw_valley():
	draw_circle_custom(Vector2(0, y_offset), valley_radius, valley_trig)

func draw_circle_custom(circle_center, radius, trig):
	draw_circle_arc_custom(circle_center, radius, 0, 180, trig, valley_color)
	draw_circle_arc_custom(circle_center, radius, 180, 360, trig, valley_color)

func draw_circle_arc_custom(center, radius, angle_from, angle_to, trig_multiplier, color):
	var nb_points = valley_nb_points
	var points_arc = PoolVector2Array()
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point) * 1 / trig_multiplier, \
			sin(angle_point) * trig_multiplier) * radius)
	
	draw_polygon(points_arc, colors)