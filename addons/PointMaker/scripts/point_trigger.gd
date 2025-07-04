@tool
extends Area2D
class_name PointTrigger

signal trigger_started
signal sounds_played
signal animation_played(name: String)
signal scene_changed(path: String)

@export var sounds: Array[AudioStream] = []
@export var animation_player_path: NodePath
@export var scene_to_load: String = ""
@export var trigger_once: bool = true

var animation_name: String = ""

var triggered := false
var _available_animations: PackedStringArray = []

func _ready():
	input_pickable = true
	connect("body_entered", _on_body_entered)
	connect("input_event", _on_input_event)
	_refresh_animation_list()

func _on_body_entered(body):
	if trigger_once and triggered:
		return
	triggered = true
	_trigger_events()

func _on_input_event(viewport, event, shape_idx):
	if trigger_once and triggered:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		triggered = true
		_trigger_events()

func _trigger_events():
	emit_signal("trigger_started")

	# Play all sounds
	for sound in sounds:
		var player = AudioStreamPlayer.new()
		add_child(player)
		player.stream = sound
		player.play()
	emit_signal("sounds_played")

	# Play animation
	if animation_player_path != NodePath("") and animation_name != "":
		var anim_player = get_node_or_null(animation_player_path)
		if anim_player and anim_player is AnimationPlayer and anim_player.has_animation(animation_name):
			anim_player.play(animation_name)
			emit_signal("animation_played", animation_name)

	# Load new scene
	if scene_to_load != "":
		get_tree().change_scene_to_file(scene_to_load)
		emit_signal("scene_changed", scene_to_load)

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
