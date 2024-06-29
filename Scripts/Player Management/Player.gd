extends CharacterBody2D
class_name Player

@onready var player = self

# PARRY RELATED VARIABLES
var previous_direction # Used in _process to store the previous parry direction
var parry_dist = 450 # The vertical distance traveled when parrying
var parry_dist_reset = 450 # Used for resetting to original value
var combo_count : int # Tracks successive parry hits
var can_parry = true

# COMBO RELATED VARIABLES
var combo_1 = 50 
var combo_2 = 80
var combo_3 = 125

# MOVEMENT RELATED VARIABLES
var speed = 125 # Player speed 
var jump = -350 # Player jump height
var forwards = true

var sprint_speed = 300 # Player speed when sprinting
var slide_speed = 250 # Speed when sliding
var slide_jump = -50 # Additional jump during slide

var can_slide = true # Used for slide cooldown
var sprinting : bool # Used to regulate some animations and SFX
var gravity = 980 # Gravity Intensity
var direction : float

var jump_timer : float # Time before playing jump animation 

# ANIMATION
@onready var marker2D = $Marker2D
@onready var animation: AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree

# AUDIO 
@onready var death_sound = $DeathSFX
@onready var walk_sound = $WalkSFX
@onready var sprint_sound = $SprintSFX
@onready var hit_sound_1 = $HitSFX
@onready var hit_sound_2 = $Hit2SFX

# OTHER
@onready var elevation = $ElevationArea/ElevationShape

func _ready():
	sprinting = false
	animation = $AnimationPlayer
	
	if Signals.respawnpos_data == null:
		pass
	else:
		player.global_position = Signals.respawnpos_data

func _process(_delta):
		# Resets combo to 0 if player lands on floor
	if player.is_on_floor():
		combo_count = 0
		parry_dist = parry_dist_reset
	
	# Sets 'sprinting' to true or false and manages speed 
	if Input.is_action_just_pressed("sprint"):
		if sprinting == false:
			elevation.scale.x = 4
			sprinting = true
			speed = sprint_speed
		else:
			elevation.scale.x = 2
			sprinting = false
			speed = 125

func _physics_process(delta):
	direction = Input.get_axis("m_left", "m_right")
	
	# JUMP
	if not is_on_floor():
		velocity.y += gravity * delta
	if Input.is_action_pressed("m_jump") and is_on_floor():
		velocity.y = jump
	
	# Walking and Running SFX handling
	# Could be optimised
	# Stops SFX when not moving
	if !is_on_floor() && walk_sound.playing || !is_on_floor() && sprint_sound.playing:
		walk_sound.stop()
		sprint_sound.stop()
	# Stops one SFX when the other is playing
	if velocity == Vector2.ZERO && walk_sound.playing:
		walk_sound.stop()
	if velocity == Vector2.ZERO && sprint_sound.playing:
		sprint_sound.stop()
	
	# Plays running or walking SFX when moving
	if Input.is_action_pressed("m_right") && !walk_sound.playing || Input.is_action_pressed("m_left") && !walk_sound.playing:
		if sprinting == false && !is_on_wall() && is_on_floor():
			walk_sound.play()
		if sprinting == false && sprint_sound.playing:
			sprint_sound.stop()
	if Input.is_action_pressed("m_right") && !sprint_sound.playing || Input.is_action_pressed("m_left") && !sprint_sound.playing:
		if sprinting == true && !is_on_wall() && is_on_floor():
			sprint_sound.play()
		if sprinting == true && walk_sound.playing:
			walk_sound.stop()

	# MOVEMENT
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	move_and_slide()
	update_animation(delta)

# Input handling
func _input(event : InputEvent):
	if(event.is_action_pressed("m_down") && is_on_floor()):
		position.y += 1

	if Input.is_action_just_released("parry_d") && !is_on_floor():
		previous_direction = "down"

	if $AnimationPlayer.is_playing() && $AnimationPlayer.current_animation == "Parry_F" || $AnimationPlayer.current_animation == "Parry_D" || $AnimationPlayer.current_animation == "Jump" && !is_on_floor() || $AnimationPlayer.current_animation == "Slide" || $AnimationPlayer.current_animation == "Wall_Slide":
		pass
	elif Input.is_action_pressed("m_right"):
		forwards = true
		marker2D.scale.x=1
	elif Input.is_action_pressed("m_left"):
		forwards = false
		marker2D.scale.x=-1
	
