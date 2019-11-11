extends KinematicBody2D

const color_eyes = Color('#2a363b')
const color_primary = Color('#d4a5a5')
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
var circle_center = Vector2(0, -30)

enum State {
	IDLE,
	WALKING,
	JUMPING
}

var current_state = State.IDLE
var screen_size

func _ready():
	screen_size = get_viewport().size

func _process(delta):
	handle_states(delta)
	update()

func _physics_process(delta):
	set_velocities(delta)
	clamp_pos_to_screen()

func handle_states(delta):
	current_scale += scale_rate * delta * scale_polarity
	if current_scale < .95: # Fatter
		scale_polarity = 1
	elif current_scale > 1.05: # Thinner
		scale_polarity = -1
		scale_rate = .1
	match current_state:
		State.IDLE:
			if !is_on_floor():
				current_state = State.JUMPING
				current_scale = 1.25
				scale_polarity = -1
			elif is_walking():
				current_state = State.WALKING
		State.WALKING:
			if !is_on_floor():
				current_state = State.JUMPING
				current_scale = 1.25
				scale_polarity = -1
			elif !is_walking():
				current_state = State.IDLE
		State.JUMPING:
			if is_on_floor():
				if is_walking():
					current_state = State.WALKING
				else:
					current_state = State.IDLE
				spawn_landing_smoke()
				current_scale = .85
				scale_polarity = 1
				scale_rate = .3

func set_velocities(delta):
	velocity.x = 0
	velocity.y += gravity * delta
	if Input.is_action_pressed("ui_right"):
		velocity.x += walk_speed
	if Input.is_action_pressed("ui_left"):
		velocity.x -= walk_speed
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = jump_speed

	velocity = move_and_slide(velocity, Vector2(0, -1))

func is_walking():
	if Input.is_action_pressed("ui_right") and !Input.is_action_pressed("ui_left"):
		return true
	if !Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_left"):
		return true
	return false

func clamp_pos_to_screen():
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

func _draw():
	draw_body()
	draw_head()

func draw_body():
	draw_circle_arc(circle_center, 40, 0, 180, color_primary)
	draw_circle_arc(circle_center, 40, 180, 360, color_primary)

var head_offset_x = 0
func draw_head():
	var head_offset_y = 50.0 * current_scale
	print(head_offset_y)
	if Input.is_action_pressed("ui_right"):
		head_offset_x = 5
	if Input.is_action_pressed("ui_left"):
		head_offset_x = -5
	var head_position = Vector2(circle_center.x + head_offset_x, circle_center.y - head_offset_y)
	draw_circle(head_position, 25, color_primary)
	draw_eyes(head_position, head_offset_x)

func draw_eyes(head_vec, eye_offset_x):
	var eye_height := 5.0
	var eye_between_width := 9.0
	var eye_radius := 3.5
	var left_eye = Vector2(head_vec.x - eye_between_width + eye_offset_x, head_vec.y - eye_height)
	var right_eye = Vector2(head_vec.x + eye_between_width + eye_offset_x, head_vec.y - eye_height)
	draw_circle(left_eye, eye_radius, color_eyes)
	draw_circle(right_eye, eye_radius, color_eyes)
#	var eye_size = Vector2(7.5, 4.5)
#	var left_eye_rect = Rect2(left_eye, eye_size)
#	var right_eye_rect = Rect2(right_eye, eye_size)
#	draw_rect(left_eye_rect, color_eyes)
#	draw_rect(right_eye_rect, color_eyes)

func draw_circle_arc(center, radius, angle_from, angle_to, color):
    var nb_points = 8
    var points_arc = PoolVector2Array()
    var colors = PoolColorArray([color])

    for i in range(nb_points + 1):
        var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
        points_arc.push_back(center + Vector2(cos(angle_point) * 1 / current_scale, sin(angle_point) * current_scale) * radius)

    for index_point in range(nb_points):
        draw_polygon(points_arc, colors)

func _on_WalkSmokeTimer_timeout():
	if is_on_floor() and (Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left")):
		var next_smoke = walk_smoke.instance()
		get_parent().add_child(next_smoke)
		next_smoke.set_position(Vector2(position.x, position.y + 20))

func spawn_landing_smoke():
	$WalkSmokeTimer.start(.5)
	for i in range(-1, 2):
		var x_offset = 0
		if Input.is_action_pressed("ui_right"):
			x_offset += 15
		elif Input.is_action_pressed("ui_left"):
			x_offset -= 15
		var next_smoke = walk_smoke.instance()
		get_parent().add_child(next_smoke)
		next_smoke.set_position(Vector2(position.x + x_offset, position.y + 20))
		next_smoke.set_x_movement_rate(i * 5)
