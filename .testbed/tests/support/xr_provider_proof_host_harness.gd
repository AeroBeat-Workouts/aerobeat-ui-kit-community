extends RefCounted

const XR_PROOF_SCENE := preload("res://scenes/glass-shader-xr-provider-proof.tscn")

func spawn(test_case: GutTest) -> Node:
	var scene := XR_PROOF_SCENE.instantiate()
	test_case.add_child_autofree(scene)
	await test_case.get_tree().process_frame
	await test_case.get_tree().process_frame
	await test_case.get_tree().process_frame
	return scene

func event_phases(events: Array) -> Array[String]:
	var phases: Array[String] = []
	for event in events:
		phases.append(str(event.phase))
	return phases
