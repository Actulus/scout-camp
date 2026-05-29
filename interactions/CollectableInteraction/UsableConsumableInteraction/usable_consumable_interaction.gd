class_name UsableConsumableInteraction
extends ConsumableInteraction

"""
Extends ConsumableInteraction to allow items to be used on specific
world objects (like fire pits, boiling pots, etc) directly from inventory.
If the player is looking at a valid target when using the item, it calls
use_item() on that target instead of consuming normally.
"""

# group name on the target node e.g. "fire_pit", "boiling_station"
@export var use_target_group: String = ""

func _ready() -> void:
	super()
