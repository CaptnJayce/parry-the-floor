extends Node
class_name RuneTimeLevel

@onready var level_name = name
@onready var petal_count : int
@export var level : String

func _ready():
	Signals.connect("quit", _quit_level)
	Signals.connect("petal_picked", _petal_count)
	LevelData.level_beaten.connect(beat_level)
	LevelData.damage_taken = 0

	if petal_count == 0 && LevelData.level_dict[level_name]["petals"] == 0:
		petal_count = 0
	else:
		petal_count = LevelData.level_dict[level_name]["petals"]
	set_values()

	if LevelData.level_dict[level_name]["petals"] == LevelData.level_dict[level_name]["max_petals"]:
		Signals.emit_signal("gold_lotus")

func set_values():
	LevelData.level_dict[level_name]["max_petals"] = 0
	for node in get_children():
		if node is Petal:
			LevelData.level_dict[level_name]["max_petals"] += 1

func _petal_count():
	petal_count += 1

func beat_level():
	LevelData.generate_level(LevelData.level_dict[level_name]["unlocks"])
	LevelData.level_dict[LevelData.level_dict[level_name]["unlocks"]]["unlocked"] = true
	LevelData.update_level(level_name, LevelData.damage_taken, true)
	save_the_thing()

	
func _quit_level():
	Signals.previous_level = level
	save_the_thing()

func save_the_thing():
	LevelData.level_dict[level_name]["petals"] = petal_count
	SaveLoad.save_game()
