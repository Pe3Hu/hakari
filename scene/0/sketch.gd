extends MarginContainer


@onready var cradle = $HBox/Cradle
@onready var universe = $HBox/Universe


func _ready() -> void:
	var input = {}
	input.sketch = self
	cradle.set_attributes(input)
	universe.set_attributes(input)
