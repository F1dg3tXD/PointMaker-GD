@tool
extends AnimationPlayer
class_name AutoAnimationPlayer

@export var auto_play_animation: String = ""

func _ready():
	if Engine.is_editor_hint():
		return  # Prevent auto-play in the editor

	if has_animation(auto_play_animation):
		play(auto_play_animation)
	else:
		push_warning("⚠ AutoAnimationPlayer: Animation '%s' not found." % auto_play_animation)
