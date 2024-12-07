extends HBoxContainer
@onready var root = $"../.."




func _on_test_input_button_down():
	print(root.match_DNA(root.get_creature('9753')[4], root.get_creature('9040')[4]))
