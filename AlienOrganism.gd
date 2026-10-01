extends Node3D

@export var light_threshold: float = 0.5
var light_source: OmniLight3D 

func _ready():
	# Simple detection
	pass

func _process(delta):
	# Stimulus: Light
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		var light = player.get_node_or_null("Flashlight") # Assume this exists
		if light and light.visible:
			# Reactive behavior
			position += (position - player.position).normalized() * delta
