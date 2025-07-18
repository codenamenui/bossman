class_name State
extends Node

# Signals
signal transition_requested(new_state_name: StringName, msg: Dictionary)

# Enumerations
enum TAP_STATE {NONE, LEFT_TAP, RIGHT_TAP, LEFT_WAITING, RIGHT_WAITING}
enum SPRINT_STATE {NOT, MAX_SPEED, SPRINTING}

func _ready() -> void:
	pass

func enter(msg : Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	pass
