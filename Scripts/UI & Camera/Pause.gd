extends Node2D

@onready var pause_menu = $CanvasLayer/PauseMenu

func _ready():
	Signals.connect("resume", _resume)
	Signals.connect("quit", _quit)

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		if !get_tree().paused:
			_pause()
		else:
			_resume()

func _pause():
	get_tree().set_deferred("paused", true)
	pause_menu.show()

func _resume():
	pause_menu.hide()
	get_tree().set_deferred("paused", false)

func _quit():
	get_tree().set_deferred("paused", false)
	get_tree().change_scene_to_file("res://UI/MainMenu/MainMenu.tscn")
