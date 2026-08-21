@tool
extends Area3D
class_name PointTrigger3D

signal trigger_started
signal sounds_played
signal animation_played(name: String)
signal method_called(method: StringName)
signal scene_changed(path: String)

@export var target_node: NodePath
@export var target_method: StringName = &""
@export var animation_player_path: NodePath
@export var animation_name: String = ""
@export var sounds: Array[AudioStream] = []
@export var scene_to_load: String = ""
@export var trigger_once: bool = true

var triggered := false
var _method_cache: PackedStringArray = []
var _animation_cache: PackedStringArray = []


func _ready():
	monitoring = true
	input_ray_pickable = true
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not input_event.is_connected(_on_input_event):
		input_event.connect(_on_input_event)
	_refresh_caches()


func _on_body_entered(_body: Node3D):
	if trigger_once and triggered:
		return
	triggered = true
	_fire()


func _on_input_event(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int):
	if trigger_once and triggered:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		triggered = true
		_fire()


func _fire():
	trigger_started.emit()

	for sound in sounds:
		if sound == null:
			continue
		var player = AudioStreamPlayer3D.new()
		add_child(player)
		player.stream = sound
		player.play()
	if not sounds.is_empty():
		sounds_played.emit()

	if animation_name != "":
		var anim_player = get_node_or_null(animation_player_path)
		if anim_player and anim_player is AnimationPlayer and anim_player.has_animation(animation_name):
			anim_player.play(animation_name)
			animation_played.emit(animation_name)

	if not target_node.is_empty() and target_method != &"":
		var node = get_node_or_null(target_node)
		if node != null and is_instance_valid(node) and node.has_method(target_method):
			node.call(target_method)
			method_called.emit(target_method)

	if scene_to_load != "":
		get_tree().change_scene_to_file(scene_to_load)
		scene_changed.emit(scene_to_load)


func _refresh_caches():
	_method_cache.clear()
	_animation_cache.clear()

	if not target_node.is_empty():
		var node = get_node_or_null(target_node)
		if node != null and is_instance_valid(node):
			for method in node.get_method_list():
				if method.flags & METHOD_FLAG_VIRTUAL:
					continue
				if method.name.begins_with("_"):
					continue
				_method_cache.append(method.name)

	var anim_player = get_node_or_null(animation_player_path)
	if anim_player and anim_player is AnimationPlayer:
		_animation_cache = anim_player.get_animation_list()


func _get_property_list() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	if not _method_cache.is_empty():
		list.append({
			"name": "target_method",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(_method_cache),
			"usage": PROPERTY_USAGE_DEFAULT
		})
	if not _animation_cache.is_empty():
		list.append({
			"name": "animation_name",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(_animation_cache),
			"usage": PROPERTY_USAGE_DEFAULT
		})
	return list


func _get(property: StringName) -> Variant:
	if property == "target_method":
		return String(target_method)
	if property == "animation_name":
		return animation_name
	return null


func _set(property: StringName, value: Variant) -> bool:
	if property == "target_method":
		target_method = StringName(value)
		return true
	if property == "animation_name":
		animation_name = value
		return true
	return false


func _notification(what: int) -> void:
	if what == NOTIFICATION_READY or what == NOTIFICATION_ENTER_TREE:
		call_deferred("_refresh_caches")
