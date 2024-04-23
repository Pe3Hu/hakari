extends MarginContainer


#region vars
@onready var index = $HBox/Index
@onready var blueprints = $HBox/Blueprints

var book = null
var hex = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	book = input_.book
	hex = input_.hex
	
	init_basic_setting()


func init_basic_setting() -> void:
	hex.index.visible = true
	init_tokens()
	init_blueprints()


func init_tokens() -> void:
	var input = {}
	input.proprietor = self
	input.type = "index"
	input.subtype = "page"
	input.value = hex.index.get_value()
	index.set_attributes(input)


func init_blueprints() -> void:
	for title in Global.arr.offense:
		for shift in Global.num.thickness[title]:
			add_blueprint(title, shift)


func add_blueprint(title_: String, shift_: int) -> void:
	var input = {}
	input.page = self
	input.title = title_
	input.shift = shift_

	var blueprint = Global.scene.blueprint.instantiate()
	blueprints.add_child(blueprint)
	blueprint.set_attributes(input)
