extends Sprite

const note = preload("res://src/minigames/Note.tscn")

var test_notes_to_render = [0, 1, 0, 1, 0, 5, 0, 1, 0, 5, 0, 1, 0, 1, 0, 5, 0, 1, 0, 5, 0, 1, 0, 1, 0, 5, 0, 1, 0, 5, 0, 1, 0, 1, 0, 5, 0, 1, 0, 5, 0, 1, 0, 1, 0, 5, 0, 1, 0, 5, 0, 1, 0, 1, 0, 5, 0, 1, 0, 5, 0, 1, 0, 1, 0, 5, 0, 1, 0, 5]

var songbirds_song = [
	0, 0, 0,
	0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	1, 0, 5, 0, 1, 0, 5, 0, 4, 0, 4, 0, 4, 0, 4, 0,
	8, 0, 7, 0, 6, 0, 5, 0, 8, 0, 5, 0, 3, 0, 1, 0,
	1, 0, 5, 0, 1, 0, 5, 0, 4, 0, 4, 0, 4, 0, 4, 0,
	8, 0, 7, 0, 6, 0, 5, 0, 8, 0, 5, 0, 3, 0, 1, 0,
	1, 0, 3, 0, 5, 0, 8, 0, 1, 0, 3, 0, 5, 0, 8, 0,
	7, 8, 6, 7, 7, 8, 6, 7, 8, 0, 5, 0, 3, 0, 1, 0,
	1, 3, 5, 8, 1, 3, 5, 8, 8, 5, 3, 1, 8, 5, 3, 1,
	7, 8, 6, 7, 7, 8, 6, 7, 8, 0, 5, 0, 3, 0, 1, 0,
	1, 3, 5, 8, 1, 3, 5, 8, 8, 5, 3, 1, 8, 5, 3, 1,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
]
var home_song = [
	0, 0, 0,
	0, 0, 0, 
	1, 0, 4, 0, 1, 0, 4, 0,
	4, 0, 6, 0, 4, 0, 7, 4,
	1, 0, 4, 0, 1, 0, 4, 0,
	4, 0, 6, 0, 4, 0, 7, 4,
	1, 0, 4, 0, 1, 0, 4, 0,
	5, 5, 4, 4, 3, 3, 2, 2,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
]

var final_song = [
	0, 0, 0, 0, 0, 0, 
	1, 0, 5, 0, 4, 0, 3, 0,
	3, 4, 5, 2, 0, 0, 0, 0,
	3, 4, 5, 2, 0, 0, 0, 0,
	2, 3, 4, 1, 0, 0, 0, 0,
	1, 0, 5, 0, 4, 0, 3, 0,
	3, 4, 5, 2, 0, 0, 0, 0,
	3, 4, 5, 2, 0, 0, 0, 0,
	2, 3, 4, 1, 0, 0, 0, 0,
	1, 0, 0, 0, 3, 2, 1, 0,
	7, 0, 8, 0, 6, 0, 0, 0,
	1, 0, 0, 0, 3, 2, 1, 0,
	7, 0, 0, 8, 5, 0, 0, 0,
	5, 0, 0, 0, 5, 4, 3, 0,
	4, 0, 0, 8, 5, 0, 0, 0,
	1, 0, 0, 0, 3, 2, 1, 0,
	7, 0, 0, 8, 6, 0, 0, 0,
	1, 1, 1, 1, 3, 2, 1, 0,
	1, 1, 1, 1, 3, 2, 1, 0,
	1, 1, 1, 1, 3, 2, 1, 0,
	7, 8, 6, 7, 5, 6, 4, 5,
	1, 1, 1, 1, 3, 2, 1, 0,
	1, 1, 1, 1, 3, 2, 1, 0,
	1, 1, 1, 1, 3, 2, 1, 0,
	7, 8, 6, 7, 5, 6, 7, 8,
	1, 0, 8, 0, 7, 0, 6, 0,
	5, 0, 0, 4, 3, 0, 2, 0,
	1, 0, 8, 0, 7, 0, 6, 0,
	6, 0, 0, 5, 5, 0, 0, 0,
	1, 0, 8, 0, 7, 0, 6, 0,
	5, 0, 0, 4, 3, 0, 2, 0,
	1, 0, 8, 0, 7, 0, 6, 0,
	6, 0, 0, 5, 5, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
]

