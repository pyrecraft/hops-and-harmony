extends Node2D

const hover_tip = preload("res://src/things/HoverTip.tscn")

export var color_primary = Color.white
export var color_eyes = Color('#2a363b')
export var is_purple_songbird = false # Facing Right

var start_pos = Vector2(0, 0)
var current_hover_tip
var current_play_hover_tip
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
var game_song_L = ''
var has_coconut_L = false
var correct_note_count_L
var wrong_note_count_L
var beat_count_L = 0

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
	has_coconut_L = Globals.get_state_value('game', 'has_coconut')
	game_song_L = Globals.get_state_value('game', 'song')
	correct_note_count_L = Globals.get_state_value('game', 'correct_note_count')
	wrong_note_count_L = Globals.get_state_value('game', 'wrong_note_count')
	beat_count_L = Globals.get_state_value('game', 'beat_count')
	
	$DialogueBox.connect("text_complete", self, "on_DialogueBox_text_complete")
	$DialogueBox.clear_text()
	if is_purple_songbird:
		$Area2D.connect("body_entered", self, "_on_Area2D_body_entered")
		$Area2D.connect("body_exited", self, "_on_Area2D_body_exited")
		$DialogueBox.position.x += 60
	else:
		$Body.rotate(90)
		$Head.rotate(PI * (3.5/3.0))
		$Head.position.x += 15
		$DialogueBox.position.x -= 60

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
	if store.get_state()['game']['has_coconut'] != null:
		has_coconut_L = store.get_state()['game']['has_coconut']
	if store.get_state()['game']['song'] != null:
		game_song_L = store.get_state()['game']['song']
	if store.get_state()['game']['correct_note_count'] != null:
		correct_note_count_L = store.get_state()['game']['correct_note_count']
	if store.get_state()['game']['wrong_note_count'] != null:
		wrong_note_count_L = store.get_state()['game']['wrong_note_count']
	if store.get_state()['game']['beat_count'] != null:
		beat_count_L = store.get_state()['game']['beat_count']
		if beat_count_L == 0 and game_song_L != '': # New song started
			$DialogueBox.clear_text()

func handle_hover_tip(queue):
	if !queue.empty() and current_hover_tip != null:
		current_hover_tip.queue_free()
		current_hover_tip = null
	
	if !queue.empty() and current_play_hover_tip != null:
		current_play_hover_tip.queue_free()
		current_play_hover_tip = null

func handle_next_dialogue(queue):
	if queue.empty():
		$DialogueBox.clear_text()
		return
	
	var next_dialogue_obj = queue.front()
	var speaker = next_dialogue_obj['speaker']
	
	if speaker != name and speaker != 'Songbirds':
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
	if Input.is_key_pressed(KEY_W) and can_start_playing():
		print('Attempted to play for Dad!')
		store.dispatch(actions.dialogue_set_queue(get_next_playing_dialogue()))
#		store.dispatch(actions.game_set_song(name))


func can_start_playing():
	return is_rabbit_in_speak_zone and (current_play_hover_tip != null and current_play_hover_tip.visible)

func get_next_playing_dialogue():
	var next_dialogue = []
	var original_game_progress = game_progress_L
	match game_progress_L:
		Globals.GameProgress.LYRE_OBTAINED:
			next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Song!"))
			next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Song!"))
			next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "I'll try my best"))
			next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "Perfection!"))
			next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "We'll appreciate anything"))
			next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Song!"))
			next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Song!"))
			next_dialogue.push_back(Globals.create_dialogue_object('Song', "Songbirds"))
	return next_dialogue

