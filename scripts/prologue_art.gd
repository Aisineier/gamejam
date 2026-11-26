extends Control
## Full-screen ink illustrations for the title and the three scenes.

var chapter := -1


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, size / Vector2(1440, 900))
	match chapter:
		-1: valley()
		0: unfinished_station()
		1: granary()
		2: ledger()
		3: station_square()
		4: village_at_night()
		5: pond()
	grain()
	draw_set_transform(Vector2.ZERO)


func silhouette(coords: Array, pigment: String) -> void:
	var points := PackedVector2Array()
	for i in range(0, coords.size(), 2):
		points.append(Vector2(coords[i], coords[i + 1]))
	draw_colored_polygon(points, Color(pigment))


func brush(x: float, y: float, to_x: float, to_y: float, pigment: String, width: float = 1.0) -> void:
	draw_line(Vector2(x, y), Vector2(to_x, to_y), Color(pigment), width, true)


func disc(x: float, y: float, radius: float, pigment: String) -> void:
	draw_circle(Vector2(x, y), radius, Color(pigment), true, -1.0, true)


func block(x: float, y: float, width: float, height: float, pigment: String) -> void:
	draw_rect(Rect2(x, y, width, height), Color(pigment))


func dawn_sky() -> void:
	for y in range(0, 900, 3):
		var color := Color("#ddd9ba").lerp(Color("#f3ddaf"), y / 900.0)
		draw_rect(Rect2(0, y, 1440, 3), color)
	disc(1067, 243, 77, "#cb81636c")
	disc(1067, 243, 67, "#b45941")
	for strip in 12:
		var x := float(108 + strip * 109 % 1160)
		var y := float(291 + strip * 31 % 196)
		brush(x, y, x + 63 + strip * 5, y, "#fff1d49a", 2)


func valley() -> void:
	dawn_sky()
	silhouette([0, 379, 135, 263, 189, 233, 253, 307, 390, 367, 488, 328, 609, 226, 711, 282, 804, 374, 932, 408, 1057, 349, 1216, 248, 1440, 373, 1440, 900, 0, 900], "#9ba993")
	silhouette([0, 500, 97, 403, 210, 338, 294, 380, 393, 420, 504, 433, 679, 483, 847, 470, 1001, 447, 1138, 384, 1266, 301, 1338, 336, 1440, 439, 1440, 900, 0, 900], "#627c67")
	silhouette([0, 501, 233, 490, 497, 512, 670, 498, 754, 469, 848, 477, 911, 503, 1089, 550, 1440, 567, 1440, 900, 0, 900], "#aea481")
	silhouette([0, 598, 227, 559, 397, 541, 661, 527, 752, 487, 814, 485, 859, 492, 773, 532, 589, 574, 457, 617, 357, 697, 323, 900, 0, 900], "#8ea69f")
	for ripple in 28:
		var x := float(11 + ripple * 62 % 780)
		var y := 510.0 + ripple * 9.0
		brush(x, y, x + 35 + ripple * 3 % 81, y, "#e9e1bd73", 2)
	house(905, 473, 1.0, "#e8d6a6", "#344b3f")
	house(1056, 486, 0.83, "#cfb293", "#5f5543")
	house(1285, 511, 0.64, "#dcc99b", "#614f3e")
	pine(83, 552, 1.1)
	pine(171, 526, 0.78)
	pine(1333, 553, 1.4)
	for straw in 90:
		var x := float(62 + straw * 71 % 1360)
		var y := float(580 + straw * 38 % 312)
		brush(x, y, x - 5, y - 12, "#e6d4a474", 2)


func unfinished_station() -> void:
	for y in range(0, 900, 3):
		var color := Color("#253c40").lerp(Color("#62847c"), y / 900.0)
		draw_rect(Rect2(0, y, 1440, 3), color)
	disc(1034, 142, 53, "#e0d5aa65")
	disc(1034, 142, 38, "#d6c9a7b8")
	silhouette([0, 322, 218, 243, 333, 285, 418, 232, 600, 314, 697, 289, 818, 315, 995, 251, 1091, 284, 1272, 230, 1440, 307, 1440, 900, 0, 900], "#516b62")
	silhouette([0, 415, 271, 389, 401, 408, 571, 384, 732, 440, 916, 407, 1086, 425, 1440, 407, 1440, 900, 0, 900], "#809993")
	for ripple in 58:
		var y := float(422 + ripple * 49 % 470)
		var x := float(4 + ripple * 117 % 1290)
		brush(x, y, x + 36 + ripple * 21 % 92, y, "#dee4cb61", 1.5)
	silhouette([0, 471, 192, 466, 369, 503, 514, 552, 607, 628, 673, 741, 744, 900, 0, 900], "#354e46")
	silhouette([1440, 507, 1232, 484, 1065, 484, 937, 526, 857, 611, 886, 705, 779, 900, 1440, 900], "#384d40")
	house(1111, 405, 1.0, "#a8a491", "#374943")
	house(1270, 434, 0.66, "#9f9d8a", "#303d37")
	pine(1372, 528, 1.15)
	pine(112, 500, 1.0)
	silhouette([134, 612, 293, 545, 763, 545, 952, 612, 891, 649, 196, 649], "#a09679")
	block(250, 306, 552, 252, "#c0b79a")
	block(235, 292, 582, 30, "#6b6a52")
	block(253, 328, 550, 13, "#aea384")
	for bay in 3:
		var x := float(292 + bay * 163)
		block(x, 370, 120, 188, "#4c5a4e")
		block(x + 8, 381, 104, 11, "#69786b")
	brush(267, 336, 283, 386, "#6c6851", 2)
	brush(281, 384, 275, 403, "#6c6851", 2)
	brush(371, 535, 515, 481, "#988163", 10)
	brush(540, 532, 710, 492, "#988163", 10)
	embankment(Vector2(142, 614), Vector2(817, 614))
	pine(91, 585, 1.2)


