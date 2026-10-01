extends Node

enum Day3State {
	DAY3_START,
	SIGNAL_DETECTED,
	STRUCTURE_FOUND,
	STRUCTURE_SCANNED,
	PATTERN_DISCOVERED,
	PATTERN_SOLVED,
	STRUCTURE_ACTIVATED,
	EARTH_RESPONSE,
	UNKNOWN_RESPONSE,
	DAY3_COMPLETE
}

var current_state: Day3State = Day3State.DAY3_START
var hud: Node
var player: Node3D

@export var alien_structure_path: NodePath
var alien_structure: Node3D

func _ready():
	add_to_group("Day3Controller")
	hud = get_tree().get_first_node_in_group("HUD")
	player = get_tree().get_first_node_in_group("Player")
	alien_structure = get_node_or_null(alien_structure_path)
	
func start_day3():
	change_state(Day3State.DAY3_START)

func change_state(new_state: Day3State):
	if current_state == new_state: return
	current_state = new_state
	
	match current_state:
		Day3State.DAY3_START:
			if hud:
				hud.set_objective("DAY 3: THE SIGNAL")
				hud.show_message("New Anomalous Signal Detected")
		
		Day3State.SIGNAL_DETECTED:
			if hud:
				hud.set_objective("Investigate Unknown Signal")
		
		Day3State.STRUCTURE_FOUND:
			if hud:
				hud.set_objective("Examine Alien Structure")
		
		Day3State.STRUCTURE_SCANNED:
			if hud:
				hud.set_objective("Analyze Structure Pattern")
				
		Day3State.PATTERN_SOLVED:
			if hud:
				hud.set_objective("Activate Structure")
			trigger_activation()

		Day3State.STRUCTURE_ACTIVATED:
			trigger_environmental_response()
			
		Day3State.EARTH_RESPONSE:
			trigger_earth_transmission()
			
		Day3State.UNKNOWN_RESPONSE:
			trigger_unknown_response()
			
		Day3State.DAY3_COMPLETE:
			if hud:
				hud.show_message("DAY 3 COMPLETE")

func trigger_activation():
	if alien_structure and alien_structure.has_method("activate"):
		alien_structure.activate()
	change_state(Day3State.STRUCTURE_ACTIVATED)

func trigger_environmental_response():
	print("WORLD REACTION: Distant lights, atmospheric shift.")
	await get_tree().create_timer(3.0).timeout
	change_state(Day3State.EARTH_RESPONSE)

func trigger_earth_transmission():
	if hud:
		hud.show_message("STATIC...")
		await get_tree().create_timer(2.0).timeout
		hud.show_message("EARTH SIGNAL DETECTED")
		await get_tree().create_timer(2.0).timeout
		hud.show_message("SENTINEL ONE.")
		await get_tree().create_timer(2.0).timeout
		hud.show_message("WE RECEIVED YOUR SIGNAL.")
		await get_tree().create_timer(2.0).timeout
		hud.show_message("YOUR STATUS?")
		await get_tree().create_timer(3.0).timeout
		hud.show_message("SENTINEL ONE...")
		await get_tree().create_timer(2.0).timeout
		hud.show_message("Something else received it.")
		await get_tree().create_timer(2.0).timeout
		hud.show_message("COMMUNICATION LOST")
	
	await get_tree().create_timer(2.0).timeout
	change_state(Day3State.UNKNOWN_RESPONSE)

func trigger_unknown_response():
	print("UNKNOWN RESPONSE: Signal pattern changed.")
	if hud:
		hud.show_message("UNKNOWN RESPONSE DETECTED")
	await get_tree().create_timer(5.0).timeout
	change_state(Day3State.DAY3_COMPLETE)
