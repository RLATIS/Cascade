extends Node2D

# HOW TO USE:
# SET CALC TO TRUE
# SET FIND1 TO WHAT YOU WANT TO FIND
# SET FIND2 TO THE OTHER THING YOU WANT TO FIND
# RUN AND CHECK WHAT PRINTS

@export var calc := false
@export var find1 := 'Jackpot'
@export var find2 := 'Greed'

var hasCheapskate := false

func _ready():
	if calc:
		var found2and1 := false
		var found3 := false
		var found3again := false

		var allgrades: Dictionary = Globals.upgradesinit.duplicate()
		if hasCheapskate:
			allgrades.erase('Cheapskate (Freeze shop tax)')

		var totalWeight := 0
		for upgradeName in allgrades.keys():
			totalWeight += allgrades[upgradeName].weight

		var rng = RandomNumberGenerator.new()

		for s in range(10000000):
			var count1 := 0
			var count2 := 0

			for i in range(3):
				rng.seed = s + 1000 + i * 10
				var randomvalue := rng.randi_range(0, totalWeight - 1)
				var currentWeight := 0

				for upgradeName in allgrades.keys():
					currentWeight += allgrades[upgradeName].weight
					if randomvalue < currentWeight:
						if upgradeName.begins_with(find1):
							count1 += 1
						elif upgradeName.begins_with(find2):
							count2 += 1
						break

			if count1 == 2 and count2 == 1:
				found2and1 = true
				print('2 ', find1, ' + 1 ', find2, ' : ', s)

			if count1 == 1 and count2 == 2:
				found2and1 = true
				print('2 ', find2, ' + 1 ', find1, ' : ', s)

			if count1 == 3:
				found3 = true
				print('3 ', find1, ' : ', s)

			if count2 == 3:
				found3again = true
				print('3 ', find2, ' : ', s)

			if found2and1 and found3 and found3again:
				break

		print('DONE')
