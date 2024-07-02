extends Control

@onready var counter = $LabelBox/Deaths

func _process(_delta):
	counter.text = str("Deaths: ", Signals.death_counter) 

func _ready():
	if Signals.music_volume == null:
		pass
	else:
		$SliderBox/HSlider.value = Signals.music_volume

func _on_h_slider_value_changed(v:float):
	AudioServer.set_bus_volume_db(0,v)
	if v == -45:
		AudioServer.set_bus_mute(0,true)
	else:
		AudioServer.set_bus_mute(0,false)

func _on_play_pressed():
	Signals.emit_signal("resume") #Signals go to Pause.gd
	Signals.music_volume = $SliderBox/HSlider.value
func _on_save_pressed():
	print("save")
	SaveLoad.save_game()
func _on_load_pressed():
	print("load")
	SaveLoad.load_game()
func _on_quit_pressed():
	Signals.emit_signal("quit") 
	Signals.music_volume = $SliderBox/HSlider.value
	get_tree().change_scene_to_file("res://UI/MainMenu/MainMenu.tscn")

