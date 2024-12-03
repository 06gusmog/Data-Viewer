extends HBoxContainer

var DATA_FOLDER = "res://Data Folder/"

@onready var root: Control = $"../.."
@onready var refresh: Button = $VBoxContainer/Refresh
@onready var files: MenuButton = $VBoxContainer/Files
@onready var selected_folder: Label = $"VBoxContainer/Selected Folder"
@onready var load: Button = $VBoxContainer/Load
@onready var tolerance: LineEdit = $VBoxContainer/Tolerance
@onready var lineage_viewer: HBoxContainer = $"../Lineage Viewer"

var popup

func _ready() -> void:
	popup = files.get_popup()
	popup.index_pressed.connect(_on_folder_selected)

func _on_refresh_button_down() -> void:
	popup.clear()
	for folder in DirAccess.get_directories_at(DATA_FOLDER):
		popup.add_item(folder)

func _on_folder_selected(index):
	var folder = popup.get_item_text(index)
	selected_folder.text = folder

func _on_load_button_down() -> void:
	if selected_folder.text != '' and tolerance.text != '':
		root.load_creature_register(selected_folder.text + '/', int(tolerance.text))
		lineage_viewer.popup.clear()
		for root_creature in root.lineages:
			lineage_viewer.popup.add_item(root_creature)
