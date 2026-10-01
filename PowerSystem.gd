extends Node3D

class_name PowerSystem

signal power_restored

var is_powered: bool = false
var cable_connected: bool = false
var solar_array_aligned: bool = false

@export var hud_path: NodePath
@export var alien_light_path: NodePath
var hud: Node
var alien_light: OmniLight3D

func _ready():
	hud = get_node_or_null(hud_path)
	alien_light = get_node_or_null(alien_light_path)
	# Connect signals from children if they are setup in scene
	for child in get_children():
		# Using has_signal or script check if class_name fails
		if child.has_signal("interacted"):
			child.interacted.connect(_on_interactable_interacted.bind(child))

func _on_interactable_interacted(node: Node):
	match node.name:
		"PowerConverter":
			if not is_powered:
				send_hud_message("SYSTEM STATUS: NO INPUT POWER DETECTED")
		"DisconnectedCable":
			if not cable_connected:
				cable_connected = true
				node.prompt_text = "CABLE CONNECTED"
				send_hud_message("CABLE RECONNECTED")
				check_status()
		"SolarArray":
			if not solar_array_aligned:
				solar_array_aligned = true
				node.prompt_text = "SOLAR ARRAY ACTIVE"
				send_hud_message("SOLAR ARRAY ALIGNED")
				check_status()

func send_hud_message(msg: String):
	if hud:
		hud.objective_label.text = msg
		# Reset to objective after 3 seconds? 
		# For now just keep it simple.

func check_status():
	if cable_connected and solar_array_aligned:
		is_powered = true
		power_restored.emit()
		if hud:
			hud.objective_label.text = "POWER RESTORED"
		trigger_alien_event()

func trigger_alien_event():
	# Simple alien event: A distant moving light
	print("Anomalous reading detected...")
	
	if alien_light:
		alien_light.visible = true
		alien_light.light_energy = 0
		
		var tween = get_tree().create_tween()
		# Fade in
		tween.tween_property(alien_light, "light_energy", 5.0, 1.5)
		# Movement
		tween.parallel().tween_property(alien_light, "position", alien_light.position + Vector3(10, 0, 5), 4.0)
		# Fade out
		tween.tween_property(alien_light, "light_energy", 0.0, 1.0)
		tween.tween_callback(func(): alien_light.visible = false)
		
	if hud:
		await get_tree().create_timer(1.0).timeout
		hud.objective_label.text = "ANOMALOUS SCANNER READING"
		play_audio_hook("warning")
		await get_tree().create_timer(4.0).timeout
		hud.objective_label.text = "OBJECTIVE: Enter Landing Pod"

func play_audio_hook(type: String):
	# Placeholder for procedural audio
	print("AUDIO HOOK: ", type)
	var audio_player = get_node_or_null("AudioStreamPlayer3D")
	if audio_player:
		# In a real scenario, we would set a procedural synth stream here
		audio_player.play()