func get_score_validation_text():
	var text_arr = []
	var score_percent = float(correct_note_count_L) / float((correct_note_count_L + wrong_note_count_L))
	print('Score percent was : ' + str(score_percent))
	text_arr.push_back(Globals.create_dialogue_object('Songbirds', "!"))
	text_arr.push_back(Globals.create_dialogue_object('Songbirds', "!"))
	if score_percent > .90:
		text_arr.push_back(Globals.create_dialogue_object('SongBirdPurple', "You got " + str(correct_note_count_L) + ' correct out of ' + str(correct_note_count_L + wrong_note_count_L)))
		text_arr.push_back(Globals.create_dialogue_object('SongbirdGreen', "Pro!"))
		text_arr.push_back(Globals.create_dialogue_object('Rabbit', "Thanks!"))
	elif score_percent > .80:
		text_arr.push_back(Globals.create_dialogue_object('SongBirdPurple', "You got " + str(correct_note_count_L) + ' correct out of ' + str(correct_note_count_L + wrong_note_count_L)))
		text_arr.push_back(Globals.create_dialogue_object('SongbirdGreen', "Not bad!"))
		text_arr.push_back(Globals.create_dialogue_object('Rabbit', "Thanks!"))
	elif score_percent > .65:
		text_arr.push_back(Globals.create_dialogue_object('SongBirdPurple', "You got " + str(correct_note_count_L) + ' correct out of ' + str(correct_note_count_L + wrong_note_count_L)))
		text_arr.push_back(Globals.create_dialogue_object('SongbirdGreen', "Weak!"))
		text_arr.push_back(Globals.create_dialogue_object('Rabbit', "I'll try harder!"))
	else:
		text_arr.push_back(Globals.create_dialogue_object('SongBirdPurple', "You got " + str(correct_note_count_L) + ' correct out of ' + str(correct_note_count_L + wrong_note_count_L)))
		text_arr.push_back(Globals.create_dialogue_object('SongbirdGreen', "Poop!"))
		text_arr.push_back(Globals.create_dialogue_object('Rabbit', "I'll try harder!"))
	return text_arr

