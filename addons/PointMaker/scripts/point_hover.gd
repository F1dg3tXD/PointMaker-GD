@tool
extends Area2D
class_name PointHover

signal hover_started
signal hover_triggered
signal hover_ended

@export var use_own_collision: bool = false
@export var stop_animation_on_exit: bool = false
@export var trigger_once: bool = true
@export var sounds: Array[AudioStream] = []
@export var animation_player_path: NodePath

var animation_name: String = ""
var _available_animations: PackedStringArray = []
var hovered := false
var triggered := false

func _ready():
	input_pickable = true
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)
	_refresh_animation_list()

	if not use_own_collision:
		var parent = get_parent()
		if parent and parent.has_node("CollisionShape2D"):
			var inherited_shape = parent.get_node("CollisionShape2D")
			if inherited_shape and inherited_shape.shape:
				var shape_copy = inherited_shape.shape.duplicate()
				var shape_node := CollisionShape2D.new()
				shape_node.shape = shape_copy
				add_child(shape_node)
				shape_node.position = inherited_shape.position
				shape_node.rotation = inherited_shape.rotation
				shape_node.scale = inherited_shape.scale
				shape_node.owner = self.owner

func _on_mouse_entered():
	if hovered:
		return
	hovered = true
	emit_signal("hover_started")
	if not trigger_once or not triggered:
		_trigger_events()
		triggered = true

func _on_mouse_exited():
	if hovered:
		hovered = false
		emit_signal("hover_ended")
		if stop_animation_on_exit:
			_stop_animation()

func _trigger_events():
	for sound in sounds:
		var player := AudioStreamPlayer.new()
		add_child(player)
		player.stream = sound
		player.play()

	if animation_player_path != NodePath("") and animation_name != "":
		var anim_player = get_node_or_null(animation_player_path)
		if anim_player and anim_player.has_animation(animation_name):
			anim_player.play(animation_name)

	emit_signal("hover_triggered")

func _stop_animation():
	if animation_player_path != NodePath("") and animation_name != "":
		var anim_player = get_node_or_null(animation_player_path)
		if anim_player and anim_player.is_playing():
			anim_player.stop()

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
