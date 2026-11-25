extends StaticBody2D

var initx := 0.0
@export var time := 1.0
@export var offscreenx := 1200
@export var col : CollisionShape2D

func _ready() -> void:
	$wallTexture.texture.noise.seed = Globals.seed
	
	col.set_deferred("disabled", true)
	initx = position.x
	position.x = offscreenx
	
	var tween = create_tween()
	tween.tween_property(self, "position:x", initx, time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	
	col.set_deferred("disabled", false)
