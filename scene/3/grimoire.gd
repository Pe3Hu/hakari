extends MarginContainer


#region var
@onready var hexs = $Hexs

var god = null
var grids = {}
var types = {}
var rings = {}
var corners = {}
var frontier = {}
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	god = input_.god
	
	init_basic_setting()


func init_basic_setting() -> void:
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
	
	for hex in hexs.get_children():
		if hex.type != null:
			update_corners(hex.position)
		else:
			hex.clean()
	
	update_hex_indexs()


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
	var _types = ["connector", "wire", "connector", "source"]
	
	for direction in Global.dict.neighbor.cube:
		var grid = Vector3()
		
		for type in _types:
			grid += direction
			var neighbor = grids[grid]
			neighbor.set_type(type)
	
	for hex in types["source"]:
		for direction in Global.dict.neighbor.cube:
			var neighbor = hex.directions[direction]
			neighbor.set_type("connector")
	
	_types = ["connector", "wire", "wire"]
	
	for hex in types["source"]:
		for direction in Global.dict.neighbor.cube:
			var neighbor = hex
			
			for type in _types:
				if neighbor.directions.has(direction):
					neighbor = neighbor.directions[direction]
					neighbor.set_type(type)
	
	var hex = grids[Vector3()]
	hex.set_type("source")


func update_hex_indexs() -> void:
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
