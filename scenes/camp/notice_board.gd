extends StaticBody3D

var tasks = {
	1: "Day 1: Build your shelter before nightfall.",
	2: "Day 2: Learn to make fire - collect dry materials.",
	3: "Day 3: Find and purify safe drinking water.",
	4: "Day 4: Identify edible and poisonous plants.",
	5: "Day 5: Navigate using compass and landmarks."
}

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.day_changed.connect(_update_task)

func _update_task(day: int):
	if day in tasks:
		print("Notice Board: ", tasks[day])
		
func interact(player: Node):
	var day = GameManager.current_day
	var box = get_tree().get_root().get_node("World/DialogueBox")
	box.show_dialogue("Notice Board", tasks.get(day, "All tasks complete!"))
