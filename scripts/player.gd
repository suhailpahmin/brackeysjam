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

# For 2D, the gravity (down) is positive, the jump velocity (up) is negative. So we multiply it to -1
@onready var jumpVelocity: float = ((2.0 * jumpHeight) / jumpTimeToPeak) * -1.0
@onready var jumpGravity: float = ((-2.0 * jumpHeight) / (jumpTimeToPeak * jumpTimeToPeak)) * -1.0
@onready var fallGravity: float = ((-2.0 * jumpHeight) / (jumpTimeToDescent * jumpTimeToDescent)) * -1.0

# General
@onready var coyoteTimer = $Coyote
@onready var sprite = $AnimatedSprite2D
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	# Sets gravity
	velocity.y += getGravity() * delta
	
	# Reset Double Jump
	if is_on_floor() and jumpCount != 0:
		jumpCount = 0
		if jumpBuffer:
			jump()
			jumpBuffer = false

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if ((is_on_floor() or !coyoteTimer.is_stopped()) or jumpCount < MAX_JUMP):
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
	
	update_animations(direction)
	
func update_animations(direction):
	# Default Animation
	var animation = "idle"
	
	if is_on_floor():
		# TODO Add Run Animation
		pass
	else:
		if velocity.y < 0:
			animation = "jump"
		elif velocity.y == jumpHeight:
			animation = "jump_peak"
		elif velocity.y > 0:
			animation = "fall"
			
	animation += DIRECTION[FACING_DIRECTION]
	
	if is_on_wall() and !animationPlayer.current_animation.contains("wall_slide"):
		if direction < 0:
			animation = "wall_slide_left"
			animationPlayer.play(animation)
		else:
			animation = "wall_slide_right"
			animationPlayer.play(animation)
	elif is_on_wall() and animationPlayer.current_animation.contains("wall_slide"):
		return
	else:
		animationPlayer.play(animation)
	
# Returns jump gravity or fall gravity
func getGravity() -> float:
	return jumpGravity if velocity.y < 0.0 else fallGravity
	
func on_jump_buffer_timeout() -> void:
	jumpBuffer = false
	
func jump():
	velocity.y = jumpVelocity
