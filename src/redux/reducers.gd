extends Node

const initial_state = preload('initial_state.gd')

onready var types = get_node('/root/action_types')
onready var store = get_node('/root/store')

func game(state, action):
	if state.empty() and action['type'] == null:
		return initial_state.get_substate('game')
	if action['type'] == action_types.GAME_SET_DAY:
		var next_state = store.shallow_copy(state)
		next_state['day'] = action['day']
		return next_state
	if action['type'] == action_types.GAME_SET_STATE:
		var next_state = store.shallow_copy(state)
		next_state['state'] = action['state']
		return next_state
	if action['type'] == action_types.GAME_SET_MONEY:
		var next_state = store.shallow_copy(state)
		next_state['money'] = action['money']
		return next_state
	if action['type'] == action_types.GAME_SET_MISSION:
		var next_state = store.shallow_copy(state)
		next_state['mission'] = action['mission']
		return next_state
	return state

func canvas(state, action):
	if state.empty() and action['type'] == null:
		return initial_state.get_substate('canvas')
	if action['type'] == action_types.CANVAS_SET_DIMENSIONS:
		var next_state = store.shallow_copy(state)
		next_state['dimensions'] = action['dimensions']
		return next_state
	if action['type'] == action_types.CANVAS_SET_STARTING_VECTOR:
		var next_state = store.shallow_copy(state)
		next_state['starting_vector'] = action['starting_vector']
		return next_state
	if action['type'] == action_types.CANVAS_SET_GRID:
		var next_state = store.shallow_copy(state)
		next_state['grid'] = action['grid']
		return next_state
	if action['type'] == action_types.CANVAS_ADD_TO_GRID:
		var next_state = store.shallow_copy(state)
		next_state['grid'] = action['grid']
		var grid = action['grid']
		for y in range(get_viewport().size.y):
			for x in range(get_viewport().size.x):
				if grid[y][x] != null:
					next_state['grid'][y][x] = grid[y][x]
		return next_state
	return state

func paint(state, action):
	if state.empty() and action['type'] == null:
		return initial_state.get_substate('paint')
	if action['type'] == action_types.PAINT_SET_CURRENT_PAINT:
		var next_state = store.shallow_copy(state)
		next_state['current_paint'] = action['current_paint']
		return next_state
	if action['type'] == action_types.PAINT_SET_PAINT_INFO:
		var next_state = store.shallow_copy(state)
		next_state['paint_info'] = action['paint_info']
		return next_state
	if action['type'] == action_types.PAINT_SET_PAINT_LIST:
		var next_state = store.shallow_copy(state)
		next_state['paint_list'] = action['paint_list']
		return next_state
	if action['type'] == action_types.PAINT_ADD_COLOR:
		var next_state = store.shallow_copy(state)
		next_state['paint_list'].append(action['color'])
		next_state['paint_info'][action['color']] = 100.0 # Percent left
		return next_state
	if action['type'] == action_types.PAINT_SET_RANDOM_PAINTS_LIST:
		var next_state = store.shallow_copy(state)
		next_state['random_paints_list'] = action['random_paints_list']
		return next_state
	if action['type'] == action_types.PAINT_REMOVE_COLOR:
		var next_state = store.shallow_copy(state)
		next_state['paint_list'].erase(action['color'])
		next_state['paint_info'].erase(action['color'])
		if next_state['current_paint'] == action['color']:
			if next_state['paint_list'].size() > 0:
				next_state['current_paint'] = next_state['paint_list'][0]
			else:
				next_state['current_paint'] = ''
		return next_state
	return state