extends AudioStreamPlayer

const menu_music = preload("res://Audio/OST/1_QuestionMark.ogg")
const one_four_music = preload("res://Audio/OST/2_WinterWarmthRemixIGuess.ogg")

var music_bus = AudioServer.get_bus_index("Master")

func _ready():
	Signals.connect("mute", _mute)

func _mute():
	AudioServer.set_bus_mute(music_bus, not AudioServer.is_bus_mute(music_bus))
	
func _play_music(music: AudioStream):
	if stream == music:
		return

	stream = music
	play()

func play_menu_music():
	_play_music(menu_music)

func play_one_four():
	_play_music(one_four_music)
