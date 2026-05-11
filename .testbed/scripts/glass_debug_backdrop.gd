extends Control

const BAND_COLORS := [
	Color("#142033"),
	Color("#204a87"),
	Color("#15803d"),
	Color("#f59e0b"),
	Color("#ef4444"),
	Color("#7c3aed"),
]

const CHECKER_LIGHT := Color(1.0, 1.0, 1.0, 0.10)
const CHECKER_DARK := Color(0.0, 0.0, 0.0, 0.12)
const GRID_COLOR := Color(1.0, 1.0, 1.0, 0.10)
const DIAGONAL_COLOR := Color(1.0, 1.0, 1.0, 0.22)
const RING_COLOR := Color(1.0, 1.0, 1.0, 0.32)
const ACCENT_A := Color("#7dd3fc")
const ACCENT_B := Color("#f472b6")


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect, Color("#091018"), true)
	_draw_color_bands(rect)
	_draw_checkerboard(rect)
	_draw_grid(rect)
	_draw_diagonals(rect)
	_draw_focus_shapes(rect)


func _draw_color_bands(rect: Rect2) -> void:
	var band_count := BAND_COLORS.size()
	if band_count == 0:
		return
	var band_width := rect.size.x / float(band_count)
	for i in range(band_count):
		var band_rect := Rect2(Vector2(i * band_width, 0.0), Vector2(ceilf(band_width) + 1.0, rect.size.y))
		var color: Color = BAND_COLORS[i]
		color.a = 0.92
		draw_rect(band_rect, color, true)


func _draw_checkerboard(rect: Rect2) -> void:
	var cell := 48.0
	var rows := int(ceilf(rect.size.y / cell))
	var cols := int(ceilf(rect.size.x / cell))
	for y in range(rows):
		for x in range(cols):
			var checker_rect := Rect2(Vector2(x * cell, y * cell), Vector2(cell, cell))
			draw_rect(checker_rect, CHECKER_LIGHT if (x + y) % 2 == 0 else CHECKER_DARK, true)


func _draw_grid(rect: Rect2) -> void:
	var spacing := 96.0
	var x := 0.0
	while x <= rect.size.x:
		draw_line(Vector2(x, 0.0), Vector2(x, rect.size.y), GRID_COLOR, 2.0, true)
		x += spacing
	var y := 0.0
	while y <= rect.size.y:
		draw_line(Vector2(0.0, y), Vector2(rect.size.x, y), GRID_COLOR, 2.0, true)
		y += spacing


func _draw_diagonals(rect: Rect2) -> void:
	var spacing := 120.0
	var start := -rect.size.y
	while start <= rect.size.x:
		draw_line(Vector2(start, 0.0), Vector2(start + rect.size.y, rect.size.y), DIAGONAL_COLOR, 6.0, true)
		start += spacing


func _draw_focus_shapes(rect: Rect2) -> void:
	var left_block := Rect2(Vector2(rect.size.x * 0.08, rect.size.y * 0.14), Vector2(rect.size.x * 0.18, rect.size.y * 0.2))
	var right_block := Rect2(Vector2(rect.size.x * 0.70, rect.size.y * 0.58), Vector2(rect.size.x * 0.18, rect.size.y * 0.18))
	draw_rect(left_block, ACCENT_A, true)
	draw_rect(right_block, ACCENT_B, true)

	var center := rect.size * 0.5
	draw_circle(center + Vector2(-140.0, -70.0), 72.0, Color(1.0, 1.0, 1.0, 0.16))
	draw_arc(center + Vector2(-140.0, -70.0), 108.0, 0.0, TAU, 80, RING_COLOR, 10.0, true)
	draw_arc(center + Vector2(170.0, 88.0), 84.0, 0.0, TAU, 80, Color(1.0, 1.0, 1.0, 0.22), 8.0, true)
	draw_line(center + Vector2(-220.0, 150.0), center + Vector2(220.0, -140.0), Color(1.0, 1.0, 1.0, 0.35), 12.0, true)
