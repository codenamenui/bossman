class_name ChasingState
extends EnemyState

# Timers
var jump_timer := 0.0
var pass_through_timer := 0.0

func _ready() -> void:
	super()

func enter(msg : Dictionary = {}) -> void:
	pass

func exit() -> void:
	enemy.set_collision_mask_value(3, true)

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	Helper.accelerate(enemy, enemy.gravity, enemy.max_gravity, 1, delta, true)
	
	jump(delta)
	pass_through(delta)
	chase(delta)
	animate_enemy()
	
func jump(delta):
	if jumping:
		jump_timer += delta
		if jump_timer <= enemy.jump_time:
			if not is_on_same_level(enemy.y_distance_to_jump):
				Helper.accelerate(enemy, enemy.jump_accel_rate, enemy.jump_speed, -1, delta, true)
		else:
			jumping = false
			jump_timer = 0

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
			if enemy.is_on_floor() and (jumping == false or passing_through == false):
				if get_direction_from_player().y == -1:
					enemy.sprite.play("jump")
					jumping = true
				else:
					enemy.set_collision_mask_value(3, false)
					passing_through = true
		else:
			if enemy.is_on_floor():
				transition_requested.emit("Attacking")
	else:
		Helper.accelerate(enemy, enemy.accel_rate, enemy.max_speed, get_direction_from_player().x, delta)
