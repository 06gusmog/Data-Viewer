extends HBoxContainer
@onready var creature_analyzer = $"../Creature Analyzer"




func _on_test_input_button_down():
	print(creature_analyzer.get_parents('12634'))
