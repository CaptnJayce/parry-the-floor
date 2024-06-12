extends CharacterBody2D
class_name Player

@onready var player = self

# PARRY RELATED VARIABLES
var previous_direction # Used in _process to store the previous parry direction
var knockback_power_vertical = 450 # The vertical distance traveled when parrying
var knockback_power_horizontal = 500 # The horizontal distance traveled when parrying
var h_modify = 2000
var v_modify = 2000

# MOVEMENT RELATED VARIABLES
var speed = 350 # Player speed 
const slide = 200 # Added to player speed when sliding
var jump = -250 # Player jump height
var slide_jump = -75 # Added to jump when sliding
var gravity = 980 # Gravity Intensity
var allow_input = true

# ANIMATION
@onready var marker2D=$Marker2D
@onready var animation: AnimationPlayer

# AUDIO 
@onready var sound=$DeathSFX

func _ready():
	animation = $AnimationPlayer
	if Signals.respawnpos_data == null:
		pass
	else:
		player.position = Signals.respawnpos_data

func _physics_process(delta):
	var direction = Input.get_axis("m_left", "m_right")

	if $AnimationPlayer.current_animation != "Slide":
		speed = 200
		jump = -350

	# JUMP
	if not is_on_floor():
		velocity.y += gravity * delta
	if Input.is_action_pressed("m_jump") and is_on_floor():
		velocity.y = jump

	# TO PREVENT ANIMATION OVERRIDE
	if velocity == Vector2.ZERO:
		if $AnimationPlayer.current_animation == "Parry_D" || !is_on_floor():
			pass
		else:
			animation.play("Idle")

	# WALL STUFF
#	wall_slide(delta)

	# MOVEMENT
	if direction && allow_input == true:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	move_and_slide()

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
		animation.play("Parry_D")
			
	if $AnimationPlayer.is_playing() && $AnimationPlayer.current_animation == "Parry_F" || $AnimationPlayer.current_animation == "Parry_D" || $AnimationPlayer.current_animation == "Jump" && !is_on_floor() || $AnimationPlayer.current_animation == "Slide" || $AnimationPlayer.current_animation == "Wall_Slide":
		pass
	elif Input.is_action_just_pressed("m_slide") && Input.is_action_pressed("m_right"):
		marker2D.scale.x=1
		speed = speed + slide
		jump = jump + slide_jump
		animation.play("Slide")
	elif Input.is_action_just_pressed("m_slide") && Input.is_action_pressed("m_left"):
		marker2D.scale.x=-1
		speed = speed + slide
		jump = jump + slide_jump
		animation.play("Slide")
	elif Input.is_action_pressed("m_jump"):
		animation.play("Jump")
	elif Input.is_action_pressed("m_right"):
		marker2D.scale.x=1
		animation.play("Walk")
	elif Input.is_action_pressed("m_left"):
		marker2D.scale.x=-1
		animation.play("Walk")

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

