extends CanvasLayer

@onready var bg: ColorRect = $bg

@export var initcol1 := Color('0d052680')
@export var initcol2 := Color('330d6680')
@export var rainbowSPEED := 0.01

var hue

func _ready() -> void:
	hue = initcol2.h

func _process(delta: float) -> void: 
	hue = fmod(hue + delta * rainbowSPEED, 1.0)
	
	var chosen := Color.from_hsv(hue, 0.87, 0.4, 0.5)
	
	var col1 := chosen.darkened(0.625) # darken it
	col1.a = 0.5 # transparentify it 
	
	var shaderMat := bg.material as ShaderMaterial # find the actual mat
	
	shaderMat.set_shader_parameter('col1', col1) 
	shaderMat.set_shader_parameter('col2', chosen)
