extends Node2D

signal text_complete

export var outline_color = Color.black

export var font_height = 26
export var font_width = 16
export var full_text = ''

var current_text = ''
var left_right_offset = 0 # translate into box margin top/bottom changes
var top_down_offset = 0 # translate into box margin left/right changes

# Called when the node enters the scene tree for the first time.
func _ready():
	$RichTextLabel.bbcode_text = ''
	full_text = ''
	update_dialogue_box('', font_height, font_width)
	$RichTextLabel.visible_characters = 0

func _input(event):
	if Input.is_key_pressed(KEY_E) and !is_empty():
#		if $RichTextLabel.visible_characters >= full_text.length():
#			emit_signal("text_complete")
#			$TextTimer.stop()
#			$TTLTimer.stop()
#		else:
#			$RichTextLabel.visible_characters = full_text.length()
		$RichTextLabel.visible_characters = full_text.length()

func is_empty():
	return full_text == '' or full_text == null or full_text.length() == 0

func get_text():
	return full_text

func clear_text():
	full_text = ''
	update_dialogue_box('', font_height, font_width)
	$RichTextLabel.visible_characters = 0

func update_dialogue_box(text, font_height, font_width):
	var box_dimens = get_dialogue_box_dimensions(text, font_height, font_width)
	left_right_offset = box_dimens.x / 2.0
	top_down_offset = box_dimens.y / 2.0
	
	$RichTextLabel.margin_top = -top_down_offset * 2.0
	$RichTextLabel.margin_bottom = 0
	$RichTextLabel.margin_left = -left_right_offset
	$RichTextLabel.margin_right = left_right_offset

func set_text(text):
	full_text = text
	update_dialogue_box(text, font_height, font_width)
	$RichTextLabel.bbcode_text = text
	$RichTextLabel.visible_characters = 0
	$TextTimer.start()

func queue_clear_text():
	$ClearTextTimer.start()

func _draw():
	pass
#	draw_rect(Rect2(Vector2(-left_right_offset, -top_down_offset * 2.0), \
#		Vector2(left_right_offset * 2.0, top_down_offset * 2.0)), Color.blue)

func get_dialogue_box_dimensions(text, f_height, f_width):
	if text == null or text.length() == 0:
		return Vector2(0, 0)
	var split_text_array = text.split(' ')
	var nums_array = convert_string_list_to_int(split_text_array)
	var max_num = get_max_num(nums_array)
	var num_sum = get_num_sum(nums_array)
	
	return get_most_squared_dimensions(split_text_array, nums_array, num_sum, max_num, f_height, f_width)

func get_most_squared_dimensions(text_array, nums_array, num_sum, max_num, f_height, f_width):
#	var half_split_dimensions = get_squared_vector(5.0, nums_array, num_sum, max_num, f_height, f_width)
#	var half_split_squaredness = abs(1.0 - (half_split_dimensions.y / half_split_dimensions.x))
	var more_than_half_split_dimensions = get_squared_vector(10.0, text_array, nums_array, num_sum, max_num, f_height, f_width)
	var more_than_half_split_squaredness = abs(1.0 - (more_than_half_split_dimensions.y / more_than_half_split_dimensions.x))
#	var even_more_than_half_split_dimensions = get_squared_vector(15.0, nums_array, num_sum, max_num, f_height, f_width)
#	var even_more_than_half_split_squaredness = abs(1.0 - (even_more_than_half_split_dimensions.y / even_more_than_half_split_dimensions.x))
	return more_than_half_split_dimensions
#	if  half_split_squaredness < more_than_half_split_squaredness and half_split_squaredness < even_more_than_half_split_squaredness:
#		return half_split_dimensions
#	elif more_than_half_split_squaredness < half_split_squaredness and \
#		more_than_half_split_squaredness < even_more_than_half_split_squaredness:
#		return more_than_half_split_dimensions
#	else:
#		return even_more_than_half_split_dimensions

func get_squared_vector(multiplier, words, nums, sum, max_num, f_height, f_width):
	var width = max(sqrt(sum) * multiplier, max_num)
	var line_count = 1
	var current_line_width_remaining = width
	var num_index = 0
	var current_num = nums[num_index]
	var max_line_width = 0
	while num_index < nums.size():
		if current_line_width_remaining - current_num >= 0:
			current_line_width_remaining -= current_num
			num_index += 1
			if width - current_line_width_remaining > max_line_width:
				max_line_width = width - current_line_width_remaining
			if num_index == nums.size():
				break
			current_num = nums[num_index]
		elif current_line_width_remaining - current_num < 0:
			if width - current_line_width_remaining > max_line_width:
				max_line_width = width - current_line_width_remaining
			current_line_width_remaining = width
			line_count += 1
	var height = line_count * f_height
	return Vector2(max_line_width, height)

func convert_string_list_to_int(str_array):
	var nums = []
	for i in range(0, str_array.size()):
		var current_str = str_array[i]
		nums.push_back((current_str.length() * font_width) + font_width) # to account for the space ' '
	nums[nums.size() - 1] = nums[nums.size() - 1] - font_width # remove space on last word in text
	return nums

func get_num_sum(nums):
	var total = 0
	for i in range(0, nums.size()):
		total += nums[i]
	return total

func get_max_num(nums):
	var max_size = 0
	if nums.size() == 0:
		return max_size
	for i in range(0, nums.size()):
		if nums[i] > max_size:
			max_size = nums[i]
	return max_size

func _on_TextTimer_timeout():
	$RichTextLabel.visible_characters += 1
	if $RichTextLabel.visible_characters >= full_text.length():
		$TextTimer.stop()
		$TTLTimer.start()
	else:
		update()
		$TextTimer.start()
#		update_dialogue_box(full_text.substr(0, $RichTextLabel.visible_characters), \
#			font_height, font_width)

func _on_TTLTimer_timeout():
	emit_signal("text_complete")

func _on_ClearTextTimer_timeout():
	full_text = ''
	update_dialogue_box('', font_height, font_width)
	$RichTextLabel.visible_characters = 0