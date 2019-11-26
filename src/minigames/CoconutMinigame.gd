extends Node2D

signal minigame_won
signal minigame_lost

const waku_font = preload("res://fonts/WakuWakuFont.tres")
const minigame_rabbit = preload("res://src/minigames/MinigameRabbit.tscn")
const coconut = preload("res://src/minigames/MinigameCoconut.tscn")

export var border_color = Color('965a3e')
export var background_color = Color('f2eee5')

var background_rect = Rect2(Vector2(0, 0), Vector2(0, 0))
var border_rect = Rect2(Vector2(0, 0), Vector2(0, 0))
var background_scale = .7
var state = State.START

var column_count = 8
var object_radius = 10
var num_rounds = 17
var drop_points = PoolVector2Array()
var current_round = 0
var object_countdown = 1.25

enum State {
	START,
	INTRO_TEXT,
	MAIN_GAME,
	SUCCESS,
	FAILURE
}

# Called when the node enters the scene tree for the first time.
func _ready():
	var viewport_rect = get_viewport_rect()
	var viewport_size = get_viewport().size
	var center_pos = viewport_size / 2.0
	var side_length = min(viewport_size.x, viewport_size.y) * background_scale
	var rect_start_pos = Vector2(center_pos.x - side_length/2.0, center_pos.y - side_length/2.0)
	background_rect = Rect2(rect_start_pos, Vector2(side_length, side_length))
	border_rect = background_rect.grow(10)
	object_radius = (float(side_length) / float(column_count)) / 2.0 # diameter -> radius
	drop_points = get_drop_points(background_rect.position, side_length, column_count)
	initialize_border_collisions(center_pos, side_length)
	set_state(State.INTRO_TEXT)
	hide_all_texts()
	connect_timers()
	initialize_rabbit(center_pos, object_radius)
	$RoundTimer.wait_time = object_countdown + .2
	$IntroText.rect_position += center_pos
	$SuccessText.rect_position += center_pos
	$FailureText.rect_position += center_pos

func get_drop_points(rect_start_pos, side_len, col_count):
	var points = PoolVector2Array()
	var column_width = float(side_len) / float(col_count)
	var y_offset = 15.0
	for i in range(0, col_count):
		points.push_back(Vector2(rect_start_pos.x + (column_width * i), rect_start_pos.y + y_offset))
	return points

func initialize_rabbit(center, radius):
	var rabbit_obj = minigame_rabbit.instance()
	rabbit_obj.initialize(center, radius)
	add_child(rabbit_obj)

func initialize_border_collisions(center, side_length):
	var half_side_length = side_length / 2.0
	var minimum_border_width = 5.0
	$StaticBody2D/BottomCollision.position = Vector2(center.x, center.y + half_side_length)
	$StaticBody2D/LeftCollision.position = Vector2(center.x - half_side_length, center.y)
	$StaticBody2D/RightCollision.position = Vector2(center.x + half_side_length, center.y)
	
	$StaticBody2D/BottomCollision.shape.extents.x = half_side_length
	$StaticBody2D/LeftCollision.shape.extents.x = half_side_length
	$StaticBody2D/RightCollision.shape.extents.x = half_side_length
	
	$StaticBody2D/BottomCollision.shape.extents.y = minimum_border_width
	$StaticBody2D/LeftCollision.shape.extents.y = minimum_border_width
	$StaticBody2D/RightCollision.shape.extents.y = minimum_border_width
	
	$StaticBody2D/LeftCollision.rotate(90 * PI/180.0)
	$StaticBody2D/RightCollision.rotate(90 * PI/180.0)

func hide_all_texts():
	$IntroText.hide()
	$SuccessText.hide()
	$FailureText.hide()

func connect_timers():
	$IntroText/InitialDisplayTimer.connect("timeout", self, "_on_IntroText_InitialDisplayTimer_timeout")
	$IntroText/DisappearTimer.connect("timeout", self, "_on_IntroText_DisappearTimer_timeout")
	$RoundTimer.connect("timeout", self, "_on_RoundTimer_timeout")
	$ExitDelayTimer.connect("timeout", self, "_on_ExitDelayTimer_timeout")

func set_state(s):
	state = s

func _process(delta):
	match state:
		State.START:
			pass
		State.INTRO_TEXT:
			pass
		State.MAIN_GAME:
			pass
		State.SUCCESS:
			pass
		State.FAILURE:
			pass
		_:
			pass

func _draw():
	draw_background()

func draw_background():
	draw_rounded_rect(border_rect, border_color, 10)
	draw_rounded_rect(background_rect, background_color, 10)

