@tool
extends CharacterBody3D
class_name PointDrag3D

signal drag_started
signal drag_moved(new_position: Vector3)
signal drag_ended

@export var gravity_enabled := false
@export var gravity_velocity := 9.8

var _dragging := false
var _drag_offset := Vector3.ZERO

const POINT_DRAG_LAYER := 1 << 1  # Layer 2

func _ready():
	input_ray_pickable = true
	input_capture_on_drag = true

	if not has_node("CollisionShape3D") and not has_node("CollisionPolygon3D"):
		push_warning("⚠ PointDrag3D requires a CollisionShape3D or CollisionPolygon3D to detect dragging.")

	# Set to layer 2
	collision_layer = POINT_DRAG_LAYER

	# Mask excludes layer 2, includes everything else by default (just unset layer 2)
	collision_mask = 0xffffffff & ~POINT_DRAG_LAYER

func _input_event(camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if not _dragging and camera:
				_start_drag(camera, event.position)
		elif _dragging:
			_end_drag()

func _start_drag(camera: Camera3D, screen_pos: Vector2) -> void:
	_dragging = true
	_drag_offset = _ray_plane_point(camera, screen_pos, global_position.y) - global_position
	velocity = Vector3.ZERO
	emit_signal("drag_started")
	get_viewport().set_input_as_handled()

func _end_drag() -> void:
	_dragging = false
	velocity = Vector3.ZERO
	emit_signal("drag_ended")

func _physics_process(delta):
	if _dragging:
		var camera := get_viewport().get_camera_3d()
		if camera:
			var target := _ray_plane_point(camera, get_viewport().get_mouse_position(), global_position.y) - _drag_offset
			velocity = (target - global_position) / delta
	elif gravity_enabled:
		velocity.y -= gravity_velocity * delta
	else:
		velocity = Vector3.ZERO

	move_and_slide()

	if _dragging:
		emit_signal("drag_moved", global_position)

func _ray_plane_point(camera: Camera3D, screen_pos: Vector2, plane_y: float) -> Vector3:
	var origin := camera.project_ray_origin(screen_pos)
	var dir := camera.project_ray_normal(screen_pos)
	if absf(dir.y) > 0.0001:
		return origin + dir * ((plane_y - origin.y) / dir.y)
	return origin
