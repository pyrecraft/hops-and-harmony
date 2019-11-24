extends Node2D

var wave_rate = 20.0
var wave_sprite_size_x = 3838

# Called when the node enters the scene tree for the first time.
func _ready():
	wave_sprite_size_x = $wave1.texture.get_size().x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var wave_movement_x = delta * wave_rate
	adjust_wave($wave1, wave_movement_x)
	adjust_wave($wave2, wave_movement_x)
	adjust_wave($wave3, wave_movement_x)
	adjust_wave($wave4, wave_movement_x)
	
func adjust_wave(wave, wave_movement_x):
	wave.position.x += wave_movement_x
	if wave.position.x >= wave_sprite_size_x * 3.0:
		wave.position.x -= (wave_sprite_size_x  * 4.0)