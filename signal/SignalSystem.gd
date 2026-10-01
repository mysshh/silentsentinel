extends Node3D

@export var detection_range: float = 20.0
var player: Node3D
var hud: Node
var signal_active: bool = false

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	hud = get_tree().get_first_node_in_group("HUD")

func _process(delta):
	if not player:
		player = get_tree().get_first_node_in_group("Player")
		return
		
	var dist = global_position.distance_to(player.global_position)
	if dist < detection_range:
		if not signal_active:
			signal_active = true
			if hud:
				hud.show_message("UNKNOWN SIGNAL DETECTED")
			print("SIGNAL DETECTED")
	else:
		signal_active = false

