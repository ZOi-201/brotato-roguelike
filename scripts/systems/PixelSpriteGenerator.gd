# PixelSpriteGenerator.gd - Autoload singleton
# All sprites redesigned following pixel art principles:
# - Top-left light source with hue-shifted ramps
# - 1px selective exterior outline
# - Clear silhouettes, no pillow shading
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

# ============================================================
# SHARED COLOR PALETTE (hue-shifted ramps, 4 shades each)
# ============================================================
# Skin: warm peach → cool shadow
var skin_ramp = [Color(1, 0.88, 0.78), Color(0.92, 0.78, 0.65), Color(0.75, 0.6, 0.5), Color(0.5, 0.38, 0.35)]
# Pink hair: warm pink → cool plum shadow
var hair_ramp = [Color(1, 0.7, 0.8), Color(0.92, 0.5, 0.6), Color(0.7, 0.35, 0.5), Color(0.4, 0.2, 0.35)]
# Blue dress: bright blue → deep navy shadow
var dress_ramp = [Color(0.35, 0.55, 0.85), Color(0.22, 0.38, 0.65), Color(0.12, 0.22, 0.45), Color(0.06, 0.12, 0.28)]
# Red enemy: bright red → purple-red shadow
var red_ramp = [Color(0.95, 0.3, 0.3), Color(0.8, 0.18, 0.18), Color(0.55, 0.1, 0.15), Color(0.3, 0.05, 0.12)]
# Orange enemy: bright orange → brown shadow
var orange_ramp = [Color(1, 0.5, 0.15), Color(0.85, 0.35, 0.08), Color(0.6, 0.22, 0.05), Color(0.35, 0.12, 0.05)]
# Purple enemy: bright purple → deep indigo shadow
var purple_ramp = [Color(0.65, 0.25, 0.85), Color(0.45, 0.15, 0.65), Color(0.25, 0.08, 0.4), Color(0.1, 0.03, 0.2)]
# Gold: bright gold → warm brown shadow
var gold_ramp = [Color(1, 0.9, 0.2), Color(0.9, 0.7, 0.1), Color(0.65, 0.45, 0.05), Color(0.35, 0.22, 0.02)]
# Green gem: bright green → dark forest shadow
var green_ramp = [Color(0.4, 1, 0.3), Color(0.2, 0.8, 0.15), Color(0.08, 0.5, 0.08), Color(0.03, 0.25, 0.05)]
# Grey (weapon/metal): light → dark
var grey_ramp = [Color(0.85, 0.85, 0.85), Color(0.6, 0.6, 0.6), Color(0.35, 0.35, 0.35), Color(0.15, 0.15, 0.15)]
# Outline (dark blue-grey, not pure black)
var outline = Color(0.08, 0.06, 0.12)
# White & black accents
var white = Color.WHITE
var pure_black = Color.BLACK
# Ground
var ground_base = Color(0.1, 0.1, 0.14)
var ground_grid = Color(0.14, 0.14, 0.18)

# Helper: draw outline around filled pixels
func _apply_outline(img: Image) -> void:
	var w = img.get_width()
	var h = img.get_height()
	var outline_img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	outline_img.fill(Color(0, 0, 0, 0))
	for y in range(h):
		for x in range(w):
			if img.get_pixel(x, y).a > 0:
				for dy in [-1, 0, 1]:
					for dx in [-1, 0, 1]:
						var nx = x + dx; var ny = y + dy
						if nx >= 0 and nx < w and ny >= 0 and ny < h:
							if outline_img.get_pixel(nx, ny).a == 0 and img.get_pixel(nx, ny).a == 0:
								outline_img.set_pixel(nx, ny, outline)
	# Composite outline behind sprite
	for y in range(h):
		for x in range(w):
			if outline_img.get_pixel(x, y).a > 0 and img.get_pixel(x, y).a == 0:
				img.set_pixel(x, y, outline)

