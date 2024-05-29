extends Node

var petals
var damage_taken
signal level_beaten()
signal petal_pickup()

var level_dic = { 
	"Level1" : {
		"unlocked" : true,
		"petals" : 0,
		"max_petals" : 0,
		"damage_taken" : 0,
		"unlocks" : "Level2",
		"beaten" : false
	}
}

func generate_level(level):
	if level not in level_dic:
		level_dic[level] = {
			"unlocked" : false,
			"petals" : 0,
			"max_petals" : 0,
			"damage_taken" : 0,
			"unlocks" : generate_level_number(level),
			"beaten" : false
		}

func generate_level_number(level):
	var level_number = ""
	for character in level:
		if character.is_valid_int():
			level_number += character
	level_number = int(level_number) + 1
	return "Level" + str(level_number)

func update_level(level, petals, max_petals, damage_taken, beaten):
	level_dic[level]["petals"] = petals
	level_dic[level]["max_petals"] = max_petals
	level_dic[level]["damage_taken"] = damage_taken
	level_dic[level]["beaten"] = beaten

func petal_collected(petals_gained):
	LevelData.petals += petals_gained
	emit_signal("petal_pickup", petals_gained)

func load_screen_to_scene(target: String) -> void:
	var loading_screen = preload("res://Levels/Loaders/Loading Screen/loading_screen.tscn").instantiate()
	loading_screen.next_scene_path = target
	get_tree().current_scene.add_child(loading_screen)

func win(): # emits to RunTime.gd
	emit_signal("level_beaten")
	SaveLoad.save_game()
