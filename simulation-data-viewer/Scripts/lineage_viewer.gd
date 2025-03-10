extends HBoxContainer

@onready var menu_button: MenuButton = $"Button Panel/MenuButton"
@onready var lineage_selected: Label = $"Button Panel/Lineage Selected"
@onready var root: Control = $"../.."
@onready var texture_rect = $"Main Window/Godot Wizardry/TextureRect"
@onready var depth: LineEdit = $"Button Panel/Depth"

var SAVE_LOCATION = "res://Saved Lineages/"

var popup

func _ready() -> void:
	popup = menu_button.get_popup()
	popup.index_pressed.connect(_on_lineage_selected)

func _on_lineage_selected(index):
	var lineage_root_creature = popup.get_item_text(index)
	lineage_selected.text = lineage_root_creature

func _on_draw_full():
	if lineage_selected.text != '':
		var image = get_image(lineage_selected.text.split('-')[0])
		texture_rect.texture = ImageTexture.create_from_image(image)

func _on_draw_depth() -> void:
	if lineage_selected.text != '' and depth.text != '':
		print('drawing')
		root.loaded_lineage = {}
		var image = get_image_depth(lineage_selected.text.split('-')[0], int(depth.text))
		texture_rect.texture = ImageTexture.create_from_image(image[0])
		root.loaded_root = lineage_selected.text.split('-')[0]

func _on_download_button_down() -> void:
	var number = str(len(DirAccess.get_files_at(SAVE_LOCATION)))
	var image = texture_rect.texture.get_image()
	image.save_png(SAVE_LOCATION + 'saved_lineage' + number + '.png')

func get_image_depth(creatureID, depth: int):
	var paddingx = 1
	var paddingy = 1
	var edge_thickness = 1
	var edge_color = Color.WHITE
	var childrenIDs = root.get_creature(creatureID)[1]
	root.loaded_lineage[creatureID] = root.get_creature(creatureID)
	var local_depth = 0
	var included_childrenIDs = []
	if len(childrenIDs) > 0:
		# Get all child icons recursively
		var images = []
		var sizex = 0
		var sizey = 0
		for childID in childrenIDs:
			var result = get_image_depth(str(childID), depth)
			var selfie = result[0]
			var generations = result[1]
			if generations > local_depth:
				local_depth = generations
			if generations < depth:
				continue
			included_childrenIDs.append(str(childID))
			images.append(selfie)
			if images[-1].get_height() > sizey:
				sizey = images[-1].get_height()
			sizex += images[-1].get_width()
		
		if local_depth +1 >= depth:
			var new_creature = root.get_creature(creatureID)
			new_creature[1] = included_childrenIDs
			if local_depth == depth:
				new_creature[1] = []
			
			
		
		if len(images) == 1:
			var selfie = generate_icon(root.get_creature(creatureID)[4], GlobalSettings.color_sheet)
			var groupie = Image.create(sizex, sizey + paddingy + selfie.get_height(), false, Image.FORMAT_RGBA8)
			groupie.fill(Color.BLACK)
			var selfie_rect = Rect2(Vector2(0,0), Vector2(selfie.get_width(), selfie.get_height()))
			groupie.blit_rect(selfie, selfie_rect, Vector2(int((groupie.get_width()-selfie.get_width())/2), 0))
			var y_pos = selfie.get_height() + paddingy
			var image = images[0]
			var image_rect = Rect2(Vector2(0,0), Vector2(image.get_width(), image.get_height()))
			groupie.blit_rect(image, image_rect, Vector2(0, y_pos))
			return [groupie, local_depth +1]
		
		# Create image and selfie
		var selfie = generate_icon(root.get_creature(creatureID)[4], GlobalSettings.color_sheet)
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
		return [groupie, local_depth +1]
	
	return [generate_icon(root.get_creature(creatureID)[4], GlobalSettings.color_sheet), 0]

func get_image(creatureID: String):
	var paddingx = 1
	var paddingy = 1
	var edge_thickness = 1
	var edge_color = Color.WHITE
	var childrenIDs = root.get_creature(creatureID)[1]
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
		
		# Create image and selfie
		var selfie = generate_icon(root.get_creature(creatureID)[4], GlobalSettings.color_sheet)
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
	
	return generate_icon(root.get_creature(creatureID)[4], GlobalSettings.color_sheet)

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