func draw_rounded_rect(rect, color, circle_radius):
	draw_circle(rect.position, circle_radius, color)
	draw_circle(Vector2(rect.position.x, rect.position.y + rect.size.y), circle_radius, color)
	draw_circle(Vector2(rect.position.x + rect.size.x, rect.position.y), circle_radius, color)
	draw_circle(Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y), circle_radius, color)
	draw_rect(Rect2(Vector2(rect.position.x - circle_radius, rect.position.y), \
		Vector2(rect.size.x + (circle_radius * 2), rect.size.y)), color)
	draw_rect(Rect2(Vector2(rect.position.x, rect.position.y - circle_radius), \
		Vector2(rect.size.x, rect.size.y + (circle_radius * 2))), color)

func get_next_round_array(next_round):
	var result_array = []
	if state == State.FAILURE:
		result_array = [0, 0, 0, 0, 0, 0, 0, 0]
	else:
		if next_round == 1:
			result_array = [0, 0, 1, 0, 0, 0, 0, 0]
		elif next_round < 2:
			result_array = get_array_with_randoms(1, column_count)
		elif next_round < 3:
			result_array = get_array_with_randoms(2, column_count)
		elif next_round < 4:
			result_array = get_array_with_randoms(3, column_count)
		elif next_round < 5:
			result_array = get_array_with_randoms(4, column_count)
		elif next_round < num_rounds:
			result_array = get_array_with_randoms(6, column_count)
		else:
			result_array = [0, 0, 0, 0, 0, 0, 0, 0]
	return result_array

# 0 -> empty space, 1 -> coconut
func get_array_with_randoms(num_randoms, arr_length):
	if num_randoms > arr_length:
		printerr('Cannot get more randoms than array length.')
		return []
	var result = []
	for i in range(0, arr_length):
		result.push_back(0)
	var total_randoms_inserted = 0
	var random_num
	if num_randoms == arr_length - 2:
		for i in range(1, arr_length):
			result[i] = 1
		randomize()
		random_num = randi() % (arr_length - 1) + 1 # 1 -> 7
		result[random_num] = 0
		if random_num == 7:
			result[6] == 0
		elif random_num != 1:
			result[random_num + 1] = 0
	else:
		while total_randoms_inserted < num_randoms:
			randomize()
			random_num = randi() % (arr_length - 1) + 1
			if result[random_num] == 0:
				result[random_num] = 1
				total_randoms_inserted += 1
	return result

func start_next_round(next_round_array):
	for i in range(0, drop_points.size()):
		if next_round_array[i] == 1: # Coconut
			var next_coconut = coconut.instance()
			next_coconut.connect("hit_rabbit", self, "_on_coconut_hit_rabbit")
			next_coconut.initialize(drop_points[i], object_radius * .85, object_countdown) # Important: The coconuts are scaled down
			add_child(next_coconut)

func _on_coconut_hit_rabbit():
	set_state(State.FAILURE)
	$FailureText.show()
	$RoundTimer.stop()
	$ExitDelayTimer.start()

func start_first_round():
	current_round = 1
	var next_round_array = get_next_round_array(current_round)
	if !next_round_array.empty():
		start_next_round(next_round_array)
		$RoundTimer.start()

func update_object_countdown():
	if object_countdown < 0.6:
		pass
	else:
		object_countdown -= .1
	$RoundTimer.wait_time = object_countdown + .2

func _on_RoundTimer_timeout():
	current_round += 1
#	print('Current round: ' + str(current_round))
	update_object_countdown()
	if current_round == num_rounds + 2 and !$FailureText.visible and state != State.FAILURE: # Finished rounds
		set_state(State.SUCCESS)
		$SuccessText.show()
		$RoundTimer.stop()
		$ExitDelayTimer.start()
	else:
		var next_round_array = get_next_round_array(current_round)
		if !next_round_array.empty():
			start_next_round(next_round_array)
			$RoundTimer.start()

func _on_ExitDelayTimer_timeout():
	match state:
		State.SUCCESS:
			emit_signal("minigame_won")
		State.FAILURE:
			emit_signal("minigame_lost")
		_:
			pass
	queue_free()

func _on_IntroText_InitialDisplayTimer_timeout():
	$IntroText.show()
	$IntroText/DisappearTimer.start()

func _on_IntroText_DisappearTimer_timeout():
	$IntroText.hide()
	if state == State.INTRO_TEXT:
		set_state(State.MAIN_GAME)
		start_first_round()
	else:
		print('Error state found where trying to start game but the game state was not INTRO_TEXT')