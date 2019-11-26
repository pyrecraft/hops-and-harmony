extends KinematicBody2D

const starting_pos = Vector2(0, 0)
const sheep_skin_color = Color('#fff4e4')
const sheep_leg_color = Color('c9d1d3')
const sheep_leg_color_secondary = Color('b2bdc0')
const sheep_skin_color_secondary = Color('#c9d1d3')
const sheep_eye_color = Color('#2a363b')
const color_pink = Color('#f78dae')

# Movement
var gravity = 1000
var walk_speed = 70
var jump_speed = -1000
var velocity = Vector2()
var normal_vec = Vector2(0, 0)
var is_moving_left = false
var is_in_shell = false

# Animation
var scale_rate = .05
var current_scale = 1
var scale_polarity = 1 # +1 or -1
var center_pos = Vector2(0, -10)

var current_state = State.IDLE

enum State {
	IDLE,
	WALKING,
	JUMPING,
	SHELL
}

enum LegState {
	FRONT,
	BACK
}

# Leg Animation
var leg_scale_rate_list = [1, 1, 1, 1]
var leg_current_scale_list = [0, 0, 0, 0]
var leg_scale_polarity_list = [1, -1, -1, 1]

var base_sheep_body_points = get_arc_points(center_pos, 95 * (4.75/10.0), \
	0, 360, .7, 32)
var sheep_body_circle_radiuses = []
var sheep_body_circle_trigs = []

func _ready():
	for i in range(0, base_sheep_body_points.size() - 1):
		randomize()
		sheep_body_circle_radiuses.push_back(get_random_radius())
		sheep_body_circle_trigs.push_back(get_random_trig_value())

func _process(delta):
	handle_states(delta)
	for i in range(0, 4):
		handle_leg_states(delta, i)
	update()

func _physics_process(delta):
	set_velocities(delta)
	check_for_water_death()

func check_for_water_death():
	if position.x < 6600 and position.y > 750: # Left side death
		position = Vector2(6550, 350)
		is_moving_left = false
	elif position.x > 8000 and position.y > 750: # Right side death
		position = Vector2(7950, 350)
		is_moving_left = true

func is_colliding_with_rabbit():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if "Rabbit" in collision.collider.name:
			return true
	return false

func get_out_of_shell():
	is_in_shell = false
	center_pos.y -= 10
	$CollisionShape2D.scale = Vector2(1, 1)
	
func handle_states(delta):
	current_scale += scale_rate * delta * scale_polarity
	if current_scale < .98: # Fatter
		scale_polarity = 1
	elif current_scale > 1.05: # Thinner
		scale_polarity = -1

func handle_leg_states(delta, index):
	leg_current_scale_list[index] += leg_scale_rate_list[index] * delta * leg_scale_polarity_list[index]
	if leg_current_scale_list[index] < -1.25: # Forward
		leg_scale_polarity_list[index] = 1
		leg_scale_rate_list[index] = 2
	elif leg_current_scale_list[index] > 1.25: # Backwards
		leg_scale_polarity_list[index] = -1
		leg_scale_rate_list[index] = 2

func set_velocities(delta):
	velocity.x = 0
	velocity.y += gravity * delta
	if position.x < 6650 and is_moving_left:
		is_moving_left = false
	elif position.x > 7850 and !is_moving_left:
		is_moving_left = true
	
	if is_moving_left:
		velocity.x -= walk_speed
	else:
		velocity.x += walk_speed
		
	velocity = move_and_slide_with_snap(velocity, Vector2(0, -1))

func clamp_pos_to_screen():
	var screen_size = get_viewport().size
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

func _draw():
	var sheep_body_length := 95
	draw_sheep_head()
	draw_sheep_legs(sheep_body_length)
	draw_sheep_body(sheep_body_length)

