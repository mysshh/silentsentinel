extends Node

# Lightweight audio hooks. Easy to replace with real samples later.
# Avoids console spam as a substitute for gameplay audio.

var _players: Dictionary = {}
var _last_played: Dictionary = {}

func _ready() -> void:
	add_to_group("AudioHookBus")
	for name in ["creature_idle", "creature_investigate", "creature_alert", "detection_warning", "ambience", "scanner", "relay"]:
		var p := AudioStreamPlayer.new()
		p.name = name
		p.volume_db = -12.0
		add_child(p)
		_players[name] = p

func play(hook: String, cooldown: float = 0.8) -> void:
	if not _players.has(hook):
		return
	var now := Time.get_ticks_msec() / 1000.0
	if _last_played.has(hook) and now - float(_last_played[hook]) < cooldown:
		return
	_last_played[hook] = now
	var player: AudioStreamPlayer = _players[hook]
	if player.playing:
		return
	# Placeholder: silent until real streams are assigned. Keeps hook API stable.
	if player.stream:
		player.play()
