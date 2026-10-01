extends StaticBody3D

@export var organism_name: String = "Alien Organism"
@export var scan_info: String = "ORGANISM: Thermal signature detected. Non-hostile under ambient conditions. Reacts to active light sources."
@export var is_thermal_source: bool = false

var player: Node3D
var initial_position: Vector3
var flashlight: OmniLight3D = null

func _ready():
	initial_position = global_position
	player = get_tree().get_first_node_in_group("Player")

func scan() -> String:
	return scan_info

func _process(delta):
	if not player:
		player = get_tree().get_first_node_in_group("Player")
		return
	
	# Safely resolve flashlight
	if not flashlight and player.has_node("Camera3D/Flashlight"):
		flashlight = player.get_node("Camera3D/Flashlight")
		
	var light_on = flashlight and flashlight.visible if flashlight else false
	
	var dist = global_position.distance_to(player.global_position)
	if dist < 10.0:
		if light_on:
			# Move away from player (light stimulus)
			var dir = (global_position - player.global_position).normalized()
			dir.y = 0
			global_position += dir * delta * 2.0
		else:
			# Observe/approach gently
			var dir = (player.global_position - global_position).normalized()
			dir.y = 0
			global_position += dir * delta * 0.5

