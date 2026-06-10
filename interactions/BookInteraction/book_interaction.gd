class_name BookInteraction
extends AbstractInteraction

enum BookType { FABLES, SURVIVAL_TIPS, CAMP_RULES }

@export var book_title: String = ""
@export var book_type: BookType = BookType.FABLES
var book_instance = null
var book_scene = preload("res://scenes/ui/page_book_ui.tscn")

var pages: Array = []

func _ready() -> void:
	super()
	_build_pages()

func _build_pages() -> void:
	pages.clear()
	match book_type:
		BookType.FABLES:
			if book_title.is_empty(): book_title = "Æsop's Fables — Camp Edition"
			_build_fables_pages()
		BookType.SURVIVAL_TIPS:
			if book_title.is_empty(): book_title = "Survival Tips"
			_build_survival_pages()
		BookType.CAMP_RULES:
			if book_title.is_empty(): book_title = "Camp Rules"
			_build_camp_rules_pages()

func _build_fables_pages() -> void:
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

func _build_survival_pages() -> void:
	var p1 = BookPage.new()
	p1.title = "Starting a Fire"
	p1.content = "[b]What you need:[/b] tinder (dry leaves/grass), kindling (thin sticks), fuel (thick logs).\n\nClear a circle of bare earth at least 1 metre across. Arrange tinder in the centre, build kindling in a small pyramid over it, then add fuel logs around the outside.\n\nStrike sparks into the tinder or use a lighter. Blow gently at the base until flames catch the kindling.\n\n[color=#8B4513][i]Always have water nearby and never leave a fire unattended.[/i][/color]"
	pages.append(p1)

	var p2 = BookPage.new()
	p2.title = "Finding & Purifying Water"
	p2.content = "[b]Finding water:[/b] Follow valleys downhill — streams collect there. Listen for running water. Look for dense green vegetation.\n\n[b]Never drink untreated water.[/b] Even clear mountain streams can carry bacteria.\n\n[b]To purify:[/b]\n1. Collect water in a clean container.\n2. Boil for at least 1 minute (3 minutes at altitude).\n3. Let cool, then add a purification tablet and wait 30 minutes.\n\n[color=#8B4513][i]Dehydration is more dangerous than bad water — but never skip purification if you can help it.[/i][/color]"
	pages.append(p2)

	var p3 = BookPage.new()
	p3.title = "Setting Up Shelter"
	p3.content = "[b]Site selection:[/b] Choose flat, dry ground above the flood line. Avoid depressions where cold air pools at night. Clear sharp rocks and sticks before pitching.\n\n[b]Tent assembly:[/b]\n1. Lay out the groundsheet.\n2. Assemble the poles and thread through the tent body sleeves.\n3. Stake the four corners first, then tighten the guy lines.\n4. Attach the fly sheet last — it keeps rain out.\n\n[color=#8B4513][i]A good shelter keeps you dry, warm, and rested — three essentials for survival.[/i][/color]"
	pages.append(p3)

	var p4 = BookPage.new()
	p4.title = "Plant Identification"
	p4.content = "[b]Edible:[/b]\n• [color=#228B22]Chanterelle[/color] — golden-yellow, wavy cap, smells fruity.\n• [color=#228B22]Blueberry[/color] — small blue berries on low bushes, oval leaves.\n• [color=#228B22]Elderberry[/color] — clusters of tiny dark berries, opposite compound leaves.\n\n[b]Poisonous:[/b]\n• [color=#CC0000]Death Cap[/color] — pale green cap, white gills, ring on stem. [b]Deadly.[/b]\n• [color=#CC0000]Fly Agaric[/color] — red cap with white spots.\n• [color=#CC0000]Nightshade[/color] — shiny black berries, purple flowers.\n\n[color=#8B4513][i]When in doubt, leave it out.[/i][/color]"
	pages.append(p4)

	var p5 = BookPage.new()
	p5.title = "Navigation Basics"
	p5.content = "[b]Using a compass:[/b] Hold it level, away from metal objects. The red needle points [b]Magnetic North[/b]. Rotate the bezel until N aligns with the needle — your direction of travel arrow now shows your bearing.\n\n[b]Using a map:[/b] Orient the map so North on the map points to Magnetic North. Find two landmarks you can see and locate them on the map — where lines from both intersect is your position.\n\n[b]Key bearings:[/b] N=0°, E=90°, S=180°, W=270°.\n\n[color=#8B4513][i]Always note a bearing before you enter dense forest — trees look the same from the inside.[/i][/color]"
	pages.append(p5)

func _build_camp_rules_pages() -> void:
	var p1 = BookPage.new()
	p1.title = "General Rules"
	p1.content = "[b]Welcome to Scout Camp![/b]\n\nPlease read and follow these rules to keep everyone safe and the camp enjoyable.\n\n• Stay within the marked camp boundary at all times unless accompanied by a leader.\n• Respect all equipment — return items to where you found them.\n• No running inside the camp house.\n• Lights out at 22:00. Keep noise to a minimum after sunset.\n• Report any accidents or injuries to the Scout Leader immediately.\n\n[color=#8B4513][i]A good scout leaves every place better than they found it.[/i][/color]"
	pages.append(p1)

	var p2 = BookPage.new()
	p2.title = "Safety Rules"
	p2.content = "[b]Fire Safety[/b]\n• Only light fires in the designated fire pit.\n• Never leave a fire unattended.\n• Keep a bucket of water nearby at all times.\n• Let the fire burn down fully before leaving the area.\n\n[b]Water Safety[/b]\n• Never drink untreated water from the river or lake.\n• Do not swim alone.\n• Stay away from the river bank during and after heavy rain.\n\n[b]Wildlife[/b]\n• Do not feed or approach wild animals.\n• Store all food in sealed containers overnight.\n\n[color=#8B4513][i]Safety first — always.[/i][/color]"
	pages.append(p2)

	var p3 = BookPage.new()
	p3.title = "Activities & Skills"
	p3.content = "[b]Your Five Scout Skills:[/b]\n\n🔥 [b]Fire[/b] — Collect wood and light the camp fire pit.\n\n💧 [b]Water[/b] — Collect, boil, and purify river water.\n\n⛺ [b]Shelter[/b] — Assemble your tent at the marked spot.\n\n🌿 [b]Plants[/b] — Read the field guide and pass the plant quiz.\n\n🧭 [b]Navigation[/b] — Recover all three journal pages from the forest.\n\nComplete each skill to earn your badge. Collect all five badges to become a fully qualified Scout!\n\n[color=#8B4513][i]Good luck, Scout — the forest is waiting.[/i][/color]"
	pages.append(p3)

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
