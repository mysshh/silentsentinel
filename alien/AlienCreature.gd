extends CharacterBody3D

enum CreatureState { IDLE, PATROL, INVESTIGATE, ALERT, SEARCH, RETURN }
@export var current_state: CreatureState = CreatureState.PATROL
@export var movement_speed: float = 3.2
@export var debug_mode: bool = false

var awareness_component: Node3D
var last_known_position: Vector3 = Vector3.ZERO
var patrol_points: Array[Vector3] = [
	Vector3(22, 0, -22),
	Vector3(32, 0, -18),
	Vector3(28, 0, -34),
	Vector3(18, 0, -30)
]
var current_patrol_index: int = 0
var search_points: Array[Vector3] = []
var current_search_index: int = 0
var search_timer: float = 0.0
var idle_timer: float = 0.0
var spawn_position: Vector3 = Vector3(22, 0, -22)
var last_state_change_time: int = 0
var visual_root: Node3D
var core_light: OmniLight3D
var sensor_head: Node3D
var glow_parts: Array[MeshInstance3D] = []
var idle_phase: float = 0.0
var hud: Node
var audio_bus: Node
var last_visual_state: CreatureState = CreatureState.PATROL

func _ready():
	spawn_position = global_position
	add_to_group("AlienCreature")
	awareness_component = get_node_or_null("AlienDetectionComponent")
	if awareness_component:
		awareness_component.awareness_changed.connect(_on_awareness_changed)
		awareness_component.stimulus_received.connect(_on_stimulus_received)
	_build_visuals()
	hud = get_tree().get_first_node_in_group("HUD")
	audio_bus = get_tree().get_first_node_in_group("AudioHookBus")

func _build_visuals() -> void:
	var old := get_node_or_null("MeshInstance3D")
	if old:
		old.queue_free()
	visual_root = Node3D.new()
	visual_root.name = "VisualRoot"
	add_child(visual_root)

	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.05, 0.07, 0.08)
	body_mat.roughness = 0.35
	body_mat.metallic = 0.15
	var glow_mat := StandardMaterial3D.new()
	glow_mat.albedo_color = Color(0.08, 0.18, 0.16)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(0.15, 0.95, 0.7)
	glow_mat.emission_energy_multiplier = 0.8
	var bone_mat := StandardMaterial3D.new()
	bone_mat.albedo_color = Color(0.12, 0.1, 0.09)
	bone_mat.roughness = 0.7

	var torso := MeshInstance3D.new()
	var torso_mesh := CapsuleMesh.new()
	torso_mesh.radius = 0.38
	torso_mesh.height = 1.7
	torso.mesh = torso_mesh
	torso.material_override = body_mat
	torso.position.y = 1.05
	visual_root.add_child(torso)

	var core := MeshInstance3D.new()
	var core_mesh := SphereMesh.new()
	core_mesh.radius = 0.22
	core_mesh.height = 0.44
	core.mesh = core_mesh
	core.material_override = glow_mat
	core.position = Vector3(0, 1.15, 0.12)
	visual_root.add_child(core)
	glow_parts.append(core)

	sensor_head = Node3D.new()
	sensor_head.name = "SensorHead"
	sensor_head.position = Vector3(0, 1.85, 0)
	visual_root.add_child(sensor_head)
	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.28
	head_mesh.height = 0.42
	head.mesh = head_mesh
	head.material_override = body_mat
	head.scale = Vector3(0.85, 1.15, 1.35)
	sensor_head.add_child(head)
	var sensor := MeshInstance3D.new()
	var sensor_mesh := SphereMesh.new()
	sensor_mesh.radius = 0.12
	sensor.mesh = sensor_mesh
	sensor.material_override = glow_mat
	sensor.position = Vector3(0, 0.05, 0.22)
	sensor_head.add_child(sensor)
	glow_parts.append(sensor)

	for i in range(4):
		var arm := MeshInstance3D.new()
		var arm_mesh := CylinderMesh.new()
		arm_mesh.top_radius = 0.04
		arm_mesh.bottom_radius = 0.08
		arm_mesh.height = 1.15
		arm.mesh = arm_mesh
		arm.material_override = bone_mat
		var side := -1.0 if i < 2 else 1.0
		var z := -0.18 if i % 2 == 0 else 0.18
		arm.position = Vector3(side * 0.28, 0.85, z)
		arm.rotation_degrees = Vector3(18 if z > 0 else -12, 0, side * 28)
		visual_root.add_child(arm)

	core_light = OmniLight3D.new()
	core_light.light_color = Color(0.25, 1.0, 0.75)
	core_light.light_energy = 0.6
	core_light.omni_range = 5.0
	core_light.shadow_enabled = false
	core_light.position = Vector3(0, 1.2, 0.2)
	visual_root.add_child(core_light)

