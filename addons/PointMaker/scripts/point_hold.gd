@tool
extends Area2D
class_name PointHold

signal hold_started
signal hold_triggered
signal hold_released

@export var required_hold_time: float = 0.5
@export var hold_loop: bool = false
@export var cancel_on_move: bool = true
@export var animation_player_path: NodePath
@export var animation_name: String = ""

var _is_holding := false
var _timer := 0.0
var _triggered := false

func _ready():
	input_pickable = true

	if not has_node("CollisionShape2D") and not has_node("CollisionPolygon2D"):
		push_warning("⚠ PointHold requires a CollisionShape2D or CollisionPolygon2D to detect mouse interaction.")

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_is_holding = true
			_timer = 0.0
			_triggered = false
			emit_signal("hold_started")
		else:
			if _is_holding:
				_end_hold()

func _process(delta):
	if _is_holding:
		# Cancel on move (if outside bounds)
		if cancel_on_move and not _is_mouse_inside():
			_end_hold()
			return

		_timer += delta
		if not _triggered and _timer >= required_hold_time:
			_triggered = true
			_trigger_event()
			emit_signal("hold_triggered")
		elif _triggered and hold_loop:
			var anim_player = get_node_or_null(animation_player_path)
			if anim_player and anim_player.has_animation(animation_name):
				if not anim_player.is_playing():
					anim_player.play(animation_name)

func _end_hold():
	_is_holding = false
	emit_signal("hold_released")

func _trigger_event():
	var anim_player = get_node_or_null(animation_player_path)
	if anim_player and anim_player.has_animation(animation_name):
		anim_player.play(animation_name)

func _is_mouse_inside() -> bool:
	var shape = get_node_or_null("CollisionShape2D") or get_node_or_null("CollisionPolygon2D")
	if not shape:
		return true  # No shape = assume always inside
	var local_pos = to_local(get_global_mouse_position())
	return shape.get_shape().contains_point(local_pos)
