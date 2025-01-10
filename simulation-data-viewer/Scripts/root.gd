extends Control

var DATA_FOLDER = "res://Data Folder/"
var creature_register = {}
var lineages = {}
var loaded_lineage = {}
var loaded_root = '-1'

var saved_creatures = {}

func get_creature(creatureID):
	return creature_register[creatureID]

func load_creature_register(folder_name, tolerance: int):
	creature_register = {}
	var i = 0
	for file in DirAccess.get_files_at(DATA_FOLDER + folder_name):
		if i % 50 == 0:
			print(i)
		if file == 'Header.txt':
			continue
		
		var config = ConfigFile.new()
		config.load(DATA_FOLDER + folder_name + file)
		for creatureID in config.get_sections():
			var creature = []
			creature.append(config.get_value(creatureID, "parent"))
			creature.append(config.get_value(creatureID, "children"))
			creature.append(config.get_value(creatureID, "time of birth"))
			creature.append(config.get_value(creatureID, "time of death"))
			creature.append(config.get_value(creatureID, "DNA"))
			creature_register[creatureID] = creature
		i += 1
	
	# DANGER REMOVE THIS!! IT FUCKS EVERYTHING UP!!!
	for creatureID in creature_register:
		if creatureID == '-1':
			continue
		if get_creature(creatureID)[0] == "-1":
			creature_register['-1'][1].append(creatureID)
	# DANGER REMOVE CODE ABOVE !!!!!!!!!
	
	for root_creature in creature_register['-1'][1]:
		var lineage = get_relative_lineage(root_creature)
		var lineage_len = len(lineage)
		if lineage_len > tolerance:
			print(root_creature)
			lineages[root_creature + '-' + str(lineage_len)] = lineage
	print('Done!')

func match_DNA(creature1, creature2):
	var result = []
	for i in range(min(len(creature1), len(creature2))):
		result.append(creature1[i]['Type'] == creature2[i]['Type'])
		for x in range(5):
			result.append(creature1[i]['Special Sauce'][x] == creature2[i]['Special Sauce'][x])
		result.append(creature1[i]['Position'] == creature2[i]['Position'])
		if len(creature1[i]['Connections']) <= len(creature1[i]['Connections']):
			for con in creature1[i]['Connections']:
				result.append(con in creature2[i]['Connections'])
		else:
			for con in creature2[i]['Connections']:
				result.append(con in creature1[i]['Connections'])
		for x in range(abs(len(creature1[i]['Connections'])-len(creature1[i]['Connections']))):
			result.append(false)
	for x in range(max(len(creature1), len(creature2))-min(len(creature1), len(creature2))):
		for i in range(10):
			result.append(false)
	return result

func match_RNA(r1, r2):
	var result = []
	if r1 is String or r2 is String:
		for i in range(10):
			result.append(false)
		return result
	result.append(r1['Type'] == r2['Type'])
	for x in range(5):
		result.append(r1['Special Sauce'][x] == r2['Special Sauce'][x])
	result.append(r1['Position'] == r2['Position'])
	if len(r1['Connections']) <= len(r2['Connections']):
		for con in r1['Connections']:
			result.append(con in r2['Connections'])
	else:
		for con in r2['Connections']:
			result.append(con in r1['Connections'])
	for x in range(abs(len(r1['Connections'])-len(r2['Connections']))):
		result.append(false)
	return result

func basic_match_DNA(c1, c2):
	var result = []
	for i in range(min(len(c1), len(c2))):
		result.append_array(match_RNA(c1[i], c2[i]))
	for x in range(max(len(c1), len(c2))-min(len(c1), len(c2))):
		for i in range(10):
			result.append(false)
	var sum = 0
	for item in result:
		sum += int(item)
	return float(sum) / float(len(result))

func better_match_DNA(c1, c2):
	var short
	var long
	if min(len(c1), len(c2)) == len(c1):
		short = str_to_var(var_to_str(c1))
		long = str_to_var(var_to_str(c2))
	else:
		short = str_to_var(var_to_str(c2))
		long = str_to_var(var_to_str(c1))
	var best_score = 0.0
	var best_test = short
	for x in range(2):
		best_test = short
		for i in range(len(short) +1):
			var test_DNA = str_to_var(var_to_str(short))
			test_DNA.insert(i, 'Blank')
			var score = basic_match_DNA(test_DNA, long)
			if score > best_score:
				best_test = test_DNA
				best_score = score
		short = best_test
		best_test = long
		for i in range(len(long) +1):
			var test_DNA = str_to_var(var_to_str(long))
			test_DNA.insert(i, 'Blank')
			var score = basic_match_DNA(test_DNA, short)
			if score > best_score:
				best_test = test_DNA
				best_score = score
		long = best_test
	return basic_match_DNA(short, long)

func get_relative_lineage(creatureID):
	# Get first creature in the chain
	var parentID = get_creature(creatureID)[0]
	while parentID != '-1':
		creatureID = parentID
		parentID = get_creature(creatureID)[0]
	
	# Get all the creatureIDs and put them into a list
	var i = 0
	var list_of_creatureIDs = [creatureID]
	while i < len(list_of_creatureIDs):
		list_of_creatureIDs.append_array(get_creature(str(list_of_creatureIDs[i]))[1])
		i += 1
	
	# Convert that list into the dictionary we want
	var relative_lineage = {'-1':['-1', [], 0.0, -1.0, '', {}]}
	for ID in list_of_creatureIDs:
		relative_lineage[ID] = get_creature(str(ID))
	
	return relative_lineage
