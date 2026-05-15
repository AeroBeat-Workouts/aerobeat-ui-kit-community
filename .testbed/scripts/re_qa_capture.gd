extends SceneTree

const OUT_DIR := "/home/derrick/.openclaw/workspace/.temp/re-qa-glass-2026-05-11"
const SCENE_PATH := "res://scenes/glass-shader-test.tscn"

var scene_root: Control

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	DisplayServer.window_set_size(Vector2i(1600, 900))
	scene_root = load(SCENE_PATH).instantiate() as Control
	root.add_child(scene_root)
	_run_capture()


func _run_capture() -> void:
	await _settle_frames(8)
	_capture("01-full")

	var plate_shadow := scene_root.find_child("PlateShadow", true, false) as CanvasItem
	var contrast_panel := scene_root.find_child("PreviewContrastPanel", true, false) as CanvasItem
	var preview_button := scene_root.find_child("PrimaryCardButton", true, false) as CanvasItem
	if plate_shadow:
		plate_shadow.visible = false
	if contrast_panel:
		contrast_panel.visible = false
	if preview_button:
		preview_button.visible = false
	await _settle_frames(4)
	_capture("02-preview-hidden")

	if plate_shadow:
		plate_shadow.visible = true
	if contrast_panel:
		contrast_panel.visible = true
	if preview_button:
		preview_button.visible = true
	await _settle_frames(4)

	var sliders := _find_sliders_by_label()
	if sliders.has("edge_width"):
		(sliders["edge_width"] as HSlider).value = 7.5
	if sliders.has("blur"):
		(sliders["blur"] as HSlider).value = 6.5
	if sliders.has("chromatic_strength"):
		(sliders["chromatic_strength"] as HSlider).value = 4.8
	if sliders.has("corner_radius"):
		(sliders["corner_radius"] as HSlider).value = 0.38
	await _settle_frames(4)
	_capture("03-after-slider-tuning")

	quit(0)


func _find_sliders_by_label() -> Dictionary:
	var result := {}
	var controls_list := scene_root.find_child("ControlsList", true, false)
	if controls_list == null:
		return result
	for child in controls_list.get_children():
		if child is VBoxContainer and child.get_child_count() >= 2:
			var label := child.get_child(0) as Label
			var row := child.get_child(1)
			if label and row is HBoxContainer:
				for row_child in row.get_children():
					if row_child is HSlider:
						result[label.text] = row_child
						break
	return result


func _settle_frames(count: int) -> void:
	for _i in range(count):
		await process_frame


func _capture(name: String) -> void:
	RenderingServer.force_draw(false)
	var image := root.get_texture().get_image()
	var path := "%s/%s.png" % [OUT_DIR, name]
	var err := image.save_png(path)
	if err != OK:
		push_error("Failed to save capture %s (err=%s)" % [path, err])
