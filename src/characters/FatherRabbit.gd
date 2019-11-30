extends KinematicBody2D

const hover_tip = preload("res://src/things/HoverTip.tscn")
const initial_state = preload("res://src/redux/initial_state.gd")

const color_eyes = Color('#2a363b')
const color_pink = Color('#64ccda')
const color_primary = Color('#c9d1d3')
const walk_smoke = preload('res://src/effects/WalkSmoke.tscn')

# Movement
var gravity = 1000
var walk_speed = 350
var jump_speed = -500
var velocity = Vector2()

# Animation
var scale_rate = .5
var current_scale = .9
var scale_polarity = 1 # +1 or -1
var circle_center = Vector2(0, -17)
var current_rabbit_state = RabbitState.IDLE
var current_hover_tip
var current_play_hover_tip
var is_rabbit_in_speak_zone = false

# State Tree
var dialogue_queue_L = []
var father_dict_L = {}
var rabbit_position_L = Vector2(0, 0)

var game_day_L = 1
var game_hour_L = 1
var game_state_L = Globals.GameState.PLAYING
var game_progress_L = Globals.GameProgress.GAME_START
var game_song_L = ''
var has_coconut_L = false
var correct_note_count_L
var wrong_note_count_L

enum RabbitState {
	IDLE,
	WALKING,
	JUMPING
}

func _ready():
	store.subscribe(self, "_on_store_changed")
	$ShowStartTextTimer.connect("timeout", self, "_on_ShowStartTextTimer_timeout")
	$Area2D.connect("body_entered", self, "_on_Area2D_body_entered")
	$Area2D.connect("body_exited", self, "_on_Area2D_body_exited")
	$DialogueBox.connect("text_complete", self, "on_DialogueBox_text_complete")
	$DialogueBox.clear_text()
	game_progress_L = initial_state.get_state()['game']['progress']
	father_dict_L = Globals.get_state_value('dialogue', 'father_dict')
	has_coconut_L = Globals.get_state_value('game', 'has_coconut')
	game_song_L = Globals.get_state_value('game', 'song')
	correct_note_count_L = Globals.get_state_value('game', 'correct_note_count')
	wrong_note_count_L = Globals.get_state_value('game', 'wrong_note_count')

func _on_Area2D_body_entered(body):
	if body.name == 'Rabbit' and current_hover_tip == null and !Globals.is_in_final_song():
#		print('Creating hover tip!')
		current_hover_tip = hover_tip.instance()
		add_child(current_hover_tip)
		current_hover_tip.z_index = 1
		current_hover_tip.set_box_position(Vector2(-13, -170))
		is_rabbit_in_speak_zone = true
		store.dispatch(actions.dialogue_set_rabbit_position(body.position))
	if body.name == 'Rabbit' and current_play_hover_tip == null and Globals.has_lyre() and !Globals.is_in_final_song():
		current_play_hover_tip = hover_tip.instance()
		add_child(current_play_hover_tip)
		current_play_hover_tip.z_index = 1
		current_play_hover_tip.set_action_text('Play')
		current_play_hover_tip.set_text('W')
		current_play_hover_tip.set_box_color('9b45e4')
		current_play_hover_tip.set_text_offset_x(-3)
		current_play_hover_tip.set_box_position(Vector2(-13, -220))

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

func on_DialogueBox_text_complete():
	store.dispatch(actions.dialogue_pop_queue())
	if dialogue_queue_L.empty(): # About to pop this last message:
		$DialogueBox.queue_clear_text()

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
#		print('Game progress now: ' + str(game_progress_L))
	if store.get_state()['dialogue']['father_dict'] != null:
		father_dict_L = store.get_state()['dialogue']['father_dict']
	if store.get_state()['game']['has_coconut'] != null:
		has_coconut_L = store.get_state()['game']['has_coconut']
	if store.get_state()['game']['song'] != null:
		var prev_song = game_song_L
		game_song_L = store.get_state()['game']['song']
		update_song_playing(prev_song, game_song_L)
	if store.get_state()['game']['correct_note_count'] != null:
		correct_note_count_L = store.get_state()['game']['correct_note_count']
	if store.get_state()['game']['wrong_note_count'] != null:
		wrong_note_count_L = store.get_state()['game']['wrong_note_count']

func update_song_playing(prev_song, curr_song):
	if curr_song == '' and prev_song != '': # Song Off
		pass
	elif curr_song != '' and prev_song == '': # New Song
		$DialogueBox.queue_clear_text()

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
	
	if speaker != name:
		return
	
	var dialogue_text = next_dialogue_obj['text']
	if dialogue_text != $DialogueBox.get_text(): # NOTE: this means you cannot say the same text twice
#		print('Setting next dialogue for FatherRabbit: ' + dialogue_text)
		$DialogueBox.set_text(dialogue_text)

