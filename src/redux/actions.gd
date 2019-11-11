extends Node

onready var types = get_node('/root/action_types')

func game_set_day(day):
	return {
		'type': types.GAME_SET_DAY,
		'day': day
	}

func game_set_state(state):
	return {
		'type': types.GAME_SET_STATE,
		'state': state
	}

func game_set_money(money):
	return {
		'type': types.GAME_SET_MONEY,
		'money': money
	}

func game_set_mission(mission):
	return {
		'type': types.GAME_SET_MISSION,
		'mission': mission
	}

func canvas_set_dimensions(dimensions):
	return {
		'type': types.CANVAS_SET_DIMENSIONS,
		'dimensions': dimensions
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

func paint_set_paint_list(list):
	return {
		'type': types.PAINT_SET_PAINT_LIST,
		'paint_list': list
	}

func paint_set_paint_info(info):
	return {
		'type': types.PAINT_SET_PAINT_INFO,
		'paint_info': info
	}

func paint_add_paint(color):
	return {
		'type': types.PAINT_ADD_COLOR,
		'color': color
	}

func paint_remove_color(color):
	return {
		'type': types.PAINT_REMOVE_COLOR,
		'color': color
	}

func paint_set_random_paints_list(list):
	return {
		'type': types.PAINT_SET_RANDOM_PAINTS_LIST,
		'random_paints_list': list
	}

func paint_set_current_paint(current):
	return {
		'type': types.PAINT_SET_CURRENT_PAINT,
		'current_paint': current
	}