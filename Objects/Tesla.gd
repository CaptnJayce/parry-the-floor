extends Node2D

@onready var main = get_tree().get_root().get_node("main")
@onready var projectile = load("res://Objects/Projectile.tscn")

func _ready():
	shoot()

func shoot():
	var instance = projectile.instantiate()
	instance.dir = rotation
	instance.spawnpos = global_position
	instance.spawnrot = rotation
	main.add_child.call_deferred(instance)
