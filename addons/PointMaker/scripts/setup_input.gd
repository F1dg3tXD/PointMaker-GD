@tool
extends EditorScript

func _run():
	var actions = [
		"walk-left", "walk-right", "walk-up", "walk-down",
		"jump", "crouch", "sprint", "attack"
	]
	for action in actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			print("Added action:", action)
		else:
			print("Already exists:", action)
