extends Node

enum Day4State {
	DAY4_START,
	AREA_ENTERED,
	CREATURE_ENCOUNTER,
	BEHAVIOR_OBSERVED,
	PLAYER_DETECTED,
	SEARCHING,
	DISTRACTION_USED,
	OBJECTIVE_REACHED,
	ESCAPE,
	DAY4_COMPLETE
}

var current_state: Day4State = Day4State.DAY4_START
var hud: Node
var player: Node3D
var creature: Node3D
var hunt_started: bool = false
var complete: bool = false
var area_announced: bool = false

func _ready():
	add_to_group("Day4Controller")
	hud = get_tree().get_first_node_in_group("HUD")
	player = get_tree().get_first_node_in_group("Player")
	creature = get_tree().get_first_node_in_group("AlienCreature")

func _process(_delta):
	if complete:
		return
	if not player:
		player = get_tree().get_first_node_in_group("Player")
		return
	if not creature:
		creature = get_tree().get_first_node_in_group("AlienCreature")
	# Enter hunt territory once the player leaves the immediate landing pad.
	var xz := Vector2(player.global_position.x, player.global_position.z)
	if not hunt_started and xz.length() > 12.0:
		start_hunt()
	elif hunt_started and not area_announced and player.global_position.distance_to(Vector3(22, 0, -22)) < 18.0:
		area_announced = true
		change_state(Day4State.AREA_ENTERED)

func start_hunt() -> void:
	if hunt_started:
		return
	hunt_started = true
	change_state(Day4State.DAY4_START)

func on_creature_state(state_value) -> void:
	if complete:
		return
	match int(state_value):
		2:
			change_state(Day4State.CREATURE_ENCOUNTER)
		3:
			change_state(Day4State.PLAYER_DETECTED)
		4:
			change_state(Day4State.SEARCHING)
		5:
			change_state(Day4State.BEHAVIOR_OBSERVED)

func on_relay_reached() -> void:
	if complete:
		return
	change_state(Day4State.OBJECTIVE_REACHED)
	_finish_day()

func _finish_day() -> void:
	complete = true
	change_state(Day4State.DAY4_COMPLETE)

func change_state(new_state: Day4State):
	if current_state == new_state and new_state != Day4State.DAY4_START:
		return
	current_state = new_state
	if not hud:
		hud = get_tree().get_first_node_in_group("HUD")
	match current_state:
		Day4State.DAY4_START:
			if hud:
				hud.set_objective("OBJECTIVE: Reach the Relay")
				hud.show_message("UNKNOWN BIOLOGICAL ACTIVITY AHEAD")
		Day4State.AREA_ENTERED:
			if hud:
				hud.show_message("THE TERRAIN CHANGES")
		Day4State.CREATURE_ENCOUNTER:
			if hud:
				hud.show_message("IT HEARD SOMETHING")
		Day4State.PLAYER_DETECTED:
			if hud:
				hud.show_message("DO NOT RUN")
		Day4State.SEARCHING:
			if hud:
				hud.show_message("IT IS SEARCHING")
		Day4State.BEHAVIOR_OBSERVED:
			if hud:
				hud.show_message("IT LOST YOU")
		Day4State.OBJECTIVE_REACHED:
			if hud:
				hud.set_objective("RELAY CONTACT")
				hud.show_message("THE RELAY ANSWERS")
		Day4State.DAY4_COMPLETE:
			if hud:
				hud.set_objective("DAY 4 COMPLETE")
				hud.show_message("THEY KNOW YOU ARE HERE")
