# ScoutCamp 🏕️

A first-person 3D serious educational game for developing wilderness survival skills, built with Godot Engine 4.6 and Blender 5.1.

> Developed as part of an MSc dissertation in Software Engineering at Sapientia Hungarian University of Transylvania (Marosvásárhely), 2026.

---

## About

ScoutCamp places the player in a scout camp environment where six wilderness survival skills must be learned and completed through interactive, multi-step skill systems:

- 🔥 **Fire-making** — Collect wood, find a match, light the campfire
- ⛺ **Shelter building** — Assemble a tent at the designated marker
- 💧 **Water purification** — Collect, boil, purify and drink water
- 🌿 **Plant identification** — Read the field guide and pass the plant quiz
- 🦊 **Animal recognition** — Read the field guide and pass the animal quiz
- 🧭 **Navigation** — Find the map and compass, collect 3 journal pages

The game features a badge-based reward system, an adaptive NPC camp leader, a context-sensitive task menu, and full keyboard/controller support.

---

## Download & Play

**Platforms:** Windows, Linux

👉 [Download from Google Drive](https://drive.google.com/drive/folders/1h1ZA7qHnF4w265EYf7_ed4QtdWtiJvbE?usp=sharing)

### Windows

1. Download and extract the `.zip` file
2. Run `ScoutCamp.exe`
3. No installation required

### Linux

1. Download and extract the `.zip` file
2. Open a terminal in the extracted folder
3. Make the binary executable:
   ```bash
   chmod +x ScoutCamp.x86_64
   ```
4. Run the game:
   ```bash
   ./ScoutCamp.x86_64
   ```

---

## Minimum System Requirements

| Component  | Minimum                                           |
| ---------- | ------------------------------------------------- |
| OS         | Windows 10/11 x64 or Linux (64-bit)               |
| CPU        | Intel Core i3 / AMD Ryzen 3, quad-core, 1.6 GHz   |
| RAM        | 4 GB                                              |
| GPU        | Integrated graphics (Intel UHD / AMD Radeon Vega) |
| Storage    | 500 MB free space                                 |
| Resolution | 1280×720                                          |

---

## Controls

### Keyboard & Mouse

| Action            | Key            |
| ----------------- | -------------- |
| Move              | WASD           |
| Look              | Mouse          |
| Interact          | E / Left Click |
| Use equipped item | Left Click     |
| Unequip item      | Right Click    |
| Task menu         | T              |
| Badge menu        | B              |
| Map               | M              |
| Inventory         | Tab            |
| Pause             | Escape         |

### Controller (Xbox layout)

| Action            | Button      |
| ----------------- | ----------- |
| Move              | Left Stick  |
| Look              | Right Stick |
| Interact          | A           |
| Use equipped item | RT          |
| Unequip item      | LT          |
| Task menu         | X           |
| Badge menu        | Y           |
| Map               | D-Pad Up    |
| Inventory         | LB          |
| Pause             | Start       |

---

## Built With

- **[Godot Engine 4.6](https://godotengine.org/)** — MIT licensed game engine
- **[Blender 5.1](https://www.blender.org/)** — 3D modeling and animation
- **[Kenney Assets](https://kenney.nl/assets)** — CC0 furniture and props
- **[Poly Pizza](https://poly.pizza)** — CC0 3D models

---

## Project Structure

```
scout-camp/
├── addons/          # Godot addons (ProtonScatter)
├── assets/          # Audio, fonts, materials, textures
├── interactions/    # Interaction component hierarchy
├── scenes/          # Game scenes (.tscn files)
│   ├── ui/          # UI scenes (HUD, menus, guides)
│   └── world/       # World and environment scenes
├── scripts/         # Standalone GDScript files
├── systems/         # Autoload singletons
│   ├── game_manager.gd
│   ├── save_system.gd
│   └── sound_manager.gd
└── resources/       # PlantInfo, AnimalInfo, ItemData resources
```

---

## Alpha Testing

This game is currently in **alpha testing** as part of an MSc research study evaluating its pedagogical effectiveness.

If you were invited to participate in the alpha test, please:

1. Download and play the game (aim for 45–60 minutes)
2. Complete the post-game questionnaire sent to your email
3. Report any bugs or issues to: **[your email here]**

### Known Issues

- Occasional editor crashes during development (Godot 4.6 + Compatibility mode)
- Location display shows "Unknown" in performance logs
- macOS build not available (untested)

---

## Academic Context

ScoutCamp was developed as part of an MSc dissertation:

**Title:** ScoutCamp — Developing a First-Person 3D Serious Educational Game for Wilderness Survival Skill Development

**Author:** Kovács-Bálint Hunor

**Institution:** Sapientia Hungarian University of Transylvania, Faculty of Technical and Human Sciences, Târgu Mureș

**Supervisor:** _(supervisor name)_

**Year:** 2026

The game is also the subject of a parallel pedagogy thesis examining its educational effectiveness through questionnaire-based and alpha-testing empirical studies.

---

## License

The source code is available under the **MIT License** — see [LICENSE](LICENSE) for details.

Third-party assets:

- Kenney Assets — [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)
- Poly Pizza models — [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)

---

## Acknowledgements

- [Kenney](https://kenney.nl) for the excellent CC0 asset packs
- [Poly Pizza](https://poly.pizza) for free 3D models
- The Godot Engine community for documentation and forum support
- Sapientia EMTE for academic support

---

_ScoutCamp is a prototype developed for research purposes. Feedback is welcome!_
