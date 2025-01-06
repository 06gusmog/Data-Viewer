extends HBoxContainer

@onready var root = $"../.."
@onready var new = $"HBoxContainer/Control Panel/New"
@onready var remove = $"HBoxContainer/Control Panel/Remove"
@onready var selected_creatures = $"HBoxContainer/Selected Creatures"
var new_popup
var remove_popup

func _compare_DNA():
	if len(selected_creatures.text.split('\n')) < 2:
		print('Select more creatures!!')
		return
	print(root.match_DNA(root.get_creature(root.saved_creatures[selected_creatures.text.split('\n')[0]])[4], root.get_creature(root.saved_creatures[selected_creatures.text.split('\n')[1]])[4]))

func get_parents(creatureID):
	var parents = []
	while root.get_creature(creatureID)[0] != '-1':
		parents.append(creatureID)
		creatureID = root.get_creature(creatureID)[0]
	parents.append(creatureID)
	return parents

# NOTE Completely untested
func DNA_match_percent(ID1, ID2):
	var result = root.match_DNA(root.get_creature(ID1)[4], root.get_creature(ID2)[4])
	var sum = 0
	for item in result:
		sum += int(item)
	return float(sum) / float(len(result))

func _compare_ALL_DNA():
	var relatedness = []
	var DNA_match = []
	for creature_name in selected_creatures.text.split('\n'):
		var creature_name_ID = root.saved_creatures[creature_name]
		var name_parents = get_parents(creature_name_ID)
		name_parents.reverse()
		for other_creature in root.creature_register:
			if creature_name_ID == other_creature:
				continue
			var other_parents = get_parents(other_creature)
			other_parents.reverse()
			if other_parents[0] == name_parents[0]:
				for i in range(min(len(name_parents), len(other_parents))):
					if other_parents[i] == name_parents[i]:
						relatedness.append(len(name_parents) + len(other_parents) - 2*i)
						break
			else:
				relatedness.append('-1')
			DNA_match.append(DNA_match_percent(creature_name_ID, other_creature))
	return [relatedness, DNA_match]







func _ready() -> void:
	new_popup = new.get_popup()
	new_popup.index_pressed.connect(_new_creature)
	remove_popup = remove.get_popup()
	remove_popup.index_pressed.connect(_remove_creature)

func _new_creature(index):
	var creature = root.saved_creatures.keys()[index]
	if selected_creatures.text == '':
		selected_creatures.text = creature
	else:
		selected_creatures.text = selected_creatures.text + '\n' + creature
	_on_update_button_down()

func _remove_creature(index):
	var creatures = Array(selected_creatures.text.split('\n'))
	creatures.pop_at(index)
	if creatures != []:
		selected_creatures.text = creatures.pop_at(0)
	else:
		selected_creatures.text = ''
	for creature in creatures:
		selected_creatures.text = selected_creatures.text + '\n' + creature
	_on_update_button_down()

func _on_update_button_down():
	remove_popup.clear()
	for creature in selected_creatures.text.split('\n'):
		remove_popup.add_item(creature)
		
	new_popup.clear()
	for creature in root.saved_creatures:
		new_popup.add_item(creature)



func _on_all_dna_button_down():
	var savefile = FileAccess.open("res://Tool Output/DNA-match.txt", FileAccess.WRITE)
	savefile.store_line('relatedness	DNA-match percentage')
	var result = _compare_ALL_DNA()
	for i in range(len(result[0])):
		savefile.store_line(str(result[0][i]) + '	' + str(result[1][i]))
