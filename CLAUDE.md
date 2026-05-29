# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**ScoutCamp** is a 3D first-person survival/adventure game built in **Godot 4.6** (Forward Plus rendering, Jolt Physics). The player progresses through 5 days completing scout survival skills: Fire, Water, Shelter, Plants, and Navigation. Each skill is a mini-game that reports completion to the global GameManager.

## Running the Project

This is a native Godot project with no build scripts. Open and run via the Godot 4.6 editor:
- Main scene entry point: `scenes/world/world.tscn`
- Physics engine: Jolt (configured in `project.godot`)
- Renderer: D3D12 on Windows (Forward Plus)
- Active addons: `terrain_3d`, `proton_scatter`, `gut` (GUT test framework)

To run tests (GUT framework): open Godot editor → GUT panel → Run All.

## Architecture

### Autoload Singletons
- **GameManager** (`scripts/game_manager.gd`): Central state — tracks completed skills, earned badges, current day. Emits `skill_completed`, `badge_earned`, `day_changed`, `flag_found`.
- **DayManager** (`scripts/day_manager.gd`): Advances the day counter and triggers transitions.

### Player (`scenes/player/`)
`PlayerController` is a `CharacterBody3D` with an enum-based state machine (`IDLE_STAND`, `IDLE_CROUCH`, `CROUCHING`, `WALKING`, `SPRINTING`, `AIR`). Key child nodes:
- **InteractionController** (`interaction_controller.gd`): Raycast-driven interaction; manages reticle states (DEFAULT / HIGHLIGHT / INTERACTING / USE_ITEM), item equipping, note inspection via SubViewport, and all interaction audio feedback.
- **InventoryController** (`inventory_controller.gd`): 20-slot grid inventory with drag-and-drop, right-click context menus, double-click actions.
- **InteractableCheck** (Area3D): Detects nearby pickups to trigger outline highlighting.

### Interaction System (`interactions/`)
Polymorphic component hierarchy — attach a child node to any object to make it interactable:
```
AbstractInteraction              ← base class (pre_interact / interact / aux_interact / post_interact)
├── CollectableInteraction
│   ├── ConsumableInteraction
│   ├── EquippableInteraction
│   └── InspectableInteraction  ← notes rendered in-hand via SubViewport
├── RotatableInteraction
│   ├── DoorInteraction
│   ├── WheelInteraction
│   └── SwitchInteraction
├── GrabbableInteraction
└── TypeableInteraction          ← keypads / text input
```

### Inventory & Items
- **ItemData** (`inventory/item_data.gd`): `Resource` subclass with name, icon, `ActionData`.
- **ActionData** (`inventory/actions/action_data.gd`): Enum-based action type (CONSUMABLE, EQUIPPABLE, INSPECTABLE).
- Item `.tres` resource files live in `assets/items/`.

### Skill Mini-Games (`scripts/skill_*.gd`)
Each skill scene (fire, water, shelter, plants, navigation) emits a completion signal caught by GameManager. `SkillFire` is representative: three slots (tinder, kindling, fuel) must be filled correctly.

### NPC System
- **NpcBase** (`scripts/npc_base.gd`): `CharacterBody3D` with patrol path, proximity detection, dialogue cycling.
- **DialogueBox** (`scripts/dialogue_box.gd`): `CanvasLayer` that shows NPC name and current dialogue line.

### UI / HUD
- **HUD** (`scripts/hud.gd`): Badge display + compass (compass unlocks on day 5 when player has compass item).
- **BadgeCard** (`scripts/badge_card.gd`): Individual badge UI node.

## Key Conventions

- **Signals over direct calls** for cross-system communication (especially GameManager → UI).
- **Interaction components are child nodes**, not embedded in the scene's root script, so any mesh node can become interactable without rewriting it.
- **Rendering layer 2** is reserved for equipped items to prevent wall-clipping.
- **Mouse capture state** must be managed carefully — inventory, dialogue, and interactions each toggle `Input.mouse_mode`; check existing patterns before adding new UI that needs cursor control.
- **Audio feedback** uses context-sensitive audio players on the player node (success/failure/pickup sounds are steel-drum themed).

## Project Layout

```
scenes/          # .tscn scene files (world, player, skills, NPCs, objects)
scripts/         # .gd scripts not tied to a single scene type
interactions/    # AbstractInteraction and all concrete interaction types
inventory/       # InventorySlot, ItemData, ActionData, InventoryController
objects/         # Standalone object scenes (doors, props, etc.)
assets/          # Audio, fonts, items (.tres), materials, models, reticles, shaders, textures
data/            # Plant definitions (plants.gd + .tres resources)
terrain_data/    # Terrain3D pre-baked chunks
addons/          # terrain_3d, proton_scatter, gut
```