func get_next_dialogue():
	var original_game_progress = game_progress_L
	var next_dialogue = []
		
	match game_progress_L:
			Globals.GameProgress.WENT_OUTSIDE:
				match songbird_purple_dict_L[game_progress_L]:
					_:
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Hi!"))
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Hola!"))
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Hola!"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "I haven't seen you before"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "I'm new here"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "Bunny fat!"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "Hey don't be rude to our new friend"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "She's a little chunky"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "I need help"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "I'm not sure what I should be doing"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "Bunny lost!"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "Hmmm.."))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "Well if you need guidance"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "I suggest you find the Sheepa"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "He'll help you figure everything out"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Where is the Sheepa?"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "Bunny can't think for self!"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "He's right"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "Finding the Sheepa is part of the journey"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Uhmmm Ok"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Thanks I guess"))
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Ciao!"))
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Ciao!"))
						store.dispatch(actions.game_set_progress(Globals.GameProgress.TALK_TO_SHEEPA))
			Globals.GameProgress.TALK_TO_SHEEPA:
				match songbird_purple_dict_L[game_progress_L]:
					0:
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Hi!"))
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Bonjour!"))
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Bonjour!"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "How many languages do you both know?"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "Yeoull-Hana!"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "Just 1 language"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "We hear stuff from our travels"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "Sometimes it's just nonsense"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Like what?"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "git push origin master"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "Like that"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Where is the Sheepa?"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "Bunny dumb!"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "We can't share that info"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "It's for you to figure out"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Alright.. "))
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Adios!"))
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Adios!"))
					_:
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Hi!"))
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Aloha!"))
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Aloha!"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Where is the Sheepa?"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "Bunny sad!"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "You need to figure that out for yourself!"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Oh.. "))
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Sayonara!"))
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Sayonara!"))
			Globals.GameProgress.TALKED_TO_SHEEPA:
				match songbird_purple_dict_L[game_progress_L]:
					0:
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "MUAAARK!! "))
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "MUAAARK!! "))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Woah "))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "That was actually kind of scary"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "Idea mine"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "What's up?"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "I found the Sheepa!"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "Baaaaaaa"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "What was he like?"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Kind of strange"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "And wonderful"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "Do you know what you have to do?"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "I think the thing I now need"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Was there all along"))
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Kidneys!"))
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Kidneys!"))
					_:
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Papers, Please!"))
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Papers, Please!"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "What papers?"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "Detain!"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "Do you need more guidance?"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "I think I know what to do"))
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Glory!"))
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Glory!"))
			Globals.GameProgress.COCONUT_STARTED:
				match songbird_purple_dict_L[game_progress_L]:
					_:
						if !has_coconut_L:
							next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Konnichiwa! "))
							next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Konnichiwa! "))
							next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Do those trees have coconuts?"))
							next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "Only deez nuts!"))
							next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', ".."))
							next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "Coconuts are only found on tall trees"))
							next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "I'll keep looking"))
							next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Coco!"))
							next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Coco!"))
						else:
							next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Nut! "))
							next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Nut! "))
							next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "I have a special delivery!"))
							next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "Bunny has big nuts!"))
							next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Don't fall into water!"))
							next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Don't fall into water!"))
			Globals.GameProgress.COCONUT_COMPLETED:
				match songbird_purple_dict_L[game_progress_L]:
					_:
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "La La La! "))
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "La La La! "))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Are you songbirds?"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "Big birds!"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "We occasionally sing"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "Do you sing?"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "I might play an instrument once it's ready!"))
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Na Na Na!"))
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Na Na Na!"))
			Globals.GameProgress.LYRE_OBTAINED:
				match songbird_purple_dict_L[game_progress_L]:
					_:
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Liar, Lyre!"))
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Liar, Lyre!"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Are you saying 'Liar'?"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Or 'Lyre'?"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "Liar!"))
						next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "Want to play us a song?"))
						next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "I might know something"))
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Liar! "))
						next_dialogue.push_back(Globals.create_dialogue_object('Songbirds', "Liar! "))
	store.dispatch(actions.dialogue_increment_songbird_purple_dict(original_game_progress))
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
	var x_offset = 0
	var eye_offset_x = 0
	if !is_purple_songbird:
		x_offset = 15
		eye_offset_x = 3
	var head_pos = Vector2(start_pos.x + x_offset, start_pos.y - 32)
	var head_radius = 18
	draw_circle(head_pos, head_radius, color_primary)
	
	var eyes_offset = Vector2(-5 + eye_offset_x, -4)
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
	if body.name == 'Rabbit' and current_hover_tip == null and !Globals.is_in_final_song():
#		print('Creating hover tip!')
		current_hover_tip = hover_tip.instance()
		add_child(current_hover_tip)
		current_hover_tip.set_box_position(Vector2(-140, -80))
		is_rabbit_in_speak_zone = true
		store.dispatch(actions.dialogue_set_rabbit_position(body.position))
	
	if body.name == 'Rabbit' and current_play_hover_tip == null and Globals.has_lyre()  and !Globals.is_in_final_song():
		current_play_hover_tip = hover_tip.instance()
		add_child(current_play_hover_tip)
		current_play_hover_tip.z_index = 1
		current_play_hover_tip.set_action_text('Play')
		current_play_hover_tip.set_text('W')
		current_play_hover_tip.set_box_color('9b45e4')
		current_play_hover_tip.set_text_offset_x(-3)
		current_play_hover_tip.set_box_position(Vector2(-140, -130))

func _on_Area2D_body_exited(body):
	if body.name == 'Rabbit' and current_hover_tip != null:
#		print('Deleting hover tip!')
		current_hover_tip.queue_free()
		current_hover_tip = null
		is_rabbit_in_speak_zone = false
	if body.name == 'Rabbit' and current_play_hover_tip != null:
#		print('Deleting hover tip!')
		current_play_hover_tip.queue_free()
		current_play_hover_tip = null