# ============================================================
# PLAYER: 32x32 chibi anime girl (head 50%, body 50%)
# ============================================================
func _gen_player() -> ImageTexture:
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var s = skin_ramp; var h = hair_ramp; var d = dress_ramp; var g = grey_ramp

	# Hair base (wide, frames face)
	for y in range(2, 18):
		var hw = 9 if y <= 6 else (10 if y <= 13 else 8)
		for x in range(16 - hw, 16 + hw):
			if img.get_pixel(x, y).a == 0:
				img.set_pixel(x, y, h[1] if x < 10 or x > 21 else h[0])

	# Hair side strands
	for y in range(14, 22):
		img.set_pixel(7, y, h[2]); img.set_pixel(8, y, h[1])
		img.set_pixel(23, y, h[2]); img.set_pixel(24, y, h[1])

	# Face (skin, round)
	for y in range(6, 17):
		var fw = 5 if y <= 8 else (6 if y <= 13 else 5)
		for x in range(16 - fw, 16 + fw):
			img.set_pixel(x, y, s[0] if y < 11 else s[1])
	# Chin shadow
	img.set_pixel(14, 16, s[2]); img.set_pixel(15, 16, s[2]); img.set_pixel(16, 16, s[2]); img.set_pixel(17, 16, s[2])

	# Big anime eyes (2px x 3px white + blue pupil)
	# Left eye
	for y in range(10, 13):
		for x in range(11, 13): img.set_pixel(x, y, white)
	img.set_pixel(11, 11, Color(0.2, 0.5, 1)); img.set_pixel(12, 11, Color(0.2, 0.5, 1))
	img.set_pixel(11, 12, pure_black)
	# Right eye
	for y in range(10, 13):
		for x in range(19, 21): img.set_pixel(x, y, white)
	img.set_pixel(19, 11, Color(0.2, 0.5, 1)); img.set_pixel(20, 11, Color(0.2, 0.5, 1))
	img.set_pixel(20, 12, pure_black)

	# Blush
	img.set_pixel(10, 14, Color(1, 0.6, 0.65)); img.set_pixel(11, 14, Color(1, 0.6, 0.65))
	img.set_pixel(20, 14, Color(1, 0.6, 0.65)); img.set_pixel(21, 14, Color(1, 0.6, 0.65))
	# Mouth
	img.set_pixel(15, 15, Color(0.85, 0.35, 0.4))

	# Bangs (hair overlapping forehead)
	for y in range(5, 9):
		for x in range(9, 23):
			if img.get_pixel(x, y).a == 0 or img.get_pixel(x, y) in [skin_ramp[0], skin_ramp[1]]:
				img.set_pixel(x, y, h[0] if y == 5 else h[1])

	# Body/Dress (rows 18-30)
	for y in range(18, 29):
		var bw = 4 if y <= 20 else (5 if y <= 24 else 6)
		for x in range(16 - bw, 16 + bw):
			img.set_pixel(x, y, d[0] if x >= 14 and x <= 17 else d[1])
	# Belt
	for x in range(12, 21):
		img.set_pixel(x, 21, Color(0.8, 0.15, 0.25))
	# Skirt trim
	for x in range(11, 22):
		img.set_pixel(x, 28, d[1])

	# Arms
	for y in range(19, 23):
		img.set_pixel(10, y, s[0]); img.set_pixel(22, y, s[0])

	# Legs
	for y in range(29, 32):
		img.set_pixel(14, y, s[1]); img.set_pixel(18, y, s[1])
	img.set_pixel(14, 31, Color(0.2, 0.1, 0.05)); img.set_pixel(18, 31, Color(0.2, 0.1, 0.05))

	# Weapon (staff, right side)
	for x in range(24, 29):
		img.set_pixel(x, 17, g[1]); img.set_pixel(x, 18, g[1])
	img.set_pixel(24, 19, g[2]); img.set_pixel(26, 17, Color(0.3, 1, 1))
	img.set_pixel(26, 18, Color(0.2, 0.8, 0.9))

	_apply_outline(img)
	return _create_texture(img)

# ============================================================
# GRUNT: 24x24 red blob (clear round silhouette, top-left light)
# ============================================================
func _gen_grunt() -> ImageTexture:
	var img = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var c = red_ramp

	for y in range(3, 21):
		var r = int(sqrt(max(0, 77 - (y - 12) * (y - 12))) * 1.05)
		for x in range(12 - r, 12 + r):
			var shade = c[0]
			if y > 16: shade = c[2]
			elif y > 10: shade = c[1]
			elif x < 8 or x > 15: shade = c[1]
			img.set_pixel(x, y, shade)
	# Highlight (top-left)
	for y in range(5, 11):
		for x in range(8, 12):
			if img.get_pixel(x, y) == c[0] or img.get_pixel(x, y) == c[1]:
				img.set_pixel(x, y, c[0].lightened(0.15))

	# Eyes (white 2x2 + dark pupil)
	img.set_pixel(8, 9, white); img.set_pixel(9, 9, white)
	img.set_pixel(8, 10, pure_black)
	img.set_pixel(14, 9, white); img.set_pixel(15, 9, white)
	img.set_pixel(15, 10, pure_black)
	# Mouth
	img.set_pixel(11, 13, pure_black); img.set_pixel(12, 13, pure_black)

	_apply_outline(img)
	return _create_texture(img)

