extends Node

func accelerate_with_curve(sample: float, player: Player, accel_curve: Curve, accel_rate: float, 
						   max_speed: float, dir: int, delta: float, vertical: bool = false) -> void:
	var acceleration = accel_curve.sample(sample) * accel_rate * delta * dir
	if vertical:
		player.velocity.y += acceleration * 0.5
		player.velocity.y += acceleration * 0.5
		player.velocity.y = clamp(player.velocity.y, -max_speed, max_speed)
	else:
		player.velocity.x += acceleration * 0.5
		player.velocity.x += acceleration * 0.5
		player.velocity.x = clamp(player.velocity.x, -max_speed, max_speed)

func accelerate(player: Player, acceleration: float, dir: int, max_speed: float, delta: float, 
				vertical: bool = false):
	if vertical:
		player.velocity.y += acceleration * 0.5 * delta
		player.velocity.y += acceleration * 0.5 * delta
		player.velocity.y = clamp(player.velocity.y, -max_speed, max_speed)
	else:
		player.velocity.x += acceleration * 0.5 * delta
		player.velocity.x += acceleration * 0.5 * delta
		player.velocity.x = clamp(player.velocity.x, -max_speed, max_speed)
	
func addSample(sample: float, delta: float, accel_time: float, more: float = 0) -> float:
	sample = sample + delta / accel_time + more
	return clamp(sample, 0, 1)
