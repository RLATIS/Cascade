extends Node2D

# CHANGEABLE VARIABLES 

var initclones := 7
var initcooldownspeed = 0.7
var initroundlength := 10.0
var taxincrement := 0.1
var quota := 3.0
var quotamultiply := 1.5

# Name: {cost, rarity}
# Lower weight makes it rarer
var upgradesinit := {
	# TIME BASED THINGS
	'Shorter shooting cooldown (-10%)': { 'cost': 2, 'weight': 35 },
	
	'Longer round length (+0.66s)': { 'cost': 3, 'weight': 25 },
	'Rush (-0.66s round)': { 'cost': -5, 'weight': 6 },
	
	'Overtime (+2.0s round, +15% cooldown)': { 'cost': 5, 'weight': 12 },
	
	'Trigger Finger (-25% cooldown, -2 Targets)': { 'cost': 5, 'weight': 8 }, 
	'Heavy (x3 Score, +25% cooldown)': { 'cost': 5, 'weight': 6 },

	# TARGETS
	'+1 Target': { 'cost': 3, 'weight': 43 },
	'+2 Targets': { 'cost': 5, 'weight': 15 },
	'-1 Target': { 'cost': -4, 'weight': 9 },
	'Traffic (+3 Targets, +15% shooting cooldown)': { 'cost': 4, 'weight': 5 }, 
	
	# MULTIPLIERS
	'x2 Score Per Target': { 'cost': 5, 'weight': 6.5},
	'x5 Score Per Target': { 'cost': 6, 'weight': 4},
	
	'+10 Score Per Target': { 'cost': 5, 'weight': 3},
	
	'Coin Flip (x4 or ÷2 Score Per Target)': { 'cost': 4, 'weight': 7 },
	'Greed (+1x SPT for each $10 held)': { 'cost': 5, 'weight': 4 },
	
	# BUILD PAYOFFS
	'Overheat (x6 Score if cooldown <= 0.35s)': { 'cost': 4, 'weight': 5 },
	'Lonely (x10 Score if Targets <= 4)': { 'cost': 5, 'weight': 5 },
	'Swarm (+1x SPT for each target)': { 'cost': 4, 'weight': 5 },

	# FREE MONEY
	'Free Money! (+$10)': { 'cost': 0, 'weight': 3 },
	'Jackpot! (+$50)': { 'cost': 0, 'weight': 1 }
}

# END CHANGEABLE VARIABLES

var roundlength := 10.0
var targets := 15
var score := 0.0
var money := 0
var canshoot := false
var cooldownspeed := 0.5
var ownedUpgrades := []
var statsLabel : Label
var tax := 1.0 # in percent
var upgrades := {}
var scorePerTarget := 1.0
var psicons := []
var round := 1
var baseSPT := 1.0
var ui : CanvasLayer
var seed := 1
var rng = RandomNumberGenerator.new()

var onController := false:
	set(value):
		if onController != value:
			onController = value
			ps4Icons()