func embankment(from: Vector2, to: Vector2) -> void:
	draw_line(from + Vector2(0, 19), to + Vector2(0, 19), Color("#273c33"), 33, true)
	draw_line(from, to, Color("#aa9d7f"), 13, true)
	for stone in 14:
		var at := from.lerp(to, stone / 14.0)
		brush(at.x, at.y - 3, at.x + 12, at.y + 17, "#514f40", 4)


func station_square() -> void:
	valley()
	silhouette([0, 697, 402, 540, 1440, 528, 1440, 900, 0, 900], "#aa9d80")
	brush(0, 732, 1440, 571, "#d3c7a3", 4.0)
	house(570, 390, 2.8, "#e1cf9f", "#3d5347")
	block(521, 530, 418, 15, "#b58b66")
	block(945, 429, 10, 134, "#584935")
	block(923, 421, 58, 27, "#a64b39")
	for stall in 3:
		var x := float(1081 + stall * 96)
		block(x, 533, 56, 22, "#6a5740")
		silhouette([x - 9, 516, x + 12, 486, x + 48, 486, x + 66, 516], "#a95e49")


func village_at_night() -> void:
	valley()
	block(0, 0, 1440, 900, "#243955a4")
	disc(1067, 243, 68, "#f3df9e")
	for star in 38:
		disc(float(18 + star * 173 % 1380), float(38 + star * 101 % 248), 1.0 + star % 2, "#eee3b5")
	for lamp in 4:
		var x := float(540 + lamp * 135)
		var y := float(510 + lamp * 18)
		brush(x, y, x, y - 84, "#393e32", 6)
		disc(x + 8, y - 83, 24, "#ecc47b70")
		disc(x + 8, y - 83, 9, "#f4cc81")


func pond() -> void:
	valley()
	silhouette([0, 531, 225, 481, 442, 473, 591, 495, 811, 493, 991, 531, 1182, 558, 1294, 679, 1113, 900, 0, 900], "#7d9a90")
	for ripple in 52:
		var x := float(6 + ripple * 109 % 1060)
		var y := float(531 + ripple * 13 % 320)
		brush(x, y, x + 29 + ripple % 7 * 9, y, "#eae6bb7a", 2.5)
	pine(1151, 568, 1.34)
	pine(1263, 575, 1.18)
	for reed in 38:
		var x := float(19 + reed * 37 % 1267)
		brush(x, 540 + reed % 5 * 4, x - 7, 519 + reed % 7 * 3, "#576b49", 2)


func granary() -> void:
	block(0, 0, 1440, 900, "#453f34")
	block(86, 0, 1268, 677, "#6b5841")
	block(98, 111, 1245, 522, "#847056")
	for glow in range(32, 0, -1):
		disc(870, 254, glow * 11.5, "#edd0a005")
	for plank in 14:
		var x := float(125 + plank * 91)
		brush(x, 114, x - 23, 634, "#6a5b48", 3)
	block(0, 632, 1440, 268, "#584d3e")
	for board in 12:
		brush(621 + board * 25, 634, board * 140 - 65, 900, "#3f3c32", 3)
	block(0, 82, 1440, 39, "#352f27")
	block(109, 0, 27, 658, "#4f4030")
	block(1289, 0, 28, 658, "#4c4032")
	block(206, 231, 302, 28, "#4c3e30")
	block(206, 403, 302, 28, "#4c3e30")
	jar(280, 204, 36, 54, "#ab875e")
	jar(370, 203, 50, 57, "#9a7353")
	jar(451, 205, 33, 50, "#b69a6c")
	jar(299, 359, 47, 76, "#857052")
	jar(409, 358, 45, 78, "#a78058")
	brush(869, 108, 869, 217, "#372e26", 4)
	disc(871, 245, 47, "#f6ca6e74")
	block(843, 214, 56, 67, "#e7b867")
	block(840, 209, 62, 7, "#523c2c")
	block(840, 281, 62, 7, "#523c2c")
	for reed in 4:
		block(851 + reed * 11, 216, 2, 65, "#a26b45")
	jar(992, 520, 83, 139, "#b09868")
	jar(1147, 561, 90, 140, "#9c825a")
	jar(609, 573, 73, 123, "#917650")
	for cloth in 3:
		var x := 888.0 + cloth * 71
		silhouette([x, 615, x + 22, 560, x + 19, 526, x + 58, 520, x + 55, 563, x + 75, 617, x + 50, 644, x + 16, 639], "#cbb480")
		brush(x + 20, 540, x + 58, 537, "#7b6348", 4)


