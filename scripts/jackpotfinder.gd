extends Node

# HOW TO USE:
# SET CALC TO TRUE
# SET FIND1 TO WHAT YOU WANT TO FIND
# SET FIND2 TO THE OTHER THING YOU WANT TO FIND
# RUN AND CHECK WHAT PRINTS

@export var calc := false
@export var find1 := 'Jackpot'
@export var find2 := 'Greed'

func _ready():
	if calc:
		var found2 := false
		var found3 := false
		var found2greed := false

		var totalWeight := 0
		var jackpotStart := 0
		var greedStart := 0
		var greedWeight := 0

		for up in Globals.upgradesinit:
			var weight = Globals.upgradesinit[up].weight
			if up.begins_with(find1):
				jackpotStart = totalWeight
			if up.begins_with(find2):
				greedStart = totalWeight
				greedWeight = weight
			totalWeight += weight

		var rngs = []
		for i in range(3):
			rngs.append(RandomNumberGenerator.new())

		for s in range(10000000):
			var jackpots := 0
			var hasGreed := false

			for i in range(3):
				rngs[i].seed = s + 1000 + i * 10
				var value = rngs[i].randi_range(0, totalWeight)

				if value >= greedStart and value < greedStart + greedWeight:
					hasGreed = true

				if value >= jackpotStart and value < jackpotStart + 1:
					jackpots += 1

			if jackpots == 2:
				print('2 ', find1, ' : ', s)

			if jackpots == 2 and hasGreed:
				found2greed = true
				print('2 ', find1, ' + ', find2, ' : ',  s)

			if jackpots == 3:
				found3 = true
				print('3 ' + find1, '!!!!!!!!!!!!!!!!!!!!!!!!!: ', s)

			if found2greed and found3:
				break

		print('DONE')
