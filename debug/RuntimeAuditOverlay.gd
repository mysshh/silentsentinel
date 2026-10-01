extends CanvasLayer

@onready var label = Label.new()
var audit_visible: bool = false

func _ready():
	layer = 100
	visible = false
	add_child(label)
	label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	label.position = Vector2(10, 10)
	label.add_theme_color_override("font_color", Color(0.85, 1.0, 0.9, 1.0))
	label.add_theme_font_size_override("font_size", 14)
	var panel = ColorRect.new()
	panel.color = Color(0.02, 0.05, 0.04, 0.72)
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.add_child(panel)
	panel.show_behind_parent = true
	label.move_child(panel, 0)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
		audit_visible = not audit_visible
		visible = audit_visible
		get_viewport().set_input_as_handled()

func _process(_delta):
	if not audit_visible:
		return
	var player = get_tree().get_first_node_in_group("Player")
	var day4 = get_tree().get_first_node_in_group("Day4Controller")
	var creature = get_tree().get_first_node_in_group("AlienCreature")
	var sound_sys = get_tree().get_first_node_in_group("SoundEventSystem")

	var p_speed = player.velocity.length() if player else 0.0
	var p_state = "IDLE"
	if p_speed > 3.0:
		p_state = "SPRINT"
	elif p_speed > 0.1:
		p_state = "WALK"

	var sound_emitted_count = player.get("sound_emitted_count") if player and player.get("sound_emitted_count") != null else 0
	var sound_events_received = 0
	var awareness_val = 0.0
	if creature and creature.has_node("AlienDetectionComponent"):
		var det = creature.get_node("AlienDetectionComponent")
		if "sound_events_received_count" in det:
			sound_events_received = det.sound_events_received_count
		if "awareness" in det:
			awareness_val = det.awareness

	var creature_state_str = "N/A"
	if creature and "current_state" in creature:
		creature_state_str = str(creature.current_state)

	var day4_state_str = "N/A"
	if day4 and "current_state" in day4:
		day4_state_str = str(day4.current_state)

	var sound_sys_count = sound_sys.total_sound_events_received if sound_sys and "total_sound_events_received" in sound_sys else 0
	var creature_pos = creature.global_position if creature else Vector3.ZERO

	var text = "=== SENTINEL LIVE AUDIT ===\n"
	text += "F3 TOGGLE | BUILD 0.5\n"
	text += "PLAYER SPEED: %.2f\n" % p_speed
	text += "PLAYER STATE: %s\n" % p_state
	text += "SOUND EMITTED: %d\n" % sound_emitted_count
	text += "SOUND RECEIVED: %d\n" % sound_sys_count
	text += "DETECTION RECEIVED: %d\n" % sound_events_received
	text += "AWARENESS: %.1f%%\n" % awareness_val
	text += "CREATURE: %s\n" % (creature.name if creature else "N/A")
	text += "CREATURE STATE: %s\n" % creature_state_str
	text += "CREATURE POSITION: %s\n" % str(creature_pos)
	text += "CREATURE Y: %.2f\n" % (creature_pos.y if creature else 0.0)
	text += "PLAYER Y: %.2f\n" % (player.global_position.y if player else 0.0)
	text += "DIST TO PLAYER: %.2f\n" % (creature.global_position.distance_to(player.global_position) if (creature and player) else 0.0)
	text += "DAY STATE: %s\n" % day4_state_str
	label.text = text