func ledger() -> void:
	dawn_sky()
	silhouette([0, 470, 153, 350, 274, 402, 418, 382, 544, 462, 823, 488, 1000, 411, 1171, 333, 1440, 448, 1440, 900, 0, 900], "#9ba993")
	silhouette([0, 545, 289, 519, 547, 547, 777, 523, 995, 503, 1117, 463, 1440, 533, 1440, 900, 0, 900], "#77896d")
	house(1033, 444, 0.66, "#dcc89c", "#546352")
	pine(1218, 526, 0.96)
	block(0, 0, 1440, 75, "#4f4939")
	for beam_x in [58, 287, 1147, 1370]:
		block(beam_x, 57, 20, 544, "#564b37")
	block(0, 557, 1440, 23, "#504535")
	silhouette([0, 685, 338, 559, 1117, 559, 1440, 669, 1440, 900, 0, 900], "#8c7453")
	for plank in 15:
		var y := 563.0 + plank * 23
		brush(0, y + 39, 1440, y, "#c5ad8155", 2)
	silhouette([523, 579, 696, 562, 722, 582, 872, 560, 948, 676, 737, 705, 486, 683], "#574a37")
	silhouette([530, 571, 696, 550, 722, 573, 729, 691, 492, 675], "#e5d3a7")
	silhouette([722, 573, 859, 546, 934, 665, 729, 691], "#f6e4b5")
	brush(721, 574, 729, 690, "#9d8963", 2.5)
	for rule in 7:
		var y := 587.0 + rule * 12
		brush(539 - rule * 4, y, 689, y - 13, "#b3a074", 1.5)
		brush(747, y - 7, 872 + rule * 6, y - 24, "#b3a074", 1.5)
	for mark in 8:
		var x := float(552 + mark * 19)
		brush(x, 589 + mark % 3 * 12, x - 3, 611 + mark % 3 * 12, "#63563f", 3)
	block(838, 623, 24, 24, "#a75340")
	brush(1026, 620, 1172, 553, "#443b2c", 9)
	brush(1010, 628, 1030, 618, "#212e27", 11)
	silhouette([985, 584, 1034, 559, 1082, 569, 1039, 597], "#384138")


func jar(x: float, y: float, half_width: float, height: float, pigment: String) -> void:
	var w := half_width
	var h := height * 0.5
	silhouette([x - w * 0.61, y - h, x + w * 0.54, y - h, x + w * 0.83, y - h * 0.51, x + w, y + h * 0.15, x + w * 0.71, y + h, x - w * 0.67, y + h, x - w, y + h * 0.15, x - w * 0.89, y - h * 0.53], pigment)
	brush(x - w * 0.71, y - h, x + w * 0.65, y - h, "#453d2f", 5)
	brush(x - w * 0.73, y + 6, x - w * 0.43, y + h * 0.57, "#efdaab52", 4)


func house(x: float, y: float, s: float, wall: String, roof: String) -> void:
	block(x, y, 112 * s, 66 * s, wall)
	block(x + 17 * s, y + 24 * s, 24 * s, 42 * s, "#65523a")
	block(x + 76 * s, y + 18 * s, 16 * s, 18 * s, "#745d40")
	silhouette([x - 22 * s, y + 7 * s, x + 12 * s, y - 12 * s, x + 52 * s, y - 51 * s, x + 82 * s, y - 31 * s, x + 104 * s, y - 14 * s, x + 137 * s, y + 4 * s, x + 119 * s, y + 10 * s, x - 6 * s, y + 12 * s], roof)
	for tile in 6:
		brush(x + 49 * s, y - 43 * s, x + (4 + tile * 19) * s, y + 8 * s, "#cab99169", 1.3)


func pine(x: float, y: float, s: float) -> void:
	brush(x, y, x - 8 * s, y - 108 * s, "#484538", 8 * s)
	for bough in 4:
		var at := y - (36 + bough * 20) * s
		var width := (62 - 8 * bough) * s
		silhouette([x - width, at, x - width * 0.57, at - 12 * s, x - 3 * s, at - 20 * s, x + width * 0.53, at - 12 * s, x + width, at + 4 * s, x + width * 0.4, at + 10 * s, x - width * 0.37, at + 8 * s], "#314b42" if bough % 2 == 0 else "#476350")


func grain() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 93
	for fleck in 2600:
		var x := rng.randf_range(1, 1436)
		var y := rng.randf_range(1, 899)
		brush(x, y, x + rng.randf_range(1, 4), y + 0.4, "#221f191a" if fleck % 2 == 0 else "#f6e5b620")
