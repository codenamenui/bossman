extends State

# Enumerations
enum JUMP_STATE {ZERO, FIRST_HELD, FIRST_WAIT, SECOND, FALLING}

# Nodes
var player : Player

# Ray Collider
var collider

# Timers
var pass_through_timer := 0.0
var last_tap_timer := 0.0
var dash_timer := 0.0
var second_jump_timer := 0.0
var turn_timer := 0.0

# Sample Points
var h_point := 0.0
var v_first_point := 0.0
var v_second_point := 0.0

# States
var passing_through := false
var jumped := JUMP_STATE.ZERO
var tapped := TAP_STATE.NONE
var dashing := false
var turning := false

# Directions
var current_dir := 0
var previous_dir := 0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func enter(msg : Dictionary = {}) -> void:
	v_first_point = 0
	v_second_point = 0
	h_point = 0
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
	player.animated_sprite_2d.play("idle")
	player.sprite.color = Color.WHITE
	if collider is TileMapLayer:
		if collider.name == "Platform":
			player.set_collision_mask_value(3, true)

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		if Input.is_action_just_pressed("jump") and jumped == JUMP_STATE.ZERO:
			jumped = JUMP_STATE.SECOND
		elif Input.is_action_pressed("jump") and jumped == JUMP_STATE.FALLING:
			Helper.accelerate(player, player.gravity / 6, 1, player.max_gravity, delta, true)
		else:
			Helper.accelerate(player, player.gravity, 1, player.max_gravity, delta, true)
	
	check_pass_through(delta)
	tap_handling(delta)
	do_vertical_movement(delta)
	if not dashing:
		get_direction()
	do_horizontal_movement(delta)
	color_player()
	animate_player()
	enable_particles()
	
	if player.is_on_floor() and jumped == JUMP_STATE.FALLING:
		v_first_point = 0
		v_second_point = 0
		second_jump_timer = 0
		jumped = JUMP_STATE.ZERO
	if player.is_on_floor() and not passing_through and jumped != JUMP_STATE.FIRST_HELD:
		transition_requested.emit("Idle")
	
func check_pass_through(delta: float):
	if passing_through:
		pass_through_timer += delta
		if pass_through_timer >= player.pass_through_time:
			passing_through = false
			pass_through_timer = 0.0
			player.set_collision_mask_value(3, true)

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
			
func do_vertical_movement(delta: float):
	if jumped != JUMP_STATE.ZERO:
		if Input.is_action_pressed("jump") and jumped == JUMP_STATE.FIRST_HELD:
			if v_first_point < 1:
				Helper.accelerate_with_curve(v_first_point, player, player.a_v_accel_curve, player.accel_rate, player.a_v_max_speed, -1, delta, true)
				v_first_point = Helper.addSample(v_first_point, delta, player.a_v_first_time)
			else:
				jumped = JUMP_STATE.FIRST_WAIT
		elif Input.is_action_just_released("jump") and jumped == JUMP_STATE.FIRST_HELD:
			jumped = JUMP_STATE.FIRST_WAIT
		elif Input.is_action_just_pressed("jump") and jumped == JUMP_STATE.FIRST_WAIT:
			jumped = JUMP_STATE.SECOND
			player.velocity.y = 0
		
		if Input.is_action_just_released("jump") and jumped == JUMP_STATE.SECOND:
			second_jump_timer = 0
		elif Input.is_action_pressed("jump") and jumped == JUMP_STATE.SECOND:
			if second_jump_timer <= player.a_v_second_time:
				second_jump_timer += delta
				v_second_point = Helper.addSample(v_second_point, delta, player.a_v_second_time)
				Helper.accelerate_with_curve(v_second_point, player, player.a_v_accel_curve, player.accel_rate, player.a_v_max_speed, -1, delta, true)
			else:
				jumped = JUMP_STATE.FALLING
				
	if Input.is_action_just_pressed("jump"):
		if player.ground_ray.get_collider() and jumped != JUMP_STATE.FIRST_HELD:
			v_first_point = 0
			v_second_point = 0
			jumped = JUMP_STATE.FIRST_HELD

func get_direction():
	current_dir = Input.get_axis("left", "right")
	
	if previous_dir != current_dir:
		h_point = 0
		if current_dir != 0:
			turning = true
	
	if current_dir != 0:
		previous_dir = current_dir
		
func do_horizontal_movement(delta):
	if dashing:
		dash_timer += delta
		if dash_timer >= player.d_max_time:
			dashing = false
			player.velocity.x = player.a_h_max_speed * current_dir
			dash_timer = 0
	elif turning:
		turn_timer += delta
		if turn_timer <= player.turning_boost_time:
			Helper.accelerate_with_curve(h_point, player, player.a_h_accel_curve, player.accel_rate * 4, player.a_h_max_speed, current_dir, delta)
			h_point = Helper.addSample(h_point, delta, player.a_h_accel_time)
		else:
			turn_timer = 0
			turning = false
	elif current_dir == 0 and abs(player.velocity.x) <= 100:
		player.velocity.x = 0
	elif current_dir == 0:
		Helper.accelerate_with_curve(h_point, player, player.a_h_deccel_curve, player.accel_rate, player.a_h_max_speed, -previous_dir, delta)
		h_point = Helper.addSample(h_point, delta, player.a_h_deccel_time)
	elif current_dir:
		Helper.accelerate_with_curve(h_point, player, player.a_h_accel_curve, player.accel_rate, player.a_h_max_speed, current_dir, delta)
		h_point = Helper.addSample(h_point, delta, player.a_h_accel_time)

func color_player():
	if jumped == JUMP_STATE.SECOND:
		player.sprite.color = lerp(Color.BLUE, Color.RED, v_second_point)
	elif jumped == JUMP_STATE.FIRST_HELD:
		player.sprite.color = lerp(Color.WHITE, Color.BLUE, v_first_point)
	else:
		player.sprite.color = Color.WHITE

func animate_player():
	if Input.is_action_pressed("jump") and jumped == JUMP_STATE.FALLING:
		player.animated_sprite_2d.play("falling")
	elif Input.is_action_pressed("jump"):
		player.animated_sprite_2d.play("flapping")
	else:
		player.animated_sprite_2d.play("idle")
		
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

func create_dash_effect():
	var playerCopyNode = player.sprite.duplicate()
	get_parent().get_parent().get_node("Sprite2D").add_child(playerCopyNode)
	playerCopyNode.global_position = player.global_position
	
	var animation_time = player.d_max_time / 3
	await get_tree().create_timer(animation_time).timeout
	playerCopyNode.modulate.a = 0.4
	await get_tree().create_timer(animation_time).timeout
	playerCopyNode.modulate.a = 0.2
	await get_tree().create_timer(animation_time).timeout
	playerCopyNode.queue_free()
