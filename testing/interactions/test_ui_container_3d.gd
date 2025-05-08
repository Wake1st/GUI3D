extends Node3D


@onready var ui_container_3d: UIContainer3D = $UIContainer3D


func _input(_event) -> void:
	if Input.is_key_label_pressed(KEY_S):
		ui_container_3d.setup()
