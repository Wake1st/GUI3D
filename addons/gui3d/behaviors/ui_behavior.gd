@icon("res://addons/gui3d/behaviors/behavior_icon.png")
class_name  UIBehavior
extends Resource


signal finished()

@export var duration: float = 1.0

var assigned_element: UIElement3D
var assigned_tween: Tween


func setup(element: UIElement3D) -> void:
	print("behavior for : %s" % element.name)
	assigned_element = element


## Override to implement specific behavior
func run(tween: Tween) -> void:
	assigned_tween = tween
	_when_finished()


func reset() -> void:
	assigned_tween.stop()


func reverse(tween: Tween) -> void:
	assigned_tween = tween


## Called at the end of the 'run()' method; internal, DO NOT override
func _when_finished() -> void:
	emit_signal("finished")
