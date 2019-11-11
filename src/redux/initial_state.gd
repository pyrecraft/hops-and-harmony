extends Node

static func get_state():
	return {
		'game': get_substate('game'),
		'canvas': get_substate('canvas'),
		'paint': get_substate('paint')
	}

static func get_state_property(substate, key):
	return get_state()[substate][key]

static func get_substate(substate):
	match substate:
		'game':
			return {
				'money': 500,
				'day': 1,
				'state': Constants.State.PAINT,
				'mission': ''
			}
		'canvas':
			return {
				'dimensions': Vector2(716, 420),
				'starting_vector': Vector2(154, 90),
				'grid': []
			}
		'paint':
			return {
				'paint_list': [], # Paint Order
				'paint_info': {}, # Paint Info
				'current_paint': '',
				'random_paints_list': []
			}
			
	return {}