# ============================================================
# CHARGER: 24x24 orange arrow (sharp silhouette, top-left light)
# ============================================================
func _gen_charger() -> ImageTexture:
	var img = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var c = orange_ramp

	# Arrow pointing right, wider at base
	for y in range(2, 22):
		var hw = int(y * 9.0 / 22) if y <= 11 else int((22 - y) * 9.0 / 22)
		for x in range(2, 2 + hw * 2):
			var shade = c[0]
			if y > 16 or y < 5: shade = c[2]
			elif x < 4: shade = c[1]
			img.set_pixel(x, y, shade)
	# Highlight top edge
	for y in range(4, 12):
		for x in range(4, 8):
			if img.get_pixel(x, y) == c[0]:
				img.set_pixel(x, y, c[0].lightened(0.2))

	# Eyes (on the right/broad side)
	img.set_pixel(14, 10, white); img.set_pixel(15, 10, white)
	img.set_pixel(15, 11, pure_black)
	img.set_pixel(14, 13, white); img.set_pixel(15, 13, white)
	img.set_pixel(15, 14, pure_black)

	_apply_outline(img)
	return _create_texture(img)

# ============================================================
# RANGED: 24x24 purple square+barrel (boxy silhouette, top-left light)
# ============================================================
func _gen_ranged() -> ImageTexture:
	var img = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var c = purple_ramp

	# Body (12x14 square)
	for y in range(5, 19):
		for x in range(4, 16):
			var shade = c[0]
			if y < 7: shade = c[0].lightened(0.1)
			elif y > 15 or x > 12: shade = c[1]
			img.set_pixel(x, y, shade)

	# Barrel (extends right)
	for y in range(10, 14):
		for x in range(16, 22):
			img.set_pixel(x, y, c[2])

	# Eye/crosshair
	img.set_pixel(9, 10, white); img.set_pixel(10, 10, white)
	img.set_pixel(9, 11, pure_black)
	img.set_pixel(9, 13, white); img.set_pixel(10, 13, white)

	_apply_outline(img)
	return _create_texture(img)

# ============================================================
# XP DROP: 12x12 green gem (diamond silhouette, bright highlight)
# ============================================================
func _gen_xp_drop() -> ImageTexture:
	var img = Image.create(12, 12, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var c = green_ramp

	for y in range(1, 11):
		var half = 5.5 - abs(y - 5.0)
		for x in range(int(6.5 - half), int(6.5 + half)):
			var shade = c[0] if y < 6 else c[1]
			if abs(x - 6.5) + abs(y - 5.0) > 4.5: shade = c[2]
			img.set_pixel(x, y, shade)
	# Highlight (top-left)
	img.set_pixel(5, 3, c[0].lightened(0.3))
	img.set_pixel(6, 3, c[0].lightened(0.3))
	img.set_pixel(5, 4, c[0].lightened(0.3))

	return _create_texture(img)

# ============================================================
# MATERIAL DROP: 12x12 gold coin (circle silhouette, rim detail)
# ============================================================
func _gen_mat_drop() -> ImageTexture:
	var img = Image.create(12, 12, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var c = gold_ramp

	for y in range(1, 11):
		for x in range(1, 11):
			var dx = x - 5.5; var dy = y - 5.5
			var dist = dx * dx + dy * dy
			if dist <= 25:
				var shade = c[0] if dy < 0 else c[1]
				if dist > 20: shade = c[2]
				img.set_pixel(x, y, shade)
	# Center shine
	for x in range(4, 8):
		for y in range(4, 6):
			img.set_pixel(x, y, c[0].lightened(0.2))

	return _create_texture(img)

# ============================================================
# BULLET: 8x6 (two-tone, bright yellow, readable at 1x)
# ============================================================
func _gen_bullet() -> ImageTexture:
	var img = Image.create(8, 6, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var yellow = Color(1, 0.9, 0.1)
	var bright = Color(1, 1, 0.6)

	img.set_pixel(0, 2, yellow); img.set_pixel(0, 3, yellow)
	for x in range(1, 7):
		img.set_pixel(x, 2, yellow); img.set_pixel(x, 3, yellow)
	img.set_pixel(7, 2, bright); img.set_pixel(7, 3, bright)
	img.set_pixel(3, 1, yellow); img.set_pixel(4, 1, yellow)
	img.set_pixel(3, 4, yellow); img.set_pixel(4, 4, yellow)
	# Core highlight
	img.set_pixel(2, 2, bright); img.set_pixel(2, 3, bright)

	return _create_texture(img)

# ============================================================
# GROUND TILE: 64x64
# ============================================================
func _gen_ground_tile() -> ImageTexture:
	var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(ground_base)
	for x in range(0, 64):
		img.set_pixel(x, 0, ground_grid)
	for y in range(0, 64):
		img.set_pixel(0, y, ground_grid)
	# Subtle random dark spots
	for _i in range(6):
		var dx = randi_range(3, 60)
		var dy = randi_range(3, 60)
		img.set_pixel(dx, dy, ground_base.darkened(0.05))
	return _create_texture(img)
