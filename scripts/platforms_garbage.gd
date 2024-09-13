extends Area2D

@export var gapWithPlayer: float = 500.0
@onready var player: CharacterBody2D = %Player

func _physics_process(_delta: float) -> void:
	# This will wipe out platforms above player
	position.y = player.position.y - gapWithPlayer

func _on_body_entered(body: Node2D) -> void:
	body.queue_free()
