extends StaticBody2D

export var radius = 50
export var color = Color('#5f6769')

var current_pos = Vector2(0, 0)

# Animation
export var scale_rate = .5
export var position_multiplier = 50.0
var current_scale = 0.0
var scale_polarity = 1 # +1 or -1

# Called when the node enters the scene tree for the first time.
func _ready():
	current_pos = position

func _physics_process(delta):
	current_scale += scale_rate * delta * scale_polarity
	if current_scale < -1.0: # Fatter
		scale_polarity = 1
	elif current_scale > 1.0: # Thinner
		scale_polarity = -1
	
	position = Vector2(current_pos.x, current_pos.y + (current_scale * position_multiplier))
	update()

func _draw():
	draw_circle(Vector2(0, 0), $CollisionShape2D.shape.radius, color)