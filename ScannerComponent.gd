extends RayCast3D

@export var hud_path: NodePath
var hud: Node

func _ready():
	hud = get_node_or_null(hud_path)

func _process(delta):
	if Input.is_action_just_pressed("scanner"):
		scan()

func scan():
	if is_colliding():
		var collider = get_collider()
		if collider.has_method("get_scan_data"):
			var data = collider.get_scan_data()
			if hud:
				hud.show_message(data)
		else:
			if hud:
				hud.show_message("No scan data detected.")
