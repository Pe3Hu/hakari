extends Node


var rng = RandomNumberGenerator.new()
var arr = {}
var num = {}
var vec = {}
var color = {}
var dict = {}
var scene = {}


func _ready() -> void:
	init_arr()
	init_num()
	init_vec()
	init_color()
	init_dict()
	init_scene()


func init_arr() -> void:
	arr.hex = ["wire", "connector", "source", "insulation"]
	arr.spot = ["wire", "connector"]
	arr.essence = ["lightning", "fire", "ice", "poison", "bone", "blood", "light", "void", "darkness"]
	arr.offense = ["whip", "hammer", "spear"]
	arr.defense = ["parry", "block", "dodge"]
	arr.role = ["offense", "defense"]


func init_num() -> void:
	num.index = {}
	
	num.area = {}
	num.area.n = 9
	num.area.col = num.area.n
	num.area.row = num.area.n
	
	num.grimoire = {}
	num.grimoire.sectors = 2
	num.grimoire.source = 1
	num.grimoire.wire = 1
	num.grimoire.connector = 2
	num.grimoire.rings = (num.grimoire.source + num.grimoire.wire + num.grimoire.connector) * num.grimoire.sectors
	
	num.hex = {}
	num.hex.a = 24
	num.hex.r = num.hex.a * sqrt(3) / 2
	num.hex.n = 6
	num.hex.remoteness = 4
	
	num.pattern = {}
	num.pattern.shift = num.hex.n / 2
	
	num.thickness = {}
	num.thickness.spear = 3
	num.thickness.hammer = 2
	num.thickness.whip = 1


func init_dict() -> void:
	init_neighbor()
	init_corner()
	init_font()
	init_offense()
	
	init_pattern()
	init_essence()


func init_neighbor() -> void:
	dict.neighbor = {}
	dict.neighbor.linear3 = [
		Vector3( 0, 0, -1),
		Vector3( 1, 0,  0),
		Vector3( 0, 0,  1),
		Vector3(-1, 0,  0)
	]
	dict.neighbor.linear2 = [
		Vector2( 0,-1),
		Vector2( 1, 0),
		Vector2( 0, 1),
		Vector2(-1, 0)
	]
	dict.neighbor.diagonal = [
		Vector2( 1,-1),
		Vector2( 1, 1),
		Vector2(-1, 1),
		Vector2(-1,-1)
	]
	dict.neighbor.zero = [
		Vector2( 0, 0),
		Vector2( 1, 0),
		Vector2( 1, 1),
		Vector2( 0, 1)
	]
	dict.neighbor.hex = [
		[
			Vector2( 1,-1), 
			Vector2( 1, 0), 
			Vector2( 0, 1), 
			Vector2(-1, 0), 
			Vector2(-1,-1),
			Vector2( 0,-1)
		],
		[
			Vector2( 1, 0),
			Vector2( 1, 1),
			Vector2( 0, 1),
			Vector2(-1, 1),
			Vector2(-1, 0),
			Vector2( 0,-1)
		]
	]
	dict.neighbor.cube = [
		Vector3(0, -1, +1),
		Vector3(+1, -1, 0),
		Vector3(+1, 0, -1),
		Vector3(0, +1, -1), 
		Vector3(-1, +1, 0),
		Vector3(-1, 0, +1),   
	]


func init_corner() -> void:
	dict.order = {}
	dict.order.pair = {}
	dict.order.pair["even"] = "odd"
	dict.order.pair["odd"] = "even"
	var corners = [6]
	dict.corner = {}
	dict.corner.vector = {}
	
	for corners_ in corners:
		dict.corner.vector[corners_] = {}
		dict.corner.vector[corners_].even = {}
		
		for order_ in dict.order.pair.keys():
			dict.corner.vector[corners_][order_] = {}
		
			for _i in corners_:
				var angle = 2*PI*_i/corners_-PI/2
				
				if order_ == "odd":
					angle += PI/corners_
				
				var vertex = Vector2(1,0).rotated(angle)
				dict.corner.vector[corners_][order_][_i] = vertex


func init_font():
	dict.font = {}
	dict.font.size = {}


func init_offense() -> void:
	#dict.blueprint = {}
	#dict.blueprint.role = {}
	dict.offense = {}
	dict.offense.shifts = {}
	#var directions = dict.neighbor.cube
	
	for offense in arr.offense:
		dict.offense.shifts[offense] = []
		var n = num.hex.n / num.thickness[offense]
		var k = num.thickness[offense]
		
		for _i in n:
			var shifts = []
			
			for _j in num.thickness[offense]:
				#grid += directions[_i]
				#dict.offense.shifts[offense].append(Vector3(grid))
				shifts.append(_i * k)
			
			dict.offense.shifts[offense].append(shifts)


