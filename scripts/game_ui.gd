extends CanvasLayer

@onready var score: Label = $VBoxContainer/Score
@onready var highscore: Label = $VBoxContainer/Highscore

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	score.text = "Score: " + str(int(Global.score))
	highscore.text = "Highscore: " + str(int(Global.highScore))
