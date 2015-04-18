
extends RigidBody2D

# member variables here, example:
# var a=2
# var b="textvar"

export var speed = 0.0
var lastPos = Vector2(0,0)

export var teleportCooldown = 0.3;
export var teleportLength = 100;
var teleportCooldownCurrent = teleportCooldown;

func _ready():
	print("hello 3")
	set_process_input(true)
	set_fixed_process(true)
	pass
	
func _fixed_process(delta):
	#aiming
	var globalAimPos = get_node("Camera2D").get_canvas_transform().xform_inv(lastPos)
	set_rot( get_pos().angle_to_point( globalAimPos ) )
	#moving
	var move_left = Input.is_action_pressed("move_left")
	var move_right = Input.is_action_pressed("move_right")
	var move_up = Input.is_action_pressed("move_up")
	var move_down = Input.is_action_pressed("move_down")
	var direction = Vector2(move_right-move_left, move_down - move_up)
	direction = direction.normalized()
	direction*=delta*speed
	set_linear_velocity(direction)
	#teleporting
	if Input.is_action_pressed("teleport") && teleportCooldownCurrent <= 0:
		teleportCooldownCurrent = teleportCooldown
		var teleportDirection = globalAimPos - get_pos()
		print(teleportDirection)
		teleportDirection = teleportDirection.normalized()
		print(teleportDirection)
		set_pos(get_pos() + teleportDirection * teleportLength)
	else:
		teleportCooldownCurrent -= delta
	#hacking
	if Input.is_action_pressed("hack"):
		var bodies = get_node("HackHitBox").get_overlapping_bodies()
		for body in bodies:
			print(body);
		
func _input(ev):
	if(ev.type == InputEvent.MOUSE_MOTION):
		lastPos = ev.pos
