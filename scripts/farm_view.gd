extends Control
## Draw the valley at a fixed composition, using the live crops and buildings.

const Village := preload("res://scripts/village.gd")
var village


func polygon(points: Array, color: String) -> void:
	draw_colored_polygon(PackedVector2Array(points), Color(color))


func line(from: Vector2, to: Vector2, color: String, width: float) -> void:
	draw_line(from, to, Color(color), width, true)


func disc(at: Vector2, radius: float, color: String) -> void:
	draw_circle(at, radius, Color(color), true, -1.0, true)


func house(x: float, y: float, scale_factor: float, wall: String, roof: String) -> void:
	var origin := Vector2(x, y)
	draw_set_transform(origin, 0, Vector2.ONE * scale_factor)
	polygon([Vector2(-12, 34), Vector2(78, 31), Vector2(105, 41), Vector2(11, 46)], "#39473845")
	polygon([Vector2(0, 0), Vector2(71, 0), Vector2(71, 34), Vector2(0, 34)], wall)
	polygon([Vector2(71, 0), Vector2(93, -10), Vector2(93, 24), Vector2(71, 34)], "#ab9c80")
	polygon([Vector2(32, -28), Vector2(52, -23), Vector2(68, -15), Vector2(101, -10), Vector2(88, -2), Vector2(75, 2)], "#4d5a4f")
	polygon([Vector2(-14, -2), Vector2(1, -5), Vector2(16, -14), Vector2(32, -28), Vector2(46, -17), Vector2(65, -7), Vector2(82, -3), Vector2(77, 4), Vector2(-7, 4)], roof)
	line(Vector2(-11, 3), Vector2(78, 3), "#273932", 2)
	for tile in 6:
		var step := float(tile)
		line(Vector2(27 + step * 2, -21), Vector2(11 + step * 9, 0), "#d7c9a445", 1)
	draw_rect(Rect2(13, 13, 15, 21), Color("#735543"))
	draw_rect(Rect2(49, 11, 12, 11), Color("#4b5547"))
	line(Vector2(55, 11), Vector2(55, 22), "#baaa84", 1)
	line(Vector2(0, 34), Vector2(70, 34), "#7a705a", 1)
	draw_set_transform(Vector2.ZERO)


func tree(at: Vector2, scale_factor: float) -> void:
	draw_set_transform(at, 0, Vector2.ONE * scale_factor)
	line(Vector2(4, 25), Vector2(-4, -17), "#484434", 4)
	line(Vector2(0, 6), Vector2(-19, -4), "#484434", 2.5)
	line(Vector2(1, 10), Vector2(21, 2), "#484434", 2.5)
	for tier in 3:
		var spread := float(15 + tier * 5)
		var y := float(-20 + tier * 10)
		polygon([Vector2(-spread, y + 6), Vector2(-spread * 0.6, y - 2), Vector2(-1, y - 7), Vector2(spread * 0.58, y - 4), Vector2(spread, y + 5), Vector2(spread * 0.2, y + 7)], "#405848" if tier < 2 else "#334a40")
		line(Vector2(-spread * 0.7, y + 2), Vector2(spread * 0.5, y), "#73856670", 1.5)
	draw_set_transform(Vector2.ZERO)


func chicken(at: Vector2, color: String) -> void:
	line(at + Vector2(-3, 4), at + Vector2(-3, 9), "#835c37", 1.5)
	line(at + Vector2(3, 4), at + Vector2(3, 9), "#835c37", 1.5)
	disc(at, 7, color)
	disc(at + Vector2(6, -5), 4, color)
	disc(at + Vector2(6, -9), 2, "#ae5849")
	disc(at + Vector2(7, -6), 1, "#47332f")
	polygon([at + Vector2(9, -6), at + Vector2(13, -4), at + Vector2(9, -3)], "#d9a254")


func stalk(at: Vector2, ripe: bool, height: float) -> void:
	var crown := at + Vector2(1, -height)
	var color := "#e8bb5b" if ripe else "#b0c18a"
	line(at, crown, color, 1.5)
	line(at + Vector2(0, -5), at + Vector2(-4, -9), color, 1.5)
	line(at + Vector2(0, -8), at + Vector2(5, -13), color, 1.5)
	if ripe:
		draw_ellipse_grain(crown)


func draw_ellipse_grain(at: Vector2) -> void:
	disc(at, 2.0, "#f1d396")
	disc(at + Vector2(-2, 3), 1.5, "#e8bf70")
	disc(at + Vector2(2, 5), 1.5, "#e8bf70")


