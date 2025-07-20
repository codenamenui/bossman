extends CharacterBody2D
class_name Player

@export_category("Base Movement Variables")
@export var b_max_speed := 300.0
@export var b_accel_rate := 1000.0
@export var b_accel_time := 1.0
@export var b_decel_rate := 1000.0
@export var b_decel_time := 0.2

@export_category("Dashing Movement Variables")
@export var d_max_speed := 700.0
#@export var d_accel_rate := 1000.0
@export var d_accel_time := 0.2

@export_category("Air Movement Variables")
@export var a_h_max_speed := 300.0
@export var a_h_accel_rate := 1000.0
@export var a_h_accel_time := 1.0
@export var a_h_decel_rate := 1000.0
@export var a_h_decel_time := 0.2
#@export var a_v_max_speed := 500.0
#@export var a_v_first_time := 0.2
#@export var a_v_first_accel_rate := 1000.0
#@export var a_v_second_time := 1.0
#@export var a_v_second_accel_rate := 1000.0
@export var takeoff_velocity := 520.0
@export var takeoff_time := 0.3
@export var gravity := 800.0
@export var max_gravity := 1600.0

@export_category("QOL Variables")
@export var pass_through_time := 0.2
@export var coyote_time := 0.15
@export var double_tap_time := 0.2
@export var turning_boost_time := 0.2

# Nodes
@onready var state_machine : StateMachine = $StateMachine
@onready var ground_ray : RayCast2D = $nearGroundRay
@onready var trail : Line2D = $Trail
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var flying_particle_system_left: CPUParticles2D = $ParticleSystems/FlyingParticleSystemLeft
@onready var flying_particle_system_right: CPUParticles2D = $ParticleSystems/FlyingParticleSystemRight
@onready var running_particle_system: CPUParticles2D = $ParticleSystems/RunningParticleSystem
@onready var health_component: HealthComponent = $HealthComponent

func _ready() -> void:
	sprite.play("idle")
	
func _physics_process(delta: float) -> void:
	state_machine._physics_process(delta)
	#if state_machine.current_state is AirMovementState:
		#sprite.look_at(get_global_mouse_position())
		#line_2d.visible = true
	#else:
		#line_2d.visible = false
		#sprite.rotation = 0
	health_component.take_damage(delta * 100)
	move_and_slide()

func _process(delta: float) -> void:
	state_machine._process(delta)

func get_angle_from_mouse():
	var v = get_global_mouse_position() - global_position + Vector2(20.0, -22.0)
	return rad_to_deg(v.angle())
