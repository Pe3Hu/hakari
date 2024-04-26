extends MarginContainer


#region var
@onready var stars = $HBox/Stars
@onready var appraisal = $HBox/Appraisal

var groove = null
var patterns = null
var hexs = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	groove = input_.groove
	patterns = input_.patterns
	hexs = input_.hexs
	
	init_basic_setting()


func init_basic_setting() -> void:
	init_tokens()
	init_stars()


func init_tokens() -> void:
	var input = {}
	input.proprietor = self
	input.type = "appraisal"
	input.subtype = "constellation"
	input.value = 0
	appraisal.set_attributes(input)


func init_stars() -> void:
	for _i in patterns.size():
		add_star(patterns[_i], hexs[_i])


func add_star(pattern_: MarginContainer, hex_: Polygon2D) -> void:
	var input = {}
	input.constellation = self
	input.hex = hex_
	input.pattern = pattern_

	var star = Global.scene.star.instantiate()
	stars.add_child(star)
	star.set_attributes(input)
#endregion
