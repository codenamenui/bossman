extends Node
class_name HelperFunctions

func accelerate(entity: PhysicsBody2D, acceleration: float, max_speed: float, direction: float, delta: float, vertical: bool = false):
	if vertical:
		entity.velocity.y += acceleration * 0.5 * delta * direction
		entity.velocity.y += acceleration * 0.5 * delta * direction
		entity.velocity.y = clamp(entity.velocity.y, -max_speed, max_speed)
	else:
		entity.velocity.x += acceleration * 0.5 * delta * direction
		entity.velocity.x += acceleration * 0.5 * delta * direction
		entity.velocity.x = clamp(entity.velocity.x, -max_speed, max_speed)

func addSample(sample: float, delta: float, accel_time: float, more: float = 0) -> float:
	sample = sample + delta / accel_time + more
	return clamp(sample, 0, 1)
