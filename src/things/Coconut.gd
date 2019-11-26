extends KinematicBody2D

const waku_font = preload("res://fonts/WakuWakuFontMedium.tres")

export var coconut_color = Color('965a3e')
export var coconut_hole_color = Color('#2a363b')
export var text_color = Color('f2eee5')
export var gravity = 950

var radius = 25

var is_initialized = false
var velocity = Vector2(0, 0)
var text_offset = Vector2(-12, 12)
var rand_hole_dividend = 4.0

var game_has_coconut_L = false

func _ready():
	initialize(Vector2(0, 0), 25)
	randomize()
	$TTLTimer.connect("timeout", self, "on_TTLTimer_timeout")
	$TTLTimer.start()
	rand_hole_dividend = float(randi() % 3 + 6)
	$Area2D.connect("body_entered", self, "_on_Area2D_body_entered")
	$Area2D.connect("body_exited", self, "_on_Area2D_body_exited")
	$HoverTalkTip.set_box_position(Vector2(-8, -70))
#	$HoverTalkTip.set_text_offset_x(-3)
	store.subscribe(self, "_on_store_changed")
	game_has_coconut_L = Globals.get_state_value('game', 'has_coconut')

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['game']['has_coconut'] != null:
		game_has_coconut_L = store.get_state()['game']['has_coconut']

func _on_Area2D_body_entered(body):
	if body.name == 'Rabbit' and !$HoverTalkTip.visible:
		$HoverTalkTip.show()

func _on_Area2D_body_exited(body):
	if body.name == 'Rabbit' and $HoverTalkTip.visible:
		$HoverTalkTip.hide()

func _input(event):
	if Input.is_key_pressed(KEY_S) and $HoverTalkTip.visible and !game_has_coconut_L:
		store.dispatch(actions.game_set_has_coconut(true))
		queue_free()

func grabbed_coconut():
	$TTLTimer.stop()

func initialize(pos, rad):
	position = pos
	radius = rad
	$CollisionShape2D.shape.radius = rad
	is_initialized = true

func _physics_process(delta):
	if is_initialized:
		velocity.x = 0
		velocity.y += gravity * delta
		velocity = move_and_slide(velocity, Vector2(0, -1))

func is_colliding():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.name == 'MinigameRabbit':
			pass
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

func on_TTLTimer_timeout():
	queue_free()