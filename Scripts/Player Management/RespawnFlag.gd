extends Node2D
class_name Respawn

var activated = false
@onready var animation = $Area2D/AnimatedSprite2D
@onready var respawnpos = $Area2D/RespawnAnchor

func _ready():
	if activated == true:
		animation.play("Checked")
	else:
		animation.play("Unchecked")

func activate():
	activated = true
	Signals.respawnpos_data = respawnpos.global_position
	print(Signals.respawnpos_data)
	animation.play("Checked")

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player") && activated == false:
		activate()
