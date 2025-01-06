extends HBoxContainer
@onready var update = $"HBoxContainer/Control Panel/Update"
@onready var child_selector = $"HBoxContainer/Control Panel/Child Selector"
@onready var root = $"../.."
@onready var texture_rect = $"HBoxContainer/Lineage Preview/Godot Wizardry/TextureRect"
@onready var save_name = $"HBoxContainer/Control Panel/Save Name"

var local_root = '-1'
var popup

func _ready() -> void:
	popup = child_selector.get_popup()
	popup.index_pressed.connect(_on_select_current_child_button_down)

func _on_update_button_down():
	if root.loaded_lineage == {}:
		print('No lineage selected!!!!')
		return
	local_root = root.loaded_root
	var image = get_image(local_root)
	texture_rect.texture = ImageTexture.create_from_image(image)
	popup.clear()
	for x in range(len(root.loaded_lineage[local_root][1])):
		popup.add_item(str(x+1))

func _on_select_current_child_button_down(i):
	var iID = root.loaded_lineage[local_root][1][i]
	local_root = iID
	var image = get_image(local_root)
	texture_rect.texture = ImageTexture.create_from_image(image)
	popup.clear()
	for x in range(len(root.loaded_lineage[local_root][1])):
		popup.add_item(str(x+1))

func _on_back_button_down():
	if local_root == root.loaded_root:
		print('Already at the top!')
		return
	local_root = root.loaded_lineage[local_root][0]
	var image = get_image(local_root)
	texture_rect.texture = ImageTexture.create_from_image(image)
	popup.clear()
	for x in range(len(root.loaded_lineage[local_root][1])):
		popup.add_item(str(x+1))

func _on_save_creature_button_down():
	if save_name.text == '':
		print('Write a name first!!!')
		return
	if save_name.text in root.saved_creatures.keys():
		print('Creature already saved under this name! Please select a new name!')
		return
	root.saved_creatures[save_name.text] = local_root

func _on_overwrite_creature_button_down():
	if save_name.text == '':
		print('Write a name first!!!')
		return
	if not save_name.text in root.saved_creatures.keys():
		print('Creature is not saved under this name! Please select a new name or click save!')
		return
	root.saved_creatures[save_name.text] = local_root


func get_image(creatureID: String):
	var paddingx = 1
	var paddingy = 1
	var edge_thickness = 1
	var edge_color = Color.WHITE
	var childrenIDs = root.loaded_lineage[creatureID][1]
	if len(childrenIDs) > 0:
		# Get all child icons recursively
		var images = []
		var sizex = 0
		var sizey = 0
		for childID in childrenIDs:
			images.append(get_image(str(childID)))
			if images[-1].get_height() > sizey:
				sizey = images[-1].get_height()
			sizex += images[-1].get_width()
		
		if len(images) == 1:
			var selfie = generate_icon(root.loaded_lineage[creatureID][4], GlobalSettings.color_sheet)
			var groupie = Image.create(sizex, sizey + paddingy + selfie.get_height(), false, Image.FORMAT_RGBA8)
			groupie.fill(Color.BLACK)
			var selfie_rect = Rect2(Vector2(0,0), Vector2(selfie.get_width(), selfie.get_height()))
			groupie.blit_rect(selfie, selfie_rect, Vector2(int((groupie.get_width()-selfie.get_width())/2), 0))
			var y_pos = selfie.get_height() + paddingy
			var image = images[0]
			var image_rect = Rect2(Vector2(0,0), Vector2(image.get_width(), image.get_height()))
			groupie.blit_rect(image, image_rect, Vector2(0, y_pos))
			return groupie
		
		# Create image and selfie
		var selfie = generate_icon(root.loaded_lineage[creatureID][4], GlobalSettings.color_sheet)
		var groupie = Image.create(sizex + (len(images) + 1) * paddingx + edge_thickness * 2, sizey + paddingy + selfie.get_height(), false, Image.FORMAT_RGBA8)
		groupie.fill(Color.BLACK)
		
		# Set edge pixels white
		var groupie_width = groupie.get_width()
		for x in range(edge_thickness):
			for y in range(groupie.get_height()):
				groupie.set_pixel(x, y, edge_color)
				groupie.set_pixel(groupie_width - x - 1, y, edge_color)
		
		# Add everything together
		var selfie_rect = Rect2(Vector2(0,0), Vector2(selfie.get_width(), selfie.get_height()))
		groupie.blit_rect(selfie, selfie_rect, Vector2(int((groupie.get_width()-selfie.get_width() + 1)/2), 0))
		var y_pos = selfie.get_height() + paddingy
		var width_sum = edge_thickness + paddingx
		for image in images:
			var image_rect = Rect2(Vector2(0,0), Vector2(image.get_width(), image.get_height()))
			groupie.blit_rect(image, image_rect, Vector2(width_sum, y_pos))
			width_sum += image.get_width() + paddingx
		return groupie
	
	return generate_icon(root.loaded_lineage[creatureID][4], GlobalSettings.color_sheet)
	
func generate_icon(DNA, color_sheet):
	var lowest_positions = Vector2(0,0)
	var icon_size = Vector2(0,0)
	for RNA in DNA:
		var pos = RNA['Position']
		if pos.x < lowest_positions.x:
			lowest_positions.x = pos.x
		if pos.y < lowest_positions.y:
			lowest_positions.y = pos.y
		if pos.x > icon_size.x:
			icon_size.x = pos.x
		if pos.y > icon_size.y:
			icon_size.y = pos.y
	icon_size -= lowest_positions # Because lowest_positions is negative
	var icon = Image.create(icon_size.x+1, icon_size.y+1, false, Image.FORMAT_RGBA8)
	icon.fill(Color.BLACK)
	for RNA in DNA:
		icon.set_pixel(RNA['Position'].x - lowest_positions.x, RNA['Position'].y - lowest_positions.y, color_sheet[RNA['Type']])
	
	return icon
