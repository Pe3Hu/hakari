extends MarginContainer


#region vars
@onready var grimoire = $HBox/Grimoire
@onready var groove = $HBox/Groove
@onready var book = $HBox/Book

var pantheon = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	pantheon = input_.pantheon
	
	init_basic_setting()


func init_basic_setting() -> void:
	var input = {}
	input.god = self
	grimoire.set_attributes(input)
	groove.set_attributes(input)
	book.set_attributes(input)
#endregion
