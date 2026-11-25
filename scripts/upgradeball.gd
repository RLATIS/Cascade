extends RigidBody2D

@export var upgradesPerRound := 3

@export var targetBall : RigidBody2D

@onready var particle : CPUParticles2D = $part
@onready var upgradeLabel : RichTextLabel = $upgradetext
@onready var costLabel : RichTextLabel = $costtext

var cost : int
var upgrade : String

var hitTrauma := 0.1
var cam : Camera2D
var ui : CanvasLayer

var isMain := true

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	if isMain:
		rng.seed = Globals.seed + 3
		
	hitTrauma = targetBall.hitTrauma
	cam = targetBall.cam
	ui = targetBall.ui
	
	if not isMain:
		# total weight of all upgrades
		var totalWeight := 0
		for upgradename in Globals.upgrades.keys():
			totalWeight += Globals.upgrades[upgradename].weight
		
		# random number between 0 and totalWeight
		var randomvalue := rng.randi_range(0, totalWeight)
		var currentWeight := 0
		var weight := 0
		
		for upgradeName in Globals.upgrades.keys():
			currentWeight += Globals.upgrades[upgradeName].weight
			if randomvalue < currentWeight:
				upgrade = upgradeName
				weight = Globals.upgrades[upgradeName].weight
				cost = Globals.upgrades[upgradeName].cost
				break
		
		cost = round(cost)
		
		if weight <= 7:
			upgradeLabel.modulate = Color('48c1ff')

		if weight <= 4:
			upgradeLabel.modulate = Color("ff7ce2ff")
		
		if weight <= 1:
			upgradeLabel.modulate = Color('ff8d00')

		upgradeLabel.text = upgrade
		costLabel.text = '$' + str(cost)
	
func particlespawn():
	var p = particle.duplicate()
	get_parent().add_child(p)
	p.global_position = self.global_position
	p.emitting = true
	p.finished.connect(p.queue_free)

func die(dotrauma=true):
	Globals.playsound('res://sounds/explosion.wav', rng.randf_range(0.7, 1.4), rng.randf_range(-3, -0.5))
	ui.updateLabels(true)
	particlespawn()
	if dotrauma:
		cam.trauma += hitTrauma
	queue_free()

func hit():
	if Globals.money >= cost:
		# ACTUAL SHOP LOGIC HERE!!!
		Globals.ownedUpgrades.append(upgrade)
		Globals.money -= cost
		
		Globals.playsound('res://sounds/upgrade.wav', rng.randf_range(0.9, 1.1), rng.randf_range(-0.5, 0.0))
		
		Globals.updateStats()
		die()
	else:
		Globals.playsound('res://sounds/poor.wav', 1.0, rng.randf_range(-0.5, 0.5))

func spawnupgrades():
	print('spawing upgrades!')

	for i in range(upgradesPerRound):
		var c = self.duplicate()
		c.position.x = 257
		c.position.y = (i-1) * 190
		c.rng.seed = Globals.seed + Globals.round * 1000 + i * 10

		c.name = 'REALUPGRADE' + str(i)
		c.isMain = false

		get_parent().add_child(c)
		
func _on_hitarea_body_entered(body: Node2D) -> void:
	if 'bullet' in body.name.to_lower():
		if not 'used' in body.name:
			body.name = 'used' + body.name

			hit()
