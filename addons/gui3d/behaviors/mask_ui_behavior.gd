class_name MaskUIBehavior
extends UIBehavior


@export_color_no_alpha var color: Color
@export var alpha: float 

func setup(element: UIElement3D) -> void:
	super.setup(element)
	
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(color, 0)
	element.set_surface_override_material(1, material)


func run(_tween: Tween) -> void:
	var material: Material = assigned_element.get_surface_override_material(1)
	material.albedo_color = Color(color, alpha)
	
	_when_finished()


func reset() -> void:
	var material: Material = assigned_element.get_surface_override_material(1)
	material.albedo_color = Color(color, alpha)


func reverse(_tween: Tween) -> void:
	var material: Material = assigned_element.get_surface_override_material(1)
	material.albedo_color = Color(color, alpha)
