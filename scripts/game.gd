extends Node2D

signal shakeCamera

@onready var player: CharacterBody2D = %Player
@onready var moodTimer: Timer = $MoodTimer
@onready var playerCamera: Camera2D = $Player/Camera2D

@export var minMoodChange: float = 10.0 # 10 seconds
@export var maxMoodChange: float = 30.0 # 30 seconds

var gameStarted: bool = false
var calmColor: Color = Color(0.80, 0.60, 0.92, 1)
var angryColor: Color = Color(0.88, 0.44, 0.52, 1)

func _ready() -> void:
	RenderingServer.set_default_clear_color(calmColor)
	randomizeMoodTimer()

func _physics_process(delta: float) -> void:
	if gameStarted and !Global.isDead:
		increaseScore(delta)
		
func angryZeus() -> void:
	shakeCamera.emit()
	RenderingServer.set_default_clear_color(angryColor)
	
func calmZeus() -> void:
	RenderingServer.set_default_clear_color(calmColor)
	
func randomizeMoodTimer():
	var randomTime = randf_range(minMoodChange, maxMoodChange)
	moodTimer.wait_time = randomTime
	
func increaseScore(delta: float):
	# The deeper the player is, the higher the score increases
	var newScore = delta * abs(player.position.y)
	Global.score += newScore

func _on_speed_timer_timeout() -> void:
	Global.currentSpeed += 0.1

func _on_game_start_point_body_entered(_body: Node2D) -> void:
	gameStarted = true
	moodTimer.start()

func _on_mood_timer_timeout() -> void:
	Global.isAngry = !Global.isAngry
	
	if Global.isAngry:
		angryZeus()
	else:
		calmZeus()
		
	randomizeMoodTimer()
	moodTimer.start()
