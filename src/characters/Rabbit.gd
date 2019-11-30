extends KinematicBody2D

const note_emission = preload('res://src/effects/NoteEmission.tscn')
const note_tracker = preload('res://src/minigames/NoteTracker.tscn')

const initial_state = preload("res://src/redux/initial_state.gd")
const coconut_minigame = preload("res://src/minigames/CoconutMinigame.tscn")
const color_eyes = Color('#2a363b')
const color_pink = Color('#f78dae')
const color_primary = Color('#dcb6b6')
const walk_smoke = preload('res://src/effects/WalkSmoke.tscn')
export var coconut_color = Color('965a3e')
export var coconut_hole_color = Color('#2a363b')
export var lyre_string_color = Color('#2a363b')

# Movement
var gravity = 950
var walk_speed = 350
var jump_speed = -500
var velocity = Vector2()

# Animation
var scale_rate = .1
var current_scale = .9
var scale_polarity = 1 # +1 or -1
var circle_center = Vector2(0, -10)
var current_rabbit_state = RabbitState.IDLE

# State Tree
var dialogue_queue_L = []
var npc_position_L = Vector2(0, 0)

var game_day_L = 1
var game_hour_L = 1
var game_state_L = Globals.GameState.PLAYING
var game_progress_L = Globals.GameProgress.GAME_START
var game_has_coconut_L = false
var game_song_L = ''
var beat_count_L = 0
var lyre_draw_points = PoolVector2Array()
var correct_note_count_L
var wrong_note_count_L
var is_preloading_initial_beats = true

var last_island = Island.MAIN
var beats_per_second = 0
var is_beat_count_set = false
var note_tracker_inst

var is_fading_in = true
var fade_rate = 1.0
var is_final_song_done = false
var has_jumped = false

enum Island {
	MAIN,
	MINI
}

enum RabbitState {
	IDLE,
	WALKING,
	JUMPING,
	TALKING,
	PLAYING_LYRE
}

func _ready():
	store.subscribe(self, "_on_store_changed")
	$DialogueBox.connect("text_complete", self, "on_DialogueBox_text_complete")
	$DialogueBox.clear_text()
	game_progress_L = Globals.get_state_value('game', 'progress')
	game_has_coconut_L = Globals.get_state_value('game', 'has_coconut')
	game_song_L = Globals.get_state_value('game', 'song')
	beat_count_L = Globals.get_state_value('game', 'beat_count')
	lyre_draw_points = get_lyre_points(1.0)
	correct_note_count_L = Globals.get_state_value('game', 'correct_note_count')
	wrong_note_count_L = Globals.get_state_value('game', 'wrong_note_count')
	$Camera2D/BlackRect.show()
	fade_rate = .5 if Globals.is_in_final_song() else 1.0

func on_DialogueBox_text_complete():
	store.dispatch(actions.dialogue_pop_queue())
	if dialogue_queue_L.empty():
		$DialogueBox.queue_clear_text()
		current_rabbit_state = RabbitState.IDLE

func set_position(pos):
	position = pos

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	
	if store.get_state()['dialogue']['npc_position'] != null:
		npc_position_L = store.get_state()['dialogue']['npc_position']
	if store.get_state()['game']['day'] != null:
		game_day_L = store.get_state()['game']['day']
	if store.get_state()['game']['hour'] != null:
		game_hour_L = store.get_state()['game']['hour']
	if store.get_state()['game']['state'] != null:
		var next_game_state = store.get_state()['game']['state']
		if next_game_state == Globals.GameState.MINIGAME and next_game_state != game_state_L:
			print('Starting new minigame!')
			start_coconut_minigame()
		game_state_L = store.get_state()['game']['state']
	if store.get_state()['game']['progress'] != null:
		game_progress_L = store.get_state()['game']['progress']
	if store.get_state()['game']['has_coconut'] != null:
		var prev_has_cocohut = game_has_coconut_L
		game_has_coconut_L = store.get_state()['game']['has_coconut']
		if !prev_has_cocohut and game_has_coconut_L:
			$PickupCoconutSound.play()
	if store.get_state()['game']['song'] != null:
		game_song_L = store.get_state()['game']['song']
	if store.get_state()['game']['beat_count'] != null:
		beat_count_L = store.get_state()['game']['beat_count']
		check_for_song_start(beat_count_L)
	if store.get_state()['dialogue']['queue'] != null:
		dialogue_queue_L = store.get_state()['dialogue']['queue']
		handle_next_dialogue(dialogue_queue_L)
	if store.get_state()['game']['correct_note_count'] != null:
		correct_note_count_L = store.get_state()['game']['correct_note_count']
	if store.get_state()['game']['wrong_note_count'] != null:
		wrong_note_count_L = store.get_state()['game']['wrong_note_count']