func ridge(points: Array, floor_y: float, pigment: String, engraving: String, seed_value: int) -> void:
	var contour := Curve2D.new()
	for i in points.size():
		var before: Vector2 = points[maxi(0, i - 1)]
		var after: Vector2 = points[mini(points.size() - 1, i + 1)]
		var tangent := (after - before) * 0.16
		contour.add_point(points[i], -tangent, tangent)
	var edge := contour.get_baked_points()
	var silhouette := edge.duplicate()
	silhouette.append(Vector2(edge[-1].x, floor_y))
	silhouette.append(Vector2(edge[0].x, floor_y))
	draw_colored_polygon(silhouette, Color(pigment))
	var grain := RandomNumberGenerator.new()
	grain.seed = seed_value
	for index in range(2, edge.size() - 2, 2):
		var top := edge[index]
		var spread := minf(floor_y - top.y, 50.0)
		if spread > 6:
			var start := top + Vector2(0, grain.randf_range(3, spread - 2))
			var finish := start + Vector2(grain.randf_range(-9, 13), minf(grain.randf_range(2, 17), floor_y - start.y))
			line(start, finish, engraving, grain.randf_range(0.5, 2.0))


func ink_grain() -> void:
	var flecks := RandomNumberGenerator.new()
	flecks.seed = 690
	for index in 1100:
		var x := flecks.randf_range(1, 899)
		var y := flecks.randf_range(1, 343)
		var color := "#fcf1d52a" if index % 3 == 0 else "#463f3415"
		line(Vector2(x, y), Vector2(x + flecks.randf_range(0.5, 3.3), y + 0.2), color, 0.8)


func _draw() -> void:
	if village == null:
		return
	draw_rect(Rect2(0, 0, 904, 344), Color("#eee2c7" if village.drought_until >= village.day else "#f1e7d0"))
	disc(Vector2(686, 57), 33, "#b6604799")
	disc(Vector2(686, 57), 29, "#b6533a")
	ridge([Vector2(0, 125), Vector2(65, 102), Vector2(128, 113), Vector2(235, 110), Vector2(328, 69), Vector2(371, 47), Vector2(406, 88), Vector2(465, 116), Vector2(512, 118), Vector2(590, 83), Vector2(622, 99), Vector2(704, 130), Vector2(810, 100), Vector2(904, 109)], 163, "#a5ad958c", "#535e4b25", 16)
	ridge([Vector2(0, 99), Vector2(47, 69), Vector2(82, 39), Vector2(104, 27), Vector2(119, 43), Vector2(156, 78), Vector2(201, 99), Vector2(239, 117), Vector2(317, 149), Vector2(394, 154)], 182, "#738975e8", "#4558495a", 92)
	ridge([Vector2(521, 177), Vector2(607, 156), Vector2(680, 143), Vector2(742, 124), Vector2(792, 84), Vector2(836, 63), Vector2(865, 87), Vector2(904, 97)], 202, "#567362d9", "#334b4270", 59)
	ridge([Vector2(0, 120), Vector2(44, 106), Vector2(112, 126), Vector2(147, 122), Vector2(213, 145), Vector2(286, 179), Vector2(333, 195)], 237, "#4a6653", "#344c3b95", 36)
	polygon([Vector2(0, 200), Vector2(138, 165), Vector2(258, 163), Vector2(389, 147), Vector2(469, 151), Vector2(546, 176), Vector2(634, 179), Vector2(904, 157), Vector2(904, 344), Vector2(0, 344)], "#bbb791")
	polygon([Vector2(279, 176), Vector2(360, 159), Vector2(389, 149), Vector2(462, 149), Vector2(479, 157), Vector2(425, 170), Vector2(374, 193), Vector2(270, 208), Vector2(222, 224), Vector2(196, 259), Vector2(151, 275), Vector2(0, 299), Vector2(0, 251), Vector2(103, 229), Vector2(137, 207), Vector2(196, 187)], "#9faea3")
	for current in 19:
		var y := 164.0 + current * 5.65
		var x := 382.0 - current * 21
		line(Vector2(maxf(2, x), y), Vector2(maxf(2, x) + 29 + (current % 4) * 6, y), "#f5eed683", 1)
	ridge([Vector2(0, 232), Vector2(106, 226), Vector2(212, 233), Vector2(310, 222), Vector2(420, 216), Vector2(544, 223), Vector2(679, 216), Vector2(788, 212), Vector2(904, 219)], 344, "#a49f72", "#e8dec245", 51)
	for mist in 13:
		var x := float(186 + (mist * 137) % 555)
		var y := float(111 + (mist * 13) % 38)
		line(Vector2(x, y), Vector2(x + 34 + mist * 2, y), "#f7e9ce75", 1.1)
	polygon([Vector2(417, 194), Vector2(553, 176), Vector2(708, 179), Vector2(904, 174), Vector2(904, 186), Vector2(709, 192), Vector2(555, 183), Vector2(417, 201)], "#ded0aa")
	for x in [36, 64, 114, 155, 485, 644, 856, 886]:
		tree(Vector2(x, 150 + x % 17), 0.55 + (x % 5) * 0.12)
	house(505, 147, 0.70, "#e8d7af", "#394b43")
	house(567, 135, 0.96, "#eadbb4", "#2f443d")
	house(740, 149, 0.86, "#d6c2a0", "#6a5146")
	draw_projects()
	for index in village.hens:
		chicken(Vector2(766 + index * 19, 210 + (index % 2) * 7), "#f0d9a9" if index % 2 == 0 else "#d2a56d")
	for index in 4:
		draw_plot(index)
	ink_grain()
	draw_rect(Rect2(0.5, 0.5, 903, 343), Color("#625f4a"), false, 1.0, true)


