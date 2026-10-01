extends Node

signal sound_emitted(position: Vector3, intensity: float, type: String)
var total_sound_events_received: int = 0

func _ready():
	add_to_group("SoundEventSystem")

func emit_sound(position: Vector3, intensity: float, type: String):
	total_sound_events_received += 1
	sound_emitted.emit(position, intensity, type)

