extends ColorRect

func _ready():
	SaveLoad.load_game()
	print(Signals.music_volume)
	$VBoxContainer2/HSlider.value = Signals.music_volume
	Music.play_menu_music()

func _process(_delta):
	if Input.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://UI/WorldMap/WorldMap.tscn")
	if Input.is_action_just_pressed("pause"):
		get_tree().quit()

func _on_play_pressed():
	get_tree().change_scene_to_file("res://UI/WorldMap/WorldMap.tscn")
func _on_quit_pressed():
	get_tree().quit()
func _on_texture_button_pressed():
	Signals.emit_signal("delete") #Signals go to SaveLoad.gd

func _on_h_slider_value_changed(v:float):
	Signals.music_volume = v
	AudioServer.set_bus_volume_db(0,v)
	if v == -45:
		AudioServer.set_bus_mute(0,true)
	else:
		AudioServer.set_bus_mute(0,false)

