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

var animation_name: String = ""
var _available_animations: PackedStringArray = []

var _is_holding := false
var _timer := 0.0
var _triggered := false

func _ready():
	input_pickable = true
	_refresh_animation_list()

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
		return true
	var local_pos = to_local(get_global_mouse_position())
	return shape.get_shape().contains_point(local_pos)

func _refresh_animation_list():
	_available_animations.clear()
	var player = get_node_or_null(animation_player_path)
	if player and player is AnimationPlayer:
		_available_animations = player.get_animation_list()

func _get_property_list() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	list.append({
		"name": "animation_name",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(_available_animations),
		"usage": PROPERTY_USAGE_DEFAULT
	})
	return list

func _get(property: StringName) -> Variant:
	if property == "animation_name":
		return animation_name
	return null

func _set(property: StringName, value: Variant) -> bool:
	if property == "animation_name":
		animation_name = value
		return true
	return false

func _notification(what: int) -> void:
	if what == NOTIFICATION_READY or what == NOTIFICATION_ENTER_TREE:
		call_deferred("_refresh_animation_list")
