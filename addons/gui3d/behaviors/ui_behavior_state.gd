@icon("res://addons/gui3d/behaviors/behavior_state_icon.png")
class_name UIBehaviorState
extends Node


enum UIInteractionState {
	WHILE_IDLE,
	ENTER_FOCUS,
	WHILE_FOCUS,
	EXIT_FOCUS,
	ENTER_SELECT,
	WHILE_SELECT,
	EXIT_SELECT,
}

@export var interaction_state: UIInteractionState
@export var behavior: UIBehavior
