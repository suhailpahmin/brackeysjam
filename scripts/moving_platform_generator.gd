extends Node2D

var blocks = [
	preload("res://scenes/blocks/block_a.tscn")
]

@export var moveDistance = 500.0
@export var minBlockAmount = 2
@export var maxBlockAmount = 5

@onready var player: CharacterBody2D = %Player
@onready var spawnCollision: CollisionShape2D = $SpawnArea/CollisionShape2D
@onready var spawnArea: Area2D = $SpawnArea

func _ready() -> void:
	generateBlocks()
	
func _physics_process(_delta: float) -> void:
	position.y = player.position.y + moveDistance

func generateBlocks():
	var spawnShape = spawnCollision.shape as RectangleShape2D
	var screenWidth = spawnShape.extents.x * 0.915
	var blocksToGenerate = randf_range(minBlockAmount, maxBlockAmount) # Generate random blocks amount
	
	for block in range(blocksToGenerate):
		# Random X position within screen width
		var randomX = randf_range(-screenWidth, screenWidth)
		var randomY = position.y + (block * 100) # Spacing for each block
		
		# Instantiate block
		var instance = blocks[randi() % blocks.size()].instantiate()
		instance.position = Vector2(randomX, randomY)
		
		# Add block to parent
		get_parent().add_child.call_deferred(instance)

func _on_generation_timer_timeout() -> void:
	generateBlocks()