func _input(event):
	if Input.is_key_pressed(KEY_E) and can_start_dialogue():
		print('Attempted to speak with Rabbit!')
		if game_progress_L == Globals.GameProgress.COCONUT_STARTED and has_coconut_L: # Receive coconut
			store.dispatch(actions.game_set_progress(Globals.GameProgress.COCONUT_COMPLETED))
			store.dispatch(actions.game_set_has_coconut(false))
		store.dispatch(actions.dialogue_set_npc_position(position))
		store.dispatch(actions.dialogue_set_queue(get_next_dialogue()))
#		store.dispatch(actions.game_set_progress(Globals.GameProgress.TALKED_TO_DAD))
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
#			next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Hey Dad"))
			next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Can I practice a song for you?"))
			next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Sure thing hun"))
#			next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', ""))
#			next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', ""))
#			next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Thanks"))
			next_dialogue.push_back(Globals.create_dialogue_object('Song', "FatherRabbit"))
#			var score_validation_arr = get_score_validation_text()
#			for i in range(0, score_validation_arr.size()):
#				next_dialogue.push_back(score_validation_arr[i])
		Globals.GameProgress.PREPARE_FINAL_SONG:
			next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Can I practice a song for you?"))
			next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Sure thing hun"))
			next_dialogue.push_back(Globals.create_dialogue_object('Song', "FatherRabbit"))
	return next_dialogue

func get_score_validation_text():
	var text_arr = []
	var score_percent = float(correct_note_count_L) / float((correct_note_count_L + wrong_note_count_L))
	print('Score percent was : ' + str(score_percent))
	text_arr.push_back(Globals.create_dialogue_object('FatherRabbit', ".."))
	if score_percent > .90:
		text_arr.push_back(Globals.create_dialogue_object('FatherRabbit', "You got " + str(correct_note_count_L) + ' correct out of ' + str(correct_note_count_L + wrong_note_count_L)))
		text_arr.push_back(Globals.create_dialogue_object('FatherRabbit', "Fantastic!"))
		text_arr.push_back(Globals.create_dialogue_object('Rabbit', "Thanks Dad!"))
	elif score_percent > .80:
		text_arr.push_back(Globals.create_dialogue_object('FatherRabbit', "You got " + str(correct_note_count_L) + ' correct out of ' + str(correct_note_count_L + wrong_note_count_L)))
		text_arr.push_back(Globals.create_dialogue_object('FatherRabbit', "Hey not too shabby!"))
		text_arr.push_back(Globals.create_dialogue_object('Rabbit', "Thanks Dad!"))
	elif score_percent > .65:
		text_arr.push_back(Globals.create_dialogue_object('FatherRabbit', "You got " + str(correct_note_count_L) + ' correct out of ' + str(correct_note_count_L + wrong_note_count_L)))
		text_arr.push_back(Globals.create_dialogue_object('FatherRabbit', "You missed a few notes but you'll get there"))
		text_arr.push_back(Globals.create_dialogue_object('Rabbit', "Thanks Dad!"))
	else:
		text_arr.push_back(Globals.create_dialogue_object('FatherRabbit', "You got " + str(correct_note_count_L) + ' correct out of ' + str(correct_note_count_L + wrong_note_count_L)))
		text_arr.push_back(Globals.create_dialogue_object('FatherRabbit', "You definitely have some room for improvement"))
		text_arr.push_back(Globals.create_dialogue_object('Rabbit', "I'll try harder"))
	return text_arr

