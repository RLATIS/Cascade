extends RigidBody2D

@export var hitTrauma := 0.1

@export var leftmost : int
@export var rightmost : int
@export var upmost : int
@export var downmost : int

@onready var particle : CPUParticles2D = $part

@export var cam : Camera2D
@export var ui : CanvasLayer
@export var bg: ColorRect

var shouldteleport := true
var isMain := true

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	if isMain:
		rng.seed = Globals.seed + 2
	
func spawn(clones):
	if isMain:
		self.visible = true
		if clones > 0:
			print('spawning ' + str(clones) + ' clones')
			for i in range(clones):
				var c = self.duplicate()
				c.isMain = false
				c.name = 'targetClone' + str(i)
				c.rng.seed = rng.seed + i
				self.get_parent().add_child(c)
		else:
			print('no clones!!')
			
func hit():
	print(self.name, ' was hit')
	
	Globals.playsound('res://sounds/explosion.wav', rng.randf_range(0.7, 1.4), rng.randf_range(-3, -0.5))
	Globals.score += Globals.scorePerTarget
	
	ui.updateLabels()
	
	particlespawn()

	cam.trauma += hitTrauma

	shouldteleport = true

func particlespawn():
	var p = particle.duplicate()
	get_parent().add_child(p)
	p.global_position = self.global_position
	p.emitting = true
	p.finished.connect(p.queue_free)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if shouldteleport:
		var newpos = Vector2(rng.randi_range(leftmost, rightmost), rng.randi_range(upmost, downmost))
		state.transform = Transform2D(state.transform.get_rotation(), newpos)
		
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0.0
		
		shouldteleport = false

func _on_hitarea_body_entered(body: Node2D) -> void:
	if 'bullet' in body.name:
		hit()
		body.hitsomething()
	
