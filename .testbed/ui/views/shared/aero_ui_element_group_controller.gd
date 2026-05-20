extends RefCounted
class_name AeroUiElementGroupController

var _elements: Array[Node] = []


func set_elements(elements: Array) -> void:
	_elements.clear()
	for element in elements:
		if element is Node:
			_elements.append(element as Node)


func add_element(element: Node) -> void:
	if element == null:
		return
	_elements.append(element)


func get_elements() -> Array[Node]:
	var live: Array[Node] = []
	for element in _elements:
		if is_instance_valid(element):
			live.append(element)
	return live


func TweenAlpha(target_alpha: float, tween_speed: float, ease_type: Variant, callback: Callable = Callable()) -> void:
	var tweenables: Array[Node] = []
	for element in get_elements():
		if element.has_method("TweenAlpha"):
			tweenables.append(element)

	if tweenables.is_empty():
		if callback.is_valid():
			callback.call_deferred()
		return

	var remaining := tweenables.size()
	var finish_one := func() -> void:
		remaining -= 1
		if remaining <= 0 and callback.is_valid():
			callback.call_deferred()

	for element in tweenables:
		element.callv("TweenAlpha", [target_alpha, tween_speed, ease_type, Callable(finish_one)])
