extends Camera2D

@export var decay := 0.8 
@export var maxTrauma := 1.0
@export var maxOffset := Vector2(100, 75) 
@export var maxRoll := 0.1 

var trauma := 0.0 
@export var traumaPower := 2 

func _ready() -> void:
	randomize()

func _process(delta: float) -> void:
	if trauma > 0.0:
		if trauma > maxTrauma: trauma = maxTrauma
		trauma = max(trauma - decay * delta, 0.0)
		shake()
	else:
		offset = Vector2.ZERO
		rotation = 0.0

#func addtrauma(amount: float) -> void:
#	trauma = min(trauma + amount, 1.0)

func shake() -> void:
	var amount := pow(trauma, traumaPower)
	rotation = maxRoll * amount * randf_range(-1.0, 1.0)
	offset.x = maxOffset.x * amount * randf_range(-1.0, 1.0)
	offset.y = maxOffset.y * amount * randf_range(-1.0, 1.0)
