extends StaticBody3D

class_name Interactable

signal interacted

@export var prompt_text: String = "Interact"

func interact():
	interacted.emit()
