extends PlayerState
class_name IdleState

func _ready() -> void:
	pass

func enter(msg : Dictionary = {}) -> void:
	player.velocity = Vector2.ZERO

func exit() -> void:
	pass

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	animate_player()

	if not player.is_on_floor():
		transition_requested.emit("AirMovement")
		
	if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		transition_requested.emit("GroundMovement", {"from_idle": true})
	elif Input.is_action_just_pressed("jump"):
		player.sprite.play("fall")
		transition_requested.emit("AirMovement", {"jump" : true})
	elif Input.is_action_just_pressed("down"):
		transition_requested.emit("AirMovement", {"drop": true})
