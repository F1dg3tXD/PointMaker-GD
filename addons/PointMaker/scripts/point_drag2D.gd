@tool
extends CharacterBody2D
class_name PointDrag

signal drag_started
signal drag_moved(new_position: Vector2)
signal drag_ended

@export var gravity_enabled := false
@export var gravity_velocity := 500.0

var _dragging := false
var _drag_offset := Vector2.ZERO

const POINT_DRAG_LAYER := 1 << 1  # Layer 2

func _ready():
	if not has_node("CollisionShape2D") and not has_node("CollisionPolygon2D"):
		push_warning("⚠ PointDrag requires a CollisionShape2D or CollisionPolygon2D to detect dragging.")

	# Set to layer 2
	collision_layer = POINT_DRAG_LAYER

	# Mask excludes layer 2, includes everything else by default (just unset layer 2)
	collision_mask = 0xffffffff & ~POINT_DRAG_LAYER

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			_drag_offset = get_global_mouse_position() - global_position
			velocity = Vector2.ZERO
			emit_signal("drag_started")
			get_viewport().set_input_as_handled()
		elif _dragging:
			_dragging = false
			velocity = Vector2.ZERO
			emit_signal("drag_ended")

func _physics_process(delta):
	if _dragging:
		var target := get_global_mouse_position() - _drag_offset
		var motion := target - global_position
		velocity = motion / delta
	else:
		if gravity_enabled:
			velocity.y += gravity_velocity * delta
		else:
			velocity = Vector2.ZERO

	move_and_slide()

	if _dragging:
		emit_signal("drag_moved", global_position)
