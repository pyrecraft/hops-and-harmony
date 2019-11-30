extends Node

const initial_state = preload("res://src/redux/initial_state.gd")

var moon
var day_night

enum GameState {
	PLAYING,
	MINIGAME,
	DIALOGUE
}

enum GameProgress {
	GAME_START,
	TALKED_TO_DAD,
	WENT_OUTSIDE,
	TALK_TO_SHEEPA,
	TALKED_TO_SHEEPA,
	COCONUT_STARTED, # Gather coconuts
	COCONUT_COMPLETED, # Lyre Obtained
	LYRE_OBTAINED,
	FINAL_SONG
}

const GAME_PROGRESS_TOTAL_STATES = 9

func get_color(r, g, b, a):
	return Color(float(r)/255.0, float(g)/255.0, float(b)/255.0, float(a)/255.0)

func create_dialogue_object(speaker, text):
	return {
		'speaker': speaker,
		'text': text
	}

func is_in_final_song():
	return get_state_value('game', 'progress') == GameProgress.FINAL_SONG

static func has_lyre():
	return get_state_value('game', 'progress') >= GameProgress.LYRE_OBTAINED

static func get_state_value(key, value):
	if store == null or store.get_state() == null or store.get_state() == {} or \
		!store.get_state().has(key) or !store.get_state()[key].has(value):
#		print('store[' + key + '][' + value + '] has not been set yet')
		return initial_state.get_state_property(key, value)
	else:
#		print('found valid k/v entry for store[' + key + '][' + value + ']: ' + str(store.get_state()[key][value]))
		return store.get_state()[key][value]

const keys = [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8]

static func get_beats_per_second(song):
	match song:
		'FatherRabbit':
			return 0.6316
		'Songbirds':
			return 0.5455
		'FinalSong':
			return (0.75 / 2.0)
		_:
			return 0.5455
	return 0

static func is_playing_lyre():
	for key in keys:
		if Input.is_key_pressed(key):
			return true
	return false

static func get_notes_played():
	var notes_played = []
	if Input.is_key_pressed(Globals.keys[0]):
		notes_played.push_back(1)
	if Input.is_key_pressed(Globals.keys[1]):
		notes_played.push_back(2)
	if Input.is_key_pressed(Globals.keys[2]):
		notes_played.push_back(3)
	if Input.is_key_pressed(Globals.keys[3]):
		notes_played.push_back(4)
	if Input.is_key_pressed(Globals.keys[4]):
		notes_played.push_back(5)
	if Input.is_key_pressed(Globals.keys[5]):
		notes_played.push_back(6)
	if Input.is_key_pressed(Globals.keys[6]):
		notes_played.push_back(7)
	if Input.is_key_pressed(Globals.keys[7]):
		notes_played.push_back(8)
	return notes_played