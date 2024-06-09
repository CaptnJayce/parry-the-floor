extends Area2D
class_name Petal

@export var petals : int
@export var petal_collected : bool
@export var petal_id : int

func _ready():
	for key in LevelData.petal_dict:
		if LevelData.petal_dict["petals"][petal_id] == true:
			queue_free()

func _on_body_entered(body):
	if body.is_in_group("Player"):
		LevelData.petal_collected(petals) # Signal emits to LevelData.gd
		LevelData.petal_dict["petals"][petal_id] = true
		queue_free()
