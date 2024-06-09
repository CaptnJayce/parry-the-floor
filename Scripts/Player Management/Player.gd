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

# ANIMATION
@onready var marker2D=$Marker2D
@onready var animation: AnimationPlayer

# AUDIO 
@onready var sound=$DeathSFX

func _ready():
	animation = $AnimationPlayer
	#LevelData.damage_taken = 0
	if Signals.respawnpos_data == null:
		pass
	else:
		print(Signals.respawnpos_data)
		player.position = Signals.respawnpos_data

func _process(_delta):
	if Input.is_action_just_released("parry_r"):
		previous_direction = "right"
		marker2D.scale.x=1
		animation.play("Parry_F")
	if Input.is_action_just_released("parry_l"):
		previous_direction = "left"
		marker2D.scale.x=-1
		animation.play("Parry_F")
	if Input.is_action_just_released("parry_d") && !is_on_floor():
		previous_direction = "down"
		animation.play("Parry_D")

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
		if $AnimationPlayer.current_animation == "Parry_F" || $AnimationPlayer.current_animation == "Parry_D" || $AnimationPlayer.current_animation == "Jump" && !is_on_floor():
			pass
		else:
			animation.play("Idle")

	if $AnimationPlayer.is_playing() && $AnimationPlayer.current_animation == "Parry_F" || $AnimationPlayer.current_animation == "Parry_D" || $AnimationPlayer.current_animation == "Jump" && !is_on_floor() || $AnimationPlayer.current_animation == "Slide":
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

	# WALL STUFF
	wall_slide(delta)

	# MOVEMENT
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	move_and_slide()

func wall_slide(_delta):
	if is_on_wall() && !is_on_floor():
		if Input.is_action_pressed("m_grab"):
			velocity.y = 0
			print("sliding")
			if Input.is_action_pressed("parry_r"):
				print("right")
				velocity.x = -knockback_power_horizontal - 1500
				velocity.y = -knockback_power_vertical + 100
			elif Input.is_action_pressed("parry_l"):
				print("left")
				velocity.x = knockback_power_horizontal + 1500
				velocity.y = -knockback_power_vertical + 100
			elif Input.is_action_pressed("parry_d"):
				print("down")
				velocity.y = -knockback_power_vertical
			else:
				velocity.x = 0

func _input(event : InputEvent):
	if(event.is_action_pressed("m_down") && is_on_floor()):
		position.y += 1

# PARRY
func _on_attack_box_area_entered(area):
	if area.is_in_group("Collide") || is_on_wall() && !is_on_floor() && Input.is_action_pressed("m_grab"):
		if previous_direction == "right":
			print("right")
			velocity.x = -knockback_power_horizontal - h_modify
			velocity.y = -knockback_power_vertical + v_modify
		elif previous_direction == "left":
			print("left")
			velocity.x = knockback_power_horizontal + h_modify
			velocity.y = -knockback_power_vertical + v_modify
		elif previous_direction == "down":
			print("down")
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

