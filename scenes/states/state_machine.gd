class_name StateMachine
extends Node

@export var initial_state: State

var current_state: State
var changing_state_to = null
var new_msg = {}
var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transition_requested.connect(_on_state_transition_requested)
	
	change_state(initial_state)
			
func change_state(new_state: State, msg: Dictionary = {}) -> void:
	if not new_state:
			push_error("Tried to transition to a null state!")
			return
			
	changing_state_to = new_state
	new_msg = msg

func _on_state_transition_requested(new_state_name: StringName, msg: Dictionary = {}) -> void:
	if states.has(new_state_name):
		change_state(states[new_state_name], msg)
	else:
		push_error("State '%s' not found!" % new_state_name)

func _physics_process(delta: float) -> void:
	if changing_state_to != null:
		if current_state:
			current_state.exit()
		
		current_state = changing_state_to
		current_state.enter(new_msg)
		
		changing_state_to = null
		new_msg = {}
		
	if current_state:
		current_state.physics_update(delta)

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)
