extends PlayerState
class_name GroundMovementState

# Timers
var coyote_timer := 0.0
var sprint_timer := 0.0

# States
var in_coyote := false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func enter(msg : Dictionary = {}) -> void:
	if msg.get("from_idle"):
		player.velocity.x = 0.0001
	coyote_timer = 0
	in_coyote = false
	h_point = 0

func exit() -> void:
	player.running_particle_system.emitting = false

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	if player.velocity.x == 0:
		transition_requested.emit("Idle")
	coyote_handling(delta)
	get_direction()
	get_vertical_actions()
	tap_handling(delta)
	move_player(delta)
	enable_particles()
	animate_player()
		
func coyote_handling(delta):
	if not player.is_on_floor() and not in_coyote:
		in_coyote = true
	elif player.is_on_floor() and in_coyote:
		in_coyote = false
	elif in_coyote:
		coyote_timer += delta
		Helper.accelerate(player, player.gravity, 1, player.max_gravity, delta, true)
		if coyote_timer >= player.coyote_time:
			coyote_timer = 0
			transition_requested.emit("AirMovement")
	
func get_vertical_actions():
	if Input.is_action_just_pressed("jump"):
		transition_requested.emit("AirMovement", {"jump" : true})
	elif Input.is_action_just_pressed("down"):
		transition_requested.emit("AirMovement", {"drop": true})
		
func move_player(delta):
	if abs(player.velocity.x) < player.b_max_speed:
		sprinting = SPRINT_STATE.NOT
		sprint_timer = 0
	elif abs(player.velocity.x) >= player.b_max_speed:
		sprinting = SPRINT_STATE.MAX_SPEED
		h_point = 0
		
	if sprinting == SPRINT_STATE.MAX_SPEED:
		sprint_timer += delta
		if sprint_timer >= player.time_to_sprint:
			sprinting = SPRINT_STATE.SPRINTING
	
	if dashing:
		dash_timer += delta
		dash_effect_timer += delta
		if dash_effect_timer >= player.d_max_time / 3:
			create_dash_effect()
			dash_effect_timer = 0
		if dash_timer >= player.d_max_time:
			dashing = false
			player.velocity.x = player.s_max_speed * current_dir
			sprinting = SPRINT_STATE.SPRINTING
			dash_timer = 0
	elif turning and current_dir:
		turn_timer += delta
		if turn_timer <= player.turning_boost_time:
			Helper.accelerate_with_curve(h_point, player, player.b_accel_curve, player.accel_rate * 5, player.b_max_speed, current_dir, delta)
			h_point = Helper.addSample(h_point, delta, player.b_accel_time)
		else:
			turn_timer = 0
			turning = false
	elif current_dir == 0 and abs(player.velocity.x) <= 100:
		player.velocity.x = 0
	elif current_dir == 0:
		Helper.accelerate_with_curve(h_point, player, player.b_deccel_curve, player.accel_rate, player.b_max_speed, -previous_dir, delta)
		h_point = Helper.addSample(h_point, delta, player.b_deccel_time)
	elif current_dir and sprinting == SPRINT_STATE.NOT:
		Helper.accelerate_with_curve(h_point, player, player.b_accel_curve, player.accel_rate, player.b_max_speed, current_dir, delta)
		h_point = Helper.addSample(h_point, delta, player.b_accel_time)
	elif current_dir and sprinting == SPRINT_STATE.SPRINTING:
		Helper.accelerate_with_curve(h_point, player, player.s_accel_curve, player.accel_rate, player.s_max_speed, current_dir, delta)
		h_point = Helper.addSample(h_point, delta, player.s_accel_time)

func enable_particles():
	if current_dir == 1 and sprinting != SPRINT_STATE.NOT:
		player.running_particle_system.emitting = true
		player.running_particle_system.direction.x = 1
		player.running_particle_system.position.x = 6.0
	elif current_dir == -1 and sprinting != SPRINT_STATE.NOT:
		player.running_particle_system.emitting = true
		player.running_particle_system.direction.x = -1
		player.running_particle_system.position.x = -6.0
	else:
		player.running_particle_system.emitting = false
