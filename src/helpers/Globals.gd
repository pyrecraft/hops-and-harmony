extends Node

const initial_state = preload("res://src/redux/initial_state.gd")

var moon
var day_night

enum GameState {
	PLAYING,
	DIALOGUE
}

enum GameProgress {
	GAME_START,
	TALKED_TO_DAD,
	COCONUT_STARTED, # Gather coconuts
	COCONUT_COMPLETED,
	STRING_STARTED, # Gather strings
	STRING_COMPLETED,
	LYRE_OBTAINED
}

const GAME_PROGRESS_TOTAL_STATES = 7

func get_color(r, g, b, a):
	return Color(float(r)/255.0, float(g)/255.0, float(b)/255.0, float(a)/255.0)

func create_dialogue_object(speaker, text):
	return {
		'speaker': speaker,
		'text': text
	}

static func get_state_value(key, value):
	if store == null or store.get_state() == null or store.get_state() == {} or \
		!store.get_state().has(key) or !store.get_state()[key].has(value):
		print('store[' + key + '][' + value + '] has not been set yet')
		return initial_state.get_state_property(key, value)
	else:
		print('found valid k/v entry for store[' + key + '][' + value + ']: ' + str(store.get_state()[key][value]))
		return store.get_state()[key][value]