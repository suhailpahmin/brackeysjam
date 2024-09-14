extends CharacterBody2D

# Movement Mechanics
@export_category("Movement")
@export var maxSpeed: float = 130.0
@export var acceleration: float = 25.0
@export var friction: float = 0.4

# Jump Mechanics
@export_category("Jump")
@export var jumpHeight: float = 30.0
@export var jumpTimeToPeak: float = 0.3
@export var jumpTimeToDescent: float = 0.2
@export var jumpBufferTimer: float = 0.1
@export var wallJumpPower: float = 300.0
@export var wallSlideFriction: float = 0.6

# Dash Mechanics
@export_category("Dash")
@export var dashSpeed: float = 300.0
@export var dashDuration: float = 0.2
@export var dashCooldown: float = 0.5
var isDashing: bool = false
var dashDirection: Vector2 = Vector2.ZERO
var dashTimer: float = 0.0
var canDash: bool = true

var jumpBuffer = false
var jumpCount = 0

const MAX_JUMP = 2
# End of Jump

# Wall Slide
var isWallSliding = false

# Handles Player Direction for cleaner animations
enum Direction { LEFT, RIGHT }
var FACING_DIRECTION = Direction.RIGHT
var DIRECTION = {
	Direction.LEFT: "_left",
	Direction.RIGHT: "_right"
}

const GAME_OVER = preload("res://scenes/game_over.tscn")

# For 2D, the gravity (down) is positive, the jump velocity (up) is negative. So we multiply it to -1
@onready var jumpVelocity: float = ((2.0 * jumpHeight) / jumpTimeToPeak) * -1.0
@onready var jumpGravity: float = ((-2.0 * jumpHeight) / (jumpTimeToPeak * jumpTimeToPeak)) * -1.0
@onready var fallGravity: float = ((-2.0 * jumpHeight) / (jumpTimeToDescent * jumpTimeToDescent)) * -1.0

# General
@onready var coyoteTimer = $Coyote
@onready var sprite = $AnimatedSprite2D
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Area2D = $Hitbox

# Sounds
@onready var jumpSound: AudioStreamPlayer2D = $JumpSound
@onready var wallSlidingSound: AudioStreamPlayer2D = $WallSlidingSound

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	Global.isDead = false

func _physics_process(delta: float) -> void:
	
	# Stops everything if dead
	if Global.isDead:
		return
		
	# Sets gravity
	velocity.y += getGravity() * delta
	
	# Handle dash
	if isDashing:
		dashMovement(delta)
		return
		
	# Reset double jump on wall slide
	if is_on_wall() and jumpCount != 0:
		jumpCount = 0
	
	# Reset Double Jump
	if is_on_floor() or is_on_wall() and jumpCount != 0:
		jumpCount = 0
		if jumpBuffer:
			jump()
			jumpBuffer = false
			
	# Handle Dash Input
	if canDash and Input.is_action_just_pressed("dash"):
		startDash()

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if ((is_on_floor() or !coyoteTimer.is_stopped()) and jumpCount < MAX_JUMP):
			jump()
		else:
			# Trigger jump buffer
			jumpBuffer = true
			get_tree().create_timer(jumpBufferTimer).timeout.connect(on_jump_buffer_timeout)
#
	## Get the input direction and handle the Imovement/deceleration.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		FACING_DIRECTION = Direction.LEFT if direction < 0 else Direction.RIGHT
		velocity.x = min(velocity.x + acceleration, maxSpeed) if direction > 0 else max(velocity.x - acceleration, -maxSpeed)
		if is_on_wall():
			velocity.y = lerp(0.0, velocity.y, wallSlideFriction)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)
	
	if !is_on_floor() and not Input.is_action_just_pressed("jump"):
		coyoteTimer.start()
		
	# Wall Jump
	if is_on_wall() and Input.is_action_just_pressed("jump"):
		if direction < 0:
			velocity = Vector2(200, -wallJumpPower)
		elif direction > 0:
			velocity = Vector2(-200, -wallJumpPower)
		
	move_and_slide()
	
	update_states(direction)
	
func update_states(direction):
	# Default Animation
	var animation = "idle"
	
	if is_on_floor():
		if direction != 0:
			animation = "run"
	else:
		if velocity.y < 0:
			animation = "jump"
		elif velocity.y == jumpHeight:
			animation = "peak_jump"
		elif velocity.y > 0:
			animation = "fall"

	animation += DIRECTION[FACING_DIRECTION]

	if is_on_wall() and isWallSliding:
		# This stops the animator from playing other animation during wall slide 
		# and keep replaying the wallslide animation
		return
	
	if is_on_wall() and !isWallSliding:
		if direction < 0:
			animation = "wall_slide_left"
			isWallSliding = true
			animationPlayer.play(animation)
		else:
			animation = "wall_slide_right"
			isWallSliding = true
			animationPlayer.play(animation)
	else:
		animationPlayer.play(animation)
		isWallSliding = false
		
func startDash() -> void:
	isDashing = true
	dashTimer = dashDuration
	dashDirection = Vector2(-1 if FACING_DIRECTION == Direction.LEFT else 1, 0)
	canDash = false
	
	# Start cooldown timer
	get_tree().create_timer(dashCooldown).timeout.connect(_on_dash_cooldown)
	
func dashMovement(delta: float) -> void:
	dashTimer -= delta
	if dashTimer <= 0.0:
		isDashing = false
		velocity = Vector2.ZERO
	else:
		velocity = dashDirection * dashSpeed
		move_and_slide()
		
# Returns jump gravity or fall gravity
func getGravity() -> float:
	return jumpGravity if velocity.y < 0.0 else fallGravity
	
func on_jump_buffer_timeout() -> void:
	jumpBuffer = false
	
func jump():
	jumpCount += 1
	velocity.y = jumpVelocity

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "wall_slide_left":
		animationPlayer.play("wall_sliding_left")
	elif anim_name == "wall_slide_right":
		animationPlayer.play("wall_sliding_right")

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
		died()
	
func _on_dash_cooldown() -> void:
	canDash = true

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "LightningBox":
		died()
		
func died():
	Global.isAngry = false
	Global.isDead = true
	GameOver.display()
