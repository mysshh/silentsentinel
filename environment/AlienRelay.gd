extends StaticBody3D

@export var prompt_text: String = "[ E ] Interface with Alien Relay"
var activated: bool = false

func _ready() -> void:
	add_to_group("AlienRelay")

func scan() -> String:
	return "UNKNOWN RELAY\nMaterial: Unknown alloy\nEnergy: Latent\nFunction: Uncertain\nRecommendation: Approach quietly"

func interact() -> void:
	if activated:
		return
	activated = true
	prompt_text = "RELAY ACTIVE"
	var day4 = get_tree().get_first_node_in_group("Day4Controller")
	if day4 and day4.has_method("on_relay_reached"):
		day4.on_relay_reached()
	var hud = get_tree().get_first_node_in_group("HUD")
	if hud and hud.has_method("show_message"):
		hud.show_message("RELAY CONTACT ESTABLISHED")
	_pulse_light()

func _pulse_light() -> void:
	for child in get_children():
		if child is OmniLight3D:
			var tween := create_tween()
			tween.tween_property(child, "light_energy", 6.0, 0.4)
			tween.tween_property(child, "light_energy", 2.8, 1.2)
