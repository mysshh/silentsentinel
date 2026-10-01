extends Node

class_name SignalPatternPuzzle

signal pattern_solved
signal pattern_reset

@export var target_pattern: Array[int] = [0, 2, 1, 0]
var player_input: Array[int] = []

func register_input(node_index: int):
	player_input.append(node_index)
	var current_index = player_input.size() - 1
	
	if player_input[current_index] != target_pattern[current_index]:
		reset_puzzle()
		return
	
	if player_input.size() == target_pattern.size():
		pattern_solved.emit()

func reset_puzzle():
	player_input.clear()
	pattern_reset.emit()
