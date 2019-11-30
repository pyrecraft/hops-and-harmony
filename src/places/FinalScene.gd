extends Node2D

#var island_color = Color('#f9d5bb')

var curr_viewport
var is_using_moon = false
var is_song_finished = false
var game_song_L

# Called when the node enters the scene tree for the first time.
func _ready():
	store.subscribe(self, "_on_store_changed")
	store.dispatch(actions.game_set_state(Globals.GameProgress.FINAL_SONG))
	game_song_L = Globals.get_state_value('game', 'song')
	curr_viewport = get_viewport().size
	if is_using_moon:
		$MoonLayer/Moon.position.x += curr_viewport.x / 2.0
	$DelayTimer.start()

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['game']['song'] != null:
		var prev_song = game_song_L
		game_song_L = store.get_state()['game']['song']
		update_song_playing(prev_song, game_song_L)

func update_song_playing(prev_song, curr_song):
	if curr_song == '' and prev_song != '':
		$WavesSound.play()
	elif curr_song != '' and prev_song == '':
		$WavesSound.stop()

func _process(delta):
	if is_using_moon and get_viewport().size != curr_viewport:
		curr_viewport = get_viewport().size
		$MoonLayer/Moon.position.x = curr_viewport.x / 2.0

func _draw():
	pass

func _on_DelayTimer_timeout():
	if !is_song_finished:
		add_final_dialogue()

func add_final_dialogue():
	store.dispatch(actions.dialogue_set_queue(get_dialogue()))

func get_dialogue():
	var next_dialogue = []
	next_dialogue.push_back(Globals.create_dialogue_object('Sheep', "Come one, come all"))
	next_dialogue.push_back(Globals.create_dialogue_object('Sheep', "Come short, come tall"))
	next_dialogue.push_back(Globals.create_dialogue_object('Sheep', "Come less-legged, come more-legged,"))
	next_dialogue.push_back(Globals.create_dialogue_object('Sheep', "Come two-legged, come four-legged"))
	next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', ".."))
	next_dialogue.push_back(Globals.create_dialogue_object('Crab', "Jesus.."))
	next_dialogue.push_back(Globals.create_dialogue_object('Sheep', "Let's all celebrate Harley's first day!"))
	next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "Still alive!"))
	next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "Woohoo Harley!"))
	next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "I'd like to share a song with you all"))
	next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "In thanks for this amazing day"))
	next_dialogue.push_back(Globals.create_dialogue_object('Song', "FinalSong"))
	return next_dialogue