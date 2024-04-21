extends MarginContainer


#region var
@onready var areas = $Areas

var universe = null
#endregion


#region init
func set_attributes(input_: Dictionary) -> void:
	universe = input_.universe
	
	
	init_basic_setting()


func init_basic_setting() -> void:
	init_areas()


func init_areas() -> void:
	var corners = {}
	corners.x = [0, Global.num.area.col - 1]
	corners.y = [0, Global.num.area.row - 1]
	
	areas.columns = Global.num.area.col
	
	for _i in Global.num.area.row:
		for _j in Global.num.area.col:
			var input = {}
			input.planet = self
			input.grid = Vector2(_j, _i)
			
			if corners.y.has(_i) or corners.x.has(_j):
				if corners.y.has(_i) and corners.x.has(_j):
					input.type = "corner"
				else:
					input.type = "edge"
			else:
				input.type = "center"
	
			var area = Global.scene.area.instantiate()
			areas.add_child(area)
			area.set_attributes(input)
#endregion
