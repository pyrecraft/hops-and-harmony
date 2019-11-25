extends Node2D

onready var actions = get_node('/root/actions')
onready var reducers = get_node('/root/reducers')
onready var store = get_node('/root/store')

var start_on_home = false

func _ready():
	store.create([
		{'name': 'game', 'instance': reducers},
		{'name': 'dialogue', 'instance': reducers},
	], [
		{'name': '_on_store_changed', 'instance': self}
	])
	
	if start_on_home:
		$MainIsland.queue_free()
	else:
		$Home.queue_free()

func _on_store_changed(name, state):
#	print(state)
	pass