# ANIMATION STATE MACHINE
# This is a major clusterfuck and could very easily be optimised but I cba
func update_animation(delta):
	# Sets idle and walking anims
	if sprinting == false:
		if velocity == Vector2.ZERO && is_on_floor() && !is_on_wall():
			animation_tree["parameters/conditions/idle"] = true
			animation_tree["parameters/conditions/is_moving"] = false
			animation_tree["parameters/conditions/sprinting"] = false
		elif velocity != Vector2.ZERO && is_on_floor() && !is_on_wall():
			animation_tree["parameters/conditions/idle"] = false
			animation_tree["parameters/conditions/sprinting"] = false
			animation_tree["parameters/conditions/is_moving"] = true
	if sprinting == true:
		if velocity == Vector2.ZERO && is_on_floor() && !is_on_wall():
			animation_tree["parameters/conditions/idle"] = true
			animation_tree["parameters/conditions/is_moving"] = false
			animation_tree["parameters/conditions/sprinting"] = false
		elif velocity != Vector2.ZERO && is_on_floor() && !is_on_wall():
			animation_tree["parameters/conditions/idle"] = false
			animation_tree["parameters/conditions/is_moving"] = false
			animation_tree["parameters/conditions/sprinting"] = true

	# Sets parry anim
	if Input.is_action_just_pressed("parry_d"):
		animation_tree["parameters/conditions/parry"] = true
	else:
		animation_tree["parameters/conditions/parry"] = false
	
	# Sets jumping anim
	if !is_on_floor():
		jump_timer += delta
		if jump_timer > 0.3:
			animation_tree["parameters/conditions/jumping"] = true
			animation_tree["parameters/conditions/walling"] = false
			animation_tree["parameters/conditions/is_moving"] = false
			animation_tree["parameters/conditions/sprinting"] = false
			animation_tree["parameters/conditions/idle"] = false
			jump_timer = 0
	else:
		animation_tree["parameters/conditions/jumping"] = false

	# Sets sliding anim and movement bonuses
	if Input.is_action_just_pressed("m_slide") && is_on_floor() && can_slide == true:
		can_slide = false
		animation_tree["parameters/conditions/sliding"] = true
		speed = speed + slide_speed
		jump = jump + slide_jump
		await get_tree().create_timer(0.5).timeout
		speed = speed - slide_speed
		jump = jump - slide_jump
		cooldown()
	else:
		animation_tree["parameters/conditions/sliding"] = false

#	if is_on_wall() && !is_on_floor():
#		if Input.is_action_pressed("m_right"):
#			animation_tree["parameters/conditions/walling"] = true
#			animation_tree["parameters/conditions/jumping"] = false
#			marker2D.scale.x=-1
#			velocity.y = 100
#		if Input.is_action_pressed("m_left"):
#			animation_tree["parameters/conditions/walling"] = true
#			animation_tree["parameters/conditions/jumping"] = false
#			marker2D.scale.x=1
#			velocity.y = 100
#	else:
#		animation_tree["parameters/conditions/walling"] = false

	# I don't actually know what this does it was just in the tut
	animation_tree["parameters/Idle/blend_position"] = direction
	animation_tree["parameters/Parry/blend_position"] = direction
	animation_tree["parameters/Walk/blend_position"] = direction
	animation_tree["parameters/Sprint/blend_position"] = direction
	animation_tree["parameters/Slide/blend_position"] = direction
	animation_tree["parameters/Jump/blend_position"] = direction
	#animation_tree["parameters/Walling/blend_position"] = direction

# PARRY
func _on_attack_box_area_entered(area):
	if area.is_in_group("Collide") && can_parry == true || is_on_wall() && !is_on_floor() && can_parry == true:
		can_parry = false
		# Randomises which hit SFX is played
		if randi_range(1,2) == 1:
			hit_sound_1.play()
		else:
			hit_sound_2.play()
			
		# Tracks combo number to add additional height to successive parries
		# Resets when landing
		combo_count += 1
		if combo_count == 1:
			parry_dist = parry_dist_reset
			parry_dist = parry_dist + combo_1
		if combo_count == 2: 
			parry_dist = parry_dist_reset
			parry_dist = parry_dist + combo_2
		if combo_count == 3:
			parry_dist = parry_dist_reset
			parry_dist = parry_dist + combo_3
		if combo_count > 3:
			parry_dist = parry_dist_reset
			combo_count = 1 # Loops back to 1 so player doesn't have to land to reset combo
		
		# I forgot what this does
		if previous_direction == "down":
			velocity.y = -parry_dist
		else:
			velocity.x = 0
		await get_tree().create_timer(0.3).timeout
		can_parry = true

# SLIDE COOLDOWN
func cooldown():
	can_slide = false
	await get_tree().create_timer(2.0).timeout
	can_slide = true

# DAMAGE
func _on_hurt_box_area_entered(area):
	if area.is_in_group("Kill"):
		die()

# DEATH
func die():
	death_sound.play()
	velocity = Vector2.ZERO
	Signals.death_counter = Signals.death_counter + 1
	LevelData.damage_taken += 1
	player.global_position = Signals.respawnpos_data
	
func anim_reset():
	animation_tree["parameters/conditions/idle"] = true
	animation_tree["parameters/conditions/is_moving"] = false
	animation_tree["parameters/conditions/sprinting"] = false
	#animation_tree["parameters/conditions/walling"] = false
	animation_tree["parameters/conditions/jumping"] = false
	animation_tree["parameters/conditions/sliding"] = false
	animation_tree["parameters/conditions/parry"] = false

func _on_elevation_area_area_entered(area):
	if area.is_in_group("Stairs"):
		player.global_position.y = player.global_position.y - 20
