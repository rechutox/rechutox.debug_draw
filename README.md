# Godot 4 DebugDraw Addon

This plugin allows to draw points, lines, vectors and more directly in the editor and provides a custom node that helps drawing this stuff in-game too!

## Installation

Clone or copy this folder into your project "addons" folder and enable the plugin in your project settings.

## How to use

### Drawing in-editor

The plugin allows any **Node3D** to draw on the editor. Your `@tool` script has to implement the method: `_debug_draw(plotter)`  and you are ready to go in a similar way you could do it in Unity with `_on_draw_gizmos`.

The drawing needs to be updated calling `update_gizmos()` that is better if you do it from a setter or a signal since doing it in `_process()` may slow down the editor. For example:
```
@tool
extends Node3D

@export var custom_value: float = 1.0:
	set(value):
		custom_value = value
		update_gizmos()

func _debug_draw(plotter):
	var p0:= global_position
	var p1:= p0 + Vector3.UP * custom_value
	plotter.draw_line(p0, p1)

```
The plotter object implements the following methods:

```
# draws a point centerd on origin.
# the type parameter can be: circle, square, diamond and triangle.
func draw_point(origin: Vector3, color:= Color.WHITE, radius:= 0.025, fill:= true, type:= "circle") -> void

# draws a line from p0 to p1
func draw_line(p0: Vector3, p1: Vector3) -> void

# draws an arrow centered on origin oriented to direction.
# arrow_size controls the size of the tip.
func draw_vector(origin: Vector3, direction: Vector3, color:= Color.WHITE, arrow_scale:= 1.0) -> void

# draws a circle|disk|arc.
func draw_disk(origin: Vector3, normal: Vector3, radius: float, color:= Color.WHITE, fill:= true, inner_radius:= 0.0, forward:= Vector3.ZERO, angle_start:= 0.0, angle_end:= 2*PI) -> void

# draws a billboarded text. size is about the text height in godot units.
func draw_text(text: String, position: Vector3, size:= 0.05, color:= Color.WHITE) -> void
```
### Drawing in-game

The plugin adds a new node: `DebugDraw` that extends from `Control`, so you just need to add it to your node and draw from there. The node has helpers that allows to draw from anywhere in your script, with the `CanvasItem` `draw_*` calls and implements some 3D variants to them to deal with vectors, planes and 3D points. The node won't draw or do anything at all in release builds, but for the sake of performance, it would be better if you remove it if you don't need it anymore.

The `queue_draw(fn: Callable)` method accepts a function that can batch your draw calls. You can call it several times if you need to.

```
func _process(delta):
	var t = sin(Time.get_unix_time_from_system())
	var DD = $DebugDraw
	DD.queue_draw(func(_d):
		DD.draw_line_3d(global_position, global_position + Vector3.FORWARD * 3 * t, Color.PINK, 1)
		DD.draw_vector_3d(global_position, Vector3.RIGHT * 3 * t, Color.GREEN_YELLOW, 5)
		DD.draw_point_3d(global_position, Color.RED, 50, false, "square")
		DD.draw_point_3d(global_position, Color.YELLOW, 50, false, "circle")
		DD.draw_point_3d(global_position, Color.ORCHID, 50, false, "triangle")
		DD.draw_point_3d(global_position, Color.RED, 50, false, "diamond")
		DD.draw_plane_3d(global_position, Vector3.UP, Vector3.RIGHT, 4, Color.YELLOW, true)
		DD.draw_circle_3d(global_position, Vector3.UP, 2, Color.html("ff000077"))
		DD.draw_coil_3d(global_position, Vector3.UP * (2 + (t*1)), 100, 7, 5, Color.PALE_VIOLET_RED)
	)
```

The node also implements `x_draw_*_3d` method variants so you can draw things in a single line. Please note that this doesn't preserve calling order, so z-ordering artifacts may appear.

```
func _process(delta):
	...
	$DebugDraw.x_draw_line_3d(p0, p1, Color.RED, 1.0)
	...
```

Since the node extends from `CanvasItem`, you can use it's API to draw things with it. The 3D extensions helpers are as follows:
```
func x_draw_line_3d(p0: Vector3, p1: Vector3, color:= Color.WHITE, width:= 1.0) -> void

func x_draw_vector_3d(origin: Vector3, direction: Vector3, color:= Color.WHITE, width:= 5.0) -> void

func x_draw_point_3d(origin: Vector3, color:= Color.WHITE, size:= 5.0, fill:=true, shape:= "circle") -> void

func x_draw_circle_3d(center: Vector3, normal: Vector3, radius: float, color:= Color.WHITE, fill:= true) -> void

func x_draw_plane_3d(center: Vector3, normal: Vector3, right: Vector3, size: float, color:= Color.WHITE, fill:= true) -> void

# draws a coil-like, zigzagging thing, for people that like using springs
func x_draw_coil_3d(pa: Vector3, pb: Vector3, width: float, rounds: int, line_width:= 4.0, color:= Color.WHITE) -> void:
```

## What it doesn't do

This plugin, unlike Unity `_on_draw_gizmos()`, cannot add any interaction via handles, it just for drawing things. If you need handles in your node, you surely better make a custom gizmo plugin for it... or wait until I create a plugin for it.
