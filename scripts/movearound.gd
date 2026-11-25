extends Label

var timepassed := 0.0

@export var amplitude: float = 5.0  
@export var frequency: float = 1.0

var startpos : Vector2

func _ready() -> void:
	startpos = position

func _process(delta: float) -> void:
	timepassed += delta
	
	position.y = startpos.y + sin(timepassed * frequency) * amplitude
