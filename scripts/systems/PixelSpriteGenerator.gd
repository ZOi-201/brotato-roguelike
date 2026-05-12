# PixelSpriteGenerator.gd - Autoload singleton for pixel art sprites
extends Node

var textures: Dictionary = {}

func _ready() -> void:
	textures["player"] = _gen_player()
	textures["grunt"] = _gen_grunt()
	textures["charger"] = _gen_charger()
	textures["ranged"] = _gen_ranged()
	textures["xp_drop"] = _gen_xp_drop()
	textures["mat_drop"] = _gen_mat_drop()
	textures["bullet"] = _gen_bullet()
	textures["ground"] = _gen_ground_tile()

func _create_texture(img: Image) -> ImageTexture:
	var tex = ImageTexture.new()
	tex.set_image(img)
	return tex

# --- PLAYER: 32x32 potato character ---
func _gen_player() -> ImageTexture:
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var brown = Color(0.65, 0.45, 0.25)
	var dark = Color(0.45, 0.3, 0.15)
	var light = Color(0.75, 0.55, 0.35)
	var white = Color.WHITE
	var black = Color.BLACK
	var grey = Color(0.6, 0.6, 0.6)
	for y in range(8, 28):
		var w = 6 + int(sin((y - 8) * PI / 20) * 10)
		for x in range(16 - w, 16 + w):
			img.set_pixel(x, y, brown)
	for y in range(12, 24):
		var w = 4 + int(sin((y - 12) * PI / 12) * 5)
		for x in range(16 - w, 16 + w):
			img.set_pixel(x, y, light)
	_outline_region(img, 8, 28, brown)
	img.set_pixel(12, 15, white); img.set_pixel(13, 15, white)
	img.set_pixel(19, 15, white); img.set_pixel(20, 15, white)
	img.set_pixel(12, 16, black); img.set_pixel(19, 16, black)
	for x in range(13, 20):
		img.set_pixel(x, 19, dark)
	img.set_pixel(13, 20, dark); img.set_pixel(14, 20, dark)
	img.set_pixel(17, 20, dark); img.set_pixel(18, 20, dark)
	for x in range(24, 31):
		img.set_pixel(x, 17, grey)
		img.set_pixel(x, 18, grey)
	img.set_pixel(30, 16, grey); img.set_pixel(30, 19, grey)
	return _create_texture(img)

# --- GRUNT: 24x24 red blob enemy ---
func _gen_grunt() -> ImageTexture:
	var img = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var red = Color(0.85, 0.2, 0.2)
	var dark = Color(0.55, 0.1, 0.1)
	var light = Color(1, 0.35, 0.35)
	var white = Color.WHITE
	var black = Color.BLACK
	for y in range(3, 21):
		var w = int(sqrt(max(0, 81 - (y - 12) * (y - 12))) * 1.1)
		for x in range(12 - w, 12 + w):
			img.set_pixel(x, y, red)
	for y in range(6, 15):
		var w = int(sqrt(max(0, 36 - (y - 10) * (y - 10))) * 0.8)
		for x in range(12 - w, 12 + w):
			img.set_pixel(x, y, light)
	img.set_pixel(8, 9, white); img.set_pixel(15, 9, white)
	img.set_pixel(8, 10, black); img.set_pixel(15, 10, black)
	for x in range(9, 15):
		img.set_pixel(x, 14, dark)
	img.set_pixel(11, 15, dark); img.set_pixel(12, 15, dark)
	return _create_texture(img)

# --- CHARGER: 24x24 orange triangle/arrow ---
func _gen_charger() -> ImageTexture:
	var img = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var orange = Color(1, 0.45, 0.1)
	var dark = Color(0.7, 0.25, 0.05)
	var white = Color.WHITE
	var black = Color.BLACK
	for y in range(0, 24):
		var half_w = int(y * 11.0 / 24) if y <= 12 else int((24 - y) * 11.0 / 24)
		for x in range(1, 2 + half_w * 2):
			img.set_pixel(x, y, orange)
	for y in range(0, 24):
		var half_w = int(y * 11.0 / 24) if y <= 12 else int((24 - y) * 11.0 / 24)
		img.set_pixel(1 + half_w * 2, y, dark)
	img.set_pixel(16, 10, white); img.set_pixel(16, 13, white)
	img.set_pixel(17, 10, black); img.set_pixel(17, 13, black)
	return _create_texture(img)

