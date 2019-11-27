extends Node2D

const initial_state = preload('res://src/redux/initial_state.gd')

var game_progress_L = Globals.GameProgress.GAME_START

# Called when the node enters the scene tree for the first time.
func _ready():
	store.subscribe(self, "_on_store_changed")
	$HoverTalkTip.set_box_position(Vector2(0, -100))
	$Area2D.connect("body_entered", self, "_on_Area2D_body_entered")
	$Area2D.connect("body_exited", self, "_on_Area2D_body_exited")
	$HoverTalkTip.hide()
	game_progress_L = Globals.get_state_value('game', 'progress')
	print(game_progress_L)

func _on_store_changed(name, state):
	if store.get_state() == null:
		return
	if store.get_state()['game']['progress'] != null:
		game_progress_L = store.get_state()['game']['progress']

func _input(event):
	if Input.is_key_pressed(KEY_E) and $HoverTalkTip.visible and is_allowed_to_exit():
		print('Attempted to go back to the island.')
		get_tree().change_scene("res://src/places/MainIsland.tscn")

func is_allowed_to_exit():
	return Constants.DEBUG_MODE or (game_progress_L != Globals.GameProgress.GAME_START)

func _process(delta):
	pass

func _on_Area2D_body_entered(body):
	if body.name == 'Rabbit' and !$HoverTalkTip.visible and is_allowed_to_exit():
		$HoverTalkTip.show()

func _on_Area2D_body_exited(body):
	if body.name == 'Rabbit' and $HoverTalkTip.visible:
		$HoverTalkTip.hide()