func check_for_song_start(beat_count):
	match game_song_L:
		'FatherRabbit':
			if is_preloading_initial_beats:
				if beat_count < 4 and $BeatTimer.is_stopped():
					$BeatTimer.wait_time = Globals.get_beats_per_second(game_song_L)
					$BeatTimer.start()
				elif beat_count == 4:
					$BeatTimer.stop()
					$HomeAudio.play(0)
					is_preloading_initial_beats = false
		'Songbirds':
			print('Songbird beat count: ' + str(beat_count))
			if is_preloading_initial_beats:
				if beat_count < 4 and $BeatTimer.is_stopped():
					$BeatTimer.wait_time = Globals.get_beats_per_second(game_song_L)
					$BeatTimer.start()
				elif beat_count == 4:
					$BeatTimer.stop()
					$SongbirdsAudio.play(0)
					print('Setting is_preloading to false')
					is_preloading_initial_beats = false
		'FinalSong':
			print('FinalSong beat count: ' + str(beat_count))
			if is_preloading_initial_beats and !is_final_song_done:
				if beat_count < 4 and $BeatTimer.is_stopped():
					$BeatTimer.wait_time = Globals.get_beats_per_second(game_song_L)
					$BeatTimer.start()
				elif beat_count == 4:
					$BeatTimer.stop()
					$FinalSongAudio.play(0)
					is_preloading_initial_beats = false
					

func start_coconut_minigame():
	var should_skip_minigame = false # Can use DEBUG_MODE here
	if !should_skip_minigame:
		var minigame = coconut_minigame.instance()
		minigame.connect("minigame_won", self, "on_coconut_minigame_won")
		minigame.connect("minigame_lost", self, "on_coconut_minigame_lost")
		minigame.position -= get_viewport().size / 1.7
		$Camera2D.add_child(minigame)
	else:
		on_coconut_minigame_won()

func on_coconut_minigame_won():
	print("WIN!")
	var special_palm_tree = get_tree().get_root().get_node('/root/Root/MainIsland/MiniIsland/SpecialPalmTree')
	if special_palm_tree == null:
		special_palm_tree = get_tree().get_root().get_node('/root/MainIsland/MiniIsland/SpecialPalmTree')
	if special_palm_tree != null:
		special_palm_tree.spawn_coconut()
	store.dispatch(actions.game_set_state(Globals.GameState.PLAYING))

func on_coconut_minigame_lost():
	print("LOST!")
	store.dispatch(actions.game_set_state(Globals.GameState.PLAYING))

func handle_next_dialogue(queue):
	if queue.empty():
		$DialogueBox.clear_text()
		if current_rabbit_state == RabbitState.TALKING:
			current_rabbit_state = RabbitState.IDLE
		return
	
	var next_dialogue_obj = queue.front()
	var speaker = next_dialogue_obj['speaker']
	
	if current_rabbit_state != RabbitState.PLAYING_LYRE:
		current_rabbit_state = RabbitState.TALKING
	
	if speaker != name and speaker != 'Song':
		return
	
	if speaker == 'Song':
		if is_beat_count_set:
			pass
		else:
			
			$DialogueBox.clear_text()
			var song_name = next_dialogue_obj['text']
			beats_per_second = Globals.get_beats_per_second(song_name)
			current_rabbit_state = RabbitState.PLAYING_LYRE
			
			if game_song_L != song_name:
				store.dispatch(actions.game_set_song(song_name))
			
			if !is_beat_count_set:
				is_beat_count_set = true
				match song_name:
					'FatherRabbit':
						store.dispatch(actions.game_set_beat_count(0))
					'Songbirds':
						store.dispatch(actions.game_set_beat_count(3))
					'FinalSong':
						store.dispatch(actions.game_set_beat_count(0))
				store.dispatch(actions.game_set_correct_note_count(0))
				store.dispatch(actions.game_set_wrong_note_count(0))
				is_preloading_initial_beats = true
			
			if note_tracker_inst == null:
				note_tracker_inst = note_tracker.instance()
				note_tracker_inst.position = Vector2(-167, -250)
				add_child(note_tracker_inst)
			
	else:
		var dialogue_text = next_dialogue_obj['text']
		if dialogue_text != $DialogueBox.get_text(): # NOTE: this means you cannot say the same text twice
