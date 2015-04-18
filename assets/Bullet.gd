
extends RigidBody2D

export var lifeTimer = 5.0

func _ready():
	# Initialization here
	connect("body_enter", self, "onCollision")
	print("create bullet")
	set_fixed_process(true)
	pass
	
func _fixed_process(delta):
	lifeTimer -= delta
	if lifeTimer < 0:
		get_parent().queue_free()
	pass

func onCollision(var obj):
	print ("collide")
	get_parent().queue_free()