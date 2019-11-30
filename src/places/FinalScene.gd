extends Node2D

#var island_color = Color('#f9d5bb')

var curr_viewport
var is_using_moon = false
var is_song_finished = false

# Called when the node enters the scene tree for the first time.
func _ready():
	store.dispatch(actions.game_set_state(Globals.GameProgress.FINAL_SONG))
	curr_viewport = get_viewport().size
	if is_using_moon:
		$MoonLayer/Moon.position.x += curr_viewport.x / 2.0
	$DelayTimer.start()

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
#	next_dialogue.push_back(Globals.create_dialogue_object('Sheep', "Come one, come all"))
#	next_dialogue.push_back(Globals.create_dialogue_object('Sheep', "Come short, come tall"))
#	next_dialogue.push_back(Globals.create_dialogue_object('Sheep', "Come less-legged, come more-legged,"))
#	next_dialogue.push_back(Globals.create_dialogue_object('Sheep', "Come two-legged, come four-legged"))
#	next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', ".."))
#	next_dialogue.push_back(Globals.create_dialogue_object('Crab', "Jesus.."))
#	next_dialogue.push_back(Globals.create_dialogue_object('Sheep', "Let's all celebrate Harley's first day!"))
#	next_dialogue.push_back(Globals.create_dialogue_object('SongbirdGreen', "Still alive!"))
#	next_dialogue.push_back(Globals.create_dialogue_object('SongbirdPurple', "Woohoo Harley!"))
#	next_dialogue.push_back(Globals.create_dialogue_object('FatherRabbit', "Proud of you darling"))
#	next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "I'd like to share a song with you all"))
	next_dialogue.push_back(Globals.create_dialogue_object('Rabbit', "In thanks for this amazing day"))
	next_dialogue.push_back(Globals.create_dialogue_object('Song', "FinalSong"))
	return next_dialogue