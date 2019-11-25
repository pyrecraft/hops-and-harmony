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

func canvas_set_starting_vector(vec):
	return {
		'type': types.CANVAS_SET_STARTING_VECTOR,
		'starting_vector': vec
	}

func canvas_set_grid(grid):
	return {
		'type': types.CANVAS_SET_GRID,
		'grid': grid
	}

func canvas_add_to_grid(grid):
	return {
		'type': types.CANVAS_SET_GRID,
		'grid': grid
	}
