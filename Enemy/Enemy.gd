
extends RigidBody2D

const playerClass = preload("res://Player/Player.gd") # cache the enemy class
var bullet = preload("res://assets/Bullet.scn") # will load when parsing the script
const bulletClass = preload("res://assets/Bullet.gd") # will load when parsing the script

var isHacked = false
var owner

export var shootCooldown = 0.2
export var bulletImpulse = 200
var shootCooldownRemain = shootCooldown
var oldIntersect 
var distance = 100
var walkSpeed = 100
func _ready():
	set_fixed_process(true)
	connect("body_enter", self, "onCollision")
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
					var rayVector = observed.get_global_pos() - get_global_pos()
					rayVector *= 10 #WORKAROUND
					var intersectResult = physWorld.intersect_ray(get_global_pos(), get_global_pos()+rayVector, [self], 1)
					oldIntersect = intersectResult
					update()
					if(intersectResult.has("collider") && intersectResult["collider"] == observed):
						target = observed
						break
		elif observed extends playerClass || (observed extends get_script() && observed.isHacked):
			var space = get_world_2d().get_space()
			var physWorld = Physics2DServer.space_get_direct_state( space )
			var rayVector = observed.get_global_pos() - get_global_pos()
			rayVector *= 10 #WORKAROUND
			var intersectResult = physWorld.intersect_ray(get_global_pos(), get_global_pos()+rayVector, [self], 1)
			oldIntersect = intersectResult
			update()
			if(intersectResult.has("collider") and intersectResult["collider"] == observed):
				target = observed
	if target != null:
		set_rot(get_global_pos().angle_to_point(target.get_global_pos()))
		_shoot(target.get_global_pos())
	elif isHacked:
		var direction = owner.get_global_pos() - get_global_pos()
		if(direction.length() > distance):
			direction = direction.normalized()
			set_linear_velocity(direction*walkSpeed)
			set_rot(get_global_pos().angle_to_point(owner.get_global_pos()))
	pass
	
func _draw():
	if(oldIntersect != null && oldIntersect.has("position")):
		draw_line( get_global_transform().xform_inv(get_global_pos()),  get_global_transform().xform_inv(oldIntersect["position"]), Color(1,1,1))
	
func onCollision(var collider):
	if collider extends bulletClass:
		get_parent().queue_free()

func hack(var hacker):
	owner = hacker
	if !isHacked:
		print("hacked")
		isHacked = true
		
func _shoot(var target):
	if(shootCooldownRemain < 0):
		print("shoot", target)
		var bulletInst = bullet.instance()
		get_owner().add_child(bulletInst)
		var shootDir = (target - get_global_pos()).normalized()
		var shootPos = get_global_pos()
		shootPos += shootDir * 20
		bulletInst.set_global_pos(shootPos)
		bulletInst.get_node("RigidBody2D").apply_impulse(Vector2(0,0), shootDir * bulletImpulse)
		bulletInst.set_rot(shootPos.angle_to_point(target))
		shootCooldownRemain = shootCooldown
	