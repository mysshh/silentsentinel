extends Node3D

func _ready() -> void:
	_build_ground()
	_build_rocks()
	_build_vegetation()
	_build_debris()
	_build_landmark()

func _mat(albedo: Color, emission: Color = Color(0, 0, 0, 1), emission_energy: float = 0.0, roughness: float = 0.85) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = albedo
	m.roughness = roughness
	m.metallic = 0.05
	if emission_energy > 0.0:
		m.emission_enabled = true
		m.emission = emission
		m.emission_energy_multiplier = emission_energy
	return m

func _static_box(size: Vector3, pos: Vector3, yaw: float, material: Material) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = pos
	body.rotation.y = yaw
	var mesh := BoxMesh.new()
	mesh.size = size
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = material
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	body.add_child(mi)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	add_child(body)
	return body

func _attach_mesh(parent: Node, mesh: Mesh, material: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = material
	mi.position = pos
	mi.rotation = rot
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi

func _build_ground() -> void:
	var ground := StaticBody3D.new()
	ground.name = "HuntGround"
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(90, 90)
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = _mat(Color(0.18, 0.16, 0.12), Color(0.08, 0.12, 0.05), 0.04, 0.95)
	ground.add_child(mi)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(90, 0.2, 90)
	col.shape = shape
	col.position.y = -0.1
	ground.add_child(col)
	ground.position = Vector3(28, 0, -32)
	add_child(ground)

func _build_rocks() -> void:
	var rock := _mat(Color(0.22, 0.2, 0.18), Color(0, 0, 0), 0.0, 0.92)
	var dark := _mat(Color(0.12, 0.11, 0.1), Color(0, 0, 0), 0.0, 0.97)
	var specs := [
		[Vector3(8, 0.7, -12), Vector3(3.2, 1.6, 2.4), 0.4],
		[Vector3(14, 0.9, -18), Vector3(2.4, 2.0, 3.6), -0.7],
		[Vector3(18, 0.55, -8), Vector3(1.8, 1.2, 2.2), 0.2],
		[Vector3(22, 1.1, -28), Vector3(4.5, 2.4, 2.8), 0.9],
		[Vector3(12, 0.8, -32), Vector3(2.6, 1.8, 4.0), -0.3],
		[Vector3(30, 0.7, -20), Vector3(3.0, 1.5, 1.8), 1.2],
		[Vector3(34, 1.3, -38), Vector3(5.0, 2.8, 3.2), 0.15],
		[Vector3(26, 0.6, -44), Vector3(2.2, 1.4, 3.4), -1.1],
		[Vector3(40, 0.9, -30), Vector3(3.4, 2.0, 2.0), 0.55],
		[Vector3(42, 0.5, -46), Vector3(2.0, 1.1, 2.8), 0.8],
		[Vector3(20, 0.4, -22), Vector3(1.4, 0.9, 1.6), -0.2],
		[Vector3(36, 0.45, -24), Vector3(1.6, 1.0, 1.4), 1.4]
	]
	var idx := 0
	for s in specs:
		_static_box(s[1], s[0], s[2], rock if idx % 2 == 0 else dark)
		idx += 1

func _build_vegetation() -> void:
	var stem := _mat(Color(0.12, 0.22, 0.18), Color(0.1, 0.45, 0.28), 0.35)
	var bloom := _mat(Color(0.18, 0.08, 0.22), Color(0.55, 0.12, 0.7), 1.4, 0.4)
	var glow := _mat(Color(0.08, 0.16, 0.2), Color(0.15, 0.7, 0.85), 1.8, 0.3)
	var spots := [
		Vector3(6, 0, -16), Vector3(10, 0, -24), Vector3(16, 0, -14),
		Vector3(24, 0, -34), Vector3(28, 0, -16), Vector3(32, 0, -42),
		Vector3(38, 0, -26), Vector3(44, 0, -40), Vector3(18, 0, -40),
		Vector3(8, 0, -28), Vector3(36, 0, -18), Vector3(46, 0, -34)
	]
	var i := 0
	for p in spots:
		var plant := Node3D.new()
		plant.name = "AlienPlant_%d" % i
		plant.position = p
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.05 + float(i % 3) * 0.02
		cyl.bottom_radius = 0.12
		cyl.height = 1.4 + float(i % 4) * 0.25
		_attach_mesh(plant, cyl, stem, Vector3(0, cyl.height * 0.5, 0))
		var cap := SphereMesh.new()
		cap.radius = 0.18 + float(i % 2) * 0.06
		cap.height = cap.radius * 2.0
		_attach_mesh(plant, cap, bloom if i % 2 == 0 else glow, Vector3(0, cyl.height + 0.12, 0))
		var script := load("res://scripts/environment/ReactivePlant.gd")
		if script:
			plant.set_script(script)
		add_child(plant)
		i += 1

func _build_debris() -> void:
	var metal := _mat(Color(0.28, 0.32, 0.34), Color(0.2, 0.7, 0.85), 0.25, 0.35)
	metal.metallic = 0.7
	var rust := _mat(Color(0.25, 0.16, 0.1), Color(0.4, 0.12, 0.05), 0.15, 0.7)
	var pieces := [
		[Vector3(11, 0.35, -20), Vector3(1.8, 0.18, 0.7), 0.6],
		[Vector3(27, 0.8, -26), Vector3(0.35, 1.6, 0.35), 0.1],
		[Vector3(33, 0.25, -33), Vector3(2.4, 0.16, 0.5), -0.8],
		[Vector3(19, 0.55, -36), Vector3(0.5, 1.1, 0.5), 0.4],
		[Vector3(41, 0.4, -36), Vector3(1.4, 0.22, 0.9), 1.1]
	]
	for p in pieces:
		_static_box(p[1], p[0], p[2], metal if p[1].y > 0.5 else rust)

func _build_landmark() -> void:
	var relay := StaticBody3D.new()
	relay.name = "AlienRelay"
	relay.position = Vector3(48, 0, -52)
	relay.add_to_group("AlienRelay")
	var script := load("res://scripts/environment/AlienRelay.gd")
	if script:
		relay.set_script(script)
	var stone := _mat(Color(0.16, 0.18, 0.22), Color(0.2, 0.85, 0.95), 0.55, 0.45)
	stone.metallic = 0.35
	var core := _mat(Color(0.05, 0.12, 0.16), Color(0.3, 1.0, 0.95), 2.4, 0.2)
	var shaft := CylinderMesh.new()
	shaft.top_radius = 0.55
	shaft.bottom_radius = 1.1
	shaft.height = 8.0
	_attach_mesh(relay, shaft, stone, Vector3(0, 4.0, 0))
	var ring := TorusMesh.new()
	ring.inner_radius = 0.35
	ring.outer_radius = 1.4
	_attach_mesh(relay, ring, core, Vector3(0, 6.2, 0), Vector3(PI / 2.0, 0, 0))
	var cap := SphereMesh.new()
	cap.radius = 0.55
	cap.height = 1.1
	_attach_mesh(relay, cap, core, Vector3(0, 8.2, 0))
	var col := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = 1.2
	shape.height = 8.0
	col.shape = shape
	col.position.y = 4.0
	relay.add_child(col)
	var light := OmniLight3D.new()
	light.light_color = Color(0.35, 0.95, 1.0)
	light.light_energy = 2.2
	light.omni_range = 14.0
	light.position = Vector3(0, 7.4, 0)
	light.shadow_enabled = false
	relay.add_child(light)
	add_child(relay)