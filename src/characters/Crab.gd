extends Node2D

const hover_tip = preload("res://src/things/HoverTip.tscn")

const color_back_legs = Color('ef4a40')
const color_secondary = Color('da1c11')
const eye_color = Color('2a363b')
export var color_primary = Color('#f26860')

var starting_pos = Vector2(0, -20)
var head_nb_points = 4

var current_hover_tip
var is_rabbit_in_speak_zone = false

# State Tree
var dialogue_queue_L = []
var crab_dict_L = {}
var rabbit_position_L = Vector2(0, 0)

# Animation
var scale_rate = .04
var current_scale = .9
var scale_polarity = 1 # +1 or -1

var game_day_L = 1
var game_hour_L = 1
var game_state_L = Globals.GameState.PLAYING
var game_progress_L = Globals.GameProgress.GAME_START
var has_coconut_L = false

func _ready():
	$Area2D.connect("body_entered", self, "_on_Area2D_body_entered")
	$Area2D.connect("body_exited", self, "_on_Area2D_body_exited")
	$ShowStartTextTimer.connect("timeout", self, "_on_ShowStartTextTimer_timeout")
	store.subscribe(self, "_on_store_changed")
	$DialogueBox.connect("text_complete", self, "on_DialogueBox_text_complete")
	$DialogueBox.clear_text()
	game_progress_L = Globals.get_state_value('game', 'progress')
	crab_dict_L = Globals.get_state_value('dialogue', 'crab_dict')

func _process(delta):
	current_scale += scale_rate * delta * scale_polarity
	if current_scale < .9: # Fatter
		scale_polarity = 1
	elif current_scale > 1.1: # Thinner
		scale_polarity = -1
	update()

func _draw():
	draw_legs()
	draw_head()
	draw_eyes()

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['dialogue']['queue'] != null:
		dialogue_queue_L = store.get_state()['dialogue']['queue']
		handle_next_dialogue(dialogue_queue_L)
		handle_hover_tip(dialogue_queue_L)
	if store.get_state()['dialogue']['rabbit_position'] != null:
		rabbit_position_L = store.get_state()['dialogue']['rabbit_position']
	if store.get_state()['game']['day'] != null:
		game_day_L = store.get_state()['game']['day']
	if store.get_state()['game']['hour'] != null:
		game_hour_L = store.get_state()['game']['hour']
	if store.get_state()['game']['state'] != null:
		game_state_L = store.get_state()['game']['state']
	if store.get_state()['game']['progress'] != null:
		game_progress_L = store.get_state()['game']['progress']
	if store.get_state()['dialogue']['crab_dict'] != null:
		crab_dict_L = store.get_state()['dialogue']['crab_dict']
	if store.get_state()['game']['has_coconut'] != null:
		has_coconut_L = store.get_state()['game']['has_coconut']

func _on_ShowStartTextTimer_timeout():
	current_hover_tip.show()

func handle_hover_tip(queue):
	if !queue.empty() and current_hover_tip != null:
		current_hover_tip.queue_free()
		current_hover_tip = null

func handle_next_dialogue(queue):
	if queue.empty():
		$DialogueBox.clear_text()
		return
	
	var next_dialogue_obj = queue.front()
	var speaker = next_dialogue_obj['speaker']
	
	if speaker != name:
		return
	
	var dialogue_text = next_dialogue_obj['text']
	
	if dialogue_text != $DialogueBox.get_text(): # NOTE: this means you cannot say the same text twice
		$DialogueBox.set_text(dialogue_text)

func on_DialogueBox_text_complete():
	store.dispatch(actions.dialogue_pop_queue())
	if dialogue_queue_L.empty():
		$DialogueBox.queue_clear_text()
		print('Crab finished talking.')

func _input(event):
	if Input.is_key_pressed(KEY_E) and can_start_dialogue():
		print('Attempted to speak with Rabbit!')
		store.dispatch(actions.dialogue_set_npc_position(position))
		store.dispatch(actions.dialogue_set_queue(get_next_dialogue()))

