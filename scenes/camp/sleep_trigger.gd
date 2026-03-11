extends StaticBody3D

var display_name: String = "Sleeping bag"

func interact(player: Node):
	DayManager.advance_day()
