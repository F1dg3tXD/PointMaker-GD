@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type(
		"PointTrigger2D",
		"Area2D",
		preload("res://addons/PointMaker/scripts/point_trigger2D.gd"),
		preload("res://addons/PointMaker/icons/pointTrigger2D.png"))
	
	add_custom_type(
		"PointHover2D",
		"Area2D",
		preload("res://addons/PointMaker/scripts/point_hover2D.gd"),
		preload("res://addons/PointMaker/icons/pointHover2D.png"))

	add_custom_type(
		"PointRadial2D",
		"Node2D",
		preload("res://addons/PointMaker/scripts/point_radial2D.gd"),
		preload("res://addons/PointMaker/icons/pointRadial2D.png"))

	add_custom_type(
		"PointSliderH2D",
		"Node2D",
		preload("res://addons/PointMaker/scripts/point_slider_h2D.gd"),
		preload("res://addons/PointMaker/icons/pointSliderH2D.png"))

	add_custom_type(
		"PointSliderV2D",
		"Node2D",
		preload("res://addons/PointMaker/scripts/point_slider_v2D.gd"),
		preload("res://addons/PointMaker/icons/pointSliderV2D.png"))

	add_custom_type(
		"PointHold2D",
		"Area2D",
		preload("res://addons/PointMaker/scripts/point_hold2D.gd"),
		preload("res://addons/PointMaker/icons/pointHold2D.png"))

	add_custom_type(
		"PointDrag2D",
		"Node2D",
		preload("res://addons/PointMaker/scripts/point_drag2D.gd"),
		preload("res://addons/PointMaker/icons/pointDrag2D.png"))

	add_custom_type(
		"PointSnap2D",
		"Area2D",
		preload("res://addons/PointMaker/scripts/point_snap2D.gd"),
		preload("res://addons/PointMaker/icons/pointSnap2D.png"))
		
	add_custom_type(
		"PointLoad",
		"Node",
		preload("res://addons/PointMaker/scripts/point_load.gd"),
		preload("res://addons/PointMaker/icons/pointLoad2D.PNG"))
		

	add_custom_type(
		"PointDrag3D",
		"CharacterBody3D",
		preload("res://addons/PointMaker/scripts/point_drag3D.gd"),
		preload("res://addons/PointMaker/icons/pointDrag3D.PNG"))

	add_custom_type(
		"PointHover3D",
		"Area3D",
		preload("res://addons/PointMaker/scripts/point_hover3D.gd"),
		preload("res://addons/PointMaker/icons/pointHover3D.PNG"))

	add_custom_type(
		"PointSnap3D",
		"Area3D",
		preload("res://addons/PointMaker/scripts/point_snap3D.gd"),
		preload("res://addons/PointMaker/icons/pointSnap3D.PNG"))

	add_custom_type(
		"PointHold3D",
		"Area3D",
		preload("res://addons/PointMaker/scripts/point_hold3D.gd"),
		preload("res://addons/PointMaker/icons/pointHold3D.PNG"))

	add_custom_type(
		"PointTrigger3D",
		"Area3D",
		preload("res://addons/PointMaker/scripts/point_trigger3D.gd"),
		preload("res://addons/PointMaker/icons/pointTrigger3D.PNG"))

func _exit_tree():
	remove_custom_type("PointTrigger2D")
	remove_custom_type("PointHover2D")
	remove_custom_type("PointRadial2D")
	remove_custom_type("PointSliderH2D")
	remove_custom_type("PointSliderV2D")
	remove_custom_type("PointHold2D")
	remove_custom_type("PointDrag2D")
	remove_custom_type("PointSnap2D")
	remove_custom_type("PointLoad")
	remove_custom_type("PointDrag3D")
	remove_custom_type("PointHover3D")
	remove_custom_type("PointSnap3D")
	remove_custom_type("PointHold3D")
	remove_custom_type("PointTrigger3D")
