extends Node2D

var high_point

func _ready():
	high_point = $Area2D/HighPoint

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		Signals.next_point = high_point.global_position.y
		Signals.emit_signal("stairs")

