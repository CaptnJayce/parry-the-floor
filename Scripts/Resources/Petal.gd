extends Area2D
class_name Petal

@export var petal_id : int
@onready var pickup_petal = $PickupSFX

func _ready():
	for key in LevelData.petal_dict:
		# if Invalid get index '0' (on base: 'Dictionary').
		# then an int value wasn't given to the petal placed in the scene
		if LevelData.petal_dict["petals"][petal_id] == true:
			queue_free()

func _on_body_entered(body):
	if body.is_in_group("Player"):
		LevelData.petal_dict["petals"][petal_id] = true
		Signals.emit_signal("petal_picked")
		pickup_petal.play()
		self.visible = false
		await get_tree().create_timer(0.5).timeout
		queue_free()
