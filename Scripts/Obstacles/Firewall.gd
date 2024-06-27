extends Node2D

@onready var animation: AnimationPlayer 

func _ready():
	animation = $AnimationPlayer
	animation.play("Idle")

func _on_fire_area_body_entered(body):
	if body.is_in_group("Player"):
		animation.play("Attack")
