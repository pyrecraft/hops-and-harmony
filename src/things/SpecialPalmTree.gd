extends Node2D

const coconut_minigame = preload("res://src/minigames/CoconutMinigame.tscn")
const coconut = preload("res://src/things/Coconut.tscn")

const trunk_color = Color(163.0/255.0, 86.0/255, 56.0/255, 230.0/255.0)
const leaf_color = Color(25.0/255.0, 150.0/255, 25.0/255, 200.0/255.0)
var coconut_color = Globals.get_color(189, 87, 78, 230)
const coconut_hole_color = Color('#2a363b')

export var tree_height = 400
export var is_tree_swaying = true
var tree_width = 60
var starting_pos = Vector2(0, 0)
var sway_points = PoolVector2Array()
var sway_index = 0
var sway_direction = 1 # +1 or -1
var leaf_points = PoolVector2Array()
var tree_top_point = Vector2(0, 0)
var coconut_radius = 15

# Called when the node enters the scene tree for the first time.
func _ready():
#	starting_pos = Vector2(position.x, 450)
	var tree_center = Vector2(starting_pos.x, starting_pos.y + (tree_height / 2.0))
	var trig_multiplier = 1.5
	var nb_points = 32
	sway_points = get_arc_points(Vector2(0, tree_center.y), tree_height, -90, 90, trig_multiplier, nb_points)
	sway_index = sway_points.size() / 2
	
	var leaf_radius = 25
	var leaf_trig = .8
	var leaf_nb_points = 4
	leaf_points = get_arc_points(Vector2(tree_center.x, tree_center.y), leaf_radius, -90, 0, leaf_trig, leaf_nb_points)
	
	$HoverTalkTip.set_box_position(Vector2(-10, 100))
	$HoverTalkTip.set_text_offset_x(-3)
	$HoverTalkTip.hide()
	$Area2D.connect("body_entered", self, "_on_Area2D_body_entered")
	$Area2D.connect("body_exited", self, "_on_Area2D_body_exited")

func spawn_coconut():
	var next_coconut = coconut.instance()
	randomize()
	var x_spawn_location = randi() % 5 - 2
	next_coconut.initialize(Vector2(x_spawn_location, -10), coconut_radius)
	add_child(next_coconut)

func _on_Area2D_body_entered(body):
	if body.name == 'Rabbit' and !$HoverTalkTip.visible:
		$HoverTalkTip.show()

func _on_Area2D_body_exited(body):
	if body.name == 'Rabbit' and $HoverTalkTip.visible:
		$HoverTalkTip.hide()

func _input(event):
	if Input.is_key_pressed(KEY_W) and $HoverTalkTip.visible:
		print('Attempted to start coconut minigame.')
		store.dispatch(actions.game_set_state(Globals.GameState.MINIGAME))

func _draw():
	draw_trunk()
#	draw_pivot_point()
	var multiplier = 1.5
	draw_leaves(50 * multiplier, .8, 8, -90, 0, .8)
	draw_leaves(60 * multiplier, .9, 8, 0, 90, .9)
	draw_leaves(30 * multiplier, .9, 6, 0, 120, .8)
	draw_leaves(20 * multiplier, .88, 4, -120, 0, .8)
	draw_coconut(Vector2(starting_pos.x - 15, starting_pos.y - 5), coconut_radius)
	draw_coconut(Vector2(starting_pos.x + 15, starting_pos.y - 5), coconut_radius)
	draw_coconut(Vector2(starting_pos.x, starting_pos.y - 10), coconut_radius)

func draw_coconut(pos, rad):
	var hole_offset = rad / 3.0
	var hole_size = rad / 8.0
	draw_circle(pos, rad, coconut_color)
	draw_circle(Vector2(pos.x - hole_offset, pos.y), hole_size, coconut_hole_color)
	draw_circle(Vector2(pos.x, pos.y + hole_offset), rad / 6.0, coconut_hole_color)
	draw_circle(Vector2(pos.x + hole_offset, pos.y), hole_size, coconut_hole_color)

func draw_leaves(leaf_radius, leaf_trig, leaf_nb_points, start_angle, end_angle, offset_multiplier):
	leaf_points = get_arc_points(Vector2(tree_top_point.x, tree_top_point.y + (leaf_radius * offset_multiplier)), \
		leaf_radius, start_angle, end_angle, leaf_trig, leaf_nb_points)
	draw_polyline(leaf_points, leaf_color, 12)
	for i in range(0, leaf_points.size()):
		draw_circle(leaf_points[i], 6, leaf_color)

func draw_trunk():
	var pivot_points = 5
	var trunk_points = PoolVector2Array()
	for i in range(0, pivot_points):
		var base_trunk_point = Vector2(starting_pos.x, starting_pos.y + ((tree_height / pivot_points) * i))
		var current_sway_point = sway_points[sway_index]
		base_trunk_point = get_trunk_sway_vector(base_trunk_point, current_sway_point, i)
		draw_circle(base_trunk_point, 7.5, trunk_color)
		if i == 0:
			tree_top_point = base_trunk_point
		trunk_points.push_back(base_trunk_point)
	draw_polyline(trunk_points, trunk_color, 15)

func get_trunk_sway_vector(trunk_point, sway_point, index):
	index = (5 - index)
	var log_sway_vector = (Vector2((sway_point.x), (sway_point.y)) / 100) * index
	return Vector2(trunk_point.x + log_sway_vector.x, trunk_point.y + log_sway_vector.y)

func draw_pivot_point():
	draw_circle(sway_points[sway_index], 5, Color.red)

func get_arc_points(center, radius, angle_from, angle_to, trig_multiplier, nb_points):
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point) * 1 / trig_multiplier, sin(angle_point) * trig_multiplier) * radius)
	
	return points_arc

func _on_TrunkSwayTimer_timeout():
	if is_tree_swaying:
		if sway_index == 0:
			sway_direction = 1
		elif sway_index >= sway_points.size() - 1:
			sway_direction = -1
		sway_index += sway_direction
		update()
