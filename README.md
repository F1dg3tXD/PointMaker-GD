# PointMaker GD

A Godot port of PointMaker by Splite.

---

## 🚀 Features

- ✅ Trigger multiple sounds
- ✅ Trigger an animation via `AnimationPlayer`
- ✅ Load another scene
- ✅ One-time or repeatable triggers
- ✅ Fully customizable hitbox using `CollisionShape2D`
- ✅ Hover, hold, drag, snap, sliders, and radial knob interactions
- ✅ All nodes emit signals for easy scripting

---

## 🧩 How to Use

### 1. Enable the Plugin

- Go to **Project → Project Settings → Plugins**
- Enable `PointMaker`

### 2. Add a PointMaker Node

- In the scene tree, click the "+" button to add a new node.
- Search for any of the following custom nodes:
  - `PointTrigger`
  - `PointHover`
  - `PointHold`
  - `PointDrag`
  - `PointSnap`
  - `PointRadial`
  - `PointSliderH`
  - `PointSliderV`

### 3. Add a `CollisionShape2D`

> This is **required** for most nodes to detect collisions or mouse input.

- Right-click your PointMaker node → Add Child Node → `CollisionShape2D` (or `CollisionPolygon2D`)
- Set its `shape` (e.g., `RectangleShape2D`, `CircleShape2D`)
- Resize as needed to define the interactive area

### 4. Configure the Node in the Inspector

Each node exposes properties in the Inspector for customizing its behavior. Common options include:

- **Sounds**: Add one or more `AudioStream` files
- **Animation Player**: Provide a node path to the `AnimationPlayer` to trigger
- **Animation Name**: Name of the animation to play
- **Scene to Load**: Optional `.tscn` path to change scenes when triggered
- **Trigger Once**: Enable if you only want the trigger to fire a single time
- **Drag/Snap/Slider/Knob Options**: See below for node-specific properties

---

## 🧑‍💻 Node Reference

### `PointTrigger`
- Triggers sounds, animations, or scene changes on body enter or mouse click.

### `PointHover`
- Triggers sounds/animations when the mouse hovers over the area.

### `PointHold`
- Triggers after holding the mouse button for a set duration.

### `PointDrag`
- Draggable object with optional gravity and signals for drag events.

### `PointSnap`
- Snap a `PointDrag` node into place, with optional alignment and feedback.

### `PointRadial`
- Rotatable knob for value selection.

### `PointSliderH` / `PointSliderV`
- Horizontal/vertical sliders along a `Path2D`.

---

## 🧪 Example Use Cases

- Play a sound and open a door when the player enters a zone
- Trigger an NPC animation when the mouse hovers over a shape
- Hold a button to activate a lever
- Drag and snap objects into place for puzzles
- Create custom sliders and knobs for UI or gameplay
- Automatically load a new level when reaching the end of a stage

---

## ⚠️ Notes

- Always add a `CollisionShape2D` or `CollisionPolygon2D` for interaction.
- For mouse input, ensure `input_pickable` is enabled (default).
- Signals are available for all nodes for custom scripting.
- `PointTrigger` works best when the object entering it is in the `"player"` group.

---

## 📜 License

This addon is licensed under the **MIT License**. You are free to use, modify, and distribute it with attribution.
