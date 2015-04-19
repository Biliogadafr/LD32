
extends RigidBody2D

# member variables here, example:
# var a=2
# var b="textvar"

const enemyClass = preload("res://Enemy/Enemy.gd")
const bulletClass = preload("res://assets/Bullet.gd") # bullet class to check collision

export var speed = 0.0
var lastPos = Vector2(0,0)

export var teleportCooldown = 0.3;
export var teleportLength = 120;
var teleportCooldownCurrent = teleportCooldown;
var animations
var health = 100

func _ready():
	print("hello 3")
	set_process_input(true)
	set_fixed_process(true)
	animations = get_node("AnimationPlayer")
	connect("body_enter", self, "onCollision")
	pass
	
func _fixed_process(delta):
	#aiming
	var globalAimPos = get_node("Camera2D").get_canvas_transform().xform_inv(lastPos)
	#moving
	var move_left = Input.is_action_pressed("move_left")
	var move_right = Input.is_action_pressed("move_right")
	var move_up = Input.is_action_pressed("move_up")
	var move_down = Input.is_action_pressed("move_down")
	var direction = Vector2(move_right-move_left, move_down - move_up)
	direction = direction.normalized()
	direction*=delta*speed
	set_linear_velocity(direction)
	if(direction.length()==0):
		set_rot( get_global_pos().angle_to_point( globalAimPos ) )
		if(animations. get_current_animation() != "Base"):
			animations.play("Base")
	else:
		set_rot( Vector2(0,-1).angle_to( direction ) )
		if(animations. get_current_animation() != "Run"):
			animations.play("Run")
	#teleporting
	if Input.is_action_pressed("teleport") && teleportCooldownCurrent <= 0:
		teleportCooldownCurrent = teleportCooldown
		var teleportDirection = globalAimPos - get_global_pos()
		teleportDirection = teleportDirection.normalized()
		#raycast to check if we can teleport to specified position.
		var space = get_world_2d().get_space()
		var space_state = Physics2DServer.space_get_direct_state( space )
		var endPoint = get_global_pos() + teleportDirection * teleportLength    
		#*20 is workaround... kind of... anyway don't work.
		var intersectResult = space_state.intersect_ray(get_global_pos(),  get_global_pos() + teleportDirection * teleportLength*20, [self])
		if intersectResult.has("position"):
			var endPointCandidate = intersectResult["position"]
			if (endPointCandidate - get_global_pos()).length() < teleportLength:
				endPoint = endPointCandidate
		set_global_pos(endPoint)
	else:
		teleportCooldownCurrent -= delta
	#hacking
	if Input.is_action_pressed("hack"):
		var bodies = get_node("HackHitBox").get_overlapping_bodies()
		for body in bodies:
			if body extends enemyClass:
				body.hack(self)
	
	if health <= 0 :
		get_parent().queue_free()
		
func onCollision(var collider):
	if collider extends bulletClass:
		health -= 20
		
func _input(ev):
	if(ev.type == InputEvent.MOUSE_MOTION):
		lastPos = ev.pos
