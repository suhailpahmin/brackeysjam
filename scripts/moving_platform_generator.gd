extends Node2D

var blocks = [
	preload("res://scenes/blocks/block_a.tscn")
]

@export var moveDistance: float = 500.0
@export var minBlockAmount: int = 2
@export var maxBlockAmount: int = 5
@export var minGap: float = 100.0

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
	var previousX = null
	
	for block in range(blocksToGenerate):
		var randomX: float = 0.0
		
		# Generate a new random X until it's far enough from previous block
		while previousX != null and abs(randomX - previousX) < minGap:
			randomX = randf_range(-screenWidth, screenWidth)
		
		var randomY: float = position.y + (block * 100) # Spacing for each block
		
		# Instantiate block
		var instance = blocks[randi() % blocks.size()].instantiate()
		instance.position = Vector2(randomX, randomY)
		
		# Add block to parent
		get_parent().add_child.call_deferred(instance)
		
		# Update previous X
		previousX = randomX

func _on_generation_timer_timeout() -> void:
	generateBlocks()
