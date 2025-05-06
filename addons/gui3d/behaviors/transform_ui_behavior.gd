class_name TransformUIBehavior
extends UIBehavior


@export var adjusted_position: Vector3
@export var adjusted_rotation: Vector3
@export var adjusted_scale: Vector3

var original_position: Vector3
var original_rotation: Vector3
var original_scale: Vector3

var assigned_element: UIElement3D


func setup(element: UIElement3D) -> void:
	# store acting element
	assigned_element = element
	
	# store initial states
	original_position = element.position
	original_rotation = element.rotation
	original_scale = element.scale


func run() -> void:
	print(
		("assigned_element.position: %s\toriginal_position: %s\n" \
		+ "assigned_element.rotation: %s\toriginal_rotation: %s\n" \
		+ "assigned_element.scale: %s\toriginal_scale: %s\n") % [
		assigned_element.position, original_position,
		assigned_element.rotation, original_rotation,
		assigned_element.scale, original_scale,
		]
	)
	
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
	tween.kill()
	
	# restore initial states
	assigned_element.position = original_position
	assigned_element.rotation = original_rotation
	assigned_element.scale = original_scale
	
	print(
		("assigned_element.position: %s\toriginal_position: %s\n" \
		+ "assigned_element.rotation: %s\toriginal_rotation: %s\n" \
		+ "assigned_element.scale: %s\toriginal_scale: %s\n") % [
		assigned_element.position, original_position,
		assigned_element.rotation, original_rotation,
		assigned_element.scale, original_scale,
		]
	)


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
		assigned_element, 
		"position", 
		target_position,
		duration
	)
	tween.tween_property(
		assigned_element,
		"rotation",
		target_rotation,
		duration
	)
	tween.tween_property(
		assigned_element,
		"scale",
		target_scale,
		duration
	)
	tween.set_parallel(false)


func _on_complete() -> void:
	super._when_finished()
