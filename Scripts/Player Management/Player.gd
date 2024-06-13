extends CharacterBody2D
class_name Player

@onready var player = self

# PARRY RELATED VARIABLES
var previous_direction # Used in _process to store the previous parry direction
var knockback_power_vertical = 450 # The vertical distance traveled when parrying

# MOVEMENT RELATED VARIABLES
var speed = 250 # Player speed 
var jump = -350 # Player jump height
var gravity = 980 # Gravity Intensity
var direction : float

# ANIMATION
@onready var marker2D = $Marker2D
@onready var animation: AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree

# AUDIO 
@onready var sound=$DeathSFX

func _ready():
	animation = $AnimationPlayer
	animation_tree.active

	if Signals.respawnpos_data == null:
		pass
	else:
		player.position = Signals.respawnpos_data

func _physics_process(delta):
	direction = Input.get_axis("m_left", "m_right")

	# JUMP
	if not is_on_floor():
		velocity.y += gravity * delta
	if Input.is_action_pressed("m_jump") and is_on_floor():
		velocity.y = jump

	# WALL STUFF
#	wall_slide(delta)

	# MOVEMENT
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	move_and_slide()
	update_animation()

#func wall_slide(_delta):
#	if is_on_wall() && !is_on_floor():
#		if Input.is_action_pressed("m_right"):
#			animation.play("Wall_Slide")
#			marker2D.scale.x=-1
#			velocity.y = 100
#		if Input.is_action_pressed("m_left"):
#			animation.play("Wall_Slide")
#			marker2D.scale.x=1
#			velocity.y = 100

func _input(event : InputEvent):
	if(event.is_action_pressed("m_down") && is_on_floor()):
		position.y += 1

	if Input.is_action_just_released("parry_d") && !is_on_floor():
		previous_direction = "down"

	if $AnimationPlayer.is_playing() && $AnimationPlayer.current_animation == "Parry_F" || $AnimationPlayer.current_animation == "Parry_D" || $AnimationPlayer.current_animation == "Jump" && !is_on_floor() || $AnimationPlayer.current_animation == "Slide" || $AnimationPlayer.current_animation == "Wall_Slide":
		pass
	elif Input.is_action_pressed("m_right"):
		marker2D.scale.x=1
	elif Input.is_action_pressed("m_left"):
		marker2D.scale.x=-1

# ANIMATION STATE MACHINE
func update_animation():
	animation_tree.set("parameters/conditions/idle", velocity == Vector2.ZERO)
	animation_tree.set("parameters/conditions/is_moving", velocity != Vector2.ZERO && is_on_floor())
	animation_tree.set("parameters/conditions/parry", Input.is_action_just_pressed("parry_d")) 
	animation_tree.set("parameters/conditions/jumping", Input.is_action_just_pressed("m_jump")) 

	if Input.is_action_just_pressed("m_slide") && is_on_floor():
		animation_tree["parameters/conditions/sliding"] = true
		speed = speed + 200
		jump = jump - 50
		await get_tree().create_timer(0.4).timeout
		speed = 250
		jump = -350
	else:
		animation_tree["parameters/conditions/sliding"] = false
	
	animation_tree["parameters/Idle/blend_position"] = direction
	animation_tree["parameters/Parry/blend_position"] = direction
	animation_tree["parameters/Walk/blend_position"] = direction
	animation_tree["parameters/Slide/blend_position"] = direction
	animation_tree["parameters/Jump/blend_position"] = direction

# PARRY
func _on_attack_box_area_entered(area):
	if area.is_in_group("Collide") || is_on_wall() && !is_on_floor():
		if previous_direction == "down":
			velocity.y = -knockback_power_vertical
		else:
			velocity.x = 0

# DAMAGE
func _on_hurt_box_area_entered(area):
	if area.is_in_group("Kill"):
		die()

# DEATH
func die():
	sound.play()
	Signals.death_counter = Signals.death_counter + 1
	LevelData.damage_taken += 1
	player.position = Signals.respawnpos_data

