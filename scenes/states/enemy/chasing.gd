class_name ChasingState
extends EnemyState

# Timers
var jump_timer := 0.0
var pass_through_timer := 0.0
var boost_timer := 0.0
var cast_timer := 0.0

func _ready() -> void:
	super()

func enter(msg : Dictionary = {}) -> void:
	boost_timer = 0
	cast_timer = 0

func exit() -> void:
	enemy.set_collision_mask_value(3, true)
	enemy.sprite.modulate = Color.WHITE
	enemy.sprite.speed_scale = 1

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	Helper.accelerate(enemy, enemy.gravity, enemy.max_gravity, 1, delta, true)
	
	pass_through(delta)
	chase(delta)
	animate_enemy()

func pass_through(delta):
	if passing_through:
		pass_through_timer += delta
		if pass_through_timer >= enemy.pass_through_time:
			passing_through = false
			pass_through_timer = 0.0
			enemy.set_collision_mask_value(3, true)

func chase(delta):
	if is_close_to_player(enemy.x_distance_to_jump):
		if not is_on_same_level(enemy.y_distance_to_jump):
			if enemy.is_on_floor():
				if get_direction_from_player().y == -1:
					enemy.velocity.y = -sqrt(2 * enemy.gravity * enemy.jump_height)
					enemy.sprite.play("jump")
				else:
					enemy.set_collision_mask_value(3, false)
					passing_through = true
		else: 
			if enemy.is_on_floor():
				transition_requested.emit("Attacking")
	elif enemy.attack == enemy.ATTACKS.CAST:
		if is_close_to_player(enemy.x_distance_to_jump) and is_on_same_level(enemy.y_distance_to_jump):
			enemy.attack = enemy.ATTACKS.SWING
			if enemy.is_on_floor():
				transition_requested.emit("Attacking")
		cast_timer += delta
		if cast_timer >= enemy.time_till_cast:
			if enemy.is_on_floor():
				transition_requested.emit("Attacking")
				
	if not enemy.is_on_floor():
		if boost_timer <= enemy.time_to_speed:
			Helper.accelerate(enemy, enemy.accel_rate, enemy.max_speed / 1.5, get_direction_from_player().x, delta)
			enemy.sprite.modulate = Color.WHITE
			enemy.sprite.speed_scale = 1
		else:
			Helper.accelerate(enemy, enemy.h_boost_rate, enemy.h_boost_speed / 1.5, get_direction_from_player().x, delta)
			enemy.sprite.modulate = Color.RED
			enemy.sprite.speed_scale = 5
	else:
		if boost_timer <= enemy.time_to_speed:
			Helper.accelerate(enemy, enemy.accel_rate, enemy.max_speed, get_direction_from_player().x, delta)
			enemy.sprite.modulate = Color.WHITE
			enemy.sprite.speed_scale = 1
		else:
			Helper.accelerate(enemy, enemy.h_boost_rate, enemy.h_boost_speed, get_direction_from_player().x, delta)
			enemy.sprite.modulate = Color.RED
			enemy.sprite.speed_scale = 5
	boost_timer += delta
