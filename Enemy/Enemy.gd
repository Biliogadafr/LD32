
extends RigidBody2D

const playerClass = preload("res://Player/Player.gd") # Check if we see player
var bullet = preload("res://assets/bullet.scn") # bullet scn to make instance and shoot
var blood = preload("res://assets/blood.scn") # blood for death
const bulletClass = preload("res://assets/Bullet.gd") # bullet class to check collision
const hackedTex = preload("res://Enemy/HeadH.png") # texture for hacked head

var isHacked = false
var owner

export var shootCooldown = 0.2
export var bulletImpulse = 200
var shootCooldownRemain = shootCooldown
var oldIntersect 
var distance = 100
var walkSpeed = 100

var animations

var lastTargetPos = null

func _ready():
	set_fixed_process(true)
	connect("body_enter", self, "onCollision")
	animations = get_node("AnimationPlayer")
	pass
	
func _fixed_process(delta):
	shootCooldownRemain -= delta;
	var fov = get_node("FieldOfView")
	var observedObjects = fov.get_overlapping_bodies()
	var target = null
	for observed in observedObjects:
		if isHacked:
			if observed != self and observed extends get_script():
				if(!observed.isHacked):
					var space = get_world_2d().get_space()
					var physWorld = Physics2DServer.space_get_direct_state( space )
					var intersectResult = physWorld.intersect_ray(get_global_pos(), observed.get_global_pos(), [self], 1)
					oldIntersect = intersectResult
					update()
					if(intersectResult.has("collider") && intersectResult["collider"] == observed):
						target = observed
						lastTargetPos = target.get_global_pos()
						break
		elif observed extends playerClass || (observed extends get_script() && observed.isHacked):
			var space = get_world_2d().get_space()
			var physWorld = Physics2DServer.space_get_direct_state( space )
			var intersectResult = physWorld.intersect_ray(get_global_pos(), observed.get_global_pos(), [self], 1)
			oldIntersect = intersectResult
			update()
			if(intersectResult.has("collider") and intersectResult["collider"] == observed):
				target = observed
				lastTargetPos = target.get_global_pos()
				break
		
	
	if target != null:
		set_rot(get_global_pos().angle_to_point(target.get_global_pos()) - get_owner().get_rot())
		_shoot(target.get_global_pos())
	elif isHacked:
		var direction = owner.get_global_pos() - get_global_pos()
		if(direction.length() > distance):
			direction = direction.normalized()
			set_linear_velocity(direction*walkSpeed)
			set_rot(get_global_pos().angle_to_point(owner.get_global_pos()) -get_owner().get_rot()) #pffffff.....
	else:
		#go to last target location   # nah... don't want to organize state machine... I'm tired with trying to make raycasts work ... 
		if(target == null && lastTargetPos != null):
			var direction = lastTargetPos - get_global_pos()
			if(direction.length() > 10):
				direction = direction.normalized()
				set_linear_velocity(direction*walkSpeed)
				set_rot(get_global_pos().angle_to_point(lastTargetPos)-get_owner().get_rot())
			else:
				lastTargetPos = null
			
	#ANIMATION
	if(shootCooldownRemain > -shootCooldown):
		if(animations. get_current_animation() != "Shoot"):
			animations.play("Shoot")
	elif(get_linear_velocity().length()>walkSpeed/2):
		if(animations. get_current_animation() != "Run"):
			animations.play("Run")
	else:
		if(animations. get_current_animation() != "Look"):
			animations.play("Look")
	pass
	
func _draw():
	pass
	#if(oldIntersect != null && oldIntersect.has("position")):
	#	draw_line( get_global_transform().xform_inv(get_global_pos()),  get_global_transform().xform_inv(oldIntersect["position"]), Color(1,1,1))
	
func onCollision(var collider):
	if collider extends bulletClass:
		var bloodInst = blood.instance()
		#insert blood to scene =/
		get_tree().get_root().get_child( get_tree().get_root().get_child_count() -1 ).add_child(bloodInst)
		bloodInst.set_pos(get_global_pos())
		bloodInst.set_z(-1)
		get_parent().queue_free()

func hack(var hacker):
	owner = hacker
	if !isHacked:
		get_node("Skin/Head").set_texture(hackedTex)
		print("hacked")
		isHacked = true
		
func _shoot(var target):
	if(shootCooldownRemain < 0):
		#print("shoot", target)
		var bulletInst = bullet.instance()
		get_tree().get_root().get_child( get_tree().get_root().get_child_count() -1 ).add_child(bulletInst)
		var shootDir = (target - get_global_pos()).normalized()
		var shootPos = get_global_pos()
		shootPos += shootDir * 20
		bulletInst.set_global_pos(shootPos)
		bulletInst.get_node("RigidBody2D").apply_impulse(Vector2(0,0), shootDir * bulletImpulse)
		bulletInst.set_rot(shootPos.angle_to_point(target))
		shootCooldownRemain = shootCooldown
	