extends Node

@onready var level_holder = $LevelHolder
@onready var player = $Player

var levels = []
@onready var curr_level = $LevelHolder/Level1

var lerp_speed = 1
var lerp_progress = 0.0
var completed_movement = true
var lerp_threshold = 0.1

func _ready():
	Music.play_menu_music()
	levels = level_holder.get_children()
	update_levels()

func update_levels():
	for level in levels:
		if level.name in LevelData.level_dict:
			if LevelData.level_dict[level.name]["unlocked"] == true:
				level.get_node("Sprite2D").texture = load("res://Sprites/WorldMap/unlocked.png")
				if LevelData.level_dict[level.name]["beaten"] == true:
					level.get_node("Sprite2D").texture = load("res://Sprites/WorldMap/beaten.png")
			else:
				level.get_node("Sprite2D").texture = load("res://Sprites/WorldMap/locked.png")

func _process(delta):
	var target_level : Node2D

	if Input.is_action_pressed("ui_up"):
		if curr_level.up:
			target_level = curr_level.up
	if Input.is_action_pressed("m_down"):
		if curr_level.down:
			target_level = curr_level.down
	if Input.is_action_pressed("m_right"):
		if curr_level.right:
			target_level = curr_level.right
	if Input.is_action_pressed("m_left"):
		if curr_level.left:
			target_level = curr_level.left
	if Input.is_action_pressed("pause"):
		get_tree().change_scene_to_file("res://UI/MainMenu/MainMenu.tscn")
	
	if Input.is_action_just_pressed("ui_accept"):
		if Signals.previous_level == curr_level.name || Signals.previous_level == null:
			pass
		else:
			Signals.respawnpos_data = null
		await get_tree().create_timer(0.4).timeout
		get_tree().change_scene_to_file("res://Levels/Test Levels/" + curr_level.name + ".tscn")

	if target_level and target_level.name in LevelData.level_dict and LevelData.level_dict[target_level.name]["unlocked"] and completed_movement:
		completed_movement = false
		lerp_progress = 0.0
		while lerp_progress < 1.0:
			lerp_progress += lerp_speed + delta
			lerp_progress = clamp(lerp_progress, 0.0, 1.0)
			player.position = player.position.lerp(target_level.global_position, lerp_progress)
			
			if player.position.distance_to(target_level.global_position) < lerp_threshold:
				break

		await get_tree().create_timer(0.1).timeout
		player.position = target_level.global_position
		show_stats(target_level)
		curr_level = target_level
		completed_movement = true

func show_stats(target_level):
	if LevelData.level_dict[target_level.name]["unlocked"]:
		target_level.get_node("StatDisplay").visible = true
		target_level.get_node("StatDisplay").get_node("AnimationPlayer").play("show")
	
	curr_level.get_node("StatDisplay").get_node("AnimationPlayer").play("show", 0, -1.0, true)
	
	if LevelData.level_dict[target_level.name]["petals"] == LevelData.level_dict[target_level.name]["max_petals"] and LevelData.level_dict[target_level.name]["max_petals"] > 0:
		target_level.get_node("StatDisplay").get_node("GoldLotus").visible = true
	else:
		target_level.get_node("StatDisplay").get_node("GoldLotus").visible = false

	if LevelData.level_dict[target_level.name]["damage_taken"] == 0 and LevelData.level_dict[target_level.name]["beaten"] == true:
		target_level.get_node("StatDisplay").get_node("GoldHeart").visible = true
	else:
		target_level.get_node("StatDisplay").get_node("GoldHeart").visible = false

