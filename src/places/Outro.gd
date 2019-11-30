extends Node2D

var viewport_size

var default_margin_left
var default_margin_right
var default_margin_top
var default_margin_bottom


# Called when the node enters the scene tree for the first time.
func _ready():
	default_margin_left = $RichTextLabel.margin_left
	default_margin_right = $RichTextLabel.margin_right
	default_margin_top = $RichTextLabel.margin_top
	default_margin_bottom = $RichTextLabel.margin_bottom
	viewport_size = get_viewport().size
	$RichTextLabel.margin_right = default_margin_right + (viewport_size.x / 2.0)
	$RichTextLabel.margin_left = default_margin_left + (viewport_size.x / 2.0)
	$RichTextLabel.margin_top = default_margin_top + (viewport_size.y / 2.0)
	$RichTextLabel.margin_bottom = default_margin_bottom + (viewport_size.y / 2.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_viewport().size.x != viewport_size.x or get_viewport().size.y != viewport_size.y:
		viewport_size = get_viewport().size
		$RichTextLabel.margin_right = default_margin_right + (viewport_size.x / 2.0)
		$RichTextLabel.margin_left = default_margin_left + (viewport_size.x / 2.0)
		$RichTextLabel.margin_top = default_margin_top + (viewport_size.y / 2.0)
		$RichTextLabel.margin_bottom = default_margin_bottom + (viewport_size.y / 2.0)
		update()

func _draw():
	draw_rect(Rect2(Vector2(0, 0), viewport_size), Color('393e46'))