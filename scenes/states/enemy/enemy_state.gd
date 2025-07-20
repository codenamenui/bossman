class_name EnemyState
extends State

# Nodes
static var player : Player
static var enemy : Enemy

# Static States
static var jumping := false
static var passing_through := false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	enemy = get_tree().get_first_node_in_group("Enemy")
	
func enter(msg : Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	pass

func animate_enemy():
	if get_direction_from_player().x == 1:
		enemy.sprite.flip_h = false
	else:
		enemy.sprite.flip_h = true
		
	if enemy.sprite.animation == "jump":
		if enemy.sprite.is_playing():
			return
	
	if enemy.sprite.animation == "fall":
		if not enemy.is_on_floor():
			return
	
	var state = enemy.state_machine.current_state
	if state is ChasingState:
		if abs(enemy.velocity.y) < 0 and not player.is_on_floor():
			enemy.sprite.play("fall")
		elif abs(enemy.velocity.x) > 0 and player.is_on_floor():
			enemy.sprite.play("run")
	elif state is AttackingState:
		match enemy.attack:
			1:
				enemy.sprite.play("attack_1")
			2:
				enemy.sprite.play("attack_3")

func on_animation_finished():
	var state = enemy.state_machine.current_state
	if enemy.sprite.animation.begins_with("attack") and state is AttackingState:
		enemy.attack = enemy.ATTACKS.NONE
		state.has_attacked = true
		enemy.state_machine.current_state.transition_requested.emit("Chasing")

func is_on_same_level(distance: float):
	return abs(player.global_position.y - enemy.global_position.y) <= distance
	
func is_close_to_player(distance: float):
	return abs(player.global_position.x - enemy.global_position.x) <= distance

func get_direction_from_player():
	return Vector2(-1 if player.global_position.x - enemy.global_position.x < 0 else 1, -1 if player.global_position.y - enemy.global_position.y < 0 else 1)
