extends Node3D


@onready var ui_element_3d: UIElement3D = $UIElement3D
@onready var ui_element_3d_2: UIElement3D = $UIElement3D2


func _input(_event):
	#if Input.is_key_label_pressed(KEY_S):
		#ui_element_3d_2.setup()
		#ui_element_3d.setup()
	
	if Input.is_action_just_pressed("ui_accept"):
		ui_element_3d.select(not ui_element_3d.isSelected)
