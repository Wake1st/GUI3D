@tool
class_name UIContainer3D
extends Node3D


@export_group("Elements")
@export var elements: Array[UIElement3D]
@export_group("Layout")
@export_range(1, 1024) var rows: int
@export_range(1, 1024) var columns: int
@export_range(0, 1024) var row_spacing: int
@export_range(0, 2048) var column_spacing: int

var container_size: Vector2


func _ready() -> void:
	# calculate container size
	container_size = Vector2(
		columns * column_spacing,
		rows * row_spacing
	)
	
	# setup the elements
	for i in elements.size():
		var element = elements[i]
		add_child(element)
		var column: float = (i % columns) + 0.5
		var row: float = (i % rows) + 0.5
		element.position.x = column * column_spacing - container_size.x/2
		element.position.y = row * row_spacing - container_size.y/2
