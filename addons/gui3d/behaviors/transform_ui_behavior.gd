class_name TransformUIBehavior
extends UIBehavior


@export var adjusted_position: Vector3
@export var adjusted_rotation: Vector3
@export var adjusted_scale: Vector3

var original_position: Vector3
var original_rotation: Vector3
var original_scale: Vector3


func run() -> void:
	# store initial states
	original_position = get_parent().get_parent().get_parent().position
	original_rotation = get_parent().get_parent().get_parent().rotation
	original_scale = get_parent().get_parent().get_parent().scale
	
	# execute transform behavior
	_perform_transform(
		original_position + adjusted_position,
		original_rotation + adjusted_rotation,
		original_scale + adjusted_scale,
	)
	
	# if not reversed, then end it
	if reversable:
		tween.tween_callback(_reverse)
	else:
		# calls to notify any listeners
		tween.tween_callback(_on_complete)


func reset() -> void:
	# stop tween
	tween.stop()
	
	# restore initial states
	get_parent().get_parent().get_parent().position = original_position
	get_parent().get_parent().get_parent().rotation = original_rotation
	get_parent().get_parent().get_parent().scale = original_scale


func _reverse() -> void:
	# return transform to original state
	_perform_transform(
		original_position,
		original_rotation,
		original_scale,
	)
	
	# only reset from here
	tween.tween_callback(_on_complete)


func _perform_transform(
	target_position: Vector3, 
	target_rotation: Vector3, 
	target_scale: Vector3
) -> void:
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		get_parent().get_parent().get_parent(), 
		"position", 
		target_position,
		duration
	)
	tween.tween_property(
		get_parent().get_parent().get_parent(),
		"rotation",
		target_rotation,
		duration
	)
	tween.tween_property(
		get_parent().get_parent().get_parent(),
		"scale",
		target_scale,
		duration
	)
	tween.set_parallel(false)


func _on_complete() -> void:
	super._when_finished()
