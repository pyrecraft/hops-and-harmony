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
	if action['type'] == action_types.GAME_SET_HOUR:
		var next_state = store.shallow_copy(state)
		next_state['hour'] = action['hour']
		return next_state
	if action['type'] == action_types.GAME_SET_PROGRESS:
		var next_state = store.shallow_copy(state)
		next_state['progress'] = action['progress']
		return next_state
	return state

func dialogue(state, action):
	if state.empty() and action['type'] == null:
		return initial_state.get_substate('dialogue')
	if action['type'] == action_types.DIALOGUE_SET_NPC_POSITION:
		var next_state = store.shallow_copy(state)
		next_state['npc_position'] = action['npc_position']
		return next_state
	if action['type'] == action_types.DIALOGUE_SET_RABBIT_POSITION:
		var next_state = store.shallow_copy(state)
		next_state['rabbit_position'] = action['rabbit_position']
		return next_state
	if action['type'] == action_types.DIALOGUE_SET_QUEUE:
		var next_state = store.shallow_copy(state)
		next_state['queue'] = action['queue']
		return next_state
	if action['type'] == action_types.DIALOGUE_POP_QUEUE:
		var next_state = store.shallow_copy(state)
		if !next_state['queue'].empty():
			next_state['queue'].pop_front()
		return next_state
	return state
