extends CharacterBody3D

@export var walk_speed = 2.6
@export var sprint_speed = 5.0
@export var mouse_sensitivity = 0.002

@onready var camera = $Camera3D
@onready var suit = $SuitComponent
@onready var scanner = $Camera3D/ScannerComponent

var input_enabled = true
var last_sound_time: int = 0
var sound_emitted_count: int = 0
var flashlight: OmniLight3D
var _light_tick: float = 0.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	add_to_group("Player")
	flashlight = OmniLight3D.new()
	flashlight.name = "Flashlight"
	flashlight.visible = false
	flashlight.light_energy = 4.5
	flashlight.omni_range = 16.0
	flashlight.light_color = Color(0.92, 0.95, 0.85)
	flashlight.shadow_enabled = false
	camera.add_child(flashlight)

func _input(event):
	if event.is_action_pressed("toggle_flashlight"):
		if flashlight:
			flashlight.visible = not flashlight.visible

func set_input_enabled(enabled: bool):
	input_enabled = enabled
	if not enabled:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if not input_enabled:
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI / 2, PI / 2)
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta):
	if not input_enabled:
		return

	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.y = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	input_dir = input_dir.normalized()

	var sprinting = Input.is_key_pressed(KEY_SHIFT)
	var speed = sprint_speed if sprinting else walk_speed
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	if not is_on_floor():
		velocity.y -= 9.8 * delta

	move_and_slide()

	var hud = get_tree().get_first_node_in_group("HUD")
	if hud and suit and hud.has_method("update_suit_status"):
		hud.update_suit_status(suit.oxygen, suit.energy, suit.temperature, suit.integrity)

	var sound_system = get_tree().get_first_node_in_group("SoundEventSystem")
	if sound_system and velocity.length() > 0.1:
		var intensity = 0.35 if velocity.length() < 3.0 else 1.0
		var type = "walk" if velocity.length() < 3.0 else "sprint"
		if Engine.get_frames_drawn() % 30 == 0:
			sound_system.emit_sound(global_position, intensity, type)
			last_sound_time = Time.get_ticks_msec()
			sound_emitted_count += 1

	_emit_light_stimulus(delta)

func _emit_light_stimulus(delta: float) -> void:
	if flashlight == null or not flashlight.visible:
		return
	_light_tick += delta
	if _light_tick < 0.35:
		return
	_light_tick = 0.0
	var creature = get_tree().get_first_node_in_group("AlienCreature")
	if creature == null or not creature.has_node("AlienDetectionComponent"):
		return
	var det = creature.get_node("AlienDetectionComponent")
	var dist = global_position.distance_to(creature.global_position)
	if dist > 22.0:
		return
	var falloff = 1.0 - (dist / 22.0)
	var strength = 18.0 * falloff
	if det.has_method("add_light"):
		det.add_light(global_position, strength)
