@tool
extends Area2D
class_name PointTrigger

signal trigger_started
signal sounds_played
signal animation_played(name: String)
signal scene_changed(path: String)

@export var sounds: Array[AudioStream] = []
@export var animation_player_path: NodePath
@export var animation_name: String = ""
@export var scene_to_load: String = ""
@export var trigger_once: bool = true

var triggered := false

func _ready():
	input_pickable = true
	connect("body_entered", _on_body_entered)
	connect("input_event", _on_input_event)

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
		if anim_player and anim_player.has_animation(animation_name):
			anim_player.play(animation_name)
			emit_signal("animation_played", animation_name)

	# Load new scene
	if scene_to_load != "":
		get_tree().change_scene_to_file(scene_to_load)
		emit_signal("scene_changed", scene_to_load)