func draw_sheep_head():
	var left_multiplier = -1 if is_moving_left else 1
	var neck_offset = Vector2(10, -20)
	var head_offset = Vector2(80 + neck_offset.x, neck_offset.y)
	var head_radius = 20
	var head_pos = Vector2(center_pos.x + (head_offset.x * left_multiplier), \
		center_pos.y + head_offset.y)

	var ear_offset_x = 0
	if !is_moving_left:
		ear_offset_x = 15
	else:
		ear_offset_x = -15
	draw_ears(head_pos, ear_offset_x)
	
	# Neck
	var neck_pos_1 = Vector2(center_pos.x + (25 * left_multiplier), center_pos.y + 20 + neck_offset.y)
	var neck_pos_2 = Vector2(center_pos.x + (65 * left_multiplier), center_pos.y + 15 + neck_offset.y)
	var neck_pos_3 = Vector2(center_pos.x + (80 * left_multiplier), center_pos.y + 0 + neck_offset.y)
	draw_circle(neck_pos_1, head_radius / 2, sheep_leg_color)
	draw_circle(neck_pos_2, head_radius / 2, sheep_leg_color)
#	draw_circle(neck_pos_3, head_radius / 2, turtle_skin_color)
	draw_line(neck_pos_1, neck_pos_2, sheep_leg_color, head_radius * 1.1)
	draw_line(neck_pos_2, neck_pos_3, sheep_leg_color, head_radius * 1.1)
	draw_line(neck_pos_3, head_pos, sheep_leg_color, head_radius * 1.1)
	
	draw_circle_arc_trig_breathing(head_pos, head_radius, 0, 360, sheep_leg_color, .85, 8)
	
	# Eyes
	var eyes_offset = Vector2(6, 4)
	var eyes_radius = 3.7
	var eye_position = Vector2(head_pos.x + (left_multiplier * eyes_offset.x), head_pos.y - eyes_offset.y)
	draw_circle_arc_trig(eye_position, eyes_radius, 0, 360, sheep_eye_color, 1, 8)

func draw_ears(head_vec, head_offset_x):
	var ear_between_distance := 6.0
	var ear_distance_y := 25.0
	var ear_radius := 8.0
	var inner_ear_radius := 4.0
	var ear_offset_x = head_offset_x
	
	var left_ear_pos = Vector2(head_vec.x - ear_between_distance - head_offset_x, head_vec.y - ear_distance_y)
	var right_ear_pos = Vector2(head_vec.x + ear_between_distance - head_offset_x, head_vec.y - ear_distance_y)
	
	# Draw outer ear
	draw_circle_arc_custom_ears(left_ear_pos, ear_radius, 0, 180, sheep_leg_color)
	draw_circle_arc_custom_ears(left_ear_pos, ear_radius, 180, 360, sheep_leg_color)
	draw_circle_arc_custom_ears(right_ear_pos, ear_radius, 0, 180, sheep_leg_color)
	draw_circle_arc_custom_ears(right_ear_pos, ear_radius, 180, 360, sheep_leg_color)
	
	draw_ear_head_connection(left_ear_pos, right_ear_pos, ear_radius, ear_distance_y, ear_offset_x)
	
	# Draw inner ear
	draw_circle_arc_custom(left_ear_pos, inner_ear_radius, 0, 180, color_pink)
	draw_circle_arc_custom(left_ear_pos, inner_ear_radius, 180, 360, color_pink)
	draw_circle_arc_custom(right_ear_pos, inner_ear_radius, 0, 180, color_pink)
	draw_circle_arc_custom(right_ear_pos, inner_ear_radius, 180, 360, color_pink)

# Uses current_scale
func draw_circle_arc_custom(center, radius, angle_from, angle_to, color):
	var nb_points = Constants.CIRCLE_NB_POINTS
	var points_arc = PoolVector2Array()
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point) * 1 / current_scale, sin(angle_point) * current_scale) * radius)

	draw_polygon(points_arc, colors)

func draw_circle_arc_custom_trig(center, radius, angle_from, angle_to, trig, color):
	var nb_points = Constants.CIRCLE_NB_POINTS
	var points_arc = PoolVector2Array()
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point) * 1 / trig, sin(angle_point) * trig) * radius)

	draw_polygon(points_arc, colors)

func draw_ear_head_connection(left_ear, right_ear, radius, height, offset_x):
	radius *= (1.0 - max(current_scale, 1)) + 1.0
		
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
	draw_colored_polygon(right_ear_shape, sheep_leg_color)
	draw_colored_polygon(left_ear_shape, sheep_leg_color)

# Maxes the ear_scale to .95
func draw_circle_arc_custom_ears(center, radius, angle_from, angle_to, color):
	var nb_points = Constants.CIRCLE_NB_POINTS
	var points_arc = PoolVector2Array()
	var colors = PoolColorArray([color])

	var ear_scale = max(current_scale, .95)

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point) * 1 / ear_scale, sin(angle_point) * ear_scale) * radius)

	draw_polygon(points_arc, colors)

