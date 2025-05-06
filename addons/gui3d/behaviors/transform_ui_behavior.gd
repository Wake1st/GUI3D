@icon("res://addons/gui3d/behaviors/behavior_icon.png")
class_name TransformUIBehavior
extends UIBehavior


@export var adjusted_position: Vector3
@export var adjusted_rotation: Vector3
@export var adjusted_scale: Vector3

var original_position: Vector3
var original_rotation: Vector3
var original_scale: Vector3


func setup(element: UIElement3D) -> void:
	super.setup(element)
	
	# store initial states
	original_position = element.position
	original_rotation = element.rotation
	original_scale = element.scale


func run(tween: Tween) -> void:
	# store acting element
	assigned_tween = tween
	
	# execute transform behavior
	_perform_transform(
		original_position + adjusted_position,
		original_rotation + adjusted_rotation,
		original_scale + adjusted_scale,
	)
	
	# if not reversed, then end it
	assigned_tween.tween_callback(_on_complete)


func reset() -> void:
	# stop tween
	assigned_tween.stop()


func reverse(tween: Tween) -> void:
	# store acting element
	assigned_tween = tween
	
	# return transform to original state
	_perform_transform(
		original_position,
		original_rotation,
		original_scale,
	)
	
	# only reset from here
	assigned_tween.tween_callback(_on_complete)


func _perform_transform(
	target_position: Vector3, 
	target_rotation: Vector3, 
	target_scale: Vector3
) -> void:
	assigned_tween.set_parallel(true)
	assigned_tween.tween_property(
		assigned_element, 
		"position", 
		target_position,
		duration
	)
	assigned_tween.tween_property(
		assigned_element,
		"rotation",
		target_rotation,
		duration
	)
	assigned_tween.tween_property(
		assigned_element,
		"scale",
		target_scale,
		duration
	)
	assigned_tween.set_parallel(false)


func _on_complete() -> void:
	super._when_finished()
