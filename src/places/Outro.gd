extends Node2D

var viewport_size

var default_margin_left
var default_margin_right
var default_margin_top
var default_margin_bottom


# Called when the node enters the scene tree for the first time.
func _ready():
	default_margin_left = $CreatedByLabel.margin_left
	default_margin_right = $CreatedByLabel.margin_right
	default_margin_top = $CreatedByLabel.margin_top
	default_margin_bottom = $CreatedByLabel.margin_bottom
	viewport_size = get_viewport().size
	adjust_label($CreatedByLabel)
	adjust_label($GithubLabel)
	adjust_label($SocialsLabel)
	adjust_label($ThanksLabel)

func adjust_label(label):
	label.margin_right = default_margin_right + (viewport_size.x / 2.0)
	label.margin_left = default_margin_left + (viewport_size.x / 2.0)
	label.margin_top = default_margin_top + (viewport_size.y / 2.0)
	label.margin_bottom = default_margin_bottom + (viewport_size.y / 2.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_viewport().size.x != viewport_size.x or get_viewport().size.y != viewport_size.y:
		viewport_size = get_viewport().size
		adjust_label($CreatedByLabel)
		adjust_label($GithubLabel)
		adjust_label($SocialsLabel)
		adjust_label($ThanksLabel)
		update()

func _draw():
	draw_rect(Rect2(Vector2(0, 0), viewport_size), Color('393e46'))

func _on_Timer_timeout():
	if $CreatedByLabel.visible:
		$Timer.start()
		$CreatedByLabel.hide()
		$GithubLabel.show()
	elif $GithubLabel.visible:
		$Timer.start()
		$GithubLabel.hide()
		$SocialsLabel.show()
	elif $SocialsLabel.visible:
		$SocialsLabel.hide()
		$ThanksLabel.show()
