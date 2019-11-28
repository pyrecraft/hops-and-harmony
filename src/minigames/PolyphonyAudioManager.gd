extends Node2D

var game_progress_L = 0

func _ready():
	store.subscribe(self, "_on_store_changed")
	game_progress_L = Globals.get_state_value('game', 'progress')

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['game']['progress'] != null:
		game_progress_L = store.get_state()['game']['progress']

func _input(event):
	if game_progress_L >= Globals.GameProgress.LYRE_OBTAINED and \
		event.is_pressed() and not event.is_echo() and Globals.is_playing_lyre():
		if event.scancode == Globals.keys[0] and Input.is_key_pressed(Globals.keys[0]):
			$LowCAudioStreamPlayer.play()
		if event.scancode == Globals.keys[1] and Input.is_key_pressed(Globals.keys[1]):
			$DAudioStreamPlayer.play()
		if event.scancode == Globals.keys[2] and Input.is_key_pressed(Globals.keys[2]):
			$EAudioStreamPlayer.play()
			$EAudioStreamPlayer
		if event.scancode == Globals.keys[3] and Input.is_key_pressed(Globals.keys[3]):
			$FAudioStreamPlayer.play()
		if event.scancode == Globals.keys[4] and Input.is_key_pressed(Globals.keys[4]):
			$GAudioStreamPlayer.play()
		if event.scancode == Globals.keys[5] and Input.is_key_pressed(Globals.keys[5]):
			$AAudioStreamPlayer.play()
		if event.scancode == Globals.keys[6] and Input.is_key_pressed(Globals.keys[6]):
			$BAudioStreamPlayer.play()
		if event.scancode == Globals.keys[7] and Input.is_key_pressed(Globals.keys[7]):
			$HighCAudioStreamPlayer.play()