class_name UIContainer3D
extends Node3D


@export_group("Elements")
@export var elements: Array[UIElement3D]
@export_group("Layout")
@export_range(1, 64) var columns: int
@export_range(0, 16) var row_spacing: float
@export_range(0, 16) var column_spacing: float

var container_size: Vector2


func _ready() -> void:
	# store sizing
	var row_count = elements.size() / columns
	container_size = Vector2(
		columns * column_spacing,
		row_count * row_spacing
	)


func setup() -> void:
	# setup the elements
	for i in elements.size():
		var element = elements[i]
		var column: float = (i % columns) + 0.5
		var row: float = floori(i / columns) + 0.5
		element.position.x = column * column_spacing - container_size.x/2
		element.position.y = container_size.y/2 - row * row_spacing
		
		element.setup()
		
		element.focus_changed.connect(handle_element_focused)
		element.select_changed.connect(handle_element_selected)


func handle_element_focused(element: UIElement3D) -> void:
	print("focused: %s" % element.name)


func handle_element_selected(element: UIElement3D) -> void:
	print("selected: %s" % element.name)
