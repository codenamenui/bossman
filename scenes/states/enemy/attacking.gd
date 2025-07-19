class_name AttackingState
extends EnemyState

func _ready() -> void:
	super()

func enter(msg : Dictionary = {}) -> void:
	enemy.velocity = Vector2.ZERO
	enemy.sprite.stop()
	
func exit() -> void:
	pass

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	Helper.accelerate(enemy, enemy.gravity, enemy.max_gravity, 1, delta, true)
	
	if not enemy.sprite.is_playing() and not is_close_to_player(enemy.x_attack_distance):
		transition_requested.emit("Chasing")
		
	animate_enemy()
