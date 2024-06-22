extends CharacterBody2D

@export var speed = 100

var dir : float
var spawn : Vector2
var spawnrot : float

func _ready():
	global_position = spawn
	global_rotation = spawnrot

func _physics_process(delta):
	velocity = Vector2(0, -speed).rotated(dir)
	move_and_slide()
