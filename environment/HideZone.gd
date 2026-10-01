extends Area3D

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		for creature in get_tree().get_nodes_in_group("AlienCreature"):
			var detector = creature.get_node_or_null("AlienDetectionComponent")
			if detector:
				detector.set_hidden(true)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		for creature in get_tree().get_nodes_in_group("AlienCreature"):
			var detector = creature.get_node_or_null("AlienDetectionComponent")
			if detector:
				detector.set_hidden(false)
