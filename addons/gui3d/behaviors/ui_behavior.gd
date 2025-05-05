@icon("res://addons/gui3d/behaviors/behavior_icon.png")
class_name  UIBehavior
extends Node


signal finished()

@export var duration: float = 1.0
@export var reversable: bool = true

var tween: Tween


## Override to implement specific behavior
func run() -> void:
	_when_finished()


func reset() -> void:
	tween.stop()


## Called at the end of the 'run()' method; internal, DO NOT override
func _when_finished() -> void:
	emit_signal("finished")