var max_visible_notes_allowed = 12
var distance_apart = 50
var current_notes_visible = []
var working_notes = []

var beat_count_L
var song_L
var correct_note_count_L
var wrong_note_count_L

func get_notes(song):
	match song:
		'FatherRabbit':
			return home_song
		'Songbirds':
			return songbirds_song
		'FinalSong':
			return final_song
	return test_notes_to_render

# Called when the node enters the scene tree for the first time.
func _ready():
	store.subscribe(self, "_on_store_changed")
	beat_count_L = Globals.get_state_value('game', 'beat_count')
	song_L = Globals.get_state_value('game', 'song')
	correct_note_count_L = Globals.get_state_value('game', 'correct_note_count')
	wrong_note_count_L = Globals.get_state_value('game', 'wrong_note_count')
#	hide()
	render_initial_notes()

func render_initial_notes():
#	show() # Displays middle note
	print('Rendering initial notes')
	working_notes = get_notes(song_L).duplicate()
	for i in range(max_visible_notes_allowed):
		var next_x_position = (i * distance_apart) - (distance_apart * 2)
		var next_note = note.instance()
		next_note.position.x = next_x_position
		next_note.position.y = 0
		next_note.set_num_text(working_notes[i])
		add_child(next_note)
		current_notes_visible.push_back(next_note)
	for i in range(max_visible_notes_allowed):
		working_notes.pop_front()

func update_notes():
	for i in range(current_notes_visible.size()):
		var current_note = current_notes_visible[i]
		if i == 0:
			if current_note.is_failure():
				print ("Found failed note!")
				store.dispatch(actions.game_set_wrong_note_count(wrong_note_count_L + 1))
			elif current_note.is_success():
				store.dispatch(actions.game_set_correct_note_count(correct_note_count_L + 1))
			current_note.queue_free()
		else:
			if i == 2 and current_note.get_num_text() != "" and !current_note.is_success_or_failure():
#				print("Setting note to failure from update_notes")
				current_note.set_background_failure()
			current_note.position.x -= distance_apart
#	print("Popping " + str(current_notes_visible.front()))
	current_notes_visible.pop_front()
	var next_note_num = working_notes.pop_front()
	var next_note = note.instance()
	next_note.set_num_text(next_note_num)
	next_note.position.x = (max_visible_notes_allowed - 1) * distance_apart - (distance_apart * 2)
	next_note.position.y = 0
	add_child(next_note)
	current_notes_visible.push_back(next_note)

func clear_current_notes():
	hide()
	for child in get_children():
		if 'Note' in child.name:
			child.queue_free()
	current_notes_visible = []

func _on_store_changed(name, state):
	if state.has('beat_count') and state['beat_count'] != beat_count_L \
		and current_notes_visible.size() == max_visible_notes_allowed:
		beat_count_L = state['beat_count']
#		print(state)
		update_notes()
		handle_note_logic()
	if store.get_state()['game']['song'] != null:
		var previous_song = song_L
		song_L = store.get_state()['game']['song']
		if previous_song == '' and song_L != '':
			render_initial_notes()
		elif song_L == '' and previous_song != '':
			clear_current_notes()
	if store.get_state()['game']['correct_note_count'] != null:
		correct_note_count_L = store.get_state()['game']['correct_note_count']
	if store.get_state()['game']['wrong_note_count'] != null:
		wrong_note_count_L = store.get_state()['game']['wrong_note_count']

func _input(event):
	if event.is_pressed() and not event.is_echo() and Globals.is_playing_lyre() and song_L != '':
		var next_note = current_notes_visible[2]
		if next_note.get_num_text() == "":
			return
		if is_right_notes_played():
			next_note.set_background_success()
		else:
			next_note.set_background_failure()
			pass
		
func handle_note_logic():
	var next_note = current_notes_visible[2]
	
	if next_note.get_num_text() == "":
		return
	
	if is_right_notes_played():
		next_note.set_background_success()
	else:
		pass

func is_right_notes_played():
	var correct_note_to_play = current_notes_visible[2].get_num_text()
	var notes_played = Globals.get_notes_played()
	# Assumes 1 note allowed per beat
	if notes_played.size() == 0 or notes_played.size() > 1:
		return false
	var note_that_player_played = str(notes_played[0])
	return str(note_that_player_played) == str(correct_note_to_play)