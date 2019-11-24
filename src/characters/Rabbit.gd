extends KinematicBody2D

const color_eyes = Color('#2a363b')
const color_pink = Color('#f78dae')
const color_primary = Color('#dcb6b6')
const walk_smoke = preload('res://src/effects/WalkSmoke.tscn')

# Movement
var gravity = 1000
var walk_speed = 350
var jump_speed = -500
var velocity = Vector2()

# Animation
var scale_rate = .1
var current_scale = .9
var scale_polarity = 1 # +1 or -1
var circle_center = Vector2(0, -10)
var current_rabbit_state = RabbitState.IDLE

# State Tree
var dialogue_queue_L = []
var npc_position_L = Vector2(0, 0)

var game_day_L = 1
var game_hour_L = 1
var game_state_L = Globals.GameState.PLAYING
var game_progress_L = Globals.GameProgress.BEDROOM

enum RabbitState {
	IDLE,
	WALKING,
	JUMPING
}

func _ready():
	store.subscribe(self, "_on_store_changed")

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['dialogue']['queue'] != null:
		dialogue_queue_L = store.get_state()['dialogue']['queue']
		handle_next_dialogue(dialogue_queue_L)
	if store.get_state()['dialogue']['npc_position'] != null:
		npc_position_L = store.get_state()['dialogue']['npc_position']
	if store.get_state()['game']['day'] != null:
		game_day_L = store.get_state()['game']['day']
	if store.get_state()['game']['hour'] != null:
		game_hour_L = store.get_state()['game']['hour']
	if store.get_state()['game']['state'] != null:
		game_state_L = store.get_state()['game']['state']
	if store.get_state()['game']['progress'] != null:
		game_progress_L = store.get_state()['game']['progress']

func handle_next_dialogue(queue):
	if queue.empty():
		return
	
	var next_dialogue_obj = queue.front()
	var speaker = next_dialogue_obj['speaker']
	
	if speaker != name:
		return
	
	var dialogue_text = next_dialogue_obj['text']
	
	print('Rabbit says: ' + dialogue_text)
	
	store.dispatch(actions.dialogue_pop_queue())

func _process(delta):
	handle_states(delta)
	update()

func _physics_process(delta):
	set_velocities(delta)
#	clamp_pos_to_screen()
	check_for_water_death()

func check_for_water_death():
	if position.x < 200 and position.y > 1000: # Left side death
		position = Vector2(150, 350)
	if position.x > 3000 and position.y > 1000:
		position = Vector2(3850, 350)

func handle_states(delta):
	current_scale += scale_rate * delta * scale_polarity
	if current_scale < .95: # Fatter
		scale_polarity = 1
	elif current_scale > 1.05: # Thinner
		scale_polarity = -1
		scale_rate = .1
	match current_rabbit_state:
		RabbitState.IDLE:
			if !is_on_floor():
				current_rabbit_state = RabbitState.JUMPING
				current_scale = 1.25
				scale_polarity = -1
			elif is_walking():
				current_rabbit_state = RabbitState.WALKING
		RabbitState.WALKING:
			if !is_on_floor():
				current_rabbit_state = RabbitState.JUMPING
				current_scale = 1.25
				scale_polarity = -1
			elif !is_walking():
				current_rabbit_state = RabbitState.IDLE
		RabbitState.JUMPING:
			if is_on_floor():
				if is_walking():
					current_rabbit_state = RabbitState.WALKING
				else:
					current_rabbit_state = RabbitState.IDLE
				spawn_landing_smoke()
				current_scale = .85
				scale_polarity = 1
				scale_rate = .3

func set_velocities(delta):
	velocity.x = 0
	velocity.y += gravity * delta
	if is_walking_right():
		velocity.x += walk_speed
	if is_walking_left():
		velocity.x -= walk_speed
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = jump_speed

	velocity = move_and_slide(velocity, Vector2(0, -1))

func is_walking_left():
	return Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A)

func is_walking_right():
	return Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D)

func is_walking():
	if is_walking_left() and !is_walking_right():
		return true
	if is_walking_right() and !is_walking_left():
		return true
	return false

func clamp_pos_to_screen():
	var screen_size = get_viewport().size
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

func _draw():
	draw_body()
	draw_head()

func draw_body():
	draw_circle_arc_custom(circle_center, 40, 0, 180, color_primary)
	draw_circle_arc_custom(circle_center, 40, 180, 360, color_primary)

