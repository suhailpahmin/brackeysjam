extends Node2D

var blocks = [
	preload("res://scenes/blocks/block_a.tscn")
]

@export var moveDistance = 100.0
@export var minBlockAmount = 1
@export var maxBlockAmount = 3

@onready var spawnCollision: CollisionShape2D = $PlayerDetector/CollisionShape2D
@onready var spawnArea: Area2D = $SpawnArea
		
func _physics_process(delta: float) -> void:
	# Generate blocks if no blocks in spawn area
	if spawnArea.get_overlapping_bodies().is_empty():
		generateBlocks()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	position.y += 100.0
	generateBlocks()
	
func generateBlocks():
	var screenWidth = get_viewport_rect().size.x
	var blocksToGenerate = randf_range(minBlockAmount, maxBlockAmount) # Generate random blocks amount
	
	for block in range(blocksToGenerate):
		# Random X position within screen width
		var randomX = randf_range(-screenWidth, screenWidth)
		var randomY = position.y + (block * 100) # Spacing for each block
		
		# Instantiate block
		var instance = blocks[randi() % blocks.size()].instantiate()
		instance.position = Vector2(randomX, randomY)
		
		# Add block to parent
		get_parent().add_child(instance)
