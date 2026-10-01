extends Node

signal pattern_complete
signal pattern_incorrect

var pattern: Array = [0, 2, 1, 0]
var current_input: Array = []

func _ready():
	pass

func input_node(node_index: int):
	current_input.append(node_index)
	print("Input: ", node_index)
	
	if current_input.size() == pattern.size():
		if current_input == pattern:
			print("Pattern Success")
			pattern_complete.emit()
		else:
			print("Pattern Incorrect, Resetting")
			current_input.clear()
			pattern_incorrect.emit()