#			print('Setting next dialogue for Rabbit: ' + dialogue_text)
			$DialogueBox.set_text(dialogue_text)

func _input(event):
	if game_progress_L >= Globals.GameProgress.LYRE_OBTAINED and \
		event.is_pressed() and not event.is_echo() and Globals.is_playing_lyre():
		if Input.is_key_pressed(Globals.keys[0]):
			var add_note = note_emission.instance()
			self.add_child(add_note)
			add_note.set_color("67b6bd")
		if Input.is_key_pressed(Globals.keys[1]):
			var add_note = note_emission.instance()
			self.add_child(add_note)
			add_note.set_color("7869c4")
		if Input.is_key_pressed(Globals.keys[2]):
			var add_note = note_emission.instance()
			self.add_child(add_note)
			add_note.set_color("8b3f96")
		if Input.is_key_pressed(Globals.keys[3]):
			var add_note = note_emission.instance()
			self.add_child(add_note)
			add_note.set_color("b86962")
		if Input.is_key_pressed(Globals.keys[4]):
			var add_note = note_emission.instance()
			self.add_child(add_note)
			add_note.set_color("bfce72")
		if Input.is_key_pressed(Globals.keys[5]):
			var add_note = note_emission.instance()
			self.add_child(add_note)
			add_note.set_color("94e089")
		if Input.is_key_pressed(Globals.keys[6]):
			var add_note = note_emission.instance()
			self.add_child(add_note)
			add_note.set_color("55a049")
		if Input.is_key_pressed(Globals.keys[7]):
			var add_note = note_emission.instance()
			self.add_child(add_note)
			add_note.set_color("2399bd")

func _process(delta):
	handle_states(delta)
	update()
	if current_rabbit_state == RabbitState.PLAYING_LYRE:
		handle_beat_management()
	handle_fading_logic(delta)

func handle_fading_logic(delta):
	if is_fading_in:
		if $Camera2D/BlackRect.color.a > 0:
			$Camera2D/BlackRect.color.a -= delta * fade_rate
	else: # Fading out
		if $Camera2D/BlackRect.color.a < 1.0:
			$Camera2D/BlackRect.color.a += delta * fade_rate

func get_playback_position(song):
	match song:
		'FatherRabbit':
			return $HomeAudio.get_playback_position()
		'Songbirds':
			return $SongbirdsAudio.get_playback_position()
		'FinalSong':
			return $FinalSongAudio.get_playback_position()
	
	return 0

func handle_beat_management():
	var playback_position = get_playback_position(game_song_L)
	if !is_preloading_initial_beats:
		if playback_position > beats_per_second * (beat_count_L - 3):
			print('Beat count: ' + str(beat_count_L))
#			print('Playback Position: ' + str(playback_position))
			beat_count_L += 1
			store.dispatch(actions.game_set_beat_count(beat_count_L))
			print(beat_count_L)
	match game_song_L:
		'FatherRabbit':
			if beat_count_L >= 51 and $SongFinishTimer.is_stopped():
				$SongFinishTimer.start()
				is_preloading_initial_beats = true
		'Songbirds':
			if beat_count_L >= 162 and $SongFinishTimer.is_stopped():
				$SongFinishTimer.start()
				is_preloading_initial_beats = true
		'FinalSong':
			var num_notes = 291
