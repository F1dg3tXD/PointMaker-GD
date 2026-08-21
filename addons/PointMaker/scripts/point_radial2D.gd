@tool
extends Area2D
class_name PointRadial

signal value_changed(value: float)
signal value_set(value: float)

@export var knob_path: NodePath
@export var min_angle: float = -135.0
@export var max_angle: float = 135.0
@export var use_limits: bool = true
@export_range(0.0, 1.0) var start_value: float = 0.5
@export var step: float = 0.0  # Set to > 0.0 for snapping (e.g. 0.1 for 10 steps)

var _dragging := false
var _value := start_value

func _ready():
	input_pickable = true
	_value = _apply_step(clamp(start_value, 0.0, 1.0))
	_update_knob_angle()

	if not has_node("CollisionShape2D") and not has_node("CollisionPolygon2D"):
		push_warning("⚠ PointRadial requires a CollisionShape2D or CollisionPolygon2D to detect mouse interaction.")

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			get_viewport().set_input_as_handled()
		else:
			if _dragging:
				_dragging = false
				emit_signal("value_set", _value)

func _unhandled_input(event):
	if event is InputEventMouseMotion and _dragging:
		var global_mouse_pos = get_global_mouse_position()
		var angle = (global_mouse_pos - global_position).angle()
		var deg_angle = rad_to_deg(angle)

		if deg_angle < 0.0:
			deg_angle += 360.0

		var new_value: float

		if use_limits:
			var clamped = clamp(deg_angle, min_angle + 180.0, max_angle + 180.0)
			new_value = inverse_lerp(min_angle, max_angle, clamped - 180.0)
		else:
			new_value = fmod(deg_angle, 360.0) / 360.0

		new_value = _apply_step(clamp(new_value, 0.0, 1.0))

		if not is_equal_approx(new_value, _value):
			_value = new_value
			_update_knob_angle()
			emit_signal("value_changed", _value)

func _apply_step(v: float) -> float:
	return round(v / step) * step if step > 0.0 else v

func _update_knob_angle():
	var knob = get_node_or_null(knob_path)
	if knob:
		var angle_deg = lerp(min_angle, max_angle, _value) if use_limits else _value * 360.0
		knob.rotation_degrees = angle_deg
