@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type(
		"PointTrigger",
		"Area2D",
		preload("res://addons/PointMaker/scripts/point_trigger.gd"),
		preload("res://addons/PointMaker/icons/pointTrigger.png"))
	
	add_custom_type(
		"PointHover",
		"Area2D",
		preload("res://addons/PointMaker/scripts/point_hover.gd"),
		preload("res://addons/PointMaker/icons/pointHover.png"))

	add_custom_type(
		"PointRadial",
		"Node2D",
		preload("res://addons/PointMaker/scripts/point_radial.gd"),
		preload("res://addons/PointMaker/icons/pointRadial.png"))

	add_custom_type(
		"PointSliderH",
		"Node2D",
		preload("res://addons/PointMaker/scripts/point_slider_h.gd"),
		preload("res://addons/PointMaker/icons/pointSliderH.png"))

	add_custom_type(
		"PointSliderV",
		"Node2D",
		preload("res://addons/PointMaker/scripts/point_slider_v.gd"),
		preload("res://addons/PointMaker/icons/pointSliderV.png"))

	add_custom_type(
		"PointHold",
		"Area2D",
		preload("res://addons/PointMaker/scripts/point_hold.gd"),
		preload("res://addons/PointMaker/icons/pointHold.png"))

	add_custom_type(
		"PointDrag",
		"Node2D",
		preload("res://addons/PointMaker/scripts/point_drag.gd"),
		preload("res://addons/PointMaker/icons/pointDrag.png"))

	add_custom_type(
		"PointSnap",
		"Area2D",
		preload("res://addons/PointMaker/scripts/point_snap.gd"),
		preload("res://addons/PointMaker/icons/pointSnap.png"))
		
	add_custom_type(
		"PointLoad",
		"Node",
		preload("res://addons/PointMaker/scripts/point_load.gd"),
		preload("res://addons/PointMaker/icons/pointLoad.png"))

func _exit_tree():
	remove_custom_type("PointTrigger")
	remove_custom_type("PointHover")
	remove_custom_type("PointRadial")
	remove_custom_type("PointSliderH")
	remove_custom_type("PointSliderV")
	remove_custom_type("PointHold")
	remove_custom_type("PointDrag")
	remove_custom_type("PointSnap")
	remove_custom_type("PointLoad")
