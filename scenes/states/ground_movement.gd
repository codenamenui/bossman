extends State

# Nodes
var player : Player

# Timers
var coyote_timer := 0.0
var last_tap_timer := 0.0
var dash_timer := 0.0
var sprint_time := 0.0
var sample := 0.0

# States
var in_coyote := false
var tapped := TAP_STATE.NONE
var sprinting := SPRINT_STATE.NOT
var dashing := false

# Directions
var current_dir := 0
var previous_dir := 0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func enter(msg : Dictionary = {}) -> void:
	coyote_timer = 0
	in_coyote = false
	sample = 0
	current_dir = 0
	previous_dir = 0
	if msg.get("tap"):
		tapped = msg.get("tap")
		
func exit() -> void:
	player.running_particle_system.emitting = false

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	coyote_handling(delta)
	if not dashing:
		get_direction()
	get_vertical_actions()
	tap_handling(delta)
	move_player(delta)
	enable_particles()
	
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

func get_direction():
	current_dir = Input.get_axis("left", "right")
		
	if previous_dir != current_dir:
		player.velocity.x = 0
		sample = 0
	
	previous_dir = current_dir
	
func get_vertical_actions():
	if Input.is_action_just_pressed("jump"):
		transition_requested.emit("AirMovement", {"jump" : true})
	elif Input.is_action_just_pressed("down"):
		transition_requested.emit("AirMovement", {"drop": true})
		
func tap_handling(delta):
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
			player.velocity.x = -player.d_max_speed
		else:
			tapped = TAP_STATE.LEFT_TAP
	elif Input.is_action_just_pressed("right"):
		if tapped == TAP_STATE.RIGHT_WAITING:
			dashing = true
			player.velocity.x = player.d_max_speed
		else:
			tapped = TAP_STATE.RIGHT_TAP
			
func move_player(delta):
	if abs(player.velocity.x) < player.b_max_speed:
		sprinting = SPRINT_STATE.NOT
		sprint_time = 0
	elif abs(player.velocity.x) >= player.b_max_speed:
		sprinting = SPRINT_STATE.MAX_SPEED
		sample = 0
		
	if sprinting == SPRINT_STATE.MAX_SPEED:
		sprint_time += delta
		if sprint_time >= player.time_to_sprint:
			sprinting = SPRINT_STATE.SPRINTING
			
	if dashing:
		dash_timer += delta
		if dash_timer >= player.d_max_time:
			dashing = false
			player.velocity.x = player.s_max_speed * current_dir
			sprinting = SPRINT_STATE.SPRINTING
			dash_timer = 0
	elif current_dir == 0 and player.velocity.x == 0:
		transition_requested.emit("Idle")
	elif current_dir == 0:
		Helper.accelerate_with_curve(sample, player, player.b_deccel_curve, player.accel_rate, player.b_max_speed, -previous_dir, delta)
		sample = Helper.addSample(sample, delta, player.b_accel_time)
	elif current_dir and sprinting == SPRINT_STATE.NOT:
		Helper.accelerate_with_curve(sample, player, player.b_accel_curve, player.accel_rate, player.b_max_speed, current_dir, delta)
		sample = Helper.addSample(sample, delta, player.b_accel_time)
	elif current_dir and sprinting == SPRINT_STATE.SPRINTING:
		Helper.accelerate_with_curve(sample, player, player.s_accel_curve, player.accel_rate, player.s_max_speed, current_dir, delta)
		sample = Helper.addSample(sample, delta, player.s_accel_time)

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
