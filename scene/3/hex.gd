extends Polygon2D


#region var
@onready var index = $Index
@onready var essence = $Essence

var proprietor = null
var grid = null
var ring = null
var type = null
var neighbors = {}
var directions = {}
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	proprietor = input_.proprietor
	grid = input_.grid
	
	init_basic_setting()


func init_basic_setting() -> void:
	#set_index()
	set_ring()
	init_tokens()
	
	set_vertexs()
	#recolor_based_on_ring()
	set_position_based_on_grid()


func set_ring() -> void:
	if proprietor.get("rings") != null:
		ring = max(abs(grid.x), abs(grid.y))
		ring = max(abs(grid.z), ring)
		
		if !proprietor.rings.has(ring):
			proprietor.rings[ring] = []
		
		proprietor.rings[ring].append(self)
	
	proprietor.grids[grid] = self


func init_tokens() -> void:
	var input = {}
	input.proprietor = self
	input.type = "essence"
	input.subtype = "empty"
	essence.set_attributes(input)
	essence.custom_minimum_size = Global.vec.size.essence
	
	input.type = "hex"
	input.subtype = "index"
	input.value = 0#proprietor.hexs.get_child_count() - 1
	index.set_attributes(input)
	index.custom_minimum_size = Global.vec.size.hex
	#index.position -= index.custom_minimum_size * 0.5 


func set_vertexs() -> void:
	var order = "odd"
	var corners = 6
	var r = Global.num.hex.a
	var vertexs = []
	
	for corner in corners:
		var vertex = Global.dict.corner.vector[corners][order][corner] * r
		vertexs.append(vertex)
	
	set_polygon(vertexs)


func recolor_based_on_ring() -> void:
	var h = float(ring) / Global.num.grimoire.rings
	color = Color.from_hsv(h, 0.75, 1.0)


func recolor_based_on_type() -> void:
	color = Global.color.hex[type]


func set_position_based_on_grid() -> void:
	position = Vector2()
	var ls = []
	ls.append(grid.x)
	ls.append(grid.y)
	ls.append(grid.z)
	var angle = {}
	angle.step = PI * 2 / ls.size()
	
	for _i in ls.size():
		var l = ls[_i]
		angle.current = angle.step * (_i)
		position += Vector2.from_angle(angle.current) * Global.num.hex.a * l


func set_type(type_: String) -> void:
	if type == null:
		type = type_
		recolor_based_on_type()
		
		if proprietor.get("types") != null:
			if !proprietor.types.has(type):
				proprietor.types[type] = []
			
			proprietor.types[type].append(self)


func clean() -> void:
	for neighbor in neighbors:
		neighbor.neighbors.erase(self)
	
	for direction in directions:
		var neighbor = directions[direction]
		neighbor.directions.erase(-direction)
	
	proprietor.grids.erase(grid)
	proprietor.rings[ring].erase(self)
	
	get_parent().remove_child(self)
	queue_free()
#endregion