func get_next_dialogue():
	var original_game_progress = game_progress_L
	var next_dialogue = []
		
	match game_progress_L:
		Globals.GameProgress.WENT_OUTSIDE:
			match crab_dict_L[game_progress_L]:
				0:
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Hi!"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "Holy crab"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "Are you new to this island?"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Actually yeah!"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', ".."))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "This is my first day!"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "Lose the excitement sweetie"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "There's nothing interesting here"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Oh.."))
				1:
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Hi!"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', ".."))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "You say Hi"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "I say Why"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', ".."))
				_:
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Hi!"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', ".."))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "You say Hi"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "I say Why"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', ".."))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "'Why' are you so bitter?"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "The world is a bitter place"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "I'm being realistic"))
		Globals.GameProgress.TALK_TO_SHEEPA:
			match crab_dict_L[game_progress_L]:
				0:
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Hi!"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', ".."))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Do you know where the Sheepa is?"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "Yep"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Oh wow!"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Where?"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "At the bottom of the ocean"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Oh.."))
				_:
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Hi!"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', ".."))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "Why do you keep bothering me?"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "What better things do you have to do?"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "Enjoy a view, free from a pestering chunky rabbit"))
		Globals.GameProgress.TALKED_TO_SHEEPA:
			match crab_dict_L[game_progress_L]:
				0:
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Hi!"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "What's your name?"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', ".."))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "You don't have a name?"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "..."))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Come on, everyone has a name"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "...."))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "If I tell you will you leave me alone?"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Sure"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "Carl"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Nice to meet you Carl!"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "I'm Harley"))
				_:
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Hi Carl!"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "Hi"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Hope your having a nice day"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "Thanks, I guess"))
		Globals.GameProgress.COCONUT_STARTED:
			match crab_dict_L[game_progress_L]:
				_:
					if !has_coconut_L:
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Carl! "))
						next_dialogue.push_back(Globals.create_dialogue_object('Crab', "Did I tell you my name? "))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "I think so! "))
						next_dialogue.push_back(Globals.create_dialogue_object('Crab', ".."))
						next_dialogue.push_back(Globals.create_dialogue_object('Crab', "What? "))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Oh I didn't have anything to say"))
						next_dialogue.push_back(Globals.create_dialogue_object('Crab', ".. "))
					else:
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Carl! "))
						next_dialogue.push_back(Globals.create_dialogue_object('Crab', "Is that a coconut? "))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Yep! "))
						next_dialogue.push_back(Globals.create_dialogue_object('Crab', "Impressive "))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Thanks "))
						next_dialogue.push_back(Globals.create_dialogue_object('Crab', ".. "))
		Globals.GameProgress.COCONUT_COMPLETED:
			match crab_dict_L[game_progress_L]:
				_:
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Hi!"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "You look anxious"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "I'm waiting"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "You should enjoy this weather"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Oh"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Thanks"))
		Globals.GameProgress.LYRE_OBTAINED:
			match crab_dict_L[game_progress_L]:
				_:
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Carl!"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "Hi"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Want to hear a song?"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "Not really"))
					next_dialogue.push_back(Globals.create_dialogue_object('Crab', "Maybe when the mood is right"))
	store.dispatch(actions.dialogue_increment_crab_dict(original_game_progress))
	return next_dialogue

func create_dialogue_object(speaker, text):
	return {
		'speaker': speaker,
		'text': text
	}

func can_start_dialogue():
	return is_rabbit_in_speak_zone and dialogue_queue_L.empty() \
		and (current_hover_tip != null and current_hover_tip.visible)

