class_name UIElement3D
extends MeshInstance3D


enum UIInteractionState {
	WHILE_IDLE,
	ENTER_FOCUS,
	WHILE_FOCUS,
	EXIT_FOCUS,
	ENTER_SELECT,
	WHILE_SELECT,
	EXIT_SELECT,
}

@export_group("Behaviors")
@export_subgroup("While Idle", "idl_whl_")
@export var idl_whl_behaviors: Array[UIBehavior]
@export_subgroup("Focus Changed", "foc_chg_")
@export var foc_chg_behaviors: Array[UIBehavior]
@export_subgroup("While Focused", "foc_whl_")
@export var foc_whl_behaviors: Array[UIBehavior]
@export_subgroup("Select Changed", "sel_chg_")
@export var sel_chg_behaviors: Array[UIBehavior]
@export_subgroup("While Selected", "sel_whl_")
@export var sel_whl_behaviors: Array[UIBehavior]

var idl_whl_has_behaviors: bool
var foc_chg_has_behaviors: bool
var foc_whl_has_behaviors: bool
var sel_chg_has_behaviors: bool
var sel_whl_has_behaviors: bool

var current_state: UIInteractionState
var next_state: UIInteractionState

var runningBehaviors: Array[UIBehavior]
var runningBehaviorCount: int

var interupting: bool = false
var isFocused: bool = false
var isSelected: bool = false
var loopingForward: bool = false


#region IncludedFunctions
func _ready() -> void:
	_setup_collition()
	
	# connect all behaviors
	idl_whl_has_behaviors = _setup_behaviors(idl_whl_behaviors)
	foc_chg_has_behaviors = _setup_behaviors(foc_chg_behaviors)
	foc_whl_has_behaviors = _setup_behaviors(foc_whl_behaviors)
	sel_chg_has_behaviors = _setup_behaviors(sel_chg_behaviors)
	sel_whl_has_behaviors = _setup_behaviors(sel_whl_behaviors)

func _process(_delta) -> void:
	# don't allow adding behaviors unless interupted
	if interupting or runningBehaviorCount <= 0:
		# interupt permitted once
		interupting = false
		
		# only run when finished
		match current_state:
			UIInteractionState.WHILE_IDLE:
				if idl_whl_has_behaviors:
					# the next state is the current state
					loopingForward = not loopingForward
					next_state = current_state
					_run_behaviors(idl_whl_behaviors, loopingForward)
			UIInteractionState.ENTER_FOCUS:
				if foc_chg_has_behaviors:
					next_state = UIInteractionState.WHILE_FOCUS
					_run_behaviors(foc_chg_behaviors, true)
				else:
					current_state = UIInteractionState.WHILE_FOCUS
			UIInteractionState.WHILE_FOCUS:
				if foc_whl_has_behaviors:
					# the next state is the current state
					loopingForward = not loopingForward
					next_state = current_state
					_run_behaviors(foc_whl_behaviors, loopingForward)
			UIInteractionState.EXIT_FOCUS:
				if foc_chg_has_behaviors:
					next_state = UIInteractionState.WHILE_IDLE
					_run_behaviors(foc_chg_behaviors, false)
				else:
					current_state = UIInteractionState.WHILE_IDLE
			UIInteractionState.ENTER_SELECT:
				if sel_chg_has_behaviors:
					next_state = UIInteractionState.WHILE_SELECT
					_run_behaviors(sel_chg_behaviors, true)
				else:
					current_state = UIInteractionState.WHILE_SELECT
			UIInteractionState.WHILE_SELECT:
				if sel_whl_has_behaviors:
					# the next state is the current state
					loopingForward = not loopingForward
					next_state = current_state
					_run_behaviors(sel_whl_behaviors, loopingForward)
			UIInteractionState.EXIT_SELECT:
				if sel_chg_has_behaviors:
					next_state = UIInteractionState.WHILE_FOCUS
					_run_behaviors(sel_chg_behaviors, false)
				else:
					current_state = UIInteractionState.WHILE_FOCUS
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
		current_state = UIInteractionState.ENTER_FOCUS
	else:
		current_state = UIInteractionState.EXIT_FOCUS

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
		current_state = UIInteractionState.ENTER_SELECT
	else:
		current_state = UIInteractionState.EXIT_SELECT
#endregion

#region InternalFunctions
func _setup_collition() -> void:
	# create a static body child
	create_trimesh_collision()
	
	# connect collision shape
	var staticBody: StaticBody3D = get_child(0)
	staticBody.mouse_entered.connect(_on_mouse_entered)
	staticBody.mouse_exited.connect(_on_mouse_exited)

func _setup_behaviors(behaviors: Array[UIBehavior]) -> bool:
	for behavior in behaviors:
		behavior.setup(self)
		behavior.finished.connect(_on_behavior_finished)
	return behaviors.size() > 0

func _run_behaviors(behaviors: Array[UIBehavior], forward: bool = true) -> void:
	# find behaviors with matching state
	runningBehaviors.clear()
	for behavior: UIBehavior in behaviors:
		runningBehaviors.push_back(behavior)
	
	# set the number of behaviors to run
	runningBehaviorCount = runningBehaviors.size()
	
	# run the behaviors
	for behavior in runningBehaviors:
		var tween = get_tree().create_tween()
		if forward:
			behavior.run(tween)
		else:
			behavior.reverse(tween)
#endregion

#region InternalHanders
func _on_behavior_finished() -> void:
	# check if it's time to progress,
	# only transition states if transition required
	runningBehaviorCount -= 1
	if runningBehaviorCount <= 0:
		current_state = next_state

func _on_mouse_entered() -> void:
	focus(true)

func _on_mouse_exited() -> void:
	focus(false)
#endregion
