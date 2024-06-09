extends Control

@export_file("*.tscn") var next_scene_path: String

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		LevelData.level_dict["last_checkpoint"] = null
		Signals.respawnpos_data = LevelData.level_dict["last_checkpoint"]
		LevelData.load_screen_to_scene(next_scene_path)
		LevelData.win()
		SaveLoad.save_game()

