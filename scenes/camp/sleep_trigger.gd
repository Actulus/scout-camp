extends StaticBody3D

var item_name: String = "Sleeping bag"
var display_name: String = "Sleeping bag"

func interact(player: Node):
	DayManager.advance_day()
