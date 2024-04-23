extends MarginContainer


#region var
@onready var hexs = $Hexs

var god = null
var groove = null
var rank = null
var grids = {}
var types = {}
var rings = {}
var corners = {}
var frontier = {}
var remotenesses = {}
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	god = input_.god
	
	init_basic_setting()


func init_basic_setting() -> void:
	rank = 3
	groove = god.groove
	corners.min = Vector2()
	corners.max = Vector2()
	init_hexs()
	update_size()


func init_hexs() -> void:
	frontier.current = []
	frontier.next = []
	add_hex(Vector3())
	
	for _i in Global.num.grimoire.rings - 1:
		frontier.current = []
		frontier.current.append_array(frontier.next)
		frontier.next = []
		
		for hex in frontier.current:
			add_neighbors(hex)
	
	update_hex_neighbors()
	update_hex_types()
	update_hex_indexs()
	
	#for remoteness in remotenesses:
		#for hex in remotenesses[remoteness]:
			#hex.recolor_based_on_remoteness()


func add_hex(grid_: Vector3) -> void:
	var input = {}
	input.proprietor = self
	input.grid = grid_

	var hex = Global.scene.hex.instantiate()
	hexs.add_child(hex)
	hex.set_attributes(input)
	frontier.next.append(hex)


func add_neighbors(hex_: Polygon2D) -> void:
	for direction in Global.dict.neighbor.cube:
		var grid = hex_.grid + direction
		
		if !grids.has(grid):
			add_hex(grid)


func update_corners(vector_: Vector2) -> void:
	if corners.min.y > vector_.y:
		corners.min.y = vector_.y
	if corners.min.x > vector_.x:
		corners.min.x = vector_.x
	if corners.max.y < vector_.y:
		corners.max.y = vector_.y
	if corners.max.x < vector_.x:
		corners.max.x = vector_.x


func update_hex_neighbors() -> void:
	for hex in hexs.get_children():
		for direction in Global.dict.neighbor.cube:
			var grid = direction + hex.grid
			
			if grids.has(grid):
				var neighbor = grids[grid]
				
				if !hex.neighbors.has(neighbor):
					hex.neighbors[neighbor] = direction
					neighbor.neighbors[hex] = -direction
					hex.directions[direction] = neighbor
					neighbor.directions[-direction] = hex


func update_hex_types() -> void:
	var source = grids[Vector3()]
	source.set_type("source")
	
	var _types = ["connector", "wire", "connector", "source"]
	
	for direction in Global.dict.neighbor.cube:
		var grid = Vector3()
		
		for type in _types:
			grid += direction
			var neighbor = grids[grid]
			neighbor.set_type(type)
	
	var sources = []
	var options = []
	options.append_array(types["source"])
	source = options.pop_front()
	sources.append(source)
	
	Global.rng.randomize()
	var shift = Global.rng.randi_range(0, options.size() - 1)
	
	while sources.size() < rank:
		source = options[shift]#options.pick_random()
		options.erase(source)
		sources.append(source)
		shift = shift % options.size()
	
	for _i in range(types["source"].size()-1,-1,-1):
		var hex = types["source"][_i]
		
		if !sources.has(hex):
			hex.clean()
	
	#for hex in types["source"]:
	for hex in sources:
		for direction in Global.dict.neighbor.cube:
			var neighbor = hex.directions[direction]
			neighbor.set_type("connector")
	
	_types = ["connector", "wire", "wire"]
	
	#for hex in types["source"]:
	for hex in sources:
		for direction in Global.dict.neighbor.cube:
			var neighbor = hex
			
			for type in _types:
				if neighbor.directions.has(direction):
					neighbor = neighbor.directions[direction]
					neighbor.set_type(type)
	
	for _i in range(types["connector"].size()-1,-1,-1):
		var hex = types["connector"][_i]
		var flag = false
		
		for neighbor in hex.neighbors:
			if neighbor.type == "source":
				flag = true
				break
		
		if !flag:
			hex.reset_type("wire")
		else:
			hex.set_remoteness(1)
	
	for hex in types["wire"]:
		var flag = false
		
		for neighbor in hex.neighbors:
			if neighbor.type == "connector":
				flag = true
				break
		
		if !flag:
			hex.set_remoteness(3)
		else:
			hex.set_remoteness(2)
	
	for hex in remotenesses[2]:
		for neighbor in hex.neighbors:
			var connectors = 0
			
			for _hex in neighbor.neighbors:
				if _hex.type == "connector":
					connectors += 1
			
			if connectors > 1:
				neighbor.set_type("insulation") 
	
	for _i in range(types["insulation"].size()-1,-1,-1):
		var hex = types["insulation"][_i]
		var insulations = 0
		
		for neighbor in hex.neighbors:
			if neighbor.type == "insulation":
				insulations += 1
		
		if insulations == 0:
			hex.reset_type(null)
	
	for _i in range(types["insulation"].size()-1,-1,-1):
		var hex = types["insulation"][_i]
		
		for neighbor in hex.neighbors:
			if neighbor.type == null:
				var insulations = 0
				
				for _hex in neighbor.neighbors:
					if _hex.type == "insulation":
						insulations += 1
					
				if insulations > 0:
					neighbor.set_type("insulation")


func update_hex_indexs() -> void:
	for hex in hexs.get_children():
		if hex.type != null:
			update_corners(hex.position)
		else:
			hex.clean()
	
	var index = 0
	
	for ring in rings:
		for hex in rings[ring]:
			hex.index.set_value(index)
			index += 1


func update_size() -> void:
	corners.min.x -= Global.num.hex.a
	corners.min.y -= Global.num.hex.r
	corners.max.x += Global.num.hex.a
	corners.max.y += Global.num.hex.r
	
	custom_minimum_size = corners.max - corners.min
	hexs.position = -corners.min


func reset() -> void:
	pass
#endregion


func refill_starter_essence() -> void:
	var n = 12
	
	for _i in n:
		var hex = Global.get_random_key(groove.weights)
		var essence = Global.arr.essence.pick_random()
		set_essence_to_hex(hex, essence)


func set_essence_to_hex(hex_: Polygon2D, essence_: String) -> void:
	hex_.essence.set_subtype(essence_)
	groove.add_hex(hex_)
