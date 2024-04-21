extends MarginContainer


#region var
@onready var hexs = $Hexs

var groove = null
var letter = null
var corners = {}
var grids = {}
var directions = {}
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	groove = input_.groove
	letter = input_.letter
	
	init_basic_setting()


func init_basic_setting() -> void:
	corners.min = Vector2()
	corners.max = Vector2()
	init_hexs()


func init_hexs() -> void:
	var gird = Vector3()
	add_hex(gird)
	
	var shifts = Global.dict.pattern.title[letter].shifts
	var types = Global.dict.pattern.title[letter].types
	var _directions = Global.dict.neighbor.cube
	var shift = int(Global.num.pattern.shift)
	var direction = _directions[shift]
	
	for _i in Global.num.hex.n:
		directions[_i] = []
	
	for _i in shifts.size():
		if _i > 0:
			shift = (shift - shifts[_i] + _directions.size()) % _directions.size()
			direction = _directions[shift]
			gird += direction
			add_hex(gird)
			#directions.append(direction)
		
		var hex = hexs.get_child(hexs.get_child_count() - 1)
		hex.set_type(types[_i])
		update_corners(hex.position)
	
	update_size()
	
	
	for _j in Global.num.hex.n:
		shift = int(Global.num.pattern.shift + _j) % _directions.size()
		direction = _directions[shift]
		
		for _i in shifts.size():
			if _i > 0:
				shift = (shift - shifts[_i] + _directions.size()) % _directions.size()
				directions[_j].append(direction)


func add_hex(grid_: Vector3) -> void:
	var input = {}
	input.proprietor = self
	input.grid = grid_

	var hex = Global.scene.hex.instantiate()
	hexs.add_child(hex)
	hex.set_attributes(input)


func update_corners(vector_: Vector2) -> void:
	if corners.min.y > vector_.y:
		corners.min.y = vector_.y
	if corners.min.x > vector_.x:
		corners.min.x = vector_.x
	if corners.max.y < vector_.y:
		corners.max.y = vector_.y
	if corners.max.x < vector_.x:
		corners.max.x = vector_.x


func update_size() -> void:
	corners.min.x -= Global.num.hex.a
	corners.min.y -= Global.num.hex.r
	corners.max.x += Global.num.hex.a
	corners.max.y += Global.num.hex.r
	
	custom_minimum_size = corners.max - corners.min
	hexs.position = -corners.min
#endregion


func check_hex(hex_: Polygon2D) -> bool:
	var types = Global.dict.pattern.title[letter].types
	
	if hex_.type != types.front():
		return false
	
	var hex = hex_
	
	for rotate in directions:
		var flag = true
		
		for _i in directions[rotate].size():
			if !flag:
				break
			
			var direction = directions[rotate][_i]
			
			if hex.directions.has(direction):
				hex = hex.directions[direction]
				
				if hex.type != types[_i + 1]:
					print([hex_.index.get_value(), str(rotate), hex.index.get_value(), "type"])
					flag = false
					break
				
				if hex.essence.subtype != "empty":
					print([hex_.index.get_value(), str(rotate), hex.index.get_value(), "essence"])
					flag = false
				break
			else:
				print([hex_.index.get_value(), str(rotate), hex.index.get_value(), "direction"])
				flag = false
				break
		
		if flag == true:
			return true
	
	return false