func ps4Icons() -> void:
	print('switching controller mode')
	for i in psicons:
		i.visible = onController
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if onController: Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func updateStats():
	targets = initclones
	cooldownspeed = initcooldownspeed
	roundlength = initroundlength
	scorePerTarget = snappedf(baseSPT, 0.01)
	
	for up in ownedUpgrades.duplicate():
		if up.begins_with("Coin Flip"):
			var mult := 4.0 if rng.randf() < 0.5 else 0.5
			mult = 0.5
			
			if mult < 1: # under 1
				playsound('res://sounds/bad.wav', rng.randf_range(0.9, 1.1), rng.randf_range(3.0, 5.0))
			
			baseSPT = max(baseSPT * mult, 0.05) 
			ownedUpgrades.erase(up)

	scorePerTarget = snappedf(baseSPT, 0.01)

	for up in ownedUpgrades:
		if up == '+1 Target':
			targets += 1
		elif up == '-1 Target':
			targets -= 1
		elif up == '+2 Targets':
			targets += 2
		
		elif up == '+10 Score Per Target':
			scorePerTarget += 10
		
		elif up.begins_with('Greed'):
			scorePerTarget += 1 * floor(money / 10)
		
		elif up.begins_with('Traffic'):
			targets += 3
			cooldownspeed *= 1.15
			
		elif up == 'Shorter shooting cooldown (-10%)':
			cooldownspeed *= 0.9
			
		elif up == 'Longer round length (+0.66s)':
			roundlength += 0.66
		elif up == 'Rush (-0.66s round)':
			roundlength -= 0.66
			
		elif up.begins_with('Overtime'):
			roundlength += 2
			cooldownspeed *= 1.15
			
		elif up.begins_with('Trigger Finger'):
			cooldownspeed *= 0.8
			targets -= 2
			
		elif up.begins_with('Free Money! (+$') or up.begins_with('Jackpot! (+$'):
			money += up.to_int()
			
			playsound('res://sounds/coin.wav', rng.randf_range(0.95, 1.1), rng.randf_range(-0.5, 0.5))
			ownedUpgrades.erase(up)
		
	if targets < 0:
		targets = 0
	
	if roundlength < 0.5:
		roundlength = 0.5
	
	# ONES DEPENDANT ON OTHER ONES
	for up in ownedUpgrades: 
		if up.begins_with('Swarm'):
			scorePerTarget += (1.0 * (targets + 1))
	
	# OTHER ONES (Multiply)
	for up in ownedUpgrades:
		if up == 'Overheat (x6 Score if cooldown <= 0.35s)':
			if cooldownspeed <= 0.35:
				scorePerTarget *= 6
				
		elif up.begins_with('Lonely'):
			if targets <= 4:
				scorePerTarget *= 10
		
		elif up == 'Heavy (x3 Score, +25% cooldown)':
			scorePerTarget *= 3
			cooldownspeed *= 1.25
		
		elif up == 'x2 Score Per Target':
			scorePerTarget *= 2
		elif up == 'x5 Score Per Target':
			scorePerTarget *= 5
		
				
	cooldownspeed = snappedf(cooldownspeed, 0.01)
	money = snappedf(money, 0.01)
	
	statsLabel.text = "Round length: {roundlength} secs\nTargets: {targets}\nShooting Cooldown: {cooldownspeed} secs\nScore Per Target: {spt}\nShop Tax: {t}%\nPress 'E' to exit shop.".format({
		"roundlength": formatcommas(roundlength),
		"targets": formatcommas(targets+1),
		"cooldownspeed": cooldownspeed,
		'spt': formatcommas(scorePerTarget),
		't': snappedf((tax*100)-100, 0.01) 
	})

func calcTax():
	tax += taxincrement
	upgrades = {}

	for upgradename in upgradesinit.keys():
		var basedata = upgradesinit[upgradename]
		upgrades[upgradename] = {
			'cost': snappedf(basedata['cost'] * tax, 0.1),
			'weight': basedata['weight']
		}

	updateStats()
	ui.updateLabels(true)

func formatcommas(number: float, decimals: int = 2) -> String:
	var snapped: float = snappedf(number, pow(10, -decimals))
	var formatted: String = ("%.*f" % [decimals, snapped])
	
	if decimals > 0:
		formatted = formatted.rstrip("0").rstrip(".")
		
	var parts: PackedStringArray = formatted.split(".")
	var whole_str: String = parts[0]
	var result: String = ""
	var count: int = 0
	
	for i in range(whole_str.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0 and whole_str[i] != "-":
			result = "," + result
		result = whole_str[i] + result
		count += 1
	
	if parts.size() > 1:
		return result + "." + parts[1]
		
	return result
func playsound(path: String, pitch: float = 1.0, volume: float = 0.0):
	var parent = get_parent()
	if not parent:
		print('NO PARENT FOR SOUND !!')
		return

	var player = AudioStreamPlayer.new()
	var stream = load(path)
	
	if not stream:
		print('Could not load sound at ', path)
		return
		
	player.stream = stream
	player.pitch_scale = pitch
	player.volume_db = volume
	
	parent.add_child(player) # add child
	player.play()

	await player.finished
	player.queue_free() # delete

func newgame() -> void:
	rng.seed = seed

	upgrades = upgradesinit

	await get_tree().process_frame # so can find child
	
	psicons = get_tree().root.find_children("*ps4icon*", "", true, false)
	print(psicons)
			
	statsLabel = get_tree().current_scene.find_child("statsLabel", true, false)

	ui = get_tree().current_scene.find_child("ui", true, false)

	if statsLabel == null:
		statsLabel = ui.statsLabel # good because it is referenced inside ui

	statsLabel.visible = false
	updateStats()
