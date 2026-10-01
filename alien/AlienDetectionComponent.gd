extends Node3D

enum StimulusType { SOUND, LIGHT, MOVEMENT, HEAT }

@export var awareness_decay_per_sec: float = 8.0
@export var max_awareness: float = 100.0
@export var hearing_range: float = 28.0
@export var debug_mode: bool = false

var awareness: float = 0.0
var last_sound_pos: Vector3 = Vector3.ZERO
var last_light_pos: Vector3 = Vector3.ZERO
var last_movement_pos: Vector3 = Vector3.ZERO
var last_stimulus_pos: Vector3 = Vector3.ZERO
var last_stimulus_type: String = ""
var sound_events_received_count: int = 0
var is_hidden: bool = false

signal awareness_changed(value: float)
signal stimulus_received(pos: Vector3, strength: float, type: String)

func set_hidden(hidden: bool):
	is_hidden = hidden

func _ready():
	call_deferred("_connect_sound_system")

func _connect_sound_system():
	var sound_system = get_tree().get_first_node_in_group("SoundEventSystem")
	if sound_system and not sound_system.sound_emitted.is_connected(_on_sound_emitted):
		sound_system.sound_emitted.connect(_on_sound_emitted)
		if debug_mode:
			print("DETECTION: connected to SoundEventSystem")

func _on_sound_emitted(pos: Vector3, intensity: float, type: String = "sound"):
	sound_events_received_count += 1
	var origin = get_parent().global_position if get_parent() is Node3D else global_position
	var dist = origin.distance_to(pos)
	if dist > hearing_range:
		return
	# Closer / louder sounds raise awareness more.
	var falloff = 1.0 - (dist / hearing_range)
	var strength = intensity * 55.0 * falloff
	add_stimulus(pos, strength, type)

func add_stimulus(stimulus_pos: Vector3, stimulus_strength: float, type: String = "sound"):
	if is_hidden: stimulus_strength *= 0.1
	last_sound_pos = stimulus_pos
	last_stimulus_pos = stimulus_pos
	last_stimulus_type = type
	_raise_awareness(stimulus_strength, stimulus_pos, type)

func add_light(stimulus_pos: Vector3, strength: float):
	if is_hidden: strength *= 0.1
	last_light_pos = stimulus_pos
	last_stimulus_pos = stimulus_pos
	last_stimulus_type = "light"
	_raise_awareness(strength, stimulus_pos, "light")

func add_movement(stimulus_pos: Vector3, strength: float):
	if is_hidden: strength *= 0.1
	last_movement_pos = stimulus_pos
	last_stimulus_pos = stimulus_pos
	last_stimulus_type = "movement"
	_raise_awareness(strength, stimulus_pos, "movement")

func _raise_awareness(amount: float, pos: Vector3, type: String):
	var previous = awareness
	awareness = clamp(awareness + amount, 0.0, max_awareness)
	if debug_mode:
		print("DETECTION: type=", type, " +", snapped(amount, 0.1), " awareness=", snapped(awareness, 0.1), " pos=", pos)
	if awareness != previous:
		awareness_changed.emit(awareness)
		stimulus_received.emit(pos, amount, type)

func _process(delta):
	if awareness <= 0.0:
		return
	var previous = awareness
	awareness = clamp(awareness - awareness_decay_per_sec * delta, 0.0, max_awareness)
	if awareness != previous:
		awareness_changed.emit(awareness)

