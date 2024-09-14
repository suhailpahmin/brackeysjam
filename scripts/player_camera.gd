extends Camera2D

# Camera Mechanics
@export var randomStrength: float = 30.0
@export var shakeFade: float = 5.0

var shakeStrength: float = 0.0
var rng = RandomNumberGenerator.new()

func shake():
	shakeStrength = randomStrength

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shakeStrength > 0:
		shakeStrength = lerpf(shakeStrength, 0, shakeFade * delta)
		offset = randomOffset()

func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shakeStrength, shakeStrength), rng.randf_range(-shakeStrength, shakeStrength))

func _on_game_shake_camera() -> void:
	shake()
