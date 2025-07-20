class_name Enemy
extends CharacterBody2D

# Enumeration
enum ATTACKS {NONE, SWING, CAST}

@export_category("Stats")

@export_category("Movement Variables")
@export var max_speed := 650
@export var accel_time := 0.5
@export var accel_rate := 1300
@export var h_boost_speed := 1300
@export var h_boost_time := 0.5
@export var h_boost_rate := 2600
@export var jump_height := 240
@export var gravity := 800.0
@export var max_gravity := 1600.0

@export_category("Chasing Variables")
@export var x_distance_to_jump := 100
@export var x_swing_distance := 100
@export var x_cast_distance := 300
@export var y_distance_to_jump := 500
@export var pass_through_time := 0.2
@export var time_to_speed := 4.0

@export_category("Attack Variables")
@export var time_till_cast := 5.0

@onready var state_machine: StateMachine = $StateMachine
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var health_component: HealthComponent = $HealthComponent

# Attack Chosen
var attack = ATTACKS.NONE

func _physics_process(delta: float) -> void:
	health_component.take_damage(delta * 100)
	if state_machine:
		state_machine._physics_process(delta)
	if attack == ATTACKS.NONE:
		choose_attack()
	move_and_slide()

func _process(delta: float) -> void:
	if state_machine:
		state_machine._process(delta)

func choose_attack():
	attack = Helper.rng.randi_range(1, 2)

func _on_animation_finished() -> void:
	state_machine.current_state.on_animation_finished()
