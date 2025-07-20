class_name AttackingState
extends EnemyState

var has_attacked := false

func _ready() -> void:
	super()

func enter(msg : Dictionary = {}) -> void:
	enemy.velocity = Vector2.ZERO
	enemy.sprite.stop()
	has_attacked = false
	
func exit() -> void:
	pass

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	Helper.accelerate(enemy, enemy.gravity, enemy.max_gravity, 1, delta, true)
	
	#var distance = enemy.x_swing_distance if enemy.attack == enemy.ATTACKS.SWING else enemy.x_cast_distance
	if has_attacked:
		transition_requested.emit("Chasing")

	animate_enemy()
