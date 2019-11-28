extends Sprite

func _ready():
	set_background_neutral()

func is_success_or_failure():
	return $ColorRect.visible

func is_failure():
	return $ColorRect.modulate == Color("883932")

func get_num_text():
	return $RichTextLabel.text

func set_num_text(num):
	if num == 0:
		$RichTextLabel.text = ""
	else:
		$RichTextLabel.text = str(num)

func set_background_neutral():
	$ColorRect.modulate = Color("323c39")

func set_background_success():
	if !$ColorRect.visible:
		$ColorRect.modulate = Color("55a049")
		$ColorRect.visible = true

func set_background_failure():
#	print("Note failure decrement")
#	if store.get_state()['player'] and store.get_state()['player']['health']:
#		store.dispatch(action_creators.player_set_health(store.get_state()['player']['health'] - 1))
	if !$ColorRect.visible:
		$ColorRect.modulate = Color("883932")
		$ColorRect.visible = true