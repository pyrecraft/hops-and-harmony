extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$HoverTalkTip.set_box_position(Vector2(0, -100))
	$Area2D.connect("body_entered", self, "_on_Area2D_body_entered")
	$Area2D.connect("body_exited", self, "_on_Area2D_body_exited")
	$HoverTalkTip.hide()

func _input(event):
	if Input.is_key_pressed(KEY_E) and $HoverTalkTip.visible:
		print('Attempted to go back to the island.')
		get_tree().change_scene("res://src/places/MainIsland.tscn")

func _process(delta):
	pass

func _on_Area2D_body_entered(body):
	if body.name == 'Rabbit' and !$HoverTalkTip.visible:
		$HoverTalkTip.show()

func _on_Area2D_body_exited(body):
	if body.name == 'Rabbit' and $HoverTalkTip.visible:
		$HoverTalkTip.hide()