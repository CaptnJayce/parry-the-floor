extends Node

var save_path = "res://ptf_save.save"

var default_level_dict = { 
	"Level1" : {
		"unlocked" : true,
		"petals" : 0,
		"max_petals" : 0,
		"damage_taken" : 0,
		"unlocks" : "Level2",
		"beaten" : false,
		"last_checkpoint" : Vector2()
	}
}

var default_petal_dict = {
	"petals" : {
		1 : false,
		2 : false,
		3 : false
	}
}

func _ready():
	Signals.connect("delete", _delete)

func _delete():
	DirAccess.remove_absolute(save_path)

func load_game():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		print("file exists")
		LevelData.level_dict = file.get_var()
		LevelData.petal_dict = file.get_var()
		Signals.death_counter = file.get_var()
	else:
		print("file doesnt exist")
		default_level_dict["last_checkpoint"] = Vector2(0, 48)
		LevelData.level_dict = default_level_dict
		LevelData.petal_dict = default_petal_dict
		Signals.death_counter = 0

func save_game():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(LevelData.level_dict)
	file.store_var(LevelData.petal_dict)
	file.store_var(Signals.death_counter)
