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

# --- PLAYER: 32x32 anime girl ---
func _gen_player() -> ImageTexture:
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var skin = Color(1, 0.88, 0.78)
	var skin_dark = Color(0.9, 0.75, 0.65)
	var hair = Color(1, 0.45, 0.65)
	var hair_dark = Color(0.8, 0.25, 0.5)
	var hair_light = Color(1, 0.65, 0.8)
	var white = Color.WHITE
	var black = Color(0.1, 0.05, 0.05)
	var eye_blue = Color(0.2, 0.5, 1)
	var eye_dark = Color(0.05, 0.15, 0.4)
	var dress = Color(0.2, 0.3, 0.6)
	var dress_light = Color(0.3, 0.45, 0.8)
	var ribbon = Color(0.95, 0.15, 0.25)
	var weapon = Color(0.55, 0.55, 0.6)
	var blush = Color(1, 0.6, 0.65)

	# Hair - back layer (rows 2-22, wide)
	for y in range(2, 23):
		var hw = 0
		if y <= 4: hw = 6
		elif y <= 14: hw = 8
		elif y <= 18: hw = 7
		else: hw = 5
		for x in range(16 - hw, 16 + hw):
			if img.get_pixel(x, y).a == 0:
				img.set_pixel(x, y, hair)
	# Hair sides flowing down
	for y in range(14, 24):
		img.set_pixel(7, y, hair)
		img.set_pixel(8, y, hair_dark)
		img.set_pixel(23, y, hair)
		img.set_pixel(24, y, hair_dark)
	# Hair highlight (top)
	for y in range(2, 8):
		for x in range(13, 18):
			if img.get_pixel(x, y) == hair:
				img.set_pixel(x, y, hair_light)

	# Ribbon/Bow (top of head)
	img.set_pixel(13, 3, ribbon); img.set_pixel(14, 3, ribbon); img.set_pixel(15, 3, ribbon)
	img.set_pixel(17, 3, ribbon); img.set_pixel(18, 3, ribbon); img.set_pixel(19, 3, ribbon)
	img.set_pixel(12, 4, ribbon); img.set_pixel(13, 4, ribbon)
	img.set_pixel(19, 4, ribbon); img.set_pixel(20, 4, ribbon)
	for x in range(14, 19): img.set_pixel(x, 2, ribbon)

	# Face (skin)
	for y in range(6, 20):
		var fw = 0
		if y <= 8: fw = 5
		elif y <= 12: fw = 6
		elif y <= 16: fw = 5
		else: fw = 4
		for x in range(16 - fw, 16 + fw):
			img.set_pixel(x, y, skin)
	# Chin
	img.set_pixel(15, 18, skin_dark); img.set_pixel(16, 18, skin_dark); img.set_pixel(17, 18, skin_dark)

	# Eyes (big anime eyes)
	# Left eye
	for y in range(10, 14):
		for x in range(11, 14):
			img.set_pixel(x, y, white)
	img.set_pixel(12, 11, eye_blue); img.set_pixel(12, 12, eye_blue)
	img.set_pixel(11, 11, eye_dark); img.set_pixel(11, 12, eye_dark)
	img.set_pixel(10, 11, eye_dark)
	img.set_pixel(12, 10, white)  # highlight
	# Right eye
	for y in range(10, 14):
		for x in range(18, 21):
			img.set_pixel(x, y, white)
	img.set_pixel(19, 11, eye_blue); img.set_pixel(19, 12, eye_blue)
	img.set_pixel(20, 11, eye_dark); img.set_pixel(20, 12, eye_dark)
	img.set_pixel(21, 11, eye_dark)
	img.set_pixel(19, 10, white)  # highlight

	# Blush
	img.set_pixel(10, 15, blush); img.set_pixel(11, 15, blush)
	img.set_pixel(20, 15, blush); img.set_pixel(21, 15, blush)

	# Mouth (small cute)
	img.set_pixel(15, 16, Color(0.9, 0.4, 0.4))
	img.set_pixel(16, 16, Color(0.9, 0.4, 0.4))

	# Bangs (hair over forehead)
	for y in range(5, 8):
		for x in range(10, 22):
			if img.get_pixel(x, y).a == 0 or img.get_pixel(x, y) == hair:
				img.set_pixel(x, y, hair)
	# Bang tips
	img.set_pixel(9, 7, hair); img.set_pixel(10, 8, hair)
	img.set_pixel(22, 7, hair); img.set_pixel(21, 8, hair)

	# Body/Dress (rows 19-31)
	for y in range(20, 29):
		var bw = 0
		if y <= 22: bw = 4
		elif y <= 25: bw = 5
		else: bw = 6
		for x in range(16 - bw, 16 + bw):
			img.set_pixel(x, y, dress)
	# Dress detail (belt/sash)
	for x in range(12, 21):
		img.set_pixel(x, 23, ribbon)
	# Dress highlight
	for y in range(20, 25):
		for x in range(14, 17):
			if img.get_pixel(x, y) == dress:
				img.set_pixel(x, y, dress_light)
	# Skirt ruffle
	for x in range(11, 22):
		img.set_pixel(x, 28, dress)

	# Legs
	for y in range(29, 32):
		img.set_pixel(14, y, skin)
		img.set_pixel(18, y, skin)
	# Shoes
	img.set_pixel(13, 31, Color(0.3, 0.15, 0.1)); img.set_pixel(14, 31, Color(0.3, 0.15, 0.1))
	img.set_pixel(15, 31, Color(0.3, 0.15, 0.1))
	img.set_pixel(18, 31, Color(0.3, 0.15, 0.1)); img.set_pixel(19, 31, Color(0.3, 0.15, 0.1))

	# Arms
	for y in range(21, 25):
		img.set_pixel(10, y, skin)
		img.set_pixel(22, y, skin)

	# Weapon (staff/wand on right side)
	for x in range(24, 29):
		img.set_pixel(x, 18, weapon)
	for x in range(25, 28):
		img.set_pixel(x, 17, weapon)
	img.set_pixel(28, 19, weapon)
	# Weapon gem
	img.set_pixel(26, 17, Color(0.3, 1, 1))
	img.set_pixel(26, 18, Color(0.2, 0.8, 0.9))

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
