extends Control

var DATA_FOLDER = "res://Data Folder/"
var creature_register = {}
var lineages = {}
var loaded_lineage = {}

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
	"""
	# DANGER REMOVE THIS!! IT FUCKS EVERYTHING UP!!!
	for creatureID in creature_register:
		if creatureID == '-1':
			continue
		if get_creature(creatureID)[0] == "-1":
			creature_register['-1'][1].append(creatureID)
	# DANGER REMOVE CODE ABOVE !!!!!!!!!
	"""
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
	return result

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
