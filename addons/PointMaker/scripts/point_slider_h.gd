@tool
extends Area2D
class_name PointSliderH

signal value_changed(value: float)
signal value_set(value: float)

@export var handle_path: NodePath
@export var min_position: float = 0.0
@export var max_position: float = 200.0
@export_range(0.0, 1.0) var value: float = 0.5
@export var step: float = 0.0

var _dragging := false

func _ready():
	input_pickable = true
	value = _apply_step(clamp(value, 0.0, 1.0))
	_update_handle_position()

	if not has_node("CollisionShape2D") and not has_node("CollisionPolygon2D"):
		push_warning("⚠ PointSliderH requires a CollisionShape2D or CollisionPolygon2D to detect mouse interaction.")

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
		var global_mouse_pos = get_global_mouse_position()
		var local_x = to_local(global_mouse_pos).x
		var range = max_position - min_position
		var raw_val = (local_x - min_position) / range
		var new_val = _apply_step(clamp(raw_val, 0.0, 1.0))

		if not is_equal_approx(new_val, value):
			value = new_val
			_update_handle_position()
			emit_signal("value_changed", value)

func _apply_step(v: float) -> float:
	return round(v / step) * step if step > 0.0 else v

func _update_handle_position():
	var handle = get_node_or_null(handle_path)
	if handle:
		var x = lerp(min_position, max_position, value)
		handle.position.x = x
