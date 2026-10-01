extends Node

signal oxygen_changed(value)
signal temperature_changed(value)
signal energy_changed(value)
signal integrity_changed(value)
signal critical_state(state)
signal suit_death

@export var max_oxygen: float = 100.0
@export var max_temperature: float = 50.0
@export var max_energy: float = 100.0
@export var max_integrity: float = 100.0

var oxygen: float = 100.0
var temperature: float = 20.0
var energy: float = 100.0
var integrity: float = 100.0

func _process(delta):
	# Basic consumption
	consume_oxygen(0.5 * delta)
	consume_energy(0.1 * delta)
	# Temperature drops over time outside (assuming outside)
	change_temperature(-0.1 * delta)

func consume_oxygen(amount):
	oxygen = clamp(oxygen - amount, 0, max_oxygen)
	oxygen_changed.emit(oxygen)
	if oxygen <= 0: suit_death.emit()

func restore_oxygen(amount):
	oxygen = clamp(oxygen + amount, 0, max_oxygen)
	oxygen_changed.emit(oxygen)

func change_temperature(amount):
	temperature = clamp(temperature + amount, -50, max_temperature)
	temperature_changed.emit(temperature)

func set_temperature(value):
	temperature = value
	temperature_changed.emit(temperature)

func consume_energy(amount):
	energy = clamp(energy - amount, 0, max_energy)
	energy_changed.emit(energy)

func restore_energy(amount):
	energy = clamp(energy + amount, 0, max_energy)
	energy_changed.emit(energy)

func take_damage(amount):
	integrity = clamp(integrity - amount, 0, max_integrity)
	integrity_changed.emit(integrity)
	if integrity <= 0: suit_death.emit()

func repair(amount):
	integrity = clamp(integrity + amount, 0, max_integrity)
	integrity_changed.emit(integrity)

func reset_suit():
	oxygen = max_oxygen
	temperature = 20.0
	energy = max_energy
	integrity = max_integrity
	oxygen_changed.emit(oxygen)
	temperature_changed.emit(temperature)
	energy_changed.emit(energy)
	integrity_changed.emit(integrity)
