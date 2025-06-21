# PointMaker GD
A Godot port of PointMaker by Splite.

---

## 🚀 Features

- ✅ Trigger multiple sounds
- ✅ Trigger an animation via `AnimationPlayer`
- ✅ Load another scene
- ✅ One-time or repeatable triggers
- ✅ Fully customizable hitbox using `CollisionShape2D`

---

## 🧩 How to Use

### 1. Enable the Plugin
- Go to **Project → Project Settings → Plugins**
- Enable `PointMaker`

### 2. Add `PointTrigger` to Your Scene
- Create a `PointTrigger` node in your 2D scene.
- It extends `Area2D`, so it supports physics and input detection.

### 3. Add a `CollisionShape2D`
> This is **required** for the trigger to detect collisions or mouse input.
- Right-click `PointTrigger` → Add Child Node → `CollisionShape2D`
- Set its `shape` (e.g., `RectangleShape2D`, `CircleShape2D`)
- Resize as needed to define the trigger area.

### 4. Configure the Trigger in the Inspector
- **Sounds**: Add one or more `AudioStream` files
- **Animation Player**: Provide a node path to the `AnimationPlayer` to trigger
- **Animation Name**: Name of the animation to play
- **Scene to Load**: Optional `.tscn` path to change scenes when triggered
- **Trigger Once**: Enable if you only want the trigger to fire a single time

---

## 🧪 Example Use Cases

- Play a sound and open a door when the player enters a zone
- Trigger an NPC animation when the mouse hovers over a shape
- Automatically load a new level when reaching the end of a stage

---

## ⚠️ Notes

- `PointTrigger` works best when the object entering it is in the `"player"` group.
- If you're using it for mouse input, make sure to also check `"Input Pickable"` or use mouse event signals on the `PointTrigger`.

---

## 📜 License

This addon is licensed under the **MIT License**. You are free to use, modify, and distribute it with attribution.
