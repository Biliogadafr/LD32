
extends RigidBody2D

# member variables here, example:
# var a=2
# var b="textvar"

const playerClass = preload("res://Player/Player.gd") # cache the enemy class

var isHacked = false
var owner

export var shootCooldown = 0.5
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
					var intersectResult = physWorld.intersect_ray(get_global_pos(), observed.get_global_pos(), [self])
					if(intersectResult.has("collision")):
						print("I see enemy")
		elif observed extends playerClass:
			_shoot(observed.get_global_pos())
			var space = get_world_2d().get_space()
			var physWorld = Physics2DServer.space_get_direct_state( space )
			print (get_global_pos(), observed.get_global_pos())
			var intersectResult = physWorld.intersect_ray(get_global_pos(), observed.get_global_pos(), [self])
			print (intersectResult)
			oldIntersect = intersectResult
			update()
			if(intersectResult.has("collider") and intersectResult["collider"] == observed):
				#print("I see player ", intersectResult["position"] )
				#_shoot(intersectResult["position"])
	pass
	
func _draw():
	if(oldIntersect != null && oldIntersect.has("position")):
		draw_line(get_global_pos(), oldIntersect["position"], Color(1,1,1))
	
func hack(var hacker):
	owner = hacker
	if !isHacked:
		print("hacked")
		isHacked = true
		
func _shoot(var target):
	if(shootCooldownRemain < 0):
		print("shoot", target)
		shootCooldownRemain = shootCooldown
	