func draw_sheep_legs(turtle_body_length):
	var left_multiplier = -1 if is_moving_left else 1
	var center_to_legs_width = turtle_body_length * .4
	var center_to_legs_height = 25
	var back_leg_pos = Vector2(center_pos.x - (center_to_legs_width * left_multiplier), center_pos.y + center_to_legs_height)
	var front_leg_pos = Vector2(center_pos.x + (center_to_legs_width * left_multiplier), center_pos.y + center_to_legs_height)
	handle_leg_animations(front_leg_pos, back_leg_pos)
	draw_circle(back_leg_pos, 5, sheep_leg_color)
	draw_circle(front_leg_pos, 5, sheep_leg_color)

func handle_leg_animations(front_leg_pos, back_leg_pos):
	var leg_distance = 30.0
	var leg_radius = 10
	
	draw_leg_animation(front_leg_pos, leg_distance, get_leg_angle(0), sheep_leg_color_secondary, leg_radius)
	draw_leg_animation(front_leg_pos, leg_distance, get_leg_angle(1), sheep_leg_color, leg_radius)

	draw_leg_animation(back_leg_pos, leg_distance, get_leg_angle(2), sheep_leg_color_secondary, leg_radius)
	draw_leg_animation(back_leg_pos, leg_distance, get_leg_angle(3), sheep_leg_color, leg_radius)

func get_leg_angle(leg_number):
	var leg_current_scale_L = leg_current_scale_list[leg_number]
	leg_current_scale_L = max(leg_current_scale_L, -1.0)
	leg_current_scale_L = min(leg_current_scale_L, 1.0)
	var angle_to_return = deg2rad(leg_current_scale_L * 45.0)
	if angle_to_return == 0:
		angle_to_return = 0.001
		
	return angle_to_return

func draw_leg_animation(leg_pos, leg_distance, angle, color, rad):
	var leg_distance_x = leg_distance * sin(angle)
	var leg_distance_y  = leg_distance * cos(angle)
	var leg_pos_extended = Vector2(leg_pos.x + leg_distance_x, \
		leg_pos.y + leg_distance_y)
	draw_line(leg_pos, leg_pos_extended, color, rad)
	draw_circle(leg_pos_extended, rad, color)

func draw_sheep_body(sheep_body_length):
	draw_circle_arc_trig_breathing(center_pos, sheep_body_length * (4.75/10.0), \
	0, 360, sheep_skin_color, .7, 12)
	for i in range(0, base_sheep_body_points.size() - 1):
		draw_circle_custom(base_sheep_body_points[i], sheep_body_circle_radiuses[i], sheep_body_circle_trigs[i])

func draw_circle_custom(circle_center, radius, trig):
	draw_circle_arc_custom_trig(circle_center, radius, 0, 180, trig, sheep_skin_color)
	draw_circle_arc_custom_trig(circle_center, radius, 180, 360, trig, sheep_skin_color)

func get_random_radius():
	return 5 + (randi() % 5)

func get_random_trig_value():
	return 0.9 + (((randi() % 2) + 1) / 10.0)

func draw_circle_trig(pos, rad, col, trig):
	draw_circle_arc_trig(pos, rad, 0, 180, col, trig, Constants.CIRCLE_NB_POINTS)
	draw_circle_arc_trig(pos, rad, 180, 360, col, trig, Constants.CIRCLE_NB_POINTS)

func draw_circle_arc_trig(center, radius, angle_from, angle_to, color, trig_multiplier, nb_points):
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point) * 1 / trig_multiplier, sin(angle_point) * trig_multiplier) * radius)

	draw_colored_polygon(points_arc, color)

func draw_circle_arc_trig_breathing(center, radius, angle_from, angle_to, color, trig_multiplier, nb_points):
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point) * 1 / (trig_multiplier * current_scale), \
			sin(angle_point) * (trig_multiplier * current_scale)) * radius)

	draw_colored_polygon(points_arc, color)

func get_arc_points(center, radius, angle_from, angle_to, trig_multiplier, nb_points):
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point) * 1 / trig_multiplier, sin(angle_point) * trig_multiplier) * radius)
	
	return points_arc