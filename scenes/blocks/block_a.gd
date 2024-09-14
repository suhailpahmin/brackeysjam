extends Node2D

var blockSpeed: float = 0.0
var blockMinBaseSpeed: float = 0.1
var blockMaxBaseSpeed: float = 0.5
var maxSpeed: float = 2

func _ready() -> void:
	# Randomize block speed
	blockSpeed = randf_range(blockMinBaseSpeed, blockMaxBaseSpeed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	var speed = Global.currentSpeed + blockSpeed
	position.y -= clamp(speed, 0.0, maxSpeed)
