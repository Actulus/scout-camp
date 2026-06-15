# ScoutCamp

A 3D first-person survival adventure game built in **Godot 4.6**. Players take on the role of a scout completing survival challenges at camp, earning badges for each skill mastered.

## Gameplay

Explore the camp and surrounding forest, interact with NPCs, and complete six survival skill challenges to earn your badges:

| Badge | Skill | How to earn |
|---|---|---|
| The Fire Starter | Fire | Gather tinder, kindling, and fuel — then light the campfire pit |
| The Tent Camper | Shelter | Assemble the tent at the designated marker near camp |
| The Water Guardian | Water | Collect water, boil it on the fire, purify it with a tablet, and drink it |
| The Nature Reader | Plants | Read the plant field guide and pass the plant identification quiz |
| The Animal Expert | Animals | Read the animal field guide and pass the animal identification quiz |
| The Pathfinder | Navigation | Find all 3 navigation journal pages hidden in the forest |

Completing all six badges triggers the game's completion screen.

## Controls

| Action | Key |
|---|---|
| Move | WASD |
| Look | Mouse |
| Interact / Pick up | E |
| Open inventory | Tab |
| Open task menu | T |
| Open badge menu | B |
| Pause | Escape |

## Features

- **First-person exploration** of a 3D camp environment with a day-night cycle
- **Inventory system** — 20-slot grid with drag-and-drop, right-click context menus, and double-click item use
- **Skill mini-games** — each badge requires solving a distinct in-world challenge
- **NPC dialogue** — patrolling scout and leader NPCs with cycling dialogue lines
- **Field guides** — in-world readable books for plants and animals; reading them unlocks the corresponding quiz
- **Save system** — progress, badges, inventory, and player position are saved automatically

## Technical Details

- **Engine:** Godot 4.6 (Forward Plus renderer, Jolt Physics)
- **Platform target:** Windows (D3D12)
- **Active addons:** Terrain3D, Proton Scatter, GUT (unit test framework)
- **Main scene:** `scenes/world/world.tscn`

## Running the Project

1. Install [Godot 4.6](https://godotengine.org/download).
2. Open the project folder in the Godot editor.
3. Press **F5** or click **Play** to run from `scenes/world/world.tscn`.

To run the automated test suite: open the GUT panel in the editor and click **Run All**.

## Project Structure

```
scenes/          # .tscn scene files (world, player, skills, NPCs, UI)
scripts/         # GDScript files not tied to a single scene
interactions/    # AbstractInteraction and all concrete interaction types
inventory/       # InventorySlot, ItemData, ActionData, InventoryController
systems/         # Autoloaded systems (SaveSystem, SoundManager, DayNightCycle)
objects/         # Standalone object scenes (doors, props, furniture)
assets/          # Audio, fonts, items, materials, models, shaders, textures
data/            # Plant and animal definitions
terrain_data/    # Pre-baked Terrain3D chunks
addons/          # Third-party Godot addons
```
