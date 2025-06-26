@tool
extends Area2D
class_name PointSnap

var snapped_object: Node = null
var overlapping_drags: Array[Node] = []

@export var accepted_dragger: NodePath
@export var allow_any_dragger: bool = true

@export var animation_player_path: NodePath
@export var snap_in_animation: String = ""
@export var snap_out_animation: String = ""

@export var correct_snap_sound: AudioStream
@export var wrong_snap_sound: AudioStream
@export var unsnap_sound: AudioStream

@export var align_rotation: bool = false
@export var align_scale: bool = false
@export var lock_when_snapped: bool = false

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

	if not has_node("CollisionShape2D") and not has_node("CollisionPolygon2D"):
		push_warning("⚠ PointSnap requires a CollisionShape2D or CollisionPolygon2D to define the snap zone.")

func _on_body_entered(body: Node):
	if not body or not body.is_class("CharacterBody2D"):
		return

	if not allow_any_dragger and body != get_node_or_null(accepted_dragger):
		_play_sound(wrong_snap_sound)
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
