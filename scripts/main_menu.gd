extends Control

const game = preload("res://scenes/game.tscn")

@onready var click_sound: AudioStreamPlayer2D = $ClickSound
@onready var mainMenuSong: AudioStreamPlayer2D = $MainMenuSong
@onready var start: Button = $VBoxContainer/Start
@onready var exit: Button = $VBoxContainer/Exit

func _on_start_pressed() -> void:
	click_sound.play()
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_packed(game)

func _on_exit_pressed() -> void:
	click_sound.play()
	get_tree().quit()