#			var num_notes = 50
			if beat_count_L >= num_notes - 32:
				note_tracker_inst.hide()
				fade_rate = 0.0775
				is_fading_in = false # fade out
			if beat_count_L >= num_notes and $SongFinishTimer.is_stopped():
				$SongFinishTimer.start()
				is_preloading_initial_beats = true
				is_final_song_done = true
				$FinalSongAudio.stop()

func song_finished():
	var next_text = get_score_validation_text()
	if !next_text.empty():
		store.dispatch(actions.dialogue_set_queue(next_text))
	$HomeAudio.stop()
	$SongbirdsAudio.stop()
	$FinalSongAudio.stop()
	print('Ending song')
	store.dispatch(actions.game_set_song(''))
	store.dispatch(actions.game_set_state(Globals.GameState.PLAYING))
	if !Globals.is_in_final_song():
		store.dispatch(actions.game_set_beat_count(0))
		is_beat_count_set = false
	current_rabbit_state = RabbitState.TALKING
	store.dispatch(actions.dialogue_pop_queue())
	if dialogue_queue_L.empty():
		$DialogueBox.queue_clear_text()
		current_rabbit_state = RabbitState.IDLE
	note_tracker_inst.queue_free()
	note_tracker_inst = null
#	$Camera2D/NoteTracker.clear_current_notes()

func get_score_validation_text():
	var text_arr = []
	var score_percent = float(correct_note_count_L) / float((correct_note_count_L + wrong_note_count_L))
	print('Score percent was : ' + str(score_percent))
	match game_song_L:
		'FatherRabbit':
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
		'Songbirds':
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
		'FinalSong':
			return [] # TODO : Perhaps add text at the very, very end
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

func _physics_process(delta):
	set_velocities(delta)
#	clamp_pos_to_screen()
	check_for_water_death()
	if position.x > 6500 and last_island == Island.MAIN:
		last_island = Island.MINI
	elif position.x < 4000 and last_island == Island.MINI:
		last_island = Island.MAIN

func check_for_water_death():
	var has_fallen_into_water = false
	if position.x < 200 and position.y > 850: # Left side death
		store.dispatch(actions.game_set_has_coconut(false))
		position = Vector2(150, 350)
		has_fallen_into_water = true
	elif position.x > 8000 and position.y > 850: # Right side death
		store.dispatch(actions.game_set_has_coconut(false))
		position = Vector2(7950, 350)
		has_fallen_into_water = true
	if position.x > 3000 and position.y > 850:
		store.dispatch(actions.game_set_has_coconut(false))		
		if last_island == Island.MINI:
			position = Vector2(6550, 350)
			has_fallen_into_water = true
		else:
			position = Vector2(3850, 350)
			has_fallen_into_water = true
	if has_fallen_into_water:
		$FallWaterSound.play()

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
				spawn_landing_smoke()
				current_scale = .85
				scale_polarity = 1
				scale_rate = .3
				if has_jumped:
					has_jumped = false
					$LandingSound.play()
		RabbitState.TALKING:
			pass

func set_velocities(delta):
	velocity.x = 0
	velocity.y += gravity * delta
	if is_walking_allowed():
		if is_walking_right():
			velocity.x += walk_speed
		if is_walking_left():
			velocity.x -= walk_speed
		if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
			$JumpSound.play()
			has_jumped = true
			velocity.y = jump_speed

	velocity = move_and_slide(velocity, Vector2(0, -1))

func is_walking_allowed():
	return current_rabbit_state != RabbitState.TALKING and current_rabbit_state != RabbitState.PLAYING_LYRE \
		and game_state_L != Globals.GameState.MINIGAME and !Globals.is_in_final_song()

func is_walking_left():
	return Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A)

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
	if game_progress_L >= Globals.GameProgress.LYRE_OBTAINED:
		draw_lyre()
	if game_has_coconut_L:
		draw_coconut()
	

func get_lyre_points(trig_offset):
	var points = PoolVector2Array()
	var hinge_starting_point = Vector2(circle_center.x + 25.0, circle_center.y - 15.0)
	points.append_array(get_arc_points(hinge_starting_point, 10, 30, -90, trig_offset + 0.2, 8))
