extends Node2D

const trunk_color = Color(163.0/255.0, 86.0/255, 56.0/255, 230.0/255.0)
const leaf_color = Color(25.0/255.0, 150.0/255, 25.0/255, 200.0/255.0)

export var tree_height = 200
export var is_tree_swaying = true
var tree_width = 25
var starting_pos = Vector2(0, 0)
var sway_points = PoolVector2Array()
var sway_index = 0
var sway_direction = 1 # +1 or -1
var leaf_points = PoolVector2Array()
var tree_top_point = Vector2(0, 0)

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

func _draw():
	draw_trunk()
#	draw_pivot_point()
	draw_leaves(50, .8, 8, -90, 0, .8)
	draw_leaves(60, .9, 8, 0, 90, .9)
	draw_leaves(30, .9, 6, 0, 120, .8)
	draw_leaves(20, .88, 4, -120, 0, .8)

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
