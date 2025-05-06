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

_ `_while_idle()`: runs while element is idle
- `_enter_focus()`: runs when an element is in focus
- `_while_focus()`: runs while an element has focus
- `_exit_focus()`: runs when an element looses focus
- `_on_selection()`: runs when an element is selected 
- `_while_selected()`: runs while an element is selected 
- `_off_selection()`: runs when an element is unselected 


## Dev Notes

- this feels overdesigned, needs stricter conditions
- does this really need to be an editor plugin?
