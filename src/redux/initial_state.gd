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
				'hour': 20,
				'state': Globals.GameState.PLAYING,
				'progress': Globals.GameProgress.TALKED_TO_DAD
			}
		'dialogue':
			return {
				'queue': [],
				'rabbit_position': Vector2(0, 0),
				'npc_position': Vector2(0, 0),
				'crab_dict': get_init_dict(),
				'father_dict': get_init_dict()
			}
	return {}

static func get_init_dict():
	var dict = {}
	for i in range(0, Globals.GAME_PROGRESS_TOTAL_STATES):
		dict[i] = 0
	return dict

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