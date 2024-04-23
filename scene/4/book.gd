extends MarginContainer


#region vars
@onready var pages = $Pages

var god = null
var grimoire = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	god = input_.god
	
	init_basic_setting()


func init_basic_setting() -> void:
	grimoire = god.grimoire
	init_pages()


func init_pages() -> void:
	for hex in grimoire.types["source"]:
		add_page(hex)


func add_page(hex_: Polygon2D) -> void:
	var input = {}
	input.book = self
	input.hex = hex_

	var page = Global.scene.page.instantiate()
	pages.add_child(page)
	page.set_attributes(input)
#endregion
