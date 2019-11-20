extends Node2D

onready var actions = get_node('/root/actions')
onready var reducers = get_node('/root/reducers')
onready var store = get_node('/root/store')

func _ready():
	store.create([
		{'name': 'game', 'instance': reducers},
		{'name': 'canvas', 'instance': reducers},
		{'name': 'paint', 'instance': reducers}
	], [
		{'name': '_on_store_changed', 'instance': self}
	])

func _on_store_changed(name, state):
	print(state)
	pass