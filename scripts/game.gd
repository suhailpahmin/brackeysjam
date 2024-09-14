extends Node2D

@onready var player: CharacterBody2D = %Player
#@onready var highScore: Label = $Control/HighScore

var gameStarted: bool = false

func _process(delta: float) -> void:
	if gameStarted:
		increaseScore(delta)
	
func increaseScore(delta: float):
	# The deeper the player is, the higher the score increases
	var newScore = delta * abs(player.position.y)
	Global.highScore += newScore
	#highScore.text = str(int(Global.highScore))

func _on_speed_timer_timeout() -> void:
	Global.currentSpeed += 0.1

func _on_game_start_point_body_entered(_body: Node2D) -> void:
	gameStarted = true