func draw_legs():
	var left_leg_center_offset = Vector2(0, 35)
	var each_leg_offset = Vector2(-10, -1)
	var leg_radius = 15
	var next_crab_leg_pos = Vector2(starting_pos.x + left_leg_center_offset.x, \
			starting_pos.y + left_leg_center_offset.y)
	var left_leg_points = get_arc_points(next_crab_leg_pos, leg_radius, 0, -180, \
			1.0 + (1.0 - current_scale), 2)
	draw_polyline(left_leg_points, color_primary, 8)
	next_crab_leg_pos.x += each_leg_offset.x * 1.2
	next_crab_leg_pos.y += each_leg_offset.y * 1.2
	draw_circle_arc_custom(left_leg_points[left_leg_points.size()-1], \
		8, -45, 125, 1.0, color_secondary)
	draw_circle_arc_custom(left_leg_points[left_leg_points.size()-1], \
		8, -45, -200, 1.0, color_secondary)
	var crab_arm_point = left_leg_points[left_leg_points.size()-1]
	draw_circle(Vector2(crab_arm_point.x - 3, crab_arm_point.y * .9), 4, color_secondary)
	for i in range(0, 3):
		left_leg_points = get_arc_points(next_crab_leg_pos, leg_radius, 0, -180, \
			1.1 + (1.0 - current_scale), 2)
		draw_polyline(left_leg_points, color_primary, 5)
		next_crab_leg_pos.x += each_leg_offset.x
		next_crab_leg_pos.y += each_leg_offset.y
	
	var right_leg_center_offset = Vector2(25, 30)
	next_crab_leg_pos = Vector2(starting_pos.x + right_leg_center_offset.x, \
			starting_pos.y + right_leg_center_offset.y)
	var right_leg_points = get_arc_points(next_crab_leg_pos, leg_radius, 0, 180, \
			1.0 + (1.0 - current_scale), 2)
	each_leg_offset = Vector2(-10, -3)
	draw_polyline(right_leg_points, color_primary, 8)
	next_crab_leg_pos.x += each_leg_offset.x * 1.2
	next_crab_leg_pos.y += each_leg_offset.y * 1.2
	draw_circle_arc_custom(right_leg_points[right_leg_points.size()-1], \
		10, 45, -125, 1.0, color_secondary)
	draw_circle_arc_custom(right_leg_points[right_leg_points.size()-1], \
		10, 45, 200, 1.0, color_secondary)
	crab_arm_point = right_leg_points[left_leg_points.size()-1]
	draw_circle(Vector2(crab_arm_point.x + 3, crab_arm_point.y * .9), 4, color_secondary)
	for i in range(0, 3):
		right_leg_points = get_arc_points(next_crab_leg_pos, leg_radius, 0, 180, \
			1.0 + (1.0 - current_scale), 2)
		draw_polyline(right_leg_points, color_back_legs, 4)
		next_crab_leg_pos.x += each_leg_offset.x
		next_crab_leg_pos.y += each_leg_offset.y

func draw_eyes():
	var left_eye_offset = Vector2(-5, 1)
	var right_eye_offset = Vector2(20, 3)
	var eye_holder_radius = 5
	var eye_holder_nb_points = 8
	var left_eye_holder_points = get_arc_points(Vector2(starting_pos.x + left_eye_offset.x, \
		starting_pos.y + left_eye_offset.y), \
		eye_holder_radius, -45, 90, 1.0, eye_holder_nb_points)
	var right_eye_holder_points = get_arc_points(Vector2(starting_pos.x + right_eye_offset.x, \
		starting_pos.y + right_eye_offset.y), \
		eye_holder_radius, -45, 90, 1.0, eye_holder_nb_points)
	draw_polyline(left_eye_holder_points, color_secondary, 4)
	draw_polyline(right_eye_holder_points, color_secondary, 4)
	
	var eye_radius = 5
	draw_circle_custom(left_eye_holder_points[left_eye_holder_points.size() - 1], eye_radius, 1.0, eye_color)
	draw_circle_custom(right_eye_holder_points[right_eye_holder_points.size() - 1], eye_radius, 1.0, eye_color)

func draw_head():
	var head_radius = 35
	var head_trig = .8
	var next_head_pos = Vector2(starting_pos.x, starting_pos.y * current_scale)
	draw_circle_custom(next_head_pos, head_radius, head_trig, color_primary)

func get_arc_points(center, radius, angle_from, angle_to, trig_multiplier, nb_points):
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point) * 1 / trig_multiplier, \
			sin(angle_point) * trig_multiplier) * radius)
	
	return points_arc

func draw_circle_custom(circle_center, radius, trig, color):
	draw_circle_arc_custom(circle_center, radius, 0, 180, trig, color)
	draw_circle_arc_custom(circle_center, radius, 180, 360, trig, color)

func draw_circle_arc_custom(center, radius, angle_from, angle_to, trig_multiplier, color):
	var nb_points = head_nb_points
	var points_arc = PoolVector2Array()
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point) * 1 / trig_multiplier, \
			sin(angle_point) * trig_multiplier) * radius)

	draw_polygon(points_arc, colors)

func _on_Area2D_body_entered(body):
	if body.name == 'Rabbit' and current_hover_tip == null and !Globals.is_in_final_song():
#		print('Creating hover tip!')
		current_hover_tip = hover_tip.instance()
		add_child(current_hover_tip)
		is_rabbit_in_speak_zone = true
		store.dispatch(actions.dialogue_set_rabbit_position(body.position))

func _on_Area2D_body_exited(body):
	if body.name == 'Rabbit' and current_hover_tip != null and !Globals.is_in_final_song():
#		print('Deleting hover tip!')
		current_hover_tip.queue_free()
		current_hover_tip = null
		is_rabbit_in_speak_zone = false