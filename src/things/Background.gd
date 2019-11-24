extends Node2D

var land_start_pos = Vector2(150, 450)
var land_end_pos = Vector2(3900, 450)
#var colors_array = [Color('#3e64ff'), Color('#5edfff'), Color('#b2fcff')] # Blue Skies
#var colors_array = [Color('#e25822'), Color('#b22222'), Color('#ecfcff'), Color('#ecfcff')] # Sunset
#var colors_array = [Color('#07689f'), Color('#07689f'), Color('#a1eafb'), Color(94.0/255.0, 223.0/255.0, 1.0, 255.0/255.0)] # Blue / White Skies
var colors_array = [Color('384259'), Color('004a7c'), Color('3490de'), Color('a1eafb'), \
	Color('55e9bc'), Color('55e9bc')] # Stardew Valley
var home_colors_array = [Color('bd574e'), Color('f9b282'), Color('de6b35'), Color('8f4426'), \
	Color('bd574e'), Color('f9b282'), Color('de6b35'), Color('8f4426')]
var color_gradient = Gradient.new()
var is_home = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_gradient()

func _draw():
	draw_background()

func set_is_home(home):
	is_home = home
	set_gradient()
	update()

func set_gradient():
	var idx = 0.0
	var step = 1.0 / (len(colors_array) - 1)
	var colors = colors_array if !is_home else home_colors_array
	if is_home:
		color_gradient = Gradient.new()
	for color in colors:
		color_gradient.add_point(idx, color)
		idx = min(idx + step, .999) # setting a color at point 1.0 failed to add it correctly to the end of the gradient

func draw_background():
	var sky_box_count = 350
	var width = 8000
	var starting_pos = Vector2(-1000, -500)
	var ending_pos = Vector2(8000, 1200)
	var height_diff = (ending_pos.y - starting_pos.y) / sky_box_count
	var color_diff = 1.0 / sky_box_count
	var current_pos = starting_pos
	for i in range(0, sky_box_count):
		draw_rect(Rect2(current_pos, Vector2(width, height_diff)), color_gradient.interpolate(color_diff * i))
		current_pos.y += height_diff