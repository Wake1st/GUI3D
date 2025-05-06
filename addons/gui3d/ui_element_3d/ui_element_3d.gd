class_name UIElement3D
extends MeshInstance3D


enum LOOPING_STATE {
	LOOP,
	TRANSITION,
	NONE,
}

@export var behavior_states: Array[UIBehaviorState]

var interupting: bool = false
var isFocused: bool = false
var isSelected: bool = false

var current_state: UIBehaviorState.UIInteractionState
var next_state: UIBehaviorState.UIInteractionState
var looping_state: LOOPING_STATE

var runningBehaviors: Array[UIBehavior]
var runningBehaviorCount: int


#region IncludedFunctions
func _ready() -> void:
	# create a static body child
	create_trimesh_collision()
	
	# connect collision shape
	var staticBody: StaticBody3D = get_child(get_child_count() - 1)
	staticBody.mouse_entered.connect(_on_mouse_entered)
	staticBody.mouse_exited.connect(_on_mouse_exited)
	
	# connect all behaviors
	for bs in behavior_states:
		bs.behavior.finished.connect(_on_behavior_finished)


func _process(_delta) -> void:
	# don't allow adding behaviors unless interupted
	if interupting or runningBehaviorCount <= 0:
		# interupt permitted once
		interupting = false
		
		# only run when finished
		#print("loop: %s\tbehavior: %s" % [looping_state, current_state])
		match looping_state:
			LOOPING_STATE.LOOP:
				_run_looping_behaviors()
			LOOPING_STATE.TRANSITION:
				match current_state:
					UIBehaviorState.UIInteractionState.ENTER_FOCUS:
						_enter_focus()
					UIBehaviorState.UIInteractionState.EXIT_FOCUS:
						_exit_focus()
					UIBehaviorState.UIInteractionState.ENTER_SELECT:
						_enter_select()
					UIBehaviorState.UIInteractionState.EXIT_SELECT:
						_exit_select()
#endregion


#region InterruptFunctions
func focus(value: bool = true) -> void:
	# do not permit interuptions of selected element
	if isSelected:
		return
	
	# toggle interupt
	interupting = true
	
	# set the state for external read
	isFocused = value
	
	# reset all running behaviors
	for behavior in runningBehaviors:
		behavior.reset()
	
	# no matter the state, override the value
	if value:
		current_state = UIBehaviorState.UIInteractionState.ENTER_FOCUS
		looping_state = LOOPING_STATE.TRANSITION
	else:
		current_state = UIBehaviorState.UIInteractionState.EXIT_FOCUS
		looping_state = LOOPING_STATE.TRANSITION


func select(value: bool = true) -> void:
	# toggle interupt
	interupting = true
	
	# set the state for external read
	isSelected = value
	
	# reset all running behaviors
	for behavior in runningBehaviors:
		behavior.reset()
	
	# no matter the state, override the value
	if value:
		current_state = UIBehaviorState.UIInteractionState.ENTER_SELECT
		looping_state = LOOPING_STATE.TRANSITION
	else:
		current_state = UIBehaviorState.UIInteractionState.EXIT_SELECT
		looping_state = LOOPING_STATE.TRANSITION
#endregion


#region BehaviorFunctions
func _run_looping_behaviors() -> void:
	# find behaviors with matching state
	runningBehaviors.clear()
	for bs: UIBehaviorState in behavior_states:
		if bs.interaction_state == current_state:
			runningBehaviors.push_back(bs.behavior)
	
	# set the number of behaviors to run
	runningBehaviorCount = runningBehaviors.size()
	if runningBehaviorCount == 0:
		# nothing to loop
		looping_state = LOOPING_STATE.NONE
	else:
		# run the behaviors
		for behavior in runningBehaviors:
			behavior.run()


func _enter_focus() -> void:
	# first, set the transition states
	next_state = UIBehaviorState.UIInteractionState.WHILE_FOCUS
	
	# run what behaviors exist
	_run_transition_behaviors()


func _exit_focus() -> void:
	# first, set the transition state
	next_state = UIBehaviorState.UIInteractionState.WHILE_IDLE
	
	# run what behaviors exist
	_run_transition_behaviors()


func _enter_select() -> void:
	# first, set the transition state
	next_state = UIBehaviorState.UIInteractionState.WHILE_SELECT
	
	# run what behaviors exist
	_run_transition_behaviors()


func _exit_select() -> void:
	# first, set the transition state
	next_state = UIBehaviorState.UIInteractionState.WHILE_FOCUS
	
	# run what behaviors exist
	_run_transition_behaviors()


func _run_transition_behaviors() -> void:
	# find behaviors with matching state
	runningBehaviors.clear()
	for bs: UIBehaviorState in behavior_states:
		if bs.interaction_state == current_state:
			runningBehaviors.push_back(bs.behavior)
	
	# set the number of behaviors to run
	runningBehaviorCount = runningBehaviors.size()
	
	# if no behaviors, simply transition
	if runningBehaviorCount == 0:
		_on_behavior_finished()
	else:
		# run the behaviors
		for behavior in runningBehaviors:
			behavior.run()
#endregion


#region InternalHanders
func _on_behavior_finished() -> void:
	# check if it's time to progress,
	# only transition states if transition required
	runningBehaviorCount -= 1
	if runningBehaviorCount <= 0 and looping_state == LOOPING_STATE.TRANSITION:
		looping_state = LOOPING_STATE.LOOP
		current_state = next_state

func _on_mouse_entered() -> void:
	focus(true)

func _on_mouse_exited() -> void:
	focus(false)
#endregion
