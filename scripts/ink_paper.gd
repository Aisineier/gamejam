extends RefCounted


static func make_texture() -> ImageTexture:
	var wash := FastNoiseLite.new()
	wash.seed = 86
	wash.frequency = 0.022
	var grain := RandomNumberGenerator.new()
	grain.seed = 2008
	var paper := Image.create_empty(480, 300, false, Image.FORMAT_RGB8)
	var base := Color("#eae0c7")
	for y in paper.get_height():
		for x in paper.get_width():
			var shade := wash.get_noise_2d(x, y) * 0.105 + grain.randf_range(-0.028, 0.030)
			paper.set_pixel(x, y, base.lightened(maxf(0, shade)).darkened(maxf(0, -shade)))
	return ImageTexture.create_from_image(paper)
