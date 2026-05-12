# SFX.gd - Autoload for 8-bit sound effects
extends Node

var _sounds: Dictionary = {}
var _player: AudioStreamPlayer

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = "Master"
	add_child(_player)
	var sfx_dir = "res://assets/sounds/"
	var files = {
		"shoot": sfx_dir + "shoot.wav",
		"hit": sfx_dir + "hit.wav",
		"player_hit": sfx_dir + "player_hit.wav",
		"kill": sfx_dir + "kill.wav",
		"pickup_xp": sfx_dir + "pickup_xp.wav",
		"pickup_coin": sfx_dir + "pickup_coin.wav",
		"level_up": sfx_dir + "level_up.wav",
		"wave_start": sfx_dir + "wave_start.wav",
		"game_over": sfx_dir + "game_over.wav",
		"victory": sfx_dir + "victory.wav",
	}
	for key in files:
		_sounds[key] = load(files[key])

func play(name: String, volume_db: float = 0.0) -> void:
	var s = _sounds.get(name)
	if s:
		var p = AudioStreamPlayer.new()
		p.stream = s
		p.volume_db = volume_db
		p.finished.connect(p.queue_free)
		add_child(p)
		p.play()
