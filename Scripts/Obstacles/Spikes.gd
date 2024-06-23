extends Node2D
class_name Spikes

@onready var animation: AnimationPlayer

func _ready():
	animation = $AnimationPlayer
	animation.play("Idle")

func _on_spike_area_body_entered(body):
	if body.is_in_group("Player"):
		animation.play("Attack")

func _on_spike_area_body_exited(body):
	if body.is_in_group("Player"):
		animation.play("Retract")

