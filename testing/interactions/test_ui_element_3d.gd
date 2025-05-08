extends Node3D


@onready var ui_element_3d = $UIElement3D


func _input(_event):
	if Input.is_action_just_pressed("ui_accept"):
		ui_element_3d.select(not ui_element_3d.isSelected)
