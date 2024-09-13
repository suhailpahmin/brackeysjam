extends Node2D

@export var tileSpeed: float  = 0.1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position.y -= tileSpeed