var head_offset_x = 0
func draw_head():
	var head_offset_y = 50.0 * current_scale
	if is_walking_right():
		head_offset_x = 5
	if is_walking_left():
		head_offset_x = -5
	var head_position = Vector2(circle_center.x + head_offset_x, circle_center.y - head_offset_y)
	draw_circle_custom(head_position, 25, color_primary)
	draw_face(head_position, head_offset_x)
	draw_ears(head_position, head_offset_x)

func draw_ears(head_vec, head_offset_x):
	var ear_between_distance := 11.0
	var ear_distance_y := 35.0
	var ear_radius := 8.0
	var inner_ear_radius := 4.0
	var ear_offset_x = head_offset_x
	
	var left_ear_pos = Vector2(head_vec.x - ear_between_distance - head_offset_x, head_vec.y - ear_distance_y)
	var right_ear_pos = Vector2(head_vec.x + ear_between_distance - head_offset_x, head_vec.y - ear_distance_y)
	
	# Draw outer ear
	draw_circle_arc_custom_ears(left_ear_pos, ear_radius, 0, 180, color_primary)
	draw_circle_arc_custom_ears(left_ear_pos, ear_radius, 180, 360, color_primary)
	draw_circle_arc_custom_ears(right_ear_pos, ear_radius, 0, 180, color_primary)
	draw_circle_arc_custom_ears(right_ear_pos, ear_radius, 180, 360, color_primary)
	
	draw_ear_head_connection(left_ear_pos, right_ear_pos, ear_radius, ear_distance_y, ear_offset_x)
	
	# Draw inner ear
	draw_circle_arc_custom(left_ear_pos, inner_ear_radius, 0, 180, color_pink)
	draw_circle_arc_custom(left_ear_pos, inner_ear_radius, 180, 360, color_pink)
	draw_circle_arc_custom(right_ear_pos, inner_ear_radius, 0, 180, color_pink)
	draw_circle_arc_custom(right_ear_pos, inner_ear_radius, 180, 360, color_pink)
	

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
	draw_colored_polygon(right_ear_shape, color_primary)
	draw_colored_polygon(left_ear_shape, color_primary)

func draw_face(head_vec, head_offset_x):
	var eye_height := 5.0
	var eye_between_width := 9.0
	var eye_radius := 3.5
	var left_eye = Vector2(head_vec.x - eye_between_width + head_offset_x, head_vec.y - eye_height)
	var right_eye = Vector2(head_vec.x + eye_between_width + head_offset_x, head_vec.y - eye_height)
	draw_circle_custom(left_eye, eye_radius, color_eyes)
	draw_circle_custom(right_eye, eye_radius, color_eyes)
	
	var nose_radius := 4.0
	var nose_offset_y := 2.0
	draw_circle_custom(Vector2(head_vec.x + head_offset_x, head_vec.y + nose_offset_y), nose_radius, color_pink)

# Uses current_scale
func draw_circle_arc_custom(center, radius, angle_from, angle_to, color):
	var nb_points = Constants.CIRCLE_NB_POINTS
	var points_arc = PoolVector2Array()
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point) * 1 / current_scale, sin(angle_point) * current_scale) * radius)

	draw_polygon(points_arc, colors)

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

func draw_circle_arc(center, radius, angle_from, angle_to, color):
	var nb_points = Constants.CIRCLE_NB_POINTS
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)

func draw_circle_custom(pos, rad, col):
	draw_circle_arc(pos, rad, 0, 180, col)
	draw_circle_arc(pos, rad, 180, 360, col)

func _on_WalkSmokeTimer_timeout():
	if is_on_floor() and is_walking():
		var next_smoke = walk_smoke.instance()
		get_parent().add_child(next_smoke)
		next_smoke.set_position(Vector2(position.x, position.y + 20))

func spawn_landing_smoke():
	$WalkSmokeTimer.start(.5)
	for i in range(-1, 2):
		var x_offset = 0
		if is_walking_right():
			x_offset += 15
		elif is_walking_left():
			x_offset -= 15
		var next_smoke = walk_smoke.instance()
		get_parent().add_child(next_smoke)
		next_smoke.set_position(Vector2(position.x + x_offset, position.y + 20))
		next_smoke.set_x_movement_rate(i * 5)