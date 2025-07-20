extends Node2D

@onready var camera: SmartCamera2D = $SmartCamera2D

var zoom : Vector2 = Vector2.ONE
var lerp_time := 0.0
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	camera.zoom = lerp(camera.zoom, zoom, lerp_time)
	lerp_time += delta
	
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom = zoom + Vector2(0.1, 0.1)
				lerp_time = 0
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom = zoom - Vector2(0.1, 0.1)
				lerp_time = 0
