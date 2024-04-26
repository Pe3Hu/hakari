extends MarginContainer


#region var
@onready var indexs = $HBox/Indexs
@onready var patterns = $HBox/Patterns
@onready var constellations = $HBox/Constellations

var god = null
var grimoire = null
var hexs = {}
var capacity = {}
var weights = {}
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	god = input_.god
	
	init_basic_setting()


func init_basic_setting() -> void:
	grimoire = god.grimoire
	capacity.patterns = 3
	capacity.constellations = 2
	
	init_hexs()
	refill_patterns()


func init_hexs() -> void:
	hexs.current = []
	hexs.next = []
	
	for hex in grimoire.types["source"]:
		add_source(hex)


func add_source(hex_: Polygon2D) -> void:
	for neighbor in hex_.neighbors:
		add_index(neighbor)


func add_hex(hex_: Polygon2D) -> void:
	if !hexs.current.has(hex_) and Global.arr.spot.has(hex_.type):
		for neighbor in hex_.neighbors:
			add_index(neighbor)
		
		remove_index(hex_)
		hexs.current.append(hex_)


func add_index(hex_: Polygon2D) -> void:
	if !hexs.next.has(hex_) and !hexs.current.has(hex_) and Global.arr.spot.has(hex_.type):
		hexs.next.append(hex_)
		hex_.index.visible = true
		weights[hex_] = Global.num.hex.remoteness - hex_.remoteness
		
		var input = {}
		input.proprietor = self
		input.type = "index"
		input.subtype = "hex"
		input.value = hex_.index.get_value()
		
		var token = Global.scene.token.instantiate()
		indexs.add_child(token)
		token.set_attributes(input)


func remove_index(hex_: Polygon2D) -> void:
	if hexs.next.has(hex_):
		hexs.next.erase(hex_)
		hex_.index.visible = false
		weights.erase(hex_)
	
		for index in indexs.get_children():
			if index.get_value() == hex_.index.get_value():
				indexs.remove_child(index)
				return


func refill_patterns() -> void:
	while patterns.get_child_count() < capacity.patterns:
		add_pattern()
	
	sort_patterns()


func add_pattern() -> void:
	var input = {}
	input.groove = self
	input.letter = Global.dict.pattern.child[null].pick_random()
	
	var pattern = Global.scene.pattern.instantiate()
	patterns.add_child(pattern)
	pattern.set_attributes(input)


func sort_patterns() -> void:
	var datas = {}
	
	while patterns.get_child_count() > 0:
		var data = {}
		data.pattern = patterns.get_child(0)
		var hex = data.pattern.hexs.get_child(0)
		data.essence = Global.arr.essence.find(hex.essence.subtype)
		data.size = data.pattern.hexs.get_child_count()
		data.letter = Global.dict.pattern.title.keys().find(data.pattern.letter)
		
		if !datas.has(data.size):
			datas[data.size] = {}
		
		if !datas[data.size].has(data.letter):
			datas[data.size][data.letter] = []
		
		datas[data.size][data.letter].append(data)
		patterns.remove_child(data.pattern)
	
	for _size in datas:
		var letters = datas[_size].keys()
		letters.sort_custom(func(a, b): return a < b)
		
		for letter in letters:
			#if datas[_size].has(letter):
			datas[_size][letter].sort_custom(func(a, b): return a.essence < b.essence)
			
			while !datas[_size][letter].is_empty():
				var data = datas[_size][letter].pop_front()
				patterns.add_child(data.pattern)
#endregion


func try_on_pattern(pattern_: MarginContainer) -> void:
	for index in indexs.get_children():
		index.visible = false
	
	var options = []
	
	for hex in hexs.next:
		if pattern_.check_hex(hex):
			options.append(hex)
			var index = hexs.next.find(hex)
			var token = indexs.get_child(index)
			token.visible = true


func get_hexs_based_on_pattern(pattern_: MarginContainer) -> Array:
	var options = []
	
	for hex in hexs.next:
		if pattern_.check_hex(hex):
			options.append(hex)
	
	return options


func refill_constellations() -> void:
	reset_constellations()
	
	var datas = {}
	
	for pattern in patterns.get_children():
		datas[pattern] = get_hexs_based_on_pattern(pattern)
	
	var constituents = Global.get_all_constituents_based_on_size_without_repeats(patterns.get_children(), capacity.constellations)
	
	for constituent in constituents:
		var donors = []
		
		for pattern in constituent:
			donors.append(datas[pattern])
		
		var multiplications = Global.get_all_multiplications(donors)
		
		for _hexs in multiplications:
			var input = {}
			input.patterns = []
			input.hexs = []
		
			for _i in constituent.size():
				input.patterns.append(constituent[_i])
				input.hexs.append(_hexs[_i])
			
			add_constellation(input)


func reset_constellations() -> void:
	while constellations.get_child_count() > 0:
		var constellation = constellations.get_child(0)
		constellation.crush()


func add_constellation(input_: Dictionary) -> void:
	input_.groove = self

	var constellation = Global.scene.constellation.instantiate()
	constellations.add_child(constellation)
	constellation.set_attributes(input_)
