class_name Enemy
extends CharacterBody2D

@export_category("Stats")

@export_category("Movement Variables")
@export var max_speed := 650
@export var accel_time := 1.0
@export var accel_rate := 1000
@export var jump_speed := 700.0
@export var jump_time := 0.2
@export var jump_accel_rate := 1000.0
@export var gravity := 800.0
@export var max_gravity := 800.0

@export_category("Chasing Variables")
@export var x_distance_to_jump := 100
@export var x_attack_distance := 300
@export var y_distance_to_jump := 500
@export var pass_through_time := 0.2

@onready var state_machine: StateMachine = $StateMachine
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Hurtbox

func _physics_process(delta: float) -> void:
	if state_machine:
		state_machine._physics_process(delta)
	move_and_slide()

func _process(delta: float) -> void:
	if state_machine:
		state_machine._process(delta)
