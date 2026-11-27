class_name PickUp
extends Area2D

@export var id = "itemname_0"

func interact() -> void:
	print("interaction completed")
	collision_layer = 0
	hide()
