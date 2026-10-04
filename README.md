# Godot Rounded Corners TextureRect

A lightweight, optimized GDScript utility for **Godot 4.x** that allows you to dynamically round the individual corners of any `TextureRect` node directly at runtime. 

Unlike heavy shader solutions, this tool manipulates the image pixels directly with high-performance math optimizations.

## ✨ Features

- **Individual Corner Control:** Independently adjust the radius for all four corners (Top-Left, Top-Right, Bottom-Left, Bottom-Right) using simple inspector sliders.
- **Highly Optimized Math:** Uses **Squared Pythagorean Distance** calculation instead of `sqrt()` to eliminate CPU performance bottlenecks and avoid access delays during pixel processing.
- **Format Safe:** Automatically converts textures to `RGBA8` format to guarantee seamless alpha/transparency support.
- **Dynamic Resizing Support:** Includes an optional `_on_resized()` hook to automatically re-calculate corner clipping if the texture bounds change.

---

## 📐 How the Code Works (Math & Logic Explained)

To avoid looping through the entire image, the code only checks the small square bounding box defined by the `radius` at each of the 4 corners. 

For every pixel `(px, py)` inside that box, the script calculates its offset distance from the **Center of the Corner Circle** to decide whether to keep the pixel or make it transparent.

### 🔹 The Pythagorean Distance Concept (فيثاغورس المسافة)

To find out if a pixel is inside or outside the rounding arc, we use the standard **Pythagorean Theorem** (\(a^2 + b^2 = c^2\)). 

Here is a visual breakdown of how the script analyzes a single corner (e.g., Top-Left):

```text
(0,0) Corner Origin
  +---------------------------------------+

  | . . . . . . * * * *                   |  <- Transparent Pixels (dist_sq > radius^2)
  | . . . . . *                           |
  | . . . .  /|                           |
  | . . .   / |                           |
  | . .    /  | dy                        |
  | . .   /   |                           |
  | . .  /    |                           |
  | . . /     |                           |
  | .  /      |                           |
  | . /   dx  |                           |
  |  *--------P (px, py)                  |  <- Current Pixel being checked
  |  :                                    |
  |  :                                    |
  |  Center (radius, radius)              |  <- The imaginary circle center
  +---------------------------------------+

     |<------- radius ------->|
```

### 🔹 Step-by-Step Logic:
1. **Find Offsets (`dx`, `dy`):** The script measures the horizontal distance (`dx`) and vertical distance (`dy`) from the pixel `P` to the imaginary center of the circle (`radius, radius`).
2. **Apply Pythagorean Theorem:** 
   \[\text{Actual Distance (d)} = \sqrt{dx^2 + dy^2}\]
3. **The Optimization Secret (No Square Root!):** 
   Calculating a square root (`sqrt()`) is very heavy on the CPU, especially inside nested loops. To make it extremely fast, the code **squares both sides** of the comparison:
   * Instead of checking: \(\sqrt{dx^2 + dy^2} > \text{radius}\)
   * The code checks: \(dx^2 + dy^2 > \text{radius}^2\) (`dist_sq > radius * radius`)
4. **Transparency:** If the squared distance is greater than the squared radius, the pixel is determined to be outside the arc, and its alpha value is instantly killed (`color.a = 0.0`) to make it transparent!

---

## 🛠️ Installation & Usage

1. Copy the script or attach it directly to any **TextureRect** node in your scene.
2. In the Godot Inspector, you will see a new category named `round image corner`.
3. Adjust the radius sliders (`leftTop`, `rightTop`, `leftBottom`, `rightBottom`) from `0` to `500` pixels according to your design needs.
4. Make sure your `TextureRect` has a valid texture assigned!

```gdscript
# Quick Snippet Example
extends TextureRect

# The script automatically runs on _ready()
# If you resize the node dynamically, connect the item_rect_changed signal to _on_resized()
```

## 📄 License

This project is open-source and distributed under **The Unlicense**. You are completely free to use, modify, publish, or monetize this code in any personal or commercial game project without any restrictions.

---
*Note: Core algorithm optimized with the assistance of [DeepAI Tools](https://deepai.org).*
