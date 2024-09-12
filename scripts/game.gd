extends Node2D

@export var cameraSpeed: float = 0.03

@onready var camera: Camera2D = $Camera2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	camera.position.y += cameraSpeed
