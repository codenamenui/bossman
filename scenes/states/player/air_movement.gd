extends PlayerState
class_name AirMovementState

# Ray Collider
var collider

# Timers
var pass_through_timer := 0.0
var first_jump_timer := 0.0
var second_jump_timer := 0.0

# States
var passing_through := false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func enter(msg : Dictionary = {}) -> void:
	passing_through = false
	jumped = JUMP_STATE.ZERO

	if msg.get("drop") == true:
		collider = player.ground_ray.get_collider()
		if collider is TileMapLayer:
			if collider.name == "Platform":
				player.set_collision_mask_value(3, false)
				passing_through = true
				
	if msg.get("jump") == true:
		jumped = JUMP_STATE.FIRST_HELD
		
func exit() -> void:
	player.flying_particle_system_left.emitting = false
	player.flying_particle_system_right.emitting = false
	if collider is TileMapLayer:
		if collider.name == "Platform":
			player.set_collision_mask_value(3, true)

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	if player.is_on_floor() and jumped == JUMP_STATE.FALLING:
		first_jump_timer = 0
		second_jump_timer = 0
		jumped = JUMP_STATE.ZERO
	if player.is_on_floor() and not passing_through and jumped != JUMP_STATE.FIRST_HELD:
		transition_requested.emit("GroundMovement")

	add_gravity(delta)
	get_direction()
	check_pass_through(delta)
	do_vertical_movement(delta)
	tap_handling(delta)
	do_horizontal_movement(delta)
	enable_particles()
	animate_player()
	
func add_gravity(delta):
	if not player.is_on_floor():
		if Input.is_action_just_pressed("jump") and jumped == JUMP_STATE.ZERO:
			player.sprite.play("jump")
			player.velocity.y = 0
			jumped = JUMP_STATE.SECOND
		elif Input.is_action_pressed("jump") and jumped == JUMP_STATE.FALLING and player.velocity.y >= 0 :
			Helper.accelerate(player, player.gravity / 6, player.max_gravity, 1, delta, true)
		else:
			Helper.accelerate(player, player.gravity, player.max_gravity, 1, delta, true)
				
func check_pass_through(delta: float):
	if passing_through:
		pass_through_timer += delta
		if pass_through_timer >= player.pass_through_time:
			passing_through = false
			pass_through_timer = 0.0
			player.set_collision_mask_value(3, true)

func do_vertical_movement(delta: float):
	if jumped != JUMP_STATE.ZERO:
		if Input.is_action_pressed("jump") and jumped == JUMP_STATE.FIRST_HELD:
			first_jump_timer += delta
			if first_jump_timer <= player.a_v_first_time:
				Helper.accelerate(player, player.a_v_first_accel_rate, player.a_v_max_speed, -1, delta, true)
			else:
				first_jump_timer = 0
				jumped = JUMP_STATE.FIRST_WAIT
		elif Input.is_action_just_released("jump") and jumped == JUMP_STATE.FIRST_HELD:
			jumped = JUMP_STATE.FIRST_WAIT
		elif Input.is_action_just_pressed("jump") and jumped == JUMP_STATE.FIRST_WAIT:
			player.sprite.play("jump")
			jumped = JUMP_STATE.SECOND
			player.velocity.y = 0
		
		if Input.is_action_just_released("jump") and jumped == JUMP_STATE.SECOND:
			jumped = JUMP_STATE.FALLING
		elif jumped == JUMP_STATE.SECOND:
			if second_jump_timer <= player.a_v_second_time:
				second_jump_timer += delta
				Helper.accelerate(player, player.a_v_second_accel_rate, player.a_v_max_speed, -1, delta, true)
			else:
				jumped = JUMP_STATE.FALLING
				
	if Input.is_action_just_pressed("jump"):
		if player.ground_ray.get_collider() and jumped != JUMP_STATE.FIRST_HELD:
			player.sprite.play("fall")
			jumped = JUMP_STATE.FIRST_HELD
		
func do_horizontal_movement(delta):
	if dashing:
		dash_timer += delta
		dash_effect_timer += delta
		if dash_effect_timer >= player.d_accel_time / 3:
			create_dash_effect()
			dash_effect_timer = 0
		if dash_timer >= player.d_accel_time:
			dashing = false
			player.velocity.x = player.a_h_max_speed * current_dir
			dash_timer = 0
	elif turning and current_dir:
		turn_timer += delta
		if turn_timer <= player.turning_boost_time:
			Helper.accelerate(player, player.a_h_accel_rate, player.a_h_max_speed, current_dir, delta)
		else:
			turn_timer = 0
			turning = false
	elif current_dir == 0 and abs(player.velocity.x) <= 100:
		player.velocity.x = 0
	elif current_dir == 0:
		var decel_dir = 1 if player.velocity.x <= 0 else -1
		Helper.accelerate(player, player.a_h_decel_rate, player.a_h_max_speed, decel_dir, delta)
	elif current_dir:
		Helper.accelerate(player, player.a_h_accel_rate, player.a_h_max_speed, current_dir, delta)

func enable_particles():
	if jumped == JUMP_STATE.FALLING:
		player.flying_particle_system_left.emitting = true
		player.flying_particle_system_left.spread = 0
		player.flying_particle_system_right.emitting = true
		player.flying_particle_system_right.spread = 0
	elif Input.is_action_pressed("jump"):
		player.flying_particle_system_left.emitting = true
		player.flying_particle_system_left.spread = 75
		player.flying_particle_system_right.emitting = true
		player.flying_particle_system_right.spread = 75
	else:
		player.flying_particle_system_left.emitting = false
		player.flying_particle_system_right.emitting = false
