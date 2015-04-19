
extends Node2D
const playerClass = preload("res://Player/Player.gd") # bullet class to check collision
# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Initialization here
	get_node("EndFlor/Area2D").connect("body_enter", self, "onEnd")
	pass

func onEnd(var object):
	if(object extends playerClass):
		print("Weee! End!")
		if(get_node("EndFlor/AnimationPlayer").get_current_animation()!="EndAnim"):
			get_node("EndFlor/AnimationPlayer").play("EndAnim")
	pass
