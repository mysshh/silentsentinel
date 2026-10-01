extends Node

enum Day { DAY0, DAY1, DAY2, DAY3, DAY4, COMPLETED }

var current_day: Day = Day.DAY0
var hud: Node

func _ready():
	add_to_group("ProgressionManager")
	hud = get_tree().get_first_node_in_group("HUD")
	_set_day(Day.DAY0)

func _set_day(day: Day):
	current_day = day
	match current_day:
		Day.DAY0:
			if hud: hud.set_objective("DAY 0: RESTORE POD POWER")
		Day.DAY1:
			if hud: hud.set_objective("DAY 1: INVESTIGATE ACTIVITY")
		Day.DAY2:
			if hud: hud.set_objective("DAY 2: DECODE SIGNAL")
		Day.DAY3:
			if hud: hud.set_objective("DAY 3: CROSS THE HUNTING GROUND")
		Day.DAY4:
			if hud: hud.set_objective("DAY 4: REACH THE RELAY")
		Day.COMPLETED:
			if hud: hud.set_objective("CHAPTER ONE COMPLETE")

func complete_day():
	if current_day < Day.COMPLETED:
		_set_day(current_day + 1)
