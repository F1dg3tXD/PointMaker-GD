@tool
extends Node
class_name PointLoad

@export var scene_path: String = ""

# This method is meant to be called by AnimationPlayer via a property track
func set_load_scene(_value):
	if scene_path == "":
		push_warning("⚠ SceneLoader: No scene path specified.")
		return
	
	if Engine.is_editor_hint():
		print("SceneLoader: Skipping load during editor playback.")
		return

	get_tree().change_scene_to_file(scene_path)
