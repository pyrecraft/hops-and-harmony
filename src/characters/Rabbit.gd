extends KinematicBody2D

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
var position_adjustment_rate = .8
var circle_center = Vector2(0, -30)
var total_position_offset = 0
var screen_size

enum State {
	IDLE,
	WALKING,
	JUMPING
}

var current_state = State.IDLE

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handle_states(delta)
	if scale_polarity == -1:
		var amount_offset = position_adjustment_rate * (current_scale - .8)
		total_position_offset += amount_offset
		circle_center.y += amount_offset
	else:
		var amount_offset = position_adjustment_rate * (current_scale - .8)
		total_position_offset -= amount_offset
		circle_center.y -= amount_offset

func handle_states(delta):
	print(current_state)
	update()
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
				circle_center.y -= total_position_offset # Hack
				total_position_offset = 0
				current_scale = .8
				scale_polarity = 1
				scale_rate = .4

func set_velocities(delta):
	velocity.x = 0
	velocity.y += gravity * delta
	if Input.is_action_pressed("ui_right"):
		velocity.x += walk_speed
	if Input.is_action_pressed("ui_left"):
		velocity.x -= walk_speed
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
#		current_scale = 1.3
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

func _physics_process(delta):
	set_velocities(delta)
	clamp_pos_to_screen()

func _draw():
	draw_body()
	draw_head()

func draw_body():
	draw_circle_arc(circle_center, 40, 0, 180, color_primary)
	draw_circle_arc(circle_center, 40, 180, 360, color_primary)

func draw_head():
	var head_offset_y = 50
	draw_circle(Vector2(circle_center.x, circle_center.y - head_offset_y), 25, color_primary)

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
		var next_smoke = walk_smoke.instance()
		get_parent().add_child(next_smoke)
		next_smoke.set_position(Vector2(position.x, position.y + 20))
		next_smoke.set_x_movement_rate(i * 5)
