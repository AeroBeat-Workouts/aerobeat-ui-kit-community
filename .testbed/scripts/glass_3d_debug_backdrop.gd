extends Node3D

const BAND_COLORS := [
	Color("#142033"),
	Color("#204a87"),
	Color("#15803d"),
	Color("#f59e0b"),
	Color("#ef4444"),
	Color("#7c3aed"),
]

const FLOOR_COLOR := Color("#0a1018")
const WALL_COLOR := Color("#091018")
const GRID_TINT := Color(1.0, 1.0, 1.0, 0.14)
const ACCENT_A := Color("#7dd3fc")
const ACCENT_B := Color("#f472b6")


func _ready() -> void:
	_build_backdrop()


func _build_backdrop() -> void:
	for child in get_children():
		child.queue_free()

	add_child(_make_box(
		"BackdropWall",
		Vector3(10.5, 6.2, 0.08),
		Vector3(0.0, 0.0, -3.4),
		WALL_COLOR,
		0.0,
		0.95
	))
	add_child(_make_box(
		"BackdropFloor",
		Vector3(10.5, 0.06, 5.0),
		Vector3(0.0, -1.95, -1.5),
		FLOOR_COLOR,
		0.0,
		0.9
	))

	var band_positions := [-3.9, -2.3, -0.8, 0.8, 2.4, 3.9]
	for i in range(band_positions.size()):
		var color: Color = BAND_COLORS[i % BAND_COLORS.size()]
		add_child(_make_box(
			"Band_%d" % i,
			Vector3(0.7, 5.2, 0.06),
			Vector3(float(band_positions[i]), 0.0, -3.32),
			color,
			0.45,
			0.55
		))

	for i in range(7):
		var y := -1.6 + float(i) * 0.55
		add_child(_make_box(
			"GridRow_%d" % i,
			Vector3(8.8, 0.04, 0.04),
			Vector3(0.0, y, -3.28),
			GRID_TINT,
			0.15,
			0.65,
			BaseMaterial3D.TRANSPARENCY_ALPHA
		))

	for i in range(6):
		var x := -3.75 + float(i) * 1.5
		add_child(_make_box(
			"GridColumn_%d" % i,
			Vector3(0.04, 5.0, 0.04),
			Vector3(x, 0.0, -3.27),
			GRID_TINT,
			0.15,
			0.65,
			BaseMaterial3D.TRANSPARENCY_ALPHA
		))

	add_child(_make_box(
		"AccentLeft",
		Vector3(1.2, 0.8, 0.3),
		Vector3(-2.8, 0.95, -1.8),
		ACCENT_A,
		0.8,
		0.3
	))
	add_child(_make_box(
		"AccentRight",
		Vector3(1.0, 1.0, 0.26),
		Vector3(2.7, -0.95, -1.55),
		ACCENT_B,
		0.8,
		0.28
	))
	add_child(_make_sphere(
		"FocusSphere",
		0.46,
		Vector3(-0.95, -0.15, -1.15),
		Color(1.0, 1.0, 1.0, 1.0),
		1.1,
		0.18
	))
	add_child(_make_sphere(
		"RearSphere",
		0.34,
		Vector3(1.35, 0.55, -2.2),
		Color("#fef08a"),
		0.9,
		0.22
	))
	add_child(_make_box(
		"DiagonalA",
		Vector3(4.8, 0.09, 0.09),
		Vector3(-0.4, -0.2, -2.5),
		Color(1.0, 1.0, 1.0, 0.78),
		0.55,
		0.22,
		BaseMaterial3D.TRANSPARENCY_ALPHA,
		Vector3(0.0, 0.0, -18.0)
	))
	add_child(_make_box(
		"DiagonalB",
		Vector3(4.2, 0.09, 0.09),
		Vector3(0.6, 0.8, -2.75),
		Color(1.0, 1.0, 1.0, 0.62),
		0.45,
		0.22,
		BaseMaterial3D.TRANSPARENCY_ALPHA,
		Vector3(0.0, 0.0, 24.0)
	))


func _make_box(
	name: String,
	size: Vector3,
	position: Vector3,
	color: Color,
	emission_energy: float = 0.0,
	roughness: float = 0.45,
	transparency: BaseMaterial3D.Transparency = BaseMaterial3D.TRANSPARENCY_DISABLED,
	rotation_degrees_value: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size

	var instance := MeshInstance3D.new()
	instance.name = name
	instance.mesh = mesh
	instance.position = position
	instance.rotation_degrees = rotation_degrees_value
	instance.material_override = _make_material(color, emission_energy, roughness, transparency)
	return instance


func _make_sphere(
	name: String,
	radius: float,
	position: Vector3,
	color: Color,
	emission_energy: float = 0.0,
	roughness: float = 0.25
) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0

	var instance := MeshInstance3D.new()
	instance.name = name
	instance.mesh = mesh
	instance.position = position
	instance.material_override = _make_material(color, emission_energy, roughness)
	return instance


func _make_material(
	color: Color,
	emission_energy: float,
	roughness: float,
	transparency: BaseMaterial3D.Transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.transparency = transparency
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = emission_energy
	return material
