@tool
extends Area2D
class_name PointHover

signal hover_started
signal hover_triggered
signal hover_ended

@export var use_own_collision: bool = false
@export var sounds: Array[AudioStream] = []
@export var animation_player_path: NodePath
@export var animation_name: String = ""

var hovered := false

func _ready():
	input_pickable = true
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)

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
	_trigger_events()

func _on_mouse_exited():
	if hovered:
		hovered = false
		emit_signal("hover_ended")

func _trigger_events():
	# Play sounds
	for sound in sounds:
		var player := AudioStreamPlayer.new()
		add_child(player)
		player.stream = sound
		player.play()

	# Play animation
	if animation_player_path != NodePath("") and animation_name != "":
		var anim_player = get_node_or_null(animation_player_path)
		if anim_player and anim_player.has_animation(animation_name):
			anim_player.play(animation_name)

	# Notify listeners
	emit_signal("hover_triggered")
