class_name PlayerState
extends State

# Enumerations
enum TAP_STATE {NONE, LEFT_TAP, RIGHT_TAP, LEFT_WAITING, RIGHT_WAITING}
enum SPRINT_STATE {NOT, MAX_SPEED, SPRINTING}
enum JUMP_STATE {ZERO, FIRST_HELD, FIRST_WAIT, SECOND, FALLING}

# Static Variable
static var player : Player

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
static var jumped := JUMP_STATE.ZERO

# Static Directions
static var current_dir := 0
static var previous_dir := 1

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func get_direction():
	current_dir = Input.get_axis("left", "right")
	
	if previous_dir != current_dir:
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
	playerCopyNode.z_index = 1
	
	if current_dir == 1:
		playerCopyNode.flip_h = false
	else:
		playerCopyNode.flip_h = true
		
	var animation_time = player.d_accel_time / 3
	await get_tree().create_timer(animation_time).timeout
	playerCopyNode.modulate.a = 0.4
	await get_tree().create_timer(animation_time).timeout
	playerCopyNode.modulate.a = 0.2
	await get_tree().create_timer(animation_time).timeout
	playerCopyNode.queue_free()

func animate_player():
	player.sprite.speed_scale = 1
	var state : State = player.state_machine.current_state
	
	if Input.is_action_pressed("attack"):
		player.sprite.play("attack")
	
	if player.sprite.animation == "attack":
		if state is AirMovementState:
			player.sprite.flip_h = false
			player.sprite.look_at(player.get_global_mouse_position())
		elif state is GroundMovementState or state is IdleState:
			var direction = player.get_global_mouse_position().x - player.sprite.global_position.x
			player.sprite.flip_h = direction < 0
			if state is IdleState:
				current_dir = direction > 0
				previous_dir = direction > 0
		if player.sprite.is_playing():
			return
	else:
		player.sprite.rotation = 0
		
	player.sprite.flip_h = current_dir != 1
	
	if player.sprite.animation == "jump":
		if player.sprite.is_playing():
			return
	
	if player.sprite.animation == "fall":
		if not player.is_on_floor():
			return
	
	if state is IdleState:
		if previous_dir == 1:
			player.sprite.flip_h = false
		else:
			player.sprite.flip_h = true
		player.sprite.play("idle")
	elif state is GroundMovementState:
		if current_dir != 0:
			player.sprite.play("run")
		player.sprite.speed_scale = lerp(1, 7, player.velocity.x / player.b_max_speed)
	elif state is AirMovementState:
		if not player.is_on_floor():
			player.sprite.play("fall")
