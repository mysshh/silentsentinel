extends StaticBody3D

@export var prompt_text: String = "[ E ] Collect Thermal Sample"
var scanned: bool = false

func interact():
	print("Thermal sample collected")
	# Trigger thermal recovery in suit
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		var suit = player.get_node_or_null("SuitComponent")
		if suit:
			suit.set_temperature(40.0)
	queue_free()

func get_scan_data() -> String:
	return "THERMAL ORGANISM\nLocalized heat emission detected.\nStable biological signature."