#
	points.append_array(get_arc_points(circle_center, 20, 60, 180, trig_offset, 5))
	points.append_array(get_arc_points(circle_center, 20, 180, 300, trig_offset, 5))
#
	var left_hinge_starting_point = Vector2(circle_center.x - 25.0, circle_center.y - 15.0)
	points.append_array(get_arc_points(left_hinge_starting_point, 10, 90, -30, trig_offset + 0.2, 8))
	
	return points

func draw_lyre():
	lyre_draw_points = get_lyre_points(current_scale)
	
	var num_strings = 8
	var string_offset_x = 35.0 / num_strings
	var y_start = circle_center.y - 15.0 - current_scale
	var y_end = circle_center.y + 18.0 - current_scale
	for i in range(0, num_strings):
		var from_pos = Vector2(circle_center.x - 15.0 + (i * string_offset_x), y_start)
		var end_pos = Vector2(circle_center.x - 15.0 + (i * string_offset_x), y_end)
		if i >= 3 and i <= 5:
			end_pos.y += 3.0
		if i == num_strings - 1:
			end_pos.y -= 2.0
		draw_line(from_pos, end_pos, lyre_string_color, 2.0)
	for i in range(0, lyre_draw_points.size()):
		draw_circle(lyre_draw_points[i], 4, coconut_color)
	draw_polyline(lyre_draw_points, coconut_color, 8)
	draw_line(Vector2(circle_center.x - 15.0, circle_center.y - 15.0 - current_scale), \
		Vector2(circle_center.x + 15.0, circle_center.y - 15.0 - current_scale), coconut_color, 4)

func get_arc_points(center, radius, angle_from, angle_to, trig_multiplier, nb_points):
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point) * 1 / trig_multiplier, sin(angle_point) * trig_multiplier) * radius)
	
	return points_arc

var pos_offset_x = 0
func draw_coconut():
	var pos = Vector2(circle_center.x, circle_center.y)
	var rad = 20.0
	var hole_offset = rad / 3.0
	var hole_size = rad / 6.0
	var offset_y = 15.0 * current_scale
	if is_walking_right():
		pos_offset_x = 25
	if is_walking_left():
		pos_offset_x = -25
	pos.x += pos_offset_x
	pos.y -= offset_y
	draw_circle(pos, rad, coconut_color)
	draw_circle(Vector2(pos.x - hole_offset, pos.y), hole_size, coconut_hole_color)
	draw_circle(Vector2(pos.x, pos.y + hole_offset), hole_size, coconut_hole_color)
	draw_circle(Vector2(pos.x + hole_offset, pos.y), hole_size, coconut_hole_color)

func draw_body():
	draw_circle_arc_custom(circle_center, 40, 0, 180, color_primary)
	draw_circle_arc_custom(circle_center, 40, 180, 360, color_primary)

var head_offset_x = 0
func draw_head():
	var head_offset_y = 50.0 * current_scale
	if is_walking_right():
		head_offset_x = 5
	if is_walking_left():
		head_offset_x = -5
	var head_position = Vector2(circle_center.x + head_offset_x, circle_center.y - head_offset_y)
	draw_circle_custom(head_position, 25, color_primary)
	draw_face(head_position, head_offset_x)
	draw_ears(head_position, head_offset_x)

func draw_ears(head_vec, head_offset_x):
	var ear_between_distance := 11.0
	var ear_distance_y := 35.0
	var ear_radius := 8.0
	var inner_ear_radius := 4.0
	var ear_offset_x = head_offset_x
	
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

func _on_SongFinishTimer_timeout():
	song_finished()
	if Globals.is_in_final_song():
		is_fading_in = false # Fade out
		$OutroTimer.start()

func _on_BeatTimer_timeout():
	print('Beat count now ' + str(beat_count_L + 1))
	store.dispatch(actions.game_set_beat_count(beat_count_L + 1))

func _on_OutroTimer_timeout():
	print('Attempting to change to outro')
	get_tree().change_scene("res://src/places/Outro.tscn")
