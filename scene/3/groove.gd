extends MarginContainer


#region var
@onready var indexs = $HBox/Indexs
@onready var pattern = $HBox/Pattern

var god = null
var grimoire = null
var hexs = {}
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	god = input_.god
	
	init_basic_setting()


func init_basic_setting() -> void:
	hexs.current = []
	hexs.next = []
	grimoire = god.grimoire
	var hex = grimoire.grids[Vector3()]
	add_hex(hex)
	
	var input = {}
	input.groove = self
	input.letter = "l"
	pattern.set_attributes(input)
	try_on_pattern()


func add_hex(hex_: Polygon2D) -> void:
	if !hexs.current.has(hex_):
		for neighbor in hex_.neighbors:
			add_index(neighbor)
		
		remove_index(hex_)
		hexs.current.append(hex_)


func add_index(hex_: Polygon2D) -> void:
	if !hexs.next.has(hex_) and !hexs.current.has(hex_):
		hexs.next.append(hex_)
		
		var input = {}
		input.proprietor = self
		input.type = "hex"
		input.subtype = "index"
		input.value = hex_.index.get_value()
		
		var token = Global.scene.token.instantiate()
		indexs.add_child(token)
		token.set_attributes(input)


func remove_index(hex_: Polygon2D) -> void:
	if hexs.next.has(hex_):
		hexs.next.erase(hex_)
	
		for index in indexs.get_children():
			if index.get_value() == hex_.index.get_value():
				indexs.remove_child(index)
				return
#endregion


func try_on_pattern() -> void:
	for index in indexs.get_children():
		index.visible = false
	
	var options = []
	
	for hex in hexs.next:
		if pattern.check_hex(hex):
			options.append(hex)
			var index = hexs.next.find(hex)
			var token = indexs.get_child(index)
			token.visible = true
