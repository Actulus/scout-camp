extends Resource
class_name AnimalInfo

@export var animal_id: String = ""
@export var display_name: String = ""
@export var latin_name: String = ""
@export var image: Texture2D
@export var habitat: String = ""
@export var description: String = ""
@export var is_dangerous: bool = false
@export var rarity: String = "Common"  # Common, Uncommon, Rare
