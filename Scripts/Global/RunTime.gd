extends Node
class_name RuneTimeLevel

@onready var level_name = name

var max_petals = 0

func _ready():
	LevelData.level_beaten.connect(beat_level)
	LevelData.petals = 0
	LevelData.damage_taken = 0
	set_values()

func set_values():
	for node in get_children():
		if node is Petal:
			max_petals += node.petals

func beat_level():
	LevelData.generate_level(LevelData.level_dict[level_name]["unlocks"])
	LevelData.level_dict[LevelData.level_dict[level_name]["unlocks"]]["unlocked"] = true
	LevelData.update_level(level_name, LevelData.petals, max_petals, LevelData.damage_taken, true)

