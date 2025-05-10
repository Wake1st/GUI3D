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

signal focus_changed(element: UIElement3D)
signal select_changed(element: UIElement3D)

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

var has_idl_whl_behaviors: bool
var has_foc_chg_behaviors: bool
var has_foc_whl_behaviors: bool
var has_sel_chg_behaviors: bool
var has_sel_whl_behaviors: bool

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
	idl_whl_behaviors = _setup_behaviors(idl_whl_behaviors)
	has_idl_whl_behaviors = idl_whl_behaviors.size() > 0
	foc_chg_behaviors = _setup_behaviors(foc_chg_behaviors)
	has_foc_chg_behaviors = foc_chg_behaviors.size() > 0
	foc_whl_behaviors = _setup_behaviors(foc_whl_behaviors)
	has_foc_whl_behaviors = foc_whl_behaviors.size() > 0
	sel_chg_behaviors = _setup_behaviors(sel_chg_behaviors)
	has_sel_chg_behaviors = sel_chg_behaviors.size() > 0
	sel_whl_behaviors = _setup_behaviors(sel_whl_behaviors)
	has_sel_whl_behaviors = sel_whl_behaviors.size() > 0

func _process(_delta) -> void:
	# don't allow adding behaviors unless interupted
	if interupting or runningBehaviorCount <= 0:
		# interupt permitted once
		interupting = false
		
		# only run when finished
		match current_state:
			UIInteractionState.WHILE_IDLE:
				if has_idl_whl_behaviors:
					# the next state is the current state
					loopingForward = not loopingForward
					next_state = current_state
					_run_behaviors(idl_whl_behaviors, loopingForward)
			UIInteractionState.ENTER_FOCUS:
				if has_foc_chg_behaviors:
					next_state = UIInteractionState.WHILE_FOCUS
					_run_behaviors(foc_chg_behaviors, true)
				else:
					current_state = UIInteractionState.WHILE_FOCUS
					interupting = true
			UIInteractionState.WHILE_FOCUS:
				if has_foc_whl_behaviors:
					# the next state is the current state
					loopingForward = not loopingForward
					next_state = current_state
					_run_behaviors(foc_whl_behaviors, loopingForward)
			UIInteractionState.EXIT_FOCUS:
				if has_foc_chg_behaviors:
					next_state = UIInteractionState.WHILE_IDLE
					_run_behaviors(foc_chg_behaviors, false)
				else:
					current_state = UIInteractionState.WHILE_IDLE
					interupting = true
			UIInteractionState.ENTER_SELECT:
				if has_sel_chg_behaviors:
					next_state = UIInteractionState.WHILE_SELECT
					_run_behaviors(sel_chg_behaviors, true)
				else:
					current_state = UIInteractionState.WHILE_SELECT
					interupting = true
			UIInteractionState.WHILE_SELECT:
				if has_sel_whl_behaviors:
					# the next state is the current state
					loopingForward = not loopingForward
					next_state = current_state
					_run_behaviors(sel_whl_behaviors, loopingForward)
			UIInteractionState.EXIT_SELECT:
				if has_sel_chg_behaviors:
					next_state = UIInteractionState.WHILE_FOCUS
					_run_behaviors(sel_chg_behaviors, false)
				else:
					current_state = UIInteractionState.WHILE_FOCUS
					interupting = true
#endregion

#region InterruptFunctions
func focus(value: bool = true) -> void:
	# selected overrides focused and check for actual change
	if isSelected || isFocused == value:
		return
	
	# toggle interupt
	interupting = true
	
	# set the state for external read
	isFocused = value
	emit_signal("focus_changed", self)
	
	# no matter the state, override the value
	if value:
		current_state = UIInteractionState.ENTER_FOCUS
		_reset_running_behaviors()
	else:
		# if there's no change state, we should manually reverse the while state
		if not has_foc_chg_behaviors and has_foc_whl_behaviors:
			next_state = UIInteractionState.EXIT_FOCUS
			_run_behaviors(foc_whl_behaviors, false)
			interupting = false
		else:
			current_state = UIInteractionState.EXIT_FOCUS
			_reset_running_behaviors()

func select(value: bool = true) -> void:
	# check for an actual change
	if isSelected == value:
		return
	
	# toggle interupt
	interupting = true
	
	# set the state for external read
	isSelected = value
	emit_signal("select_changed", self)
	
	# no matter the state, override the value
	if value:
		current_state = UIInteractionState.ENTER_SELECT
		_reset_running_behaviors()
	else:
		# if there's no change state, we should manually reverse the while state
		if not has_sel_chg_behaviors and has_sel_whl_behaviors:
			next_state = UIInteractionState.EXIT_SELECT
			_run_behaviors(sel_whl_behaviors, false)
			interupting = false
		else:
			current_state = UIInteractionState.EXIT_SELECT
			_reset_running_behaviors()
#endregion

#region InternalFunctions
func _setup_collition() -> void:
	# create a static body child
	#create_trimesh_collision()
	
	# connect collision shape
	var staticBody: StaticBody3D = get_node("StaticBody3D")
	staticBody.mouse_entered.connect(_on_mouse_entered)
	staticBody.mouse_exited.connect(_on_mouse_exited)

func _setup_behaviors(behaviors: Array[UIBehavior]) -> Array[UIBehavior]:
	# duplicate the behaviors for them to be unique per element
	var copies: Array[UIBehavior]
	for behavior in behaviors:
		var copy = behavior.duplicate(true)
		copy.setup(self)
		copy.finished.connect(_on_behavior_finished)
		copies.push_back(copy)
	
	# return duplicate array
	return copies

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

func _reset_running_behaviors() -> void:
	# reset all running behaviors
	for behavior in runningBehaviors:
		behavior.reset()
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
