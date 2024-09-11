extends CharacterBody2D

signal player_died

# Movement Mechanics
@export_category("Movement")
@export var MAX_SPEED = 130.0
@export var ACCELERATION = 25.0
@export var FRICTION = 0.4

# Jump Mechanics
@export_category("Jump")
@export var JUMP_HEIGHT: float = 30.0
@export var JUMP_TIME_TO_PEAK: float = 0.3
@export var JUMP_TIME_TO_DESCENT: float = 0.2
@export var JUMP_BUFFER_TIMER:float = 0.1
@export var WALL_JUMP_POWER:float = 200.0
@export var WALL_SLIDE_GRAVITY:float = 50

# Attack Mechanics
@export_category("Combat")
@export var DAMAGE = 10
@export var MAX_HEALTH = 500
@export var CRASH_DAMAGE = 10
@export var KNOCKBACK = 100.0
var HEALTH
var IS_ATTACKING = false
var IS_DODGING = false
var CAN_DODGE = true
var CURRENT_ATTACK = 0
var HAS_DIED = false

# For 2D, the gravity (down) is positive, the jump velocity (up) is negative. So we multiply it to -1
@onready var JUMP_VELOCITY: float = ((2.0 * JUMP_HEIGHT) / JUMP_TIME_TO_PEAK) * -1.0
@onready var JUMP_GRAVITY: float = ((-2.0 * JUMP_HEIGHT) / (JUMP_TIME_TO_PEAK * JUMP_TIME_TO_PEAK)) * -1.0
@onready var FALL_GRAVITY: float = ((-2.0 * JUMP_HEIGHT) / (JUMP_TIME_TO_DESCENT * JUMP_TIME_TO_DESCENT)) * -1.0

# General
@onready var COYOTE_TIMER = $Coyote
@onready var ANIMATION = $AnimationPlayer
@onready var PLAYER = $"."
@onready var COLLISION = $CollisionShape2D
@onready var CAMERA = $Camera2D
@onready var dodge_timer = $DodgeTimer
@onready var smash_sound = $SmashSound
@onready var animated_sprite_2d = $AnimatedSprite2D

# Handles Player Direction for cleaner animations
enum Direction { LEFT, RIGHT }
var FACING_DIRECTION = Direction.RIGHT
var DIRECTION = {
	Direction.LEFT: "_left",
	Direction.RIGHT: "_right"
}

# Jump Buffer
var JUMP_BUFFER = false

# Double Jump
const MAX_JUMP = 2
var JUMP_COUNT = 0

# Wall Slide
var WALL_SLIDING = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	HEALTH = MAX_HEALTH

func _physics_process(delta):
	# Sets the gravity
	velocity.y += get_gravity() * delta
	
	if CutsceneManager.is_cutscene_ongoing() or HAS_DIED:
		return
		
	if HEALTH <= 0:
		move_and_slide()
		died()
		return
	
	# Handles Combat
	if Input.is_action_just_pressed("attack") and is_on_floor():
		attack()
	
	# Reset Double Jump
	if is_on_floor() and JUMP_COUNT != 0:
		JUMP_COUNT = 0
		if JUMP_BUFFER:
			jump()
			JUMP_BUFFER = false

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if ((is_on_floor() or !COYOTE_TIMER.is_stopped()) or JUMP_COUNT < MAX_JUMP):
			jump()
		else:
			# Trigger jump buffer
			JUMP_BUFFER = true
			get_tree().create_timer(JUMP_BUFFER_TIMER).timeout.connect(on_jump_buffer_timeout)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if direction and !IS_ATTACKING:
		FACING_DIRECTION = Direction.LEFT if direction < 0 else Direction.RIGHT
		velocity.x = min(velocity.x + ACCELERATION, MAX_SPEED) if direction > 0 else max(velocity.x - ACCELERATION, -MAX_SPEED)
		#PLAYER_SPRITE.flip_h = direction < 0  # Flip character based on direction
		#PLAYER.scale.x = scale.y * direction # Flip the whole node to affect collision too
	else:
		velocity.x = lerp(velocity.x, 0.0, FRICTION)
		
	if Input.is_action_just_pressed("dodge") and is_on_floor() and CAN_DODGE:
		dodge()
		
	# Checks if player is on the floor before moving
	var wasOnFloor = is_on_floor()
	
	# Handles Coyote
	if wasOnFloor and !is_on_floor() and not Input.is_action_just_pressed("jump"):
		COYOTE_TIMER.start()
	
	if !IS_ATTACKING:
		move_and_slide()
	
	update_animations(direction)
	