func init_pattern() -> void:
	dict.pattern = {}
	dict.pattern.title = {}
	dict.pattern.child = {}
	dict.pattern.parent = {}
	dict.pattern.child[null] = []
	var exceptions = ["title", "size"]
	
	var path = "res://asset/json/hakari_pattern.json"
	var array = load_data(path)
	var types = {}
	types["c"] = "connector"
	types["w"] = "wire"
	
	for pattern in array:
		dict.pattern.child[pattern.title] = []
		dict.pattern.parent[pattern.title] = []
		var data = {}
		data.size = int(pattern.size)
		
		for key in pattern:
			if !exceptions.has(key):
				var words = pattern[key].split(",")
				data[key] = []
				
				for word in words:
					match key:
						"types":
							data[key].append(types[word])
						"shifts":
							data[key].append(int(word))
						"childs":
							data[key].append(word)
							dict.pattern.child[pattern.title].append(word)
						"parents":
							data[key].append(word)
							dict.pattern.parent[pattern.title].append(word)
					
			
		#if !dict.pattern.title.has(pattern.size):
			#dict.pattern.title[pattern.size] = {}
	
		dict.pattern.title[pattern.title] = data
		
		if dict.pattern.parent[pattern.title].is_empty():
			dict.pattern.parent[pattern.title].append(null)
			dict.pattern.child[null].append(pattern.title)
			
		if dict.pattern.child[pattern.title].is_empty():
			dict.pattern.child.erase(pattern.title)


func init_essence() -> void:
	dict.essence = {}
	dict.essence.title = {}
	dict.essence.offense = {}
	dict.essence.defense = {}
	
	var exceptions = ["title"]
	var path = "res://asset/json/hakari_essence.json"
	var array = load_data(path)
	
	for essence in array:
		var data = {}
		data.offense = {}
		data.defense = {}
		
		for key in essence:
			if !exceptions.has(key):
				for type in data:
					if arr[type].has(key):
						data[type][key] = essence[key]
		
		for type in data:
			for subtype in data[type]:
				if !dict.essence[type].has(subtype):
					dict.essence[type][subtype] = {}
				
				dict.essence[type][subtype][essence.title] = data[type][subtype]
		
		dict.essence.title[essence.title] = data


func init_scene() -> void:
	scene.token = load("res://scene/0/token.tscn")
	
	scene.pantheon = load("res://scene/1/pantheon.tscn")
	scene.god = load("res://scene/1/god.tscn")
	
	scene.planet = load("res://scene/2/planet.tscn")
	scene.area = load("res://scene/2/area.tscn")
	
	scene.hex = load("res://scene/3/hex.tscn")
	
	scene.page = load("res://scene/4/page.tscn")
	scene.blueprint = load("res://scene/4/blueprint.tscn")


func init_vec():
	vec.size = {}
	vec.size.sixteen = Vector2(16, 16)
	vec.size.area = Vector2(60, 60)
	vec.size.token = Vector2(32, 32)
	
	vec.size.hex = Vector2.ONE * num.hex.r * 2
	vec.size.essence = vec.size.hex * 0.75
	
	init_window_size()


func init_window_size():
	vec.size.window = {}
	vec.size.window.width = ProjectSettings.get_setting("display/window/size/viewport_width")
	vec.size.window.height = ProjectSettings.get_setting("display/window/size/viewport_height")
	vec.size.window.center = Vector2(vec.size.window.width/2, vec.size.window.height/2)


func init_color():
	var h = 360.0
	
	color.hex = {}
	color.hex.source = Color.from_hsv(0 / h, 0.9, 0.7)
	color.hex.connector = Color.from_hsv(120 / h, 0.9, 0.7)
	color.hex.wire = Color.from_hsv(210 / h, 0.9, 0.7)
	color.hex.insulation = Color.from_hsv(270 / h, 0.9, 0.7)
	
	color.remoteness = {}
	color.remoteness[1] = Color.from_hsv(20 / h, 0.8, 0.4)
	color.remoteness[2] = Color.from_hsv(40 / h, 0.8, 0.4)
	color.remoteness[3] = Color.from_hsv(60 / h, 0.8, 0.4)


func save(path_: String, data_: String):
	var path = path_ + ".json"
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(data_)


func load_data(path_: String):
	var file = FileAccess.open(path_, FileAccess.READ)
	var text = file.get_as_text()
	var json_object = JSON.new()
	var _parse_err = json_object.parse(text)
	return json_object.get_data()


func get_random_key(dict_: Dictionary):
	if dict_.keys().size() == 0:
		print("!bug! empty array in get_random_key func")
		return null
	
	var total = 0
	
	for key in dict_.keys():
		total += dict_[key]
	
	rng.randomize()
	var index_r = rng.randf_range(0, 1)
	var index = 0
	
	for key in dict_.keys():
		var weight = float(dict_[key])
		index += weight/total
		
		if index > index_r:
			return key
	
	print("!bug! index_r error in get_random_key func")
	return null
