extends CanvasLayer

@export var roundcooldown := 1.33
@export var scorePerMoney := 3.0

@export var maintarget : RigidBody2D
@export var upgradeBall : RigidBody2D
@export var statsLabel : Label
@export var cam : Camera2D
@export var path : Line2D
@export var bginthisscene : CanvasLayer

@onready var timerBar : ProgressBar = $timer
@onready var roundLabel : Label = $roundLabel

@export var pausemenu : CanvasLayer

var exiting := false

var triggeredyet := false

var lastScoreCheckedForMoney := 0.0
var moneyScoreRemainder := 0.0

var LEAVINGGAME := false

var beatenquotatrigger := false

func _ready() -> void:
	Globals.newgame()
	
	triggeredyet = true
	timerBar.value = 0.01

	for c in get_children():
		c.modulate = Color('ffffff00')
		var ct = create_tween()
		ct.tween_property(c, 'modulate', Color('ffffff'), 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		
	await get_tree().create_timer(2.3).timeout

	restartround()

func updateLabels(eq:=false):
	$scoreText.text = 'Score: ' + Globals.formatcommas(Globals.score)
	$moneyText.text = 'Money: $' + Globals.formatcommas(Globals.money)
	if eq:
		$quotaText.text = 'Next Quota: ' + Globals.formatcommas(Globals.quota)
	else:
		$quotaText.text = 'Quota: ' + Globals.formatcommas(Globals.quota)
	Globals.updateStats()

func _process(delta: float) -> void:
	if timerBar.value > 0 and not LEAVINGGAME:
		timerBar.value -= (100.0 / Globals.roundlength) * delta
		
		var scoreDiff: float = Globals.score - lastScoreCheckedForMoney
		lastScoreCheckedForMoney = Globals.score

		if scoreDiff > 0.0 and Globals.scorePerTarget > 0.0:
			moneyScoreRemainder += scoreDiff / Globals.scorePerTarget

			var moneyEarned := floori(moneyScoreRemainder / scorePerMoney)

			if moneyEarned > 0:
				Globals.money += moneyEarned + (Globals.scorePerTarget / 500_000_000_000_000_000_000.0) # wow you can put underscores and easier to read
				moneyScoreRemainder -= moneyEarned * scorePerMoney

				Globals.playsound('res://sounds/coin.wav', randf_range(0.9, 1.2), randf_range(-1.0, -0.25))
				updateLabels()
			
		if not beatenquotatrigger:
			if Globals.score >= Globals.quota:
				beatenquotatrigger = true
				Globals.playsound('res://sounds/upgrade.wav', randf_range(0.9, 1.2), randf_range(2.0, 2.25))

	if timerBar.value <= 0 and not triggeredyet:
		triggeredyet = true
		print('end round!')
				
		for child in get_parent().get_children():
			if 'targetclone' in child.name.to_lower():
				child.particlespawn()
				child.queue_free()
				
			if child.name.to_lower() == 'targetball':
				child.particlespawn()
				child.visible = false
				child.position = Vector2(10000, 10000)

		Globals.playsound('res://sounds/explosion.wav', randf_range(0.4, 0.6))

		updateLabels()
		
		Globals.canshoot = false
		
		await waitfornobullets()
		
		if Globals.score >= Globals.quota: # win!!
			Globals.playsound('res://sounds/shop.wav', randf_range(0.9, 1.1), randf_range(3.0, 5.0))
			
			cam.trauma += 0.8
			
			Globals.canshoot = true
			upgradeBall.spawnupgrades()
			statsLabel.visible = true
			Globals.quota = snapped(Globals.quota * Globals.quotamultiply, 0.5)
			Globals.calcTax()
			
			Globals.entershop()
		else: # lose :(
			Globals.playsound('res://sounds/shop.wav', randf_range(0.4, 0.43), 3.0)
	
			Globals.canshoot = false
	
			# reset things here in case globals fails
			Globals.quota = 3.0
			Globals.round = 1
			Globals.money = 0
			Globals.scorePerTarget = 0
			Globals.ownedUpgrades.clear()
	
			var roundlabelclone = roundLabel.duplicate()
			get_parent().add_child(roundlabelclone)
			
			roundlabelclone.visible = true
			roundlabelclone.add_theme_font_size_override('font_size', 75)

			roundlabelclone.text = "You failed to\nmeet the quota..."
			var roundlabelfadein = create_tween() 
			roundlabelfadein.tween_property(roundlabelclone, 'modulate', Color(1.0, 1.0, 1.0, 1.0), 2.0)
			
			await roundlabelfadein.finished
			await get_tree().create_timer(1.0).timeout
			
			var zoominend = create_tween() 
			zoominend.tween_property(cam, "zoom", Vector2(50.0, 50.0), 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			for c in get_children():
				var ctween = create_tween()
				ctween.tween_property(c, 'modulate', Color('ffffff00'), 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			
			var pathhidetween = create_tween()
			pathhidetween.tween_property(path, 'modulate', Color('ffffff00'), 2.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			
			await zoominend.finished
			
			var menuSCENE = load("res://scenes/menu.tscn")
			var menuINSTANCE = menuSCENE.instantiate()

			# cool bg no jump
			var bg = menuINSTANCE.get_node("bg")
			bg.initcol2 = Color.from_hsv(bginthisscene.hue, 0.87, 0.4, 0.5)

			# swap
			var tree = get_tree()
			var curscene = tree.current_scene
			tree.root.add_child(menuINSTANCE)
			tree.current_scene = menuINSTANCE
			curscene.queue_free()

	elif timerBar.value <= 0 and not exiting: # check for exit
		if Input.is_action_just_pressed("exit"):
			exiting = true

			for child in get_parent().get_children():
				if 'realupgrade' in child.name.to_lower():
					child.die()
			
			timerBar.value = 0.01
			
			Globals.round += 1
			
			restartround()

func restartround():
	roundLabel.modulate = Color("ffffff00")
	roundLabel.add_theme_font_size_override('font_size', 103)
	Globals.canshoot = false
	roundLabel.text = 'ROUND ' + str(Globals.round)
	roundLabel.visible = true
	maintarget.visible = false
	maintarget.position = Vector2(10000, 10000)

	var statslabeltween = create_tween() 
	statslabeltween.tween_property(statsLabel, 'modulate', Color(1.0, 1.0, 1.0, 0.0), 0.33)

	await statslabeltween.finished
	
	var roundlabelfadein = create_tween() 
	roundlabelfadein.tween_property(roundLabel, 'modulate', Color(1.0, 1.0, 1.0, 1.0), 0.33)
	
	await waitfornobullets()

	await get_tree().create_timer(1.0).timeout

	var restarttween = create_tween()
	restarttween.tween_property(timerBar, 'value', 100.0, roundcooldown)
	
	var roundlabeltween = create_tween() 
	roundlabeltween.tween_property(roundLabel, 'modulate', Color(1.0, 1.0, 1.0, 0.0), roundcooldown-0.2)
	
	await restarttween.finished
	
	Globals.canshoot = true
	
	maintarget.visible = true
	maintarget.spawn(Globals.targets)
	maintarget.shouldteleport = true
	
	Globals.score = 0
	lastScoreCheckedForMoney = 0.0
	moneyScoreRemainder = 0.0
	updateLabels()
	
	triggeredyet = false
	timerBar.value = 100

	statsLabel.visible = false
	statsLabel.modulate = Color.WHITE
	
	roundLabel.visible = false
	roundLabel.modulate = Color.WHITE
	
	exiting = false
	beatenquotatrigger = false


func waitfornobullets() -> void:
	while true:
		var bulletsfound = false
		for child in get_parent().get_children():
			if 'bullet' in child.name.to_lower():
				bulletsfound = true
				break
		
		if not bulletsfound:
			break
			
		await get_tree().process_frame


func _on_quit_pressed() -> void:
	LEAVINGGAME = true
	
	Globals.canshoot = false
	pausemenu.paused = false
	pausemenu.upd()
	
	
	get_tree().paused = true 
	
	await get_tree().create_timer(0.33)

	get_tree().paused = true 

	# reset things here in case globals fails
	Globals.quota = 3.0
	Globals.round = 1
	Globals.money = 0
	Globals.scorePerTarget = 0
	Globals.ownedUpgrades.clear()
	
	$roundLabel.visible = false
	
	var zoominend = create_tween() 
	zoominend.tween_property(cam, "zoom", Vector2(50.0, 50.0), 2.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	for c in get_children():
		var ctween = create_tween()
		ctween.tween_property(c, 'modulate', Color('ffffff00'), 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	var pathhidetween = create_tween()
	pathhidetween.tween_property(path, 'modulate', Color('ffffff00'), 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	await zoominend.finished
	
	var menuSCENE = load("res://scenes/menu.tscn")
	var menuINSTANCE = menuSCENE.instantiate()

	# cool bg no jump
	var bg = menuINSTANCE.get_node("bg")
	bg.initcol2 = Color.from_hsv(bginthisscene.hue, 0.87, 0.4, 0.5)

	# swap
	var tree = get_tree()
	var curscene = tree.current_scene
	tree.root.add_child(menuINSTANCE)
	tree.current_scene = menuINSTANCE
	curscene.queue_free()
