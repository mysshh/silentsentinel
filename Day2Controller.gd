extends Node

class_name Day2Controller

@export var hud_path: NodePath
var hud: Node
var puzzle_completed: bool = false
var event_triggered: bool = false

func _ready():
	add_to_group("Day2Controller")
	hud = get_node_or_null(hud_path)
	start_day2()

func start_day2():
	if hud:
		hud.show_message("DAY 2: SURVIVAL & DISCOVERY")
		await get_tree().create_timer(3.0).timeout
		hud.hide_message()
		hud.objective_label.text = "Objective: Stabilize Suit Temperature"
	
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		var suit = player.get_node_or_null("SuitComponent")
		if suit:
			suit.change_temperature(-15.0)

func complete_thermal_puzzle():
	if puzzle_completed: return
	puzzle_completed = true
	
	if hud:
		hud.objective_label.text = "TEMPERATURE STABILIZING"
	
	trigger_end_event()

func trigger_end_event():
	if event_triggered: return
	event_triggered = true
	
	if hud:
		await get_tree().create_timer(2.0).timeout
		hud.show_message("ANOMALOUS ENVIRONMENTAL SURGE DETECTED")
		await get_tree().create_timer(3.0).timeout
		hud.objective_label.text = "DAY 2 COMPLETE: THE PLANET IS ALIVE"
	
	print("DAY 2 END EVENT TRIGGERED: Vegetation illuminates, distant organisms react.")

