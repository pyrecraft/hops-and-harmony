extends Node2D

const waku_font = preload("res://fonts/WakuWakuFont.tres")

export var text_color = Color.white
export var shadow_color = Color('#393e46')

export var box_color = Color('#62d2a2')
var inside_box_color = Color(1, 1, 1, 0)

var font_position = Vector2(0, 0)
var box_position = Vector2(0, 0)
var box_dimensions = Vector2(0, 0)
var text_offset_x = 0
var text_offset_y = 5
var is_hover = false
var is_clicked = false
export var text = 'E'

# Animation
var scale_rate = .05
var current_scale = .9
var scale_polarity = 1 # +1 or -1

# Called when the node enters the scene tree for the first time.
func _ready():
	set_box_position(Vector2(0, -100))

func _process(delta):
	current_scale += scale_rate * delta * scale_polarity
	if current_scale < .95: # Fatter
		scale_polarity = 1
	elif current_scale > 1.05: # Thinner
		scale_polarity = -1
	update()

func set_text(t):
	text = t

func set_colors(regular):
	box_color = regular
	update()

func set_box_position(vec):
	box_position = vec
	box_dimensions = get_box_dimensions()
	font_position = get_starting_font_position()
	update()

func get_box_position():
	var font_border_offset = 0.075
	var viewport_size = get_viewport().size
	var border_offset_size = viewport_size * font_border_offset
	return Vector2(viewport_size.x - border_offset_size.x - box_dimensions.x, \
		viewport_size.y - border_offset_size.y - box_dimensions.y)

func get_box_dimensions():
	var box_height = 15
	var box_width = 15
	return Vector2(box_width, box_height)

func set_box_dimensions(h, w):
	box_dimensions = Vector2(h, w)
	font_position = get_starting_font_position()
	update()

func set_text_offset_x(val):
	text_offset_x = val
	font_position = get_starting_font_position()
	update()

func set_text_offset_y(val):
	text_offset_y = val
	font_position = get_starting_font_position()
	update()

func get_starting_font_position():
	return Vector2(box_position.x + text_offset_x, text_offset_y + box_position.y + (box_dimensions.y * (3.75/5.0)))

func _draw():
	var next_position_offset = box_position.y - (box_position.y * current_scale)
	var next_box_position = Vector2(box_position.x, box_position.y + next_position_offset)
	draw_rounded_rect(Rect2(next_box_position, box_dimensions), box_color, 15)
	
	var next_font_position = Vector2(font_position.x, font_position.y + next_position_offset)
#	draw_string(waku_font, Vector2(next_font_position.x * 1.002, next_font_position.y * 1.002), \
#		text, shadow_color)
	draw_string(waku_font, next_font_position, text, text_color)

func draw_rounded_rect(rect, color, circle_radius):
	draw_circle(rect.position, circle_radius, color)
	draw_circle(Vector2(rect.position.x, rect.position.y + rect.size.y), circle_radius, color)
	draw_circle(Vector2(rect.position.x + rect.size.x, rect.position.y), circle_radius, color)
	draw_circle(Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y), circle_radius, color)
	draw_rect(Rect2(Vector2(rect.position.x - circle_radius, rect.position.y), \
		Vector2(rect.size.x + (circle_radius * 2), rect.size.y)), color)
	draw_rect(Rect2(Vector2(rect.position.x, rect.position.y - circle_radius), \
		Vector2(rect.size.x, rect.size.y + (circle_radius * 2))), color)

func draw_rounded_outline_rect(rect, color, circle_radius):
	draw_circle(rect.position, circle_radius, color)
	draw_circle(Vector2(rect.position.x, rect.position.y + rect.size.y), circle_radius, color)
	draw_circle(Vector2(rect.position.x + rect.size.x, rect.position.y), circle_radius, color)
	draw_circle(Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y), circle_radius, color)
	draw_line(rect.position, Vector2(rect.position.x, rect.position.y + rect.size.y), color, circle_radius * 2)
	draw_line(Vector2(rect.position.x, rect.position.y + rect.size.y), \
		Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y), color, circle_radius * 2)
	draw_line(Vector2(rect.position.x + rect.size.x, rect.position.y), \
		Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y), color, circle_radius * 2)
	draw_line(rect.position, \
		Vector2(rect.position.x + rect.size.x, rect.position.y), color, circle_radius * 2)