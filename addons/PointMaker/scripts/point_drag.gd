@tool
extends Node2D
class_name PointDrag

signal drag_started
signal drag_moved(new_position: Vector2)
signal drag_ended

@export var gravity_enabled: bool = false
@export var gravity_velocity: float = 500.0  # Pixels per second

var _dragging := false
var _drag_offset := Vector2.ZERO
var _velocity := Vector2.ZERO

func _ready():
	if not has_node("CollisionShape2D") and not has_node("CollisionPolygon2D"):
		push_warning("⚠ PointDrag requires a CollisionShape2D or CollisionPolygon2D as a child to detect dragging.")

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			_drag_offset = get_global_mouse_position() - global_position
			_velocity = Vector2.ZERO
			emit_signal("drag_started")
			get_viewport().set_input_as_handled()
		else:
			if _dragging:
				_dragging = false
				emit_signal("drag_ended")

func _process(delta):
	if _dragging:
		var new_pos = get_global_mouse_position() - _drag_offset
		global_position = new_pos
		emit_signal("drag_moved", new_pos)
	else:
		if gravity_enabled:
			_velocity.y += gravity_velocity * delta
			global_position += _velocity * delta
