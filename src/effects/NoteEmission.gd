extends Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	scale.x = 0.25
	scale.y = 0.25

func set_color(hex_color):
	modulate = Color(hex_color)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	scale.x += delta
	scale.y += delta
	modulate.a -= delta
	if scale.x > 1.3 and scale.y > 1.3:
		self.queue_free()