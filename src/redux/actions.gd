extends Node

onready var types = get_node('/root/action_types')

func game_set_day(day):
	return {
		'type': types.GAME_SET_DAY,
		'day': day
	}

func game_set_hour(hour):
	return {
		'type': types.GAME_SET_HOUR,
		'hour': hour
	}

func game_set_correct_note_count(correct_note_count):
	return {
		'type': types.GAME_SET_CORRECT_NOTE_COUNT,
		'correct_note_count': correct_note_count
	}

func game_set_wrong_note_count(wrong_note_count):
	return {
		'type': types.GAME_SET_WRONG_NOTE_COUNT,
		'wrong_note_count': wrong_note_count
	}

func game_set_has_coconut(has_coconut):
	return {
		'type': types.GAME_SET_HAS_COCONUT,
		'has_coconut': has_coconut
	}

func game_set_beat_count(beat_count):
	return {
		'type': types.GAME_SET_BEAT_COUNT,
		'beat_count': beat_count
	}

func game_set_state(state):
	return {
		'type': types.GAME_SET_STATE,
		'state': state
	}

func game_set_progress(progress):
	return {
		'type': types.GAME_SET_PROGRESS,
		'progress': progress
	}

func game_set_song(song):
	return {
		'type': types.GAME_SET_SONG,
		'song': song
	}

func dialogue_set_queue(queue):
	return {
		'type': types.DIALOGUE_SET_QUEUE,
		'queue': queue
	}

func dialogue_pop_queue():
	return {
		'type': types.DIALOGUE_POP_QUEUE
	}

func dialogue_set_rabbit_position(rabbit_position):
	return {
		'type': types.DIALOGUE_SET_RABBIT_POSITION,
		'rabbit_position': rabbit_position
	}

func dialogue_set_npc_position(npc_position):
	return {
		'type': types.DIALOGUE_SET_NPC_POSITION,
		'npc_position': npc_position
	}

func dialogue_set_crab_dict(crab_dict):
	return {
		'type': types.DIALOGUE_SET_CRAB_DICT,
		'crab_dict': crab_dict
	}

func dialogue_increment_crab_dict(game_progress_index):
	return {
		'type': types.DIALOGUE_INCREMENT_CRAB_DICT,
		'game_progress_index': game_progress_index
	}

func dialogue_increment_songbird_green_dict(game_progress_index):
	return {
		'type': types.DIALOGUE_INCREMENT_SONGBIRD_GREEN_DICT,
		'game_progress_index': game_progress_index
	}

func dialogue_increment_songbird_purple_dict(game_progress_index):
	return {
		'type': types.DIALOGUE_INCREMENT_SONGBIRD_PURPLE_DICT,
		'game_progress_index': game_progress_index
	}

func dialogue_increment_sheep_dict(game_progress_index):
	return {
		'type': types.DIALOGUE_INCREMENT_SHEEP_DICT,
		'game_progress_index': game_progress_index
	}

func dialogue_set_father_dict(father_dict):
	return {
		'type': types.DIALOGUE_SET_FATHER_DICT,
		'father_dict': father_dict
	}

func dialogue_increment_father_dict(game_progress_index):
	return {
		'type': types.DIALOGUE_INCREMENT_FATHER_DICT,
		'game_progress_index': game_progress_index
	}
