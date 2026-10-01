extends DirectionalLight3D

class_name DayCycle

signal night_started

@export var night_color: Color = Color(0.1, 0.1, 0.3)
@export var night_energy: float = 0.2

func transition_to_night():
	self.light_color = night_color
	self.light_energy = night_energy
	night_started.emit()
