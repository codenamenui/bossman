class_name State
extends Node

# Signals
signal transition_requested(new_state_name: StringName, msg: Dictionary)

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
