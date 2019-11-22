extends Node2D

const cloud = preload("res://src/things/Cloud.tscn")

const land_color = Color('#f9d5bb')
const hill_color = Color('#5f6769')

var land_start_pos = Vector2(150, 450)
var land_end_pos = Vector2(3900, 450)
var cloud_spawn_location = Vector2(-1000, 50)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _draw():
#	draw_background()
	draw_land()
	draw_hills()

func draw_hills():
	draw_circle(Vector2(1246, 454), 115, hill_color)
	draw_circle(Vector2(1802, 450), 95, hill_color)
	draw_circle(Vector2(2768, 461), 155, hill_color)

func draw_land():
	draw_circle(Vector2(land_start_pos.x, land_start_pos.y + 50), 50, land_color)
	draw_circle(Vector2(land_end_pos.x, land_end_pos.y + 50), 50, land_color)
	draw_circle(Vector2(land_start_pos.x, land_start_pos.y + 150), 150, land_color)
	draw_circle(Vector2(land_end_pos.x, land_end_pos.y + 150), 150, land_color)
	draw_rect(Rect2(land_start_pos, Vector2(land_end_pos.x - land_start_pos.x, 300)), land_color)

func _on_CloudTimer_timeout():
	var next_cloud_spawn_location = Vector2(cloud_spawn_location.x, cloud_spawn_location.y + randi() % 30)
	var cloud_inst = cloud.instance()
	cloud_inst.set_position(next_cloud_spawn_location)
	add_child(cloud_inst)
	$CloudTimer.wait_time = 35
