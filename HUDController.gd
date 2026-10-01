extends CanvasLayer

@onready var objective_label: Label = $ObjectiveLabel
@onready var status_label: Label = $StatusLabel
@onready var prompt_label: Label = $InteractionPrompt
@onready var message_label: Label = $MessageLabel
@onready var threat_overlay: ColorRect = $ThreatOverlay
@onready var threat_label: Label = $ThreatLabel

var threat_level: float = 0.0
var _message_token: int = 0

func _ready() -> void:
	if prompt_label:
		prompt_label.visible = false
	if message_label:
		message_label.visible = false
	if threat_overlay:
		threat_overlay.modulate.a = 0.0
	if threat_label:
		threat_label.visible = false

func update_suit_status(oxygen: float, energy: float, temperature: float, integrity: float):
	if status_label:
		status_label.text = "O2 %d%%   E %d%%   T %dC   H %d%%" % [oxygen, energy, temperature, integrity]

func set_objective(text: String) -> void:
	if objective_label:
		objective_label.text = text

func show_message(text: String) -> void:
	if not message_label:
		return
	_message_token += 1
	var token = _message_token
	message_label.text = text
	message_label.visible = true
	await get_tree().create_timer(3.0).timeout
	if token == _message_token and message_label:
		message_label.visible = false

func hide_message() -> void:
	if message_label:
		message_label.visible = false

func set_threat_level(value: float) -> void:
	threat_level = clampf(value, 0.0, 1.0)
	if threat_overlay:
		threat_overlay.modulate.a = threat_level * 0.38
	if threat_label:
		if threat_level >= 0.72:
			threat_label.text = "SOMETHING IS HUNTING YOU"
			threat_label.visible = true
		elif threat_level >= 0.35:
			threat_label.text = "IT NOTICED YOU"
			threat_label.visible = true
		else:
			threat_label.visible = false

func set_overlay_alpha(alpha: float) -> void:
	if threat_overlay:
		threat_overlay.modulate.a = alpha

