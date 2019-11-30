extends CanvasModulate

export (float) var day_duration = 0.5 # In minutes
export (float) var day_start_hour = 10 # 24 hours time (0-23)
export (float) var day_start_number = 1

export var color_dawn = Color(0.86, 0.70, 0.70, 1.0)
export var color_day = Color(1.0, 1.0, 1.0, 1.0)
export var color_dusk = Color(0.59, 0.66, 0.78, 1.0)
export var color_night = Color(0.07, 0.09, 0.38, 1.0)

export (float) var state_dawn_start_hour = 5
export (float) var state_day_start_hour = 8
export (float) var state_dusk_start_hour = 16
export (float) var state_night_start_hour = 19

export (float) var state_transition_duration = 1 # In hours

export (bool) var debug_mode = false

export (bool) var on = true

var current_time
var current_day_hour
var current_day_number

var game_progress_L = 0

var previous_day_hour

var transition_duration

var cycle
enum cycle_state { NIGHT, DAWN, DAY, DUSK }


func _ready():
	store.subscribe(self, "_on_store_changed")
	game_progress_L = Globals.get_state_value('game', 'progress')
#	transition_duration = (((day_duration / 24) * state_transition_duration) / 60) * 250
	transition_duration = .01
	
	handle_setting_cycle(game_progress_L)
	if not on:
		queue_free()

#	Globals.day_night = self
#
#	day_duration = 60 * 60 * day_duration # Convert 'day_duration' from minutes to seconds
#
##	current_day_number = day_start_number
#	current_day_number = Globals.get_state_value("game", "day")
##	current_day_hour = current_time / (day_duration / 24)
#	current_day_hour = Globals.get_state_value("game", "hour")
#	current_time = (day_duration / 24) * current_day_hour
#	previous_day_hour = current_day_hour
#
#
#	if current_day_hour >= state_night_start_hour or current_day_hour < state_dawn_start_hour:
#		cycle = cycle_state.NIGHT
#		color = color_night
#	elif current_day_hour >= state_dawn_start_hour and current_day_hour < state_day_start_hour:
#		cycle = cycle_state.DAWN
#		color = color_dawn
#	elif current_day_hour >= state_day_start_hour and current_day_hour < state_dusk_start_hour:
#		cycle = cycle_state.DAY
#		color = color_day
#	elif current_day_hour >= state_dusk_start_hour and current_day_hour < state_night_start_hour:
#		cycle = cycle_state.DUSK
#		color = color_dusk

func handle_setting_cycle(game_progress):
	if game_progress <= Globals.GameProgress.TALK_TO_SHEEPA:
		cycle_test(cycle_state.DAWN)
	elif game_progress <= Globals.GameProgress.COCONUT_COMPLETED:
		cycle_test(cycle_state.DAY)
	elif game_progress <= Globals.GameProgress.LYRE_OBTAINED:
		cycle_test(cycle_state.DUSK)
	elif game_progress <= Globals.GameProgress.FINAL_SONG:
		cycle_test(cycle_state.NIGHT)

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['game']['progress'] != null:
		game_progress_L = store.get_state()['game']['progress']
		transition_duration = 30
		handle_setting_cycle(game_progress_L)

func _physics_process(delta):
	pass
#	day_cycle()
#	current_time += 1

func day_cycle():
	current_day_hour = int(current_time / (day_duration / 24))

	if current_day_hour != previous_day_hour:
#		print('Updating hour to ' + str(current_day_hour))
		store.dispatch(actions.game_set_hour(current_day_hour))
		previous_day_hour = int(current_day_hour)

	if current_time >= day_duration:
		current_time = 0
		current_day_hour = 0
		current_day_number += 1
		store.dispatch(actions.game_set_hour(current_day_hour))
#		print('Updating hour to ' + str(current_day_hour))
		store.dispatch(actions.game_set_day(current_day_number))
#		print('Updating day to ' + str(current_day_number))

	if current_day_hour >= state_night_start_hour or current_day_hour < state_dawn_start_hour:
		cycle_test(cycle_state.NIGHT)
	elif current_day_hour >= state_dawn_start_hour and current_day_hour < state_day_start_hour:
		cycle_test(cycle_state.DAWN)
	elif current_day_hour >= state_day_start_hour and current_day_hour < state_dusk_start_hour:
		cycle_test(cycle_state.DAY)
	elif current_day_hour >= state_dusk_start_hour and current_day_hour < state_night_start_hour:
		cycle_test(cycle_state.DUSK)

	if debug_mode:
		print(str("Day ", current_day_number)  + " - " + str(int(current_day_hour), " h") + " - " + str(cycle_state.keys()[cycle]))


func cycle_test(new_cycle):
	if cycle != new_cycle:
		cycle = new_cycle

		if cycle == cycle_state.NIGHT:
			if obj_exists(Globals.moon):
				Globals.moon.change_state(Globals.moon.state_night_energy)
			$Tween.interpolate_property(self, "color", color_dusk, color_night, transition_duration, Tween.TRANS_SINE, Tween.EASE_OUT)
			$Tween.start()

		if cycle == cycle_state.DAWN:
			if obj_exists(Globals.moon):
				Globals.moon.change_state(Globals.moon.state_dawn_energy)
			$Tween.interpolate_property(self, "color", color_night, color_dawn, transition_duration, Tween.TRANS_SINE, Tween.EASE_OUT)
			$Tween.start()

		if cycle == cycle_state.DAY:
			if obj_exists(Globals.moon):
				Globals.moon.change_state(Globals.moon.state_day_energy)
			$Tween.interpolate_property(self, "color", color_dawn, color_day, transition_duration, Tween.TRANS_SINE, Tween.EASE_OUT)
			$Tween.start()

		if cycle == cycle_state.DUSK:
			if obj_exists(Globals.moon):
				Globals.moon.change_state(Globals.moon.state_dusk_energy)
			$Tween.interpolate_property(self, "color", color_day, color_dusk, transition_duration, Tween.TRANS_SINE, Tween.EASE_OUT)
			$Tween.start()


func obj_exists(obj):
	if Engine.get_version_info().major >= 3 and Engine.get_version_info().minor == 1:
		return true if is_instance_valid(obj) else false
	if Engine.get_version_info().major <= 3 and Engine.get_version_info().minor == 0:
		return true if weakref(obj).get_ref() != null else false
