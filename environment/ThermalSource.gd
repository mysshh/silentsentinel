extends StaticBody3D

@export var scan_info: String = "THERMAL ORGANISM: Localized heat emission detected. Stable biological signature. Safe to harvest."
var collected: bool = false
@export var prompt_text: String = "[ E ] Collect Thermal Sample"

func scan() -> String:
	return scan_info

func interact():
	if collected: return
	collected = true
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		var suit = player.get_node_or_null("SuitComponent")
		if suit:
			suit.change_temperature(40.0) 
			suit.restore_energy(50.0)
	var hud = get_tree().get_first_node_in_group("HUD")
	if hud:
		hud.show_message("THERMAL SOURCE ACQUIRED - TEMPERATURE STABILIZING")
	
	var day2 = get_tree().get_first_node_in_group("Day2Controller")
	if day2:
		day2.complete_thermal_puzzle()
		
	queue_free()
