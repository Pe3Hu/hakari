extends MarginContainer


#region var
@onready var index = $HBox/Index
@onready var pattern = $HBox/Pattern
@onready var appraisal = $HBox/Appraisal

var constellation = null
var donor = {}
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	constellation = input_.constellation
	donor.hex = input_.hex
	donor.pattern = input_.pattern
	
	init_basic_setting()


func init_basic_setting() -> void:
	init_tokens()


func init_tokens() -> void:
	var input = {}
	input.proprietor = self
	input.type = "appraisal"
	input.subtype = "star"
	input.value = 0
	appraisal.set_attributes(input)
	
	input.type = "index"
	input.subtype = "hex"
	input.value = donor.hex.index.get_value()
	index.set_attributes(input)
#endregion