func died():
	HAS_DIED = true
	var animation = "death"
	animation += DIRECTION[FACING_DIRECTION]
	ANIMATION.play(animation)
	PLAYER.set_collision_layer_value(1, false)
	PLAYER.set_collision_mask_value(3, false)
	player_died.emit()
	
# Returns jump gravity or fall gravity
func get_gravity() -> float:
	return JUMP_GRAVITY if velocity.y < 0.0 else FALL_GRAVITY
	
func dodge():
	dodge_timer.start()
	IS_DODGING = true
	toggle_enemy_detection()
	CAN_DODGE = false
	await get_tree().create_timer(1).timeout
	CAN_DODGE = true
	
func toggle_enemy_detection():
	var playerLayer = PLAYER.get_collision_layer_value(1)
	PLAYER.set_collision_layer_value(1, !playerLayer)
	var enemyMask = PLAYER.get_collision_mask_value(3)
	PLAYER.set_collision_mask_value(3, !enemyMask)
	
func jump():
	velocity.y = JUMP_VELOCITY
	if is_on_wall() and Input.is_action_pressed("move_right"):
		# On right wall
		velocity.x = -WALL_JUMP_POWER
	elif is_on_wall() and Input.is_action_pressed("move_left"):
		# On left wall
		velocity.x = WALL_JUMP_POWER
	else:
		JUMP_COUNT += 1
		
func attack():
	IS_ATTACKING = true
	if CURRENT_ATTACK == 0:
		CURRENT_ATTACK = 1
	elif CURRENT_ATTACK == 1:
		CURRENT_ATTACK = 2
	elif CURRENT_ATTACK == 2:
		CURRENT_ATTACK = 3
		
func update_animations(direction):
	# Default Animation
	var animation = "idle"
	
	if !IS_ATTACKING:
		if is_on_floor():
			if IS_DODGING:
				animation = "roll"
			elif direction:
				animation = "run"
		else:
			if velocity.y < 0:
				animation = "jump"
			elif velocity.y > 0:
				animation = "fall"
	else:
		animation = "attack_" + str(CURRENT_ATTACK)
			
	# Directs animation
	animation += DIRECTION[FACING_DIRECTION]
	ANIMATION.play(animation)
	
func on_jump_buffer_timeout() -> void:
	JUMP_BUFFER = false
	
func get_damage():
	var damage = 10
	if CURRENT_ATTACK == 2:
		damage = 15
	elif CURRENT_ATTACK == 3:
		damage = 20
	return damage
	
func hit(damage):
	HEALTH -= damage
	animated_sprite_2d.material.set_shader_parameter("hit_opacity", 1)
	smash_sound.play(0.37)
	await get_tree().create_timer(0.5).timeout
	animated_sprite_2d.material.set_shader_parameter("hit_opacity", 0)
	smash_sound.stop()

func _on_attack_range_body_entered(body):
	if body.name == 'Father' or body.name.contains('Eyeball'):
		body.hit(get_damage())

func _on_animation_player_animation_finished(anim_name):
	if anim_name.contains("attack"):
		IS_ATTACKING = false
		CURRENT_ATTACK = 0
	elif anim_name.contains("death"):
		await get_tree().create_timer(3).timeout
		get_tree().reload_current_scene()

func _on_danger_range_body_entered(_body):
	if !IS_DODGING:
		velocity.x = lerp(KNOCKBACK, 0.0, 5.0)
		move_and_slide()

func _on_end_of_map_body_entered(_body):
	CAMERA.limit_right = 1800

func play_animation(anim_name):
	ANIMATION.play(anim_name)

func _on_dodge_timer_timeout():
	IS_DODGING = false
	toggle_enemy_detection()
	
func move_towards(directionX):
	move_and_slide()
	velocity.x = directionX
	var direction = "left" if directionX < 0 else "right"
	ANIMATION.play("run_" + direction)
