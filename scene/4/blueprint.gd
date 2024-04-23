extends MarginContainer


#region vars
@onready var designation = $Tokens/Designation
@onready var readiness = $Tokens/Readiness
@onready var power = $Tokens/Power

var page = null
var shift = null
var hexs = []
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	page = input_.page
	shift = input_.shift
	
	init_basic_setting(input_)


func init_basic_setting(input_: Dictionary) -> void:
	init_tokens(input_)
	init_hexs()


func init_tokens(input_: Dictionary) -> void:
	var input = {}
	input.proprietor = self
	
	for role in Global.arr.role:
		if Global.arr[role].has(input_.title):
			input.type = role
			break
	
	input.subtype = input_.title
	designation.set_attributes(input)
	
	input.type = "blueprint"
	input.subtype = "readiness"
	input.value = 0
	readiness.set_attributes(input)
	
	input.subtype = "power"
	power.set_attributes(input)


func init_hexs() -> void:
	var shifts = Global.dict.offense.shifts[designation.subtype]
	var directions = Global.dict.neighbor.cube
	
	for _shifts in shifts:
		var hex = page.hex
		
		for _i in _shifts.size():
			var _shift = (_shifts[_i]+ shift) % directions.size()
			var direction = directions[_shift]
			hex = hex.directions[direction]
			hexs.append(hex)
			
			if hex.essence.subtype != "empty":
				var value = 1
				readiness.change_value(value)
				value = Global.dict.essence.offense[designation.subtype][hex.essence.subtype]
				power.change_value(value)
