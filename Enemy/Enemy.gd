
extends RigidBody2D

# member variables here, example:
# var a=2
# var b="textvar"

const playerClass = preload("res://Player/Player.gd") # cache the enemy class
var bullet = preload("res://assets/Bullet.scn") # will load when parsing the script

var isHacked = false
var owner

export var shootCooldown = 0.2
export var bulletImpulse = 200
var shootCooldownRemain = shootCooldown
var oldIntersect 
func _ready():
	set_fixed_process(true)
	pass
	
func _fixed_process(delta):
	shootCooldownRemain -= delta;
	var fov = get_node("FieldOfView")
	var observedObjects = fov.get_overlapping_bodies()
	for observed in observedObjects:
		if isHacked:
			if observed != self and observed extends get_script():
				if(!observed.isHacked):
					var space = get_world_2d().get_space()
					var physWorld = Physics2DServer.space_get_direct_state( space )
					var intersectResult = physWorld.intersect_ray(get_global_pos(), observed.get_global_pos(), [self], 1)
					if(intersectResult.has("collision")):
						print("I see enemy")
		elif observed extends playerClass:
			var space = get_world_2d().get_space()
			var physWorld = Physics2DServer.space_get_direct_state( space )
			var vector = observed.get_global_pos() - get_global_pos()
			vector *= 10 #WORKAROUND
			var intersectResult = physWorld.intersect_ray(get_global_pos(), get_global_pos()+vector, [self], 1)
			oldIntersect = intersectResult
			update()
			if(intersectResult.has("collider") and intersectResult["collider"] == observed):
				_shoot(observed.get_global_pos())
	pass
	
func _draw():
	if(oldIntersect != null && oldIntersect.has("position")):
		draw_line( get_global_transform().xform_inv(get_global_pos()),  get_global_transform().xform_inv(oldIntersect["position"]), Color(1,1,1))
	
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
	