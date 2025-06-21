@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type(
	"PointTrigger",
	"Area2D",
	preload("res://addons/PointMaker/point_trigger.gd"),
	preload("res://addons/PointMaker/pointTrigger.png")
)

func _exit_tree():
	remove_custom_type("PointTrigger")
