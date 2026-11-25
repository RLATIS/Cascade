extends Node

# HOW TO USE:
# SET CALC TO TRUE
# SET FIND1, FIND2 AND FIND3 TO THE UPGRADES YOU WANT
# RUN AND CHECK WHAT PRINTS
# PLAY IT :)

@export var calc := false
@export var find1 := 'Jackpot'
@export var find2 := 'Cheapskate'
@export var find3 := 'Greed'

# 230106: 3 Jackpots
# 5059484: Jackpot, Greed, Free money

func _ready():
	if calc:
		var totalWeight := 0
		var starts := {}
		var weights := {}

		for up in Globals.upgradesinit:
			var weight = Globals.upgradesinit[up].weight

			if up.begins_with(find1) or up.begins_with(find2) or up.begins_with(find3):
				starts[up] = totalWeight
				weights[up] = weight

			totalWeight += weight

		var start1 := -1
		var start2 := -1
		var start3 := -1
		var weight1 := 0
		var weight2 := 0
		var weight3 := 0

		for up in starts:
			if up.begins_with(find1):
				start1 = starts[up]
				weight1 = weights[up]
			if up.begins_with(find2):
				start2 = starts[up]
				weight2 = weights[up]
			if up.begins_with(find3):
				start3 = starts[up]
				weight3 = weights[up]

		if start1 == -1 or start2 == -1 or start3 == -1:
			print('Could not find one or more upgrades')
			return

		var rngs = []
		for i in range(3):
			rngs.append(RandomNumberGenerator.new())

		for s in range(10000000):
			var count1 := 0
			var count2 := 0
			var count3 := 0

			for i in range(3):
				rngs[i].seed = s + 1000 + i * 10
				var value = rngs[i].randi_range(0, totalWeight)

				if value >= start1 and value < start1 + weight1:
					count1 += 1
				if value >= start2 and value < start2 + weight2:
					count2 += 1
				if value >= start3 and value < start3 + weight3:
					count3 += 1

			if count2 == 2 and count1 == 1:
				print('2 ', find2, ' + 1 ', find1, ' : ', s)

			if count1 == 3:
				print('3 ', find1, ' : ', s)

			if count1 == 1 and count2 == 1 and count3 == 1:
				print('1 ', find1, ' + 1 ', find2, ' + 1 ', find3, ' : ', s)

		print('DONE')
