extends State

var player : Player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func enter(msg : Dictionary = {}) -> void:
	player.velocity = Vector2.ZERO

func exit() -> void:
	pass

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		transition_requested.emit("AirMovement")
		
	if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		transition_requested.emit("GroundMovement")
	elif Input.is_action_just_pressed("jump"):
		transition_requested.emit("AirMovement", {"jump" : true})
	elif Input.is_action_just_pressed("down"):
		transition_requested.emit("AirMovement", {"drop": true})
