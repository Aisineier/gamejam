extends Control
## Small original ink illustrations for resources and action cards.

var kind := ""
var pigment := Color("#38584a")


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, size / Vector2(64, 64))
	match kind:
		"coin":
			draw_circle(Vector2(32, 32), 20, Color("#e0bc70"), true, -1.0, true)
			draw_arc(Vector2(32, 32), 20, 0.0, TAU, 40, pigment, 3, true)
			draw_rect(Rect2(26, 26, 12, 12), Color("#fcf3d8"))
		"labor":
			stroke(Vector2(43, 15), Vector2(21, 52), pigment, 6)
			draw_arc(Vector2(30, 20), 15, 3.1, 5.9, 22, Color("#a36b36"), 6, true)
		"trust":
			draw_colored_polygon(PackedVector2Array([Vector2(14, 43), Vector2(20, 23), Vector2(33, 14), Vector2(46, 23), Vector2(52, 43)]), pigment)
			draw_rect(Rect2(18, 43, 31, 7), Color("#ad7457"))
			draw_rect(Rect2(30, 31, 6, 13), Color("#f4e1a8"))
		"calendar":
			draw_rect(Rect2(15, 18, 34, 34), pigment)
			draw_rect(Rect2(19, 28, 26, 19), Color("#f1dfab"))
			for x in [25, 39]:
				stroke(Vector2(x, 13), Vector2(x, 23), Color("#a97053"), 4)
		"egg":
			draw_set_transform(Vector2(size.x * 0.5, size.y * 0.52), -0.20, size / Vector2(64, 64) * Vector2(0.83, 1.19))
			draw_circle(Vector2.ZERO, 20, Color("#d5ad72"), true, -1.0, true)
			draw_circle(Vector2.ZERO, 17, Color("#fff0cc"), true, -1.0, true)
		"potato":
			draw_set_transform(Vector2(size.x * 0.5, size.y * 0.52), 0.32, size / Vector2(64, 64) * Vector2(1.11, 0.84))
			draw_circle(Vector2.ZERO, 22, Color("#aa794b"), true, -1.0, true)
			draw_circle(Vector2(-3, -4), 17, Color("#d3a96b"), true, -1.0, true)
			for fleck in [Vector2(-9, -3), Vector2(9, -5), Vector2(6, 8), Vector2(-6, 11)]:
				draw_circle(fleck, 2.3, Color("#875d40"))
		"berry":
			draw_colored_polygon(PackedVector2Array([Vector2(13, 31), Vector2(22, 18), Vector2(39, 17), Vector2(52, 29), Vector2(45, 42), Vector2(32, 54), Vector2(19, 43)]), Color("#a95043"))
			draw_colored_polygon(PackedVector2Array([Vector2(16, 17), Vector2(29, 18), Vector2(33, 9), Vector2(38, 19), Vector2(51, 16), Vector2(42, 29), Vector2(31, 25), Vector2(23, 30)]), pigment)
			for fleck in [Vector2(23, 35), Vector2(33, 32), Vector2(40, 36), Vector2(32, 43)]:
				draw_circle(fleck, 1.8, Color("#edbd88"))
		"crate":
			draw_rect(Rect2(13, 22, 38, 27), Color("#b28356"))
			for y in [23, 34, 46]:
				stroke(Vector2(13, y), Vector2(51, y), Color("#80563a"), 3)
			stroke(Vector2(17, 21), Vector2(17, 50), Color("#6e593d"), 4)
			stroke(Vector2(47, 21), Vector2(47, 50), Color("#6e593d"), 4)
		_:
			stroke(Vector2(32, 51), Vector2(32, 19), pigment, 4)
			draw_colored_polygon(PackedVector2Array([Vector2(31, 38), Vector2(16, 33), Vector2(10, 19), Vector2(25, 21), Vector2(34, 30), Vector2(46, 17), Vector2(55, 15), Vector2(51, 32), Vector2(36, 43)]), pigment)
			stroke(Vector2(32, 39), Vector2(19, 26), Color("#97af72"), 2)
			stroke(Vector2(34, 36), Vector2(46, 24), Color("#97af72"), 2)
	draw_set_transform(Vector2.ZERO)


func stroke(from: Vector2, to: Vector2, color: Color, width: float) -> void:
	draw_line(from, to, color, width, true)
