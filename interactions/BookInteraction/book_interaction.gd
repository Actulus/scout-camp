class_name BookInteraction
extends AbstractInteraction

@export var book_title: String = "Æsop's Fables — Camp Edition"
var book_instance = null
var book_scene = preload("res://scenes/ui/page_book_ui.tscn")

# pages defined here directly
var pages: Array = []

func _ready() -> void:
	super()
	_build_pages()

func _build_pages() -> void:
	var cover = BookPage.new()
	cover.title = ""
	cover.content = "[center]Ancient tales retold for the campfire.[/center]\n\n[center]— Turn the page to begin —[/center]"
	pages.append(cover)
	
	var p1 = BookPage.new()
	p1.title = "The Ant and the Grasshopper"
	p1.content = "In a field one summer's day a Grasshopper was hopping about, chirping and singing to its heart's content. An Ant passed by, bearing along with great toil an ear of corn he was taking to the nest.\n\n[i]\"Why not come and chat with me,\"[/i] said the Grasshopper, [i]\"instead of toiling and moiling in that way?\"[/i]\n\n[i]\"I am helping to lay up food for the winter,\"[/i] said the Ant, [i]\"and recommend you to do the same.\"[/i]\n\n[i]\"Why bother about winter?\"[/i] said the Grasshopper; [i]\"we have got plenty of food at present.\"[/i]\n\nBut the Ant went on its way. When winter came the Grasshopper found itself dying of hunger, while it saw the ants distributing every day corn from the stores they had collected in summer.\n\n[color=#8B4513][i]Work today and you shall eat tomorrow.[/i][/color]"
	pages.append(p1)
	
	var p2 = BookPage.new()
	p2.title = "The Fox and the Crow"
	p2.content = "A Crow was sitting on a branch of a tree with a piece of cheese in her beak when a Fox observed her and set his wits to work to discover some way of getting the cheese.\n\nComing and standing under the tree he looked up and said, [i]\"What a noble bird I see above me! Her beauty is without equal. If only her voice is as sweet as her looks, she ought without doubt to be Queen of the Birds.\"[/i]\n\nThe Crow was so pleased that she gave a loud caw. Down came the cheese, and the Fox, snatching it up, said:\n\n[i]\"You have a voice. What you want is wit.\"[/i]\n\n[color=#8B4513][i]Do not trust flatterers.[/i][/color]"
	pages.append(p2)
	
	var p3 = BookPage.new()
	p3.title = "The Tortoise and the Hare"
	p3.content = "The Hare was once boasting of his speed before the other animals. [i]\"I have never yet been beaten,\"[/i] said he, [i]\"when I put forth my full speed. I challenge anyone here to race with me.\"[/i]\n\nThe Tortoise said quietly, [i]\"I accept your challenge.\"[/i]\n\n[i]\"That is a good joke,\"[/i] said the Hare; [i]\"I could dance round you all the way.\"[/i]\n\nThe course was fixed and a start was made. The Hare darted almost out of sight at once, and thinking the Tortoise had no chance, lay down for a nap. The Tortoise plodded on and on, and when the Hare awoke from his nap he saw the Tortoise nearing the finish line, and could not catch him in time.\n\n[color=#8B4513][i]Slow and steady wins the race.[/i][/color]"
	pages.append(p3)
	
	var p4 = BookPage.new()
	p4.title = "The Lion and the Mouse"
	p4.content = "Once when a Lion was asleep a little Mouse began running up and down upon him. This soon wakened the Lion, who placed his huge paw upon the Mouse and opened his big jaws to swallow him.\n\n[i]\"Pardon, O King,\"[/i] cried the little Mouse, [i]\"forgive me this time and I shall never forget it. Who knows but what I may be able to do you a turn some of these days?\"[/i]\n\nThe Lion was so tickled at the idea that he lifted up his paw and let him go.\n\nSome time later the Lion was caught in a trap. The Mouse heard his roars and came to help. With his sharp little teeth he gnawed through the ropes and set the Lion free.\n\n[color=#8B4513][i]Little friends may prove great friends.[/i][/color]"
	pages.append(p4)
	
	var p5 = BookPage.new()
	p5.title = "The Boy Who Cried Wolf"
	p5.content = "A Shepherd Boy tended his master's sheep near a dark forest. He thought it would be great fun to trick the villagers by crying out [i]\"Wolf! Wolf!\"[/i] when there was no wolf.\n\nThe villagers came running, only to find no wolf. The boy laughed at the sight.\n\nHe tried the trick again. Again the villagers ran to help, again to find no wolf.\n\nThen one evening a real Wolf appeared. The boy cried [i]\"Wolf! Wolf!\"[/i] as loud as he could. But the villagers thought he was deceiving them again, and nobody came.\n\nAt sunset the villagers found the boy weeping.\n\n[i]\"There really was a wolf! The flock is gone!\"[/i]\n\n[color=#8B4513][i]Nobody believes a liar, even when he tells the truth.[/i][/color]"
	pages.append(p5)
	
	var p6 = BookPage.new()
	p6.title = "The Wind and the Sun"
	p6.content = "The Wind and the Sun were disputing which was the stronger. Suddenly they saw a traveller coming down the road.\n\n[i]\"The one who can strip that traveller of his cloak shall be the stronger,\"[/i] said the Sun.\n\nThe Wind blew as hard as he could, but the harder he blew the more closely the traveller wrapped his cloak around him. At last the Wind gave up.\n\nThen the Sun shone out warmly. The traveller soon found it too hot to walk with his cloak on and took it off.\n\n[color=#8B4513][i]Kindness and warmth win what force cannot.[/i][/color]"
	pages.append(p6)

func pre_interact() -> void:
	super()

func interact() -> void:
	super()
	if not can_interact: return
	if book_instance: return
	book_instance = book_scene.instantiate()
	book_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(book_instance)
	book_instance.setup(book_title, pages)
	book_instance.closed.connect(func(): book_instance = null)

func aux_interact() -> void:
	super()

func post_interact() -> void:
	super()

func use_item(_item_data: ItemData) -> bool:
	return false
