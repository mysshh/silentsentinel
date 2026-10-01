extends Node3D

@export var player_path: NodePath
@export var hud_path: NodePath
@export var day_cycle_path: NodePath

var player: CharacterBody3D
var hud: Node

var sequence_timer: float = 0.0
var sequence_active: bool = false

func _ready():
	player = get_node(player_path)
	hud = get_node(hud_path)
	start_sequence()

func start_sequence():
	sequence_active = true
	sequence_timer = 0.0
	if player:
		player.set_input_enabled(false)
	if hud:
		hud.objective_label.text = "SYSTEM STATUS: RE-ENTRY"

func _process(delta):
	if not sequence_active:
		return
	
	sequence_timer += delta
	
	# 0-5 seconds: unstable camera, warnings
	if sequence_timer < 5.0:
		shake_camera(0.05)
		if hud and int(sequence_timer * 2) % 2 == 0:
			hud.objective_label.text = "WARNING: ATMOSPHERIC TURBULENCE"
	
	# 5-10 seconds: stronger impact, camera shake
	elif sequence_timer < 10.0:
		shake_camera(0.2)
		if hud:
			hud.objective_label.text = "CRITICAL FAILURE: LANDING SYSTEMS"
	
	# 10-13 seconds: impact and blackout
	elif sequence_timer < 13.0:
		if player:
			player.camera.v_offset = lerp(player.camera.v_offset, -0.5, delta * 2)
		if hud:
			hud.set_overlay_alpha(min(hud.threat_overlay.modulate.a + delta * 2.0, 1.0))
	
	# 13-20 seconds: systems restart
	elif sequence_timer < 20.0:
		if hud:
			hud.set_overlay_alpha(max(hud.threat_overlay.modulate.a - delta * 0.5, 0.0))
			hud.visible = true
			hud.objective_label.text = "REBOOTING SYSTEMS..."
		if player:
			player.camera.v_offset = lerp(player.camera.v_offset, 0.0, delta)
	
	# End sequence
	else:
		end_sequence()

func shake_camera(intensity: float):
	if player and player.camera:
		player.camera.h_offset = randf_range(-intensity, intensity)
		player.camera.v_offset = randf_range(-intensity, intensity)

func end_sequence():
	sequence_active = false
	if player:
		player.camera.h_offset = 0
		player.camera.v_offset = 0
		player.set_input_enabled(true)
	if hud:
		hud.objective_label.text = "OBJECTIVE: Restore Pod Power"
	if day_cycle_path:
		get_node(day_cycle_path).transition_to_night()

