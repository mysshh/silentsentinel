extends RayCast3D

class_name PlayerInteraction

@export var interaction_distance: float = 2.0
var prompt_label: Label = null

func _ready():
	target_position = Vector3(0, 0, -interaction_distance)
	# Find HUD prompt label via group or relative path
	var hud = get_tree().get_first_node_in_group("HUD")
	if hud:
		prompt_label = hud.get_node_or_null("InteractionPrompt")

func _process(_delta):
	if is_colliding():
		var collider = get_collider()
		if collider.has_method("interact"):
			if prompt_label:
				prompt_label.text = "[ E ] " + (collider.prompt_text if "prompt_text" in collider else "INTERACT")
				prompt_label.visible = true
		elif prompt_label:
			prompt_label.visible = false
	elif prompt_label:
		prompt_label.visible = false

	if Input.is_action_just_pressed("interact"):
		if is_colliding():
			var collider = get_collider()
			if collider.has_method("interact"):
				collider.interact()

