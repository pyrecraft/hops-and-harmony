extends Node2D

const hover_tip = preload("res://src/things/HoverTip.tscn")

export var color_primary = Color.white
export var color_eyes = Color('#2a363b')
export var is_purple_songbird = false

var start_pos = Vector2(0, 0)
var current_hover_tip
var is_rabbit_in_speak_zone = false

# State Tree
var dialogue_queue_L = []
var songbird_green_dict_L = {}
var songbird_purple_dict_L = {}
var rabbit_position_L = Vector2(0, 0)
var game_day_L = 1
var game_hour_L = 1
var game_state_L = Globals.GameState.PLAYING
var game_progress_L = Globals.GameProgress.GAME_START

# Called when the node enters the scene tree for the first time.
func _ready():
	store.subscribe(self, "_on_store_changed")
	$Body.supershape_color = color_primary
	dialogue_queue_L = Globals.get_state_value('dialogue', 'queue')
	songbird_green_dict_L = Globals.get_state_value('dialogue', 'songbird_green_dict')
	songbird_purple_dict_L = Globals.get_state_value('dialogue', 'songbird_purple_dict')
	rabbit_position_L = Globals.get_state_value('dialogue', 'rabbit_position')
	game_day_L = Globals.get_state_value('game', 'day')
	game_hour_L = Globals.get_state_value('game', 'hour')
	game_state_L = Globals.get_state_value('game', 'state')
	game_progress_L = Globals.get_state_value('game', 'progress')
	
	$DialogueBox.connect("text_complete", self, "on_DialogueBox_text_complete")
	$DialogueBox.clear_text()
	$Area2D.connect("body_entered", self, "_on_Area2D_body_entered")
	$Area2D.connect("body_exited", self, "_on_Area2D_body_exited")

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
	if store.get_state()['dialogue']['songbird_green_dict'] != null:
		songbird_green_dict_L = store.get_state()['dialogue']['songbird_green_dict']
	if store.get_state()['dialogue']['songbird_purple_dict'] != null:
		songbird_purple_dict_L = store.get_state()['dialogue']['songbird_purple_dict']

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
	
	print('Speaker : ' + speaker)
	print('Name : ' + name)
	
	if speaker != name:
		return
	
	var dialogue_text = next_dialogue_obj['text']
	
	print ('Next dialogue: ' + dialogue_text)
	print('Existing: ' + $DialogueBox.get_text())
	
	if dialogue_text != $DialogueBox.get_text(): # NOTE: this means you cannot say the same text twice
		print('Setting next dialogue for ' + name + ': ' + dialogue_text)
		$DialogueBox.set_text(dialogue_text)

func can_start_dialogue():
	return is_rabbit_in_speak_zone and dialogue_queue_L.empty() \
		and (current_hover_tip != null and current_hover_tip.visible)

func _input(event):
	if Input.is_key_pressed(KEY_E) and can_start_dialogue():
		print('Attempted to speak with Rabbit!')
		store.dispatch(actions.dialogue_set_npc_position(position))
		store.dispatch(actions.dialogue_set_queue(get_next_dialogue()))

func get_next_dialogue():
	return get_next_dialogue_purple() if is_purple_songbird else get_next_dialogue_green()

func get_next_dialogue_purple():
	match game_progress_L:
			Globals.GameProgress.TALKED_TO_DAD:
				var next_dialogue = []
				match songbird_purple_dict_L[game_progress_L]:
					0:
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Hi!"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "Hi"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Today's my first day"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', ".."))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "Try not to get eaten!"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', ".."))
					_:
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Hi!"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "Hi"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Today's my first day"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', ".."))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "Try not to get eaten!"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', ".."))
					
				store.dispatch(actions.dialogue_increment_crab_dict(game_progress_L))
				return next_dialogue

func get_next_dialogue_green():
	match game_progress_L:
		Globals.GameProgress.TALKED_TO_DAD:
			var next_dialogue = []
			match songbird_green_dict_L[game_progress_L]:
				0:
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Hi!"))
					next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "Why hello there"))
					next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "I haven't seen you before"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "This is actually my first day!"))
					next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "Cool!"))
					next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "You should make yourself known to the Sheepa"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Sheepa?"))
					next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "Head east and you will find him"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Ok "))
					next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "Just watch out for slippery rocks"))
				_:
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Hi!"))
					next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "Hello again"))
					next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "Have you found the sherpa yet?"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Actually no, not yet"))
					next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "Head east and you will find him"))
				
			store.dispatch(actions.dialogue_increment_crab_dict(game_progress_L))
			return next_dialogue

func create_dialogue_object(speaker, text):
	return {
		'speaker': speaker,
		'text': text
	}

func on_DialogueBox_text_complete():
	store.dispatch(actions.dialogue_pop_queue())
	if dialogue_queue_L.empty():
		$DialogueBox.queue_clear_text()
		print('Crab finished talking.')

func _draw():
	draw_head()

func draw_head():
	var head_pos = Vector2(start_pos.x, start_pos.y - 32)
	var head_radius = 18
	draw_circle(head_pos, head_radius, color_primary)
	
	var eyes_offset = Vector2(-5, -4)
	var eye_radius = 3
	var eye_pos = Vector2(head_pos.x + (eyes_offset.x * 1.0), head_pos.y + eyes_offset.y)
	draw_circle_custom(eye_pos, eye_radius, 1.0, color_eyes)

func draw_circle_custom(circle_center, radius, trig, color):
	draw_circle_arc_custom(circle_center, radius, 0, 180, trig, color)
	draw_circle_arc_custom(circle_center, radius, 180, 360, trig, color)

func draw_circle_arc_custom(center, radius, angle_from, angle_to, trig_multiplier, color):
	var nb_points = Constants.CIRCLE_NB_POINTS
	var points_arc = PoolVector2Array()
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point) * 1 / trig_multiplier, \
			sin(angle_point) * trig_multiplier) * radius)

	draw_polygon(points_arc, colors)

func _on_Area2D_body_entered(body):
	if body.name == 'Rabbit' and current_hover_tip == null:
#		print('Creating hover tip!')
		current_hover_tip = hover_tip.instance()
		add_child(current_hover_tip)
		is_rabbit_in_speak_zone = true
		actions.dialogue_set_rabbit_position(body.position)

func _on_Area2D_body_exited(body):
	if body.name == 'Rabbit' and current_hover_tip != null:
#		print('Deleting hover tip!')
		current_hover_tip.queue_free()
		current_hover_tip = null
		is_rabbit_in_speak_zone = false