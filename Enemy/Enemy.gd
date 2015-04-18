
extends RigidBody2D

# member variables here, example:
# var a=2
# var b="textvar"

var isHacked = false

func _ready():
	set_fixed_process(true)
	pass
	
func _fixed_process(delta):
	pass
	
func hack():
	if !isHacked:
		print("hacked")
		isHacked = true