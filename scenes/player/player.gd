extends CharacterBody2D
class_name Player

@export_category("Acceleration Rate")
@export var accel_rate = 1000

@export_category("Base Movement Variables")
@export var b_max_speed := 300.0
@export var b_accel_time := 1.0
@export var b_deccel_time := 0.2
@export var b_accel_curve : Curve
@export var b_deccel_curve : Curve

@export_category("Sprint Movement Variables")
@export var time_to_sprint := 1.0
@export var s_max_speed := 300.0
@export var s_accel_time := 1.0
@export var s_deccel_time := 0.2
@export var s_accel_curve : Curve
@export var s_deccel_curve : Curve

@export_category("Dashing Movement Variables")
@export var d_max_speed := 700.0
@export var d_max_time := 0.2

@export_category("Air Movement Variables")
@export var a_h_max_speed := 300.0
@export var a_h_accel_time := 1.0
@export var a_h_deccel_time := 0.2
@export var a_h_accel_curve : Curve
@export var a_h_deccel_curve : Curve
@export var a_v_max_speed := 300.0
@export var a_v_first_time := 1.0
@export var a_v_second_time := 1.0
@export var a_v_accel_curve : Curve
@export var gravity := 800
@export var max_gravity := 800

@export_category("QOL Variables")
@export var pass_through_time := 0.2
@export var coyote_time := 0.15
@export var double_tap_time := 0.2

# Nodes
@onready var state_machine : StateMachine = $StateMachine
@onready var sprite : ColorRect = $Sprite2D/ColorRect
@onready var ground_ray : RayCast2D = $nearGroundRay
@onready var trail : Line2D = $Trail
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var flying_particle_system_left: CPUParticles2D = $ParticleSystems/FlyingParticleSystemLeft
@onready var flying_particle_system_right: CPUParticles2D = $ParticleSystems/FlyingParticleSystemRight
@onready var running_particle_system: CPUParticles2D = $ParticleSystems/RunningParticleSystem

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	state_machine._physics_process(delta)
	move_and_slide()

func _process(delta: float) -> void:
	state_machine._process(delta)