# --- RANGED: 24x24 purple square with scope ---
func _gen_ranged() -> ImageTexture:
	var img = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var purple = Color(0.55, 0.15, 0.8)
	var dark = Color(0.35, 0.05, 0.55)
	var light = Color(0.75, 0.3, 1)
	var white = Color.WHITE
	var black = Color.BLACK
	for y in range(3, 21):
		for x in range(3, 16):
			img.set_pixel(x, y, purple)
	for y in range(3, 10):
		for x in range(4, 15):
			img.set_pixel(x, y, light)
	for y in range(9, 15):
		for x in range(16, 23):
			img.set_pixel(x, y, dark)
	img.set_pixel(9, 9, white); img.set_pixel(10, 9, white)
	img.set_pixel(9, 10, black)
	img.set_pixel(9, 13, white); img.set_pixel(10, 13, white)
	return _create_texture(img)

# --- XP DROP: 12x12 green gem ---
func _gen_xp_drop() -> ImageTexture:
	var img = Image.create(12, 12, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var green = Color(0.2, 1, 0.3)
	var light = Color(0.6, 1, 0.6)
	var dark = Color(0.05, 0.6, 0.1)
	for y in range(0, 12):
		var half = 6 - abs(y - 5.5)
		for x in range(int(6 - half), int(6 + half)):
			var c = light if y < 6 else dark
			img.set_pixel(x, y, c)
	for y in range(2, 7):
		for x in range(4, 8):
			img.set_pixel(x, y, green)
	return _create_texture(img)

# --- MATERIAL DROP: 12x12 gold coin ---
func _gen_mat_drop() -> ImageTexture:
	var img = Image.create(12, 12, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var gold = Color(1, 0.8, 0.1)
	var light = Color(1, 0.95, 0.5)
	var dark = Color(0.7, 0.55, 0.05)
	for y in range(0, 12):
		for x in range(0, 12):
			var dx = x - 5.5
			var dy = y - 5.5
			if dx * dx + dy * dy <= 30:
				var c = light if dy < 0 else gold
				if dx * dx + dy * dy > 22:
					c = dark
				img.set_pixel(x, y, c)
	img.set_pixel(5, 5, light); img.set_pixel(6, 5, light)
	img.set_pixel(5, 6, light); img.set_pixel(6, 6, light)
	return _create_texture(img)

# --- BULLET: 8x6 pixel bullet ---
func _gen_bullet() -> ImageTexture:
	var img = Image.create(8, 6, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var yellow = Color(1, 0.9, 0.1)
	var white = Color.WHITE
	for x in range(0, 8):
		img.set_pixel(x, 2, yellow)
		img.set_pixel(x, 3, yellow)
	img.set_pixel(3, 1, yellow); img.set_pixel(4, 1, yellow)
	img.set_pixel(3, 4, yellow); img.set_pixel(4, 4, yellow)
	img.set_pixel(4, 2, white); img.set_pixel(4, 3, white)
	return _create_texture(img)

# --- GROUND TILE: 64x64 arena floor ---
func _gen_ground_tile() -> ImageTexture:
	var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	var base = Color(0.12, 0.12, 0.16, 1)
	var grid = Color(0.15, 0.15, 0.2, 1)
	img.fill(base)
	for x in range(0, 64):
		img.set_pixel(x, 0, grid)
		img.set_pixel(x, 63, grid)
	for y in range(0, 64):
		img.set_pixel(0, y, grid)
		img.set_pixel(63, y, grid)
	for _i in range(8):
		var dx = randi_range(2, 61)
		var dy = randi_range(2, 61)
		img.set_pixel(dx, dy, Color(0.13, 0.13, 0.17, 1))
	return _create_texture(img)

func _outline_region(img: Image, y_start: int, y_end: int, color: Color) -> void:
	for y in range(y_start, y_end):
		for x in range(0, img.get_width()):
			if img.get_pixel(x, y).a > 0:
				_neighbors_draw(img, x, y, color)

func _neighbors_draw(img: Image, x: int, y: int, color: Color) -> void:
	for dx in [-1, 1]:
		var nx = x + dx
		if nx >= 0 and nx < img.get_width():
			if img.get_pixel(nx, y).a == 0:
				img.set_pixel(nx, y, color)
	for dy in [-1, 1]:
		var ny = y + dy
		if ny >= 0 and ny < img.get_height():
			if img.get_pixel(x, ny).a == 0:
				img.set_pixel(x, ny, color)
