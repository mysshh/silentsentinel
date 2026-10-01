extends Node3D

var _base_scale: Vector3 = Vector3.ONE
var _pulse: float = 0.0
var player: Node3D

func _ready() -> void:
	_base_scale = scale
	player = get_tree().get_first_node_in_group("Player")

func _process(delta: float) -> void:
	_pulse += delta
	if not player:
		player = get_tree().get_first_node_in_group("Player")
		return
	var dist := global_position.distance_to(player.global_position)
	var react := clampf(1.0 - dist / 8.0, 0.0, 1.0)
	var breathe := 1.0 + sin(_pulse * 1.6) * 0.04
	scale = _base_scale * (breathe + react * 0.18)
	rotation.y += delta * (0.15 + react * 0.8)

func scan() -> String:
	return "BIOLOGICAL ANOMALY\nThermal activity: HIGH\nResponse to movement: DETECTED"

