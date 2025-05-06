# Godot UI 3D

A godot add on for 3D UI components.


## Components 

### UIElement3D

- `BehaviorStates`: a list of behaviors to fire during a given state. These are an array to allow to user to add only what they want, and to reuse these as much as possible.


#### States

There are seven types of `STATE` which an element can be interacted with: 
- `WHILE_IDLE`
- `ENTER_FOCUS`
- `WHILE_FOCUS`
- `EXIT_FOCUS`
- `ENTER_SELECT`
- `WHILE_SELECT`
- `EXIT_SELECT`

These states are run when their corresponding interaction method is called.


#### Behaviors

There are 3 types of `Behavior`:
- `MaskBehavior`
- `TransformBehavior`
- `CustomBehavior`

These behaviors are assigned to a state, and will occur when said state is active. Behaviors are savable to allow reusability.


#### Methods

- `_run_behaviors()`: runs the behaviors for the current state


## Dev Notes

- ~this feels overdesigned, needs stricter conditions~
- ~follow the new method approach~
	- ~reverse for state change~
- working much better now, easier to read, and more stable
- still off, but getting closer
- does this really need to be an editor plugin?