func draw_plot(index: int) -> void:
	var x := float(79 + index * 204)
	var y := float(232 + (index % 2) * 6)
	var plot: Dictionary = village.plots[index]
	var unlocked: bool = plot["cleared"]
	var crop: String = plot["crop"]
	var ripe: bool = village.plot_ready(index)
	polygon([Vector2(x - 20, y), Vector2(x + 155, y), Vector2(x + 175, y + 66), Vector2(x - 41, y + 66)], "#64583f")
	polygon([Vector2(x - 16, y + 3), Vector2(x + 150, y + 3), Vector2(x + 169, y + 61), Vector2(x - 35, y + 61)], "#7b684d" if unlocked else "#948c68")
	for row in 4:
		var row_y := y + 13 + float(row) * 13
		var left := x - row * 5
		line(Vector2(left - 8, row_y), Vector2(x + 150 + row * 3, row_y), "#ad9266" if unlocked else "#a8a17d", 2)
		if not crop.is_empty():
			for column in range(0, 10):
				var at := Vector2(left + 4 + column * (14 + row * 0.65), row_y - 1)
				var height := float(8 + (row * 3 + column * 7) % 6)
				stalk(at, ripe and crop != "berry", height + (6 if ripe else 0))
				if ripe and crop == "berry":
					disc(at + Vector2(2, -7), 2.3, "#b64f45")


func draw_projects() -> void:
	var built: Array = village.built
	house(796, 113, 0.85, "#e4d2a6" if built.has("station") else "#b1ab8d", "#3d554a" if built.has("station") else "#715e4b")
	if built.has("station"):
		draw_rect(Rect2(821, 151, 52, 17), Color("#a46145"))
		draw_rect(Rect2(825, 153, 34, 6), Color("#d7d6ae"))
		disc(Vector2(832, 169), 4, "#414136")
		disc(Vector2(864, 169), 4, "#414136")
	else:
		line(Vector2(801, 109), Vector2(818, 104), "#ebe0c0", 2)
	if built.has("road"):
		line(Vector2(451, 194), Vector2(899, 181), "#8e8b7b", 7)
	if built.has("lamps"):
		for x in [493, 688, 890]:
			line(Vector2(x, 191), Vector2(x, 171), "#4e5141", 2)
			disc(Vector2(x + 2, 172), 3, "#ecca76")
	if built.has("pond"):
		for beam in 8:
			var x := 47.0 + beam * 11
			line(Vector2(x, 216), Vector2(x + 10, 206), "#8b6b4d", 3)
	if built.has("camp"):
		polygon([Vector2(18, 158), Vector2(32, 124), Vector2(51, 159)], "#d6b474")
		polygon([Vector2(68, 156), Vector2(82, 127), Vector2(98, 157)], "#cf9677")
	if built.has("square"):
		draw_rect(Rect2(463, 202, 154, 19), Color("#d6c8a2"))
		for mark in 7:
			line(Vector2(468 + mark * 22, 202), Vector2(471 + mark * 22, 221), "#a99c7b", 1)
	if built.has("network"):
		line(Vector2(694, 155), Vector2(694, 107), "#3b5547", 3)
		draw_arc(Vector2(694, 110), 14, 3.75, 5.65, 18, Color("#3b5547"), 2, true)
	if village.machine_level > 0:
		draw_rect(Rect2(559, 170, 22, 11), Color("#a66349"))
		disc(Vector2(563, 182), 4, "#44463b")
		disc(Vector2(577, 182), 3, "#44463b")
