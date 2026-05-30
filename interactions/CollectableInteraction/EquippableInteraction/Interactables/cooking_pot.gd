extends RigidBody3D


func get_interaction_component() -> AbstractInteraction:
	var pot_ic: PotInteraction = null
	var equip_ic: EquippableInteraction = null
	for child in get_children():
		if child is PotInteraction and not pot_ic:
			pot_ic = child
		elif child is EquippableInteraction and not equip_ic:
			equip_ic = child

	# On fire: always use pot interaction
	if is_in_group("cooking_pot"):
		return pot_ic if pot_ic else equip_ic

	# Has contents: use pot interaction even when not on fire yet
	if pot_ic and pot_ic.contents != "":
		return pot_ic

	# Empty and free: let the player pick it up
	return equip_ic if equip_ic else null
