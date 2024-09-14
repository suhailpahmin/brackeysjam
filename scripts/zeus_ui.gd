extends Control

# Angry Assets
const ANGRY_BACKGROUND = preload("res://assets/zeus/angry_background.png")
const ANGRY_BORDER = preload("res://assets/zeus/angry_border.png")
const ANGRY_ZEUS = preload("res://assets/zeus/angry_zeus.png")

# Calm Assets
const CALM_BACKGROUND = preload("res://assets/zeus/calm_background.png")
const CALM_BORDER = preload("res://assets/zeus/calm_border.png")
const CALM_ZEUS = preload("res://assets/zeus/calm_zeus.png")

@onready var portrait: NinePatchRect = $Portrait
@onready var bg: NinePatchRect = $BG
@onready var border: NinePatchRect = $Border

# General
@export var frequency: float = 3.0
@export var amplitude: float = 100.0
var time: float = 0.0

# This is to avoid an infinite loop of resetting the same texture every frame
var isAngry: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	time += delta
	var offset = cos(time * frequency) * amplitude
	portrait.position.y = offset * delta
	
	if Global.isAngry:
		angry()
	else:
		calm()
	
func calm():
	if isAngry:
		bg.texture = CALM_BACKGROUND
		portrait.texture = CALM_ZEUS
		border.texture = CALM_BORDER
		isAngry = false
	
func angry():
	if not isAngry:
		bg.texture = ANGRY_BACKGROUND
		portrait.texture = ANGRY_ZEUS
		border.texture = ANGRY_BORDER
		isAngry = true
