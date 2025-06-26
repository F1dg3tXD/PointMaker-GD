@tool
extends Area2D
class_name PointSliderV

signal value_changed(value: float)
signal value_set(value: float)

@export var handle_path: NodePath
@export var path2d_path: NodePath
@export_range(0.0, 1.0) var value: float = 0.5
@export var step: float = 0.0

var _dragging := false

func _ready():
	input_pickable = true

	if not has_node("CollisionShape2D") and not has_node("CollisionPolygon2D"):
		push_warning("⚠ PointSliderV requires a CollisionShape2D or CollisionPolygon2D to detect mouse interaction.")

	# Wait one frame to make sure child nodes are ready
	await get_tree().process_frame

	value = _apply_step(clamp(value, 0.0, 1.0))
	_update_handle_position()

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			get_viewport().set_input_as_handled()
		else:
			if _dragging:
				_dragging = false
				emit_signal("value_set", value)

func _unhandled_input(event):
	if _dragging and event is InputEventMouseMotion:
		var path_node := get_node_or_null(path2d_path)
		if not path_node:
			return

		var curve: Curve2D = path_node.curve
		if not curve:
			return

		var mouse_pos: Vector2 = get_global_mouse_position()
		var closest_offset: float = 0.0
		var closest_dist: float = INF
		var steps := 64  # You can increase this for better precision

		var curve_len: float = curve.get_baked_length()

		for i in steps:
			var t: float = i / float(steps)
			var sample_pos: Vector2 = path_node.to_global(curve.sample_baked(t * curve_len))
			var dist := sample_pos.distance_to(mouse_pos)

			if dist < closest_dist:
				closest_dist = dist
				closest_offset = t * curve_len

		var raw_val: float = closest_offset / curve_len
		var new_val: float = _apply_step(clamp(raw_val, 0.0, 1.0))

		if not is_equal_approx(new_val, value):
			value = new_val
			_update_handle_position()
			emit_signal("value_changed", value)

func _apply_step(v: float) -> float:
	return round(v / step) * step if step > 0.0 else v

func _update_handle_position():
	var handle = get_node_or_null(handle_path)
	var path_node = get_node_or_null(path2d_path)
	if not handle or not path_node:
		return

	var curve: Curve2D = path_node.curve
	if not curve:
		return

	var offset: float = value * curve.get_baked_length()
	var global_point: Vector2 = path_node.to_global(curve.sample_baked(offset))
	handle.position = to_local(global_point)
