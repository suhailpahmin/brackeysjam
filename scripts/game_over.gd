extends CanvasLayer

const GAME = preload("res://scenes/game.tscn")
const MAIN_MENU = preload("res://scenes/main_menu.tscn")

@onready var score_value: Label = $Panel/VBoxContainer/ScoreBox/ScoreValue
@onready var gameOverPanel: VBoxContainer = $Panel/VBoxContainer
@onready var highscore_value: Label = $Panel/VBoxContainer/HighScoreBox/HighscoreValue
@onready var click_sound: AudioStreamPlayer2D = $ClickSound

func _ready():
	hide()
	
func _process(_delta: float) -> void:
	score_value.text = str(int(Global.score))
	var highScore = Global.score if Global.score > Global.highScore else Global.highScore
	highscore_value.text = str(int(highScore))

# Function to display the game over screen
func display() -> void:
	show()
	
# Helper function to handle transitions and scene changes
func change_scene(scene: PackedScene) -> void:
	hide()
	TransitionScreen.transition()
	updateScore()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_packed(scene)
	
func _on_retry_pressed() -> void:
	click_sound.play()
	change_scene(GAME)
	
func updateScore():
	Global.highScore = max(Global.highScore, Global.score)
	Global.score = 0

func _on_main_menu_pressed() -> void:
	change_scene(MAIN_MENU)
