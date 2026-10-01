extends RayCast3D

@export var scan_range: float = 8.0
@export var energy_cost: float = 8.0

var hud: Node

func _ready():
	target_position = Vector3(0, 0, -scan_range)
	hud = get_tree().get_first_node_in_group("HUD")

func _unhandled_input(event):
	if event.is_action_pressed("scanner"):
		perform_scan()

func perform_scan():
	var player = get_parent().get_parent()
	var suit = player.get_node_or_null("SuitComponent") if player else null
	if suit and suit.energy < energy_cost:
		if hud:
			hud.show_message("SUIT ENERGY LOW - CANNOT SCAN")
		return

	if suit:
		suit.consume_energy(energy_cost)

	var audio_bus = get_tree().get_first_node_in_group("AudioHookBus")
	if audio_bus and audio_bus.has_method("play"):
		audio_bus.play("scanner", 0.4)

	if is_colliding():
		var collider = get_collider()
		if collider and collider.has_method("scan"):
			var info = collider.scan()
			if hud:
				hud.show_message(info)
		else:
			if hud:
				hud.show_message("NO SCANNABLE DATA DETECTED")
	else:
		if hud:
				hud.show_message("SCANNER CLEAR")
