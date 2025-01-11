extends HBoxContainer

@onready var root = $"../.."
@onready var new = $"HBoxContainer/Control Panel/New"
@onready var remove = $"HBoxContainer/Control Panel/Remove"
@onready var selected_creatures = $"HBoxContainer/Selected Creatures"
@onready var lineage_viewer = $"../Lineage Viewer"

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
"""
func DNA_match_percent(ID1, ID2):
	if ID1 == '-1' or ID2 == '-1':
		return 0.0
	var result = root.better_match_DNA(root.get_creature(ID1)[4], root.get_creature(ID2)[4])
	var sum = 0
	for item in result:
		sum += int(item)
	return float(sum) / float(len(result))
"""
func DNA_match_percent(ID1, ID2):
	if ID1 == '-1' or ID2 == '-1':
		return 0.0
	#print(ID2)
	return root.better_match_DNA(root.get_creature(ID1)[4], root.get_creature(ID2)[4])
	

func _compare_ALL_DNA():
	var creature_count = len(root.creature_register) * len(selected_creatures.text.split('\n'))
	var relatedness = []
	var DNA_match = []
	var i_ = 0
	for creature_name in selected_creatures.text.split('\n'):
		var creature_name_ID = root.saved_creatures[creature_name]
		var name_parents = get_parents(creature_name_ID)
		name_parents.reverse()
		for other_creature in root.creature_register:
			if i_ % 100 == 0:
				print(str(i_) + '/' + str(creature_count))
			if creature_name_ID == other_creature:
				continue
			var other_parents = get_parents(other_creature)
			other_parents.reverse()
			if other_parents[0] == name_parents[0]:
				var to_add = max(len(name_parents), len(other_parents)) - min(len(name_parents), len(other_parents))
				for i in range(min(len(name_parents), len(other_parents))):
					if other_parents[i] != name_parents[i]:
						to_add = len(name_parents) + len(other_parents) - 2*i
						break
				relatedness.append(to_add)
			else:
				relatedness.append('-1')
			DNA_match.append(DNA_match_percent(creature_name_ID, other_creature))
			i_ += 1
	return [relatedness, DNA_match]

func draw_evo_history(creatureID):
	var result = Image.create(0,0,false, Image.FORMAT_RGBA8)
	var previous_DNA = []
	var paddingy = 1
	while root.get_creature(creatureID)[0] != '-1':
		var creature = root.get_creature(creatureID)
		creatureID = creature[0]
		var current_DNA = get_cell_type_DNA(creature[4])
		if current_DNA == previous_DNA:
			continue
		previous_DNA = current_DNA
		var selfie = lineage_viewer.generate_icon(creature[4], GlobalSettings.color_sheet)
		var groupie = Image.create(max(selfie.get_width(), result.get_width()), result.get_height() + paddingy + selfie.get_height(), false, Image.FORMAT_RGBA8)
		groupie.fill(Color.BLACK)
		var selfie_rect = Rect2(Vector2(0,0), Vector2(selfie.get_width(), selfie.get_height()))
		var result_rect = Rect2(Vector2(0,0), Vector2(result.get_width(), result.get_height()))
		groupie.blit_rect(selfie, selfie_rect, Vector2(0, 0))
		groupie.blit_rect(result, result_rect, Vector2(0, selfie.get_height() + paddingy))
		result = groupie
	return result

func get_cell_type_DNA(DNA):
	var new_DNA = []
	for item in DNA:
		new_DNA.append(item['Type'])
	return new_DNA



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


func _on_evo_history_button_down():
	draw_evo_history(root.saved_creatures[selected_creatures.text.split('\n')[0]]).save_png('res://Tool Output/evo_history.png')
