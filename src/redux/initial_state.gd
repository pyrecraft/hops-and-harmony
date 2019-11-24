extends Node

static func get_state():
	return {
		'game': get_substate('game'),
		'dialogue': get_substate('dialogue')
	}

static func get_state_property(substate, key):
	return get_state()[substate][key]

static func get_substate(substate):
	match substate:
		'game':
			return {
				'day': 1,
				'hour': 1,
				'state': Globals.GameState.PLAYING,
				'progress': Globals.GameProgress.BEDROOM
			}
		'dialogue':
			return {
				'queue': [],
				'rabbit_position': Vector2(0, 0),
				'npc_position': Vector2(0, 0)
			}
			
	return {}

# dialogue_queue object example:
#[
#	{
#		'speaker': 'Rabbit',
#		'text': 'Hello Carl!'
#	},
#	{
#		'speaker': 'Crab',
#		'text': 'Hi Harley how is it going?'
#	}
#]