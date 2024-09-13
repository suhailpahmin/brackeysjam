extends Node2D

@export var generationHeight: float = 100.0

var pillarBody = preload("res://scenes/blocks/pillar_body.tscn")

@onready var spawnCollision: CollisionShape2D = $SpawnArea/CollisionShape2D
@onready var spawnArea: Area2D = $SpawnArea
		
func _physics_process(_delta: float) -> void:
	# Generate blocks if no blocks in spawn area
	if spawnArea.get_overlapping_bodies().is_empty():
		generateBlocks()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	position.y += generationHeight
	generateBlocks()
	
func generateBlocks():
	var spawnShape = spawnCollision.shape as RectangleShape2D
	var screenWidth = spawnShape.extents.x * 0.915
	var blocksToGenerate = 5
	
	for block in range(blocksToGenerate):
		# Spawn left pillar body
		var leftX = -screenWidth
		var rightX = screenWidth + 4
		var pillarY = position.y + (block * 25)
		
		var leftPillar = pillarBody.instantiate()
		var rightPillar = pillarBody.instantiate()
		leftPillar.position = Vector2(leftX, pillarY)
		rightPillar.position = Vector2(rightX, pillarY)
		# Add block to parent
		get_parent().add_child(leftPillar)
		get_parent().add_child(rightPillar)
