extends Area2D
class_name Petal

@export var petals : int
@export var petal_collected : bool

func _ready():
	pass

func _on_body_entered(body):
	if body.is_in_group("Player"):
		LevelData.petal_collected(petals)
		queue_free()
