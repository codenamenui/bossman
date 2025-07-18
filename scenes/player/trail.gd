extends Line2D
class_name Trails
 
var queue : Array
@export var MAX_LENGTH : int
 
func _process(delta):
	var global_pos = get_parent().global_position

	queue.push_front(global_pos)
	
	if queue.size() > MAX_LENGTH:
		queue.pop_back()
	
	clear_points()
	
	for point in queue:
		add_point(point)
