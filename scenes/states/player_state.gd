class_name PlayerState
extends State

# Enumerations
enum TAP_STATE {NONE, LEFT_TAP, RIGHT_TAP, LEFT_WAITING, RIGHT_WAITING}
enum SPRINT_STATE {NOT, MAX_SPEED, SPRINTING}
enum JUMP_STATE {ZERO, FIRST_HELD, FIRST_WAIT, SECOND, FALLING}

# Static Variable
static var player : Player

# Static Goals
static var deceleration_goal := 0

# Static Timers
static var dash_timer := 0.0
static var dash_effect_timer := 0.0
static var last_tap_timer := 0.0
static var turn_timer := 0.0

# Static States
static var tapped := TAP_STATE.NONE
static var dashing := false
static var turning := false
static var sprinting := SPRINT_STATE.NOT

# Static Directions
var current_dir := 0
var previous_dir := 0

# Static Sample Points
static var h_point := 0.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func get_direction():
	if Input.is_action_pressed("left") and Input.is_action_pressed("right"):
		current_dir = 0
	elif Input.is_action_pressed("right"):
		current_dir = 1
	elif Input.is_action_pressed("left"):
		current_dir = -1
	else:
		current_dir = 0
	
	if previous_dir != current_dir:
		h_point = 0
		if current_dir != 0:
			turning = true
	
	if current_dir != 0:
		previous_dir = current_dir
		
	if current_dir == 0:
		turning = false
		turn_timer = 0
		
func tap_handling(delta: float):
	if tapped:
		last_tap_timer += delta
		if last_tap_timer >= player.double_tap_time:
			last_tap_timer = 0
			tapped = TAP_STATE.NONE
	
	if Input.is_action_just_released("left"):
		if tapped == TAP_STATE.LEFT_TAP:
			tapped = TAP_STATE.LEFT_WAITING
	elif Input.is_action_just_released("right"):
		if tapped == TAP_STATE.RIGHT_TAP:
			tapped = TAP_STATE.RIGHT_WAITING
			
	if Input.is_action_just_pressed("left"):
		if tapped == TAP_STATE.LEFT_WAITING:
			dashing = true
			create_dash_effect()
			player.velocity.x = -player.d_max_speed
		else:
			tapped = TAP_STATE.LEFT_TAP
	elif Input.is_action_just_pressed("right"):
		if tapped == TAP_STATE.RIGHT_WAITING:
			dashing = true
			create_dash_effect()
			player.velocity.x = player.d_max_speed
		else:
			tapped = TAP_STATE.RIGHT_TAP

func create_dash_effect():
	var playerCopyNode: AnimatedSprite2D = player.sprite.duplicate()
	get_parent().get_parent().get_parent().add_child(playerCopyNode)
	playerCopyNode.global_position = player.global_position
	playerCopyNode.position.y += -16
	if current_dir == 1:
		playerCopyNode.flip_h = false
	else:
		playerCopyNode.flip_h = true
		
	var animation_time = player.d_max_time / 3
	await get_tree().create_timer(animation_time).timeout
	playerCopyNode.modulate.a = 0.4
	await get_tree().create_timer(animation_time).timeout
	playerCopyNode.modulate.a = 0.2
	await get_tree().create_timer(animation_time).timeout
	playerCopyNode.queue_free()

func animate_player():
	var state : State = player.state_machine.current_state
	player.sprite.speed_scale = 1
	if state is GroundMovementState:
		if current_dir != 0:
			if current_dir == 1:
				player.sprite.flip_h = false
			else:
				player.sprite.flip_h = true
			player.sprite.play("run")
			if sprinting:
				player.sprite.speed_scale = 6
		else:
			player.sprite.play("idle")
	elif state is IdleState:
		player.sprite.play("idle")
