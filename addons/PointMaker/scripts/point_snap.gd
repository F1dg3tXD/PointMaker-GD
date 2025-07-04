@tool
extends Area2D
class_name PointSnap

signal snapped(dragger: Node)
signal unsnapped(dragger: Node)
signal snap_failed(dragger: Node)
signal rejected_dragger(dragger: Node)

var snapped_object: Node = null
var overlapping_drags: Array[Node] = []

@export var accepted_dragger: NodePath
@export var allow_any_dragger: bool = true
@export var require_specific_dragger: bool = false  # Applies only if allow_any_dragger is true

@export var animation_player_path: NodePath
var snap_in_animation: String = ""
var snap_out_animation: String = ""
var _available_animations: PackedStringArray = []

@export var correct_snap_sound: AudioStream
@export var wrong_snap_sound: AudioStream
@export var unsnap_sound: AudioStream

@export var align_rotation: bool = false
@export var align_scale: bool = false
@export var lock_when_snapped: bool = false

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	_refresh_animation_list()

	if not has_node("CollisionShape2D") and not has_node("CollisionPolygon2D"):
		push_warning("⚠ PointSnap requires a CollisionShape2D or CollisionPolygon2D to define the snap zone.")

func _on_body_entered(body: Node):
	if not body or not body.is_class("CharacterBody2D"):
		return

	var expected = get_node_or_null(accepted_dragger)

	if not allow_any_dragger:
		if body != expected:
			_play_sound(wrong_snap_sound)
			_play_animation(snap_out_animation)
			emit_signal("rejected_dragger", body)
			return
	elif require_specific_dragger:
		if body != expected:
			_play_sound(wrong_snap_sound)
			_play_animation(snap_out_animation)
			emit_signal("rejected_dragger", body)
			return

	if body.has_signal("drag_ended"):
		if not body.is_connected("drag_ended", Callable(self, "_on_drag_ended")):
			body.connect("drag_ended", Callable(self, "_on_drag_ended"))

	if body not in overlapping_drags:
		overlapping_drags.append(body)

func _on_body_exited(body: Node):
	overlapping_drags.erase(body)

func _on_drag_ended():
	for drag in overlapping_drags:
		if is_instance_valid(drag):
			try_snap(drag)

func try_snap(point_drag: Node):
	if snapped_object or not is_instance_valid(point_drag):
		emit_signal("snap_failed", point_drag)
		return

	snapped_object = point_drag
	snapped_object.global_position = global_position

	if align_rotation:
		snapped_object.rotation = rotation
	if align_scale:
		snapped_object.scale = scale

	if lock_when_snapped:
		if snapped_object.has_method("set_process_input"):
			snapped_object.set_process_input(false)
		if snapped_object.has_method("set_pickable"):
			snapped_object.set_pickable(false)

	_play_sound(correct_snap_sound)
	_play_animation(snap_in_animation)
	emit_signal("snapped", snapped_object)

	if snapped_object.has_signal("drag_started"):
		snapped_object.connect("drag_started", Callable(self, "_on_drag_started"), CONNECT_ONE_SHOT)

func _on_drag_started():
	if snapped_object:
		if lock_when_snapped:
			if snapped_object.has_method("set_process_input"):
				snapped_object.set_process_input(true)
			if snapped_object.has_method("set_pickable"):
				snapped_object.set_pickable(true)

		_play_sound(unsnap_sound)
		_play_animation(snap_out_animation)
		emit_signal("unsnapped", snapped_object)
		snapped_object = null

func _play_animation(name: String):
	if name == "":
		return
	var anim_player = get_node_or_null(animation_player_path)
	if anim_player and anim_player.has_animation(name):
		anim_player.play(name)

func _play_sound(stream: AudioStream):
	if not stream:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	add_child(player)
	player.play()
	player.connect("finished", player.queue_free)

func _refresh_animation_list():
	_available_animations.clear()
	var player = get_node_or_null(animation_player_path)
	if player and player is AnimationPlayer:
		_available_animations = player.get_animation_list()

func _get_property_list() -> Array[Dictionary]:
	return [
		{
			"name": "snap_in_animation",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(_available_animations),
			"usage": PROPERTY_USAGE_DEFAULT
		},
		{
			"name": "snap_out_animation",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(_available_animations),
			"usage": PROPERTY_USAGE_DEFAULT
		}
	]

func _get(property: StringName) -> Variant:
	match property:
		"snap_in_animation":
			return snap_in_animation
		"snap_out_animation":
			return snap_out_animation
	return null

func _set(property: StringName, value: Variant) -> bool:
	match property:
		"snap_in_animation":
			snap_in_animation = value
			return true
		"snap_out_animation":
			snap_out_animation = value
			return true
	return false

func _notification(what: int) -> void:
	if what == NOTIFICATION_READY or what == NOTIFICATION_ENTER_TREE:
		call_deferred("_refresh_animation_list")
