extends KinematicBody2D

signal hit_rabbit

const waku_font = preload("res://fonts/WakuWakuFontMedium.tres")

export var coconut_color = Color('965a3e')
export var coconut_hole_color = Color('#2a363b')
export var text_color = Color('f2eee5')
export var gravity = 950

var radius = 25
var countdown = 2.0

var is_initialized = false
var is_ready_to_fall = false
var velocity = Vector2(0, 0)
var text_offset = Vector2(-12, 12)
var rand_hole_dividend = 4.0

func _ready():
	$CountdownTimer.connect("timeout", self, "on_CountdownTimer_timeout")
	$TTLTimer.connect("timeout", self, "on_TTLTimer_timeout")
#	initialize(Vector2(250, 150), 65)
	randomize()
	rand_hole_dividend = float(randi() % 3 + 6)

func initialize(pos, rad, cd):
	position = pos
	radius = rad
	countdown = cd
	$CollisionShape2D.shape.radius = rad
	is_initialized = true
	$CountdownTimer.wait_time = cd
	$CountdownTimer.start()

func _physics_process(delta):
	if is_initialized and is_ready_to_fall:
		velocity.x = 0
		velocity.y += gravity * delta
		velocity = move_and_slide(velocity, Vector2(0, -1))
	if is_colliding():
		queue_free()

func is_colliding():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
#		print('MinigameCoconut collided with ' + collision.collider.name)
		if collision.collider.name == 'MinigameRabbit':
			emit_signal("hit_rabbit")
		return true
	return false

func _draw():
	var pos = Vector2.ZERO
	draw_circle(pos, radius, coconut_color)
	var hole_offset = radius / 3.0

	var hole_size = radius / rand_hole_dividend
	draw_circle(Vector2(pos.x - hole_offset, pos.y), hole_size, coconut_hole_color)
	draw_circle(Vector2(pos.x, pos.y + hole_offset), hole_size, coconut_hole_color)
	draw_circle(Vector2(pos.x + hole_offset, pos.y), hole_size, coconut_hole_color)

func on_CountdownTimer_timeout():
	is_ready_to_fall = true

func on_TTLTimer_timeout():
	print('MinigameCoconut reached TTL of 10 seconds. Queueing free.')
	queue_free()