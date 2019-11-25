extends Node2D

var color_primary = Color('a34a28')
var color_secondary = Globals.get_color(190, 117, 117, 255)

var base_circle_points = PoolVector2Array()
var base_radius = 20
var base_trig = 0.4
var base_nb_points = 6

# Called when the node enters the scene tree for the first time.
func _ready():
	base_circle_points = generate_random_base_circle()
	$HoverTalkTip.set_box_position(Vector2(-5, 50))
	$Area2D.connect("body_entered", self, "_on_Area2D_body_entered")
	$Area2D.connect("body_exited", self, "_on_Area2D_body_exited")
	$HoverTalkTip.hide()

func _input(event):
	if Input.is_key_pressed(KEY_S) and $HoverTalkTip.visible:
		print('Attempted to go into hole.')
		get_tree().change_scene("res://src/places/Home.tscn")

func _process(delta):
	pass

func _on_Area2D_body_entered(body):
	if body.name == 'Rabbit' and !$HoverTalkTip.visible:
		$HoverTalkTip.show()

func _on_Area2D_body_exited(body):
	if body.name == 'Rabbit' and $HoverTalkTip.visible:
		$HoverTalkTip.hide()

func draw_circle_custom(circle_center, radius, trig, color):
	draw_circle_arc_custom(circle_center, radius, 0, 180, trig, color)
	draw_circle_arc_custom(circle_center, radius, 180, 360, trig, color)

func _draw():
	for i in range(0, base_circle_points.size() - 1):
		draw_circle_custom(base_circle_points[i], base_radius, base_trig, color_secondary)
	draw_circle_custom(Vector2(0, 0), base_radius, base_trig, color_primary)
	draw_circle_custom(Vector2(0, 0), base_radius * .75, base_trig, Color('411d10'))

func generate_random_base_circle():
	return get_arc_points(Vector2(0, 0), base_radius, 0, 360, base_trig, base_nb_points)

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