func _on_awareness_changed(value: float):
	if value >= 75.0:
		change_state(CreatureState.ALERT)
	elif value >= 25.0 and current_state != CreatureState.ALERT:
		change_state(CreatureState.INVESTIGATE)
	elif value <= 2.0 and current_state != CreatureState.IDLE and current_state != CreatureState.PATROL:
		change_state(CreatureState.RETURN)
	if hud and hud.has_method("set_threat_level"):
		hud.set_threat_level(value / 100.0)

func _on_stimulus_received(pos: Vector3, _strength: float, _type: String):
	last_known_position = pos
	if current_state != CreatureState.ALERT:
		change_state(CreatureState.INVESTIGATE)

func change_state(new_state: CreatureState):
	if current_state == new_state:
		return
	var prev = current_state
	current_state = new_state
	last_state_change_time = Time.get_ticks_msec()
	if debug_mode:
		print("CREATURE STATE: ", CreatureState.keys()[prev], " -> ", CreatureState.keys()[current_state])
	_apply_visual_state(current_state)
	_play_state_audio(current_state)
	var day4 = get_tree().get_first_node_in_group("Day4Controller")
	if day4 and day4.has_method("on_creature_state"):
		day4.on_creature_state(current_state)
	if current_state == CreatureState.SEARCH:
		_setup_search_points(last_known_position)
	elif current_state == CreatureState.IDLE:
		idle_timer = 4.0

func _apply_visual_state(state: CreatureState) -> void:
	last_visual_state = state
	var energy := 0.5
	var color := Color(0.25, 1.0, 0.75)
	match state:
		CreatureState.IDLE:
			pass
		_:
			energy = 0.35
			color = Color(0.2, 0.7, 0.65)
		CreatureState.PATROL:
			energy = 0.55
			color = Color(0.25, 0.9, 0.7)
		CreatureState.INVESTIGATE:
			energy = 1.4
			color = Color(0.85, 0.85, 0.25)
		CreatureState.ALERT:
			energy = 2.6
			color = Color(1.0, 0.22, 0.12)
		CreatureState.SEARCH:
			energy = 1.1
			color = Color(0.95, 0.55, 0.15)
		CreatureState.RETURN:
			energy = 0.45
			color = Color(0.2, 0.75, 0.7)
	
	_update_visual_state()
	
	if core_light:
		core_light.light_energy = energy
		core_light.light_color = color
	for part in glow_parts:
		var mat := part.material_override as StandardMaterial3D
		if mat:
			mat = mat.duplicate()
			part.material_override = mat
			mat.emission = color
			mat.emission_energy_multiplier = energy


func _play_state_audio(state: CreatureState) -> void:
	if not audio_bus:
		audio_bus = get_tree().get_first_node_in_group("AudioHookBus")
	if not audio_bus or not audio_bus.has_method("play"):
		return
	match state:
		CreatureState.INVESTIGATE:
			audio_bus.play("creature_investigate", 1.5)
		CreatureState.ALERT:
			audio_bus.play("creature_alert", 2.0)
			audio_bus.play("detection_warning", 2.0)
		CreatureState.IDLE, CreatureState.PATROL, CreatureState.RETURN:
			audio_bus.play("creature_idle", 4.0)

func _update_visual_state():
	for part in glow_parts:
		if part.material_override is StandardMaterial3D:
			match current_state:
				CreatureState.IDLE, CreatureState.PATROL, CreatureState.RETURN:
					part.material_override.emission_energy_multiplier = 0.8
				CreatureState.INVESTIGATE:
					part.material_override.emission_energy_multiplier = 1.8
				CreatureState.ALERT, CreatureState.SEARCH:
					part.material_override.emission_energy_multiplier = 3.5


func _setup_search_points(center: Vector3):
	search_points = [
		center + Vector3(2.4, 0, 0),
		center + Vector3(-2.2, 0, 2.2),
		center + Vector3(0, 0, -2.4),
		center
	]
	current_search_index = 0
	search_timer = 1.6

func _physics_process(delta):
	idle_phase += delta
	if visual_root:
		var breathe := 1.0 + sin(idle_phase * 1.8) * 0.03
		visual_root.scale = Vector3(breathe, 1.0 + sin(idle_phase * 1.4) * 0.04, breathe)
	if sensor_head and last_known_position != Vector3.ZERO:
		var look := last_known_position
		look.y = sensor_head.global_position.y
		if current_state == CreatureState.INVESTIGATE or current_state == CreatureState.ALERT or current_state == CreatureState.SEARCH:
			sensor_head.look_at(look, Vector3.UP)

	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0.0

	match current_state:
		CreatureState.IDLE:
			velocity.x = 0
			velocity.z = 0
			idle_timer -= delta
			if idle_timer <= 0:
				change_state(CreatureState.PATROL)
			move_and_slide()

		CreatureState.PATROL:
			if patrol_points.size() == 0:
				change_state(CreatureState.IDLE)
				return
			var target = patrol_points[current_patrol_index]
			_move_towards(target, delta, movement_speed * 0.65)
			if global_position.distance_to(target) < 1.5:
				current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
				change_state(CreatureState.IDLE)

		CreatureState.INVESTIGATE:
			_move_towards(last_known_position, delta, movement_speed)
			if global_position.distance_to(last_known_position) < 2.0:
				change_state(CreatureState.SEARCH)

		CreatureState.SEARCH:
			search_timer -= delta
			if search_points.size() > 0 and current_search_index < search_points.size():
				var sp = search_points[current_search_index]
				_move_towards(sp, delta, movement_speed * 0.55)
				if global_position.distance_to(sp) < 1.1:
					current_search_index += 1
					search_timer = 1.4
			elif search_timer <= 0:
				change_state(CreatureState.RETURN)

		CreatureState.ALERT:
			var player = get_tree().get_first_node_in_group("Player")
			var target = last_known_position
			if player and global_position.distance_to(player.global_position) < 18.0:
				# Fair: only chase last known / nearby confirmed stimulus, never teleport.
				target = player.global_position
				last_known_position = target
			_move_towards(target, delta, movement_speed * 1.45)

		CreatureState.RETURN:
			_move_towards(spawn_position, delta, movement_speed * 0.75)
			if global_position.distance_to(spawn_position) < 2.0:
				change_state(CreatureState.PATROL)

func _move_towards(target: Vector3, delta: float, speed: float):
	var dir = (target - global_position)
	dir.y = 0
	if dir.length() > 0.05:
		dir = dir.normalized()
		velocity.x = move_toward(velocity.x, dir.x * speed, speed * 4.0 * delta)
		velocity.z = move_toward(velocity.z, dir.z * speed, speed * 4.0 * delta)
		var target_angle = atan2(-dir.x, -dir.z)
		rotation.y = lerp_angle(rotation.y, target_angle, delta * 4.0)
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 5.0 * delta)
		velocity.z = move_toward(velocity.z, 0, speed * 5.0 * delta)
	move_and_slide()

func scan() -> String:
	return "UNKNOWN ORGANISM\nBehavior: Reactive\nObserved Response: Sound / Light\nThreat: Uncertain"
