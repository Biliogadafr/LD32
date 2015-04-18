
extends RigidBody2D

# member variables here, example:
# var a=2
# var b="textvar"

export var speed = 0.0

func _ready():
	set_fixed_process(true);
	pass
	
func _fixed_process(delta):
	var move_left = Input.is_action_pressed("move_left")
	var move_right = Input.is_action_pressed("move_right")
	var move_up = Input.is_action_pressed("move_up")
	var move_down = Input.is_action_pressed("move_down")
	var direction = Vector2(move_right-move_left, move_down - move_up)
	direction = direction.normalized()
	direction*=delta*speed
	set_linear_velocity(direction)
	#set_pos(pos)