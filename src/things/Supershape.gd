extends Node2D

export var supershape_color := Color.white
export var supershape_scale = 10.0

export var supershape_np = 16
export var m := 5.0
export var n1 := 0.2
export var n2 := 1.7
export var n3 := 1.7

var supershape_points = PoolVector2Array()

# Called when the node enters the scene tree for the first time.
func _ready():
	fill_supershape_points()

func _draw():
	draw_colored_polygon(supershape_points, supershape_color)

func fill_supershape_points():
	for i in range(0, supershape_np + 1):
		var phi = i * (PI * 2) / supershape_np
		supershape_points.push_back(get_supershape_point(m,n1,n2,n3,phi) * supershape_scale)

func get_supershape_point(m, n1, n2, n3, phi):
	var vec = Vector2(0, 0)
	var r
	var t1
	var t2
	var a = 1
	var b = 1

	t1 = cos(m * phi / 4) / a
	t1 = abs(t1)
	t1 = pow(t1,n2)

	t2 = sin(m * phi / 4) / b
	t2 = abs(t2)
	t2 = pow(t2,n3)

	r = pow(t1+t2,1/n1)
	if abs(r) == 0:
		return vec
	else:
		r = 1 / r
		vec.x = r * cos(phi)
		vec.y = r * sin(phi)
		return vec