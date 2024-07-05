extends Control

@onready var counter = $LabelBox/Deaths
@onready var timer = $LabelBox2/Timer
@onready var timer_start = false
@onready var time_ticks = 0
@onready var level_time = 0

func _process(_delta):
	counter.text = str("Deaths: ", Signals.death_counter) 
	level_time = Time.get_ticks_msec() - time_ticks
	timer.text = str("Time: ", level_time / 1000.0)
	Signals.previous_time = level_time / 1000.0

func _ready():
	time_ticks = Time.get_ticks_msec()
	$SliderBox/HSlider.value = Signals.music_volume

func _on_h_slider_value_changed(v:float):
	AudioServer.set_bus_volume_db(0,v)
	if v == -45:
		AudioServer.set_bus_mute(0,true)
	else:
		AudioServer.set_bus_mute(0,false)

func _on_play_pressed():
	Signals.emit_signal("resume") #Signals go to Pause.gd
func _on_save_pressed():
	print("save")
	SaveLoad.save_game()
func _on_load_pressed():
	print("load")
	SaveLoad.load_game()
func _on_quit_pressed():
	Signals.music_volume = $SliderBox/HSlider.value
	Signals.emit_signal("quit") #Signals go to Pause.gd
	get_tree().change_scene_to_file("res://UI/MainMenu/MainMenu.tscn")