func get_next_dialogue():
	var next_dialogue = []
	var original_game_progress = game_progress_L
	match game_progress_L:
		Globals.GameProgress.GAME_START:
			match father_dict_L[game_progress_L]:
				0:
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Harley!"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Dad!"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Do you know what today is?"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "What's today?"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "A ta-hare-iffic day!"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', ".."))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Today is the day you are all grown up"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', ""))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "One might say"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "You now have a full head of hare!"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', ".."))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "You're old enough to be on your own"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Go head on up and see what the world holds!"))
					store.dispatch(actions.game_set_progress(Globals.GameProgress.TALKED_TO_DAD))
		Globals.GameProgress.TALKED_TO_DAD:
			match father_dict_L[game_progress_L]:
				0:
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Go on now"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "You're the hare-o this world needs!"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', ".."))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Just exit out over to the left"))
				_:
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Don't be shy"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "You're the hare-o this world needs!"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', ".."))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Just exit out over to the left"))
		Globals.GameProgress.WENT_OUTSIDE:
			match father_dict_L[game_progress_L]:
				0:
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Hi Dad"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Hey hun"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "What should I do?"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Well"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Explore of course!"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Where should I go?"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Anywhere!"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Don't feel like your bound to just this island"))
				_:
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Hi Dad"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Hey hun"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "I'm not sure what to do"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "There's more to this island than meets the eye!"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Don't be afraid to venture out"))
		Globals.GameProgress.TALK_TO_SHEEPA:
			match father_dict_L[game_progress_L]:
				0:
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Hi Dad"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Hey hun"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "I heard there's a Sheepa somewhere"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "A cheetah??"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "No Dad, a 'Sheepa'"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Oh "))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "'Wool' in that case, you should be fine"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', ".."))
				1:
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Hi Dad"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Hey hun"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Where do you think the Sheepa lives?"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "I don't know I haven't been outside in months"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', ".."))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "What do you eat?"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "I've stored enough fat to last the rest of my life"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', ".."))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "That explains a lot"))
				_:
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Hi Dad"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Hey hun"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Where do you think the Sheepa lives?"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "In a mediterranean oven for 25 minutes"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "After it rises, let it cool"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "I said Sheepa"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Not 'Pita'"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Oh "))
		Globals.GameProgress.TALKED_TO_SHEEPA:
			match father_dict_L[game_progress_L]:
				0:
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Guess what!"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "What?!"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "I met the Sheepa!"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Wow!"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "What's a 'Shika'?"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "No Dad, the 'Sheepa'!"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "He's this wonderful, strange sheep"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "And he even told me to talk to you!"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Me?"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Apparently you know how to make instruments"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Oh yeah I do know how to do that"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', ".."))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "If you get me a coconut I can make you a lyre"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "How did you not mention this before?"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Mention what?"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', ".."))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Nevermind"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Where can I find coconuts?"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "It's been awhile but"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "They only grow on the tallest trees"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "I'll see what I can find"))
					
					store.dispatch(actions.game_set_progress(Globals.GameProgress.COCONUT_STARTED))
				_:
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Hi Dad"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Hey hun"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Did you get me a coconut yet?"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Not yet"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Still searching for it"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Make sure to bring it back here"))
		Globals.GameProgress.COCONUT_STARTED:
			match father_dict_L[game_progress_L]:
				_:
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Hi Dad"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Hey hun"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Did you get me a coconut yet?"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Not yet"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Still searching for it!"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Make sure to bring it back here"))
		Globals.GameProgress.COCONUT_COMPLETED:
			match father_dict_L[game_progress_L]:
				0:
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Here you go Dad"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Oh wow!"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "This will make an amazing smoothie"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Dad no!"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "It's for the lyre"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Remember?"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Oh right"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Give me one second to make it for you"))
				1:
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Your lyre is ready!"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "That fast?"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Yup "))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "How many other hidden talents do you have?"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "I can make my belly expand very wide"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', ".."))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "That isn't a talent, Dad"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "It's also not very 'hidden'"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Anyways, just use numbers 1-8 to play the lyre"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', ".."))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "What does use 1-8 mean?"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Your puppet master will know"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', ".."))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "I worry about you sometimes"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "You can play a practice song with me if you like"))
					store.dispatch(actions.game_set_progress(Globals.GameProgress.LYRE_OBTAINED))
				_:
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "How do I play the lyre again?"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Use numbers 1-8 on your keyboard"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', ".."))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Whatever that means"))
		Globals.GameProgress.LYRE_OBTAINED:
			match father_dict_L[game_progress_L]:
				_:
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "How do I play the lyre again?"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Use numbers 1-8 on your keyboard"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', ".."))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Whatever that means"))
		Globals.GameProgress.PREPARE_FINAL_SONG:
			match father_dict_L[game_progress_L]:
				_:
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "How do I play the lyre again?"))
					next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Use numbers 1-8 on your keyboard"))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', ".."))
					next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "Whatever that means"))
	
	store.dispatch(actions.dialogue_increment_father_dict(original_game_progress))
	return next_dialogue

func can_start_dialogue():
	return is_rabbit_in_speak_zone and dialogue_queue_L.empty() \
		and (current_hover_tip != null and current_hover_tip.visible)

func _process(delta):
	handle_states(delta)
	update()

func _physics_process(delta):
	set_velocities(delta)

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
#				spawn_landing_smoke()
				current_scale = .85
				scale_polarity = 1
				scale_rate = .3

func set_velocities(delta):
	velocity.x = 0
	velocity.y += gravity * delta
#	if is_walking_right():
#		velocity.x += walk_speed
#	if is_walking_left():
#		velocity.x -= walk_speed
#	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
#		velocity.y = jump_speed

	velocity = move_and_slide(velocity, Vector2(0, -1))

func is_walking_left():
	return true
#	return Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A)

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
	draw_circle_arc_custom(circle_center, 45, 0, 180, color_primary)
	draw_circle_arc_custom(circle_center, 45, 180, 360, color_primary)

var head_offset_x = 0
func draw_head():
	var head_offset_y = 55.0 * current_scale
	if is_walking_right():
		head_offset_x = 5
	if is_walking_left():
		head_offset_x = -5
	var head_position = Vector2(circle_center.x + head_offset_x, circle_center.y - head_offset_y)
	draw_circle_custom(head_position, 27.5, color_primary)
	draw_face(head_position, head_offset_x)
	draw_ears(head_position, head_offset_x)

func draw_ears(head_vec, head_offset_x):
	var ear_between_distance := 11.0
	var ear_distance_y := 35.0
	var ear_radius := 8.0
	var inner_ear_radius := 4.0
	var ear_offset_x = head_offset_x * 1.5
	
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