extends TextureRect

@onready var main_window: ScrollContainer = $".."


func _process(delta: float) -> void:
	custom_minimum_size = main_window.size
