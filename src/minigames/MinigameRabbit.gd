extends KinematicBody2D

# Movement
var gravity = 950
var walk_speed = 500
var velocity = Vector2()

var radius = 25
var is_initialized = false

func _ready():
	pass

# Rabbit offsets:
# 	pos.y = radius * (-7.5/25.0)
# 	scale = radius / 25.0
func initialize(pos, rad):
	position = pos
	radius = rad
	var rabbit_scale = Vector2(rad / 25.0, rad / 25.0)
	$"rabbit-head-sheet".scale = rabbit_scale
	$"rabbit-head-sheet".position.y = rad * (-7.5/25.0)
	walk_speed *= rabbit_scale.x
	$CollisionShape2D.shape.radius = rad * .8 # Give player benefit of doubt in terms of collisions
	is_initialized = true

func _physics_process(delta):
	if is_initialized:
		velocity.x = 0
		velocity.y += gravity * delta
		if is_walking_right():
			velocity.x += walk_speed
			if $"rabbit-head-sheet".frame != 2:
				$"rabbit-head-sheet".frame = 2
		if is_walking_left():
			velocity.x -= walk_speed
			if $"rabbit-head-sheet".frame != 1:
				$"rabbit-head-sheet".frame = 1
		if velocity.x == 0 and $"rabbit-head-sheet".frame != 0:
			$"rabbit-head-sheet".frame = 0
		velocity = move_and_slide(velocity, Vector2(0, -1))

#	if is_colliding():
#		pass

func is_colliding():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
#		print('MinigameRabbit collided with ' + collision.collider.name)
		return true
	return false

func is_walking_left():
	return Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A)

func is_walking_right():
	return Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D)