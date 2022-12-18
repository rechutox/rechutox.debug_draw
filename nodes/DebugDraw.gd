@tool
extends Control

#---------------------------------------------------------------------------------------------------
# main API
#---------------------------------------------------------------------------------------------------

# this function allows you to put several draw_* calls inside.
# for example:
# ```$DebugDraw.queue_draw(func(dd): dd.draw_line(...) ...)```
func queue_draw(callback) -> void:
	if Engine.is_editor_hint() or not OS.is_debug_build(): return
	draw.connect(func(): callback.call(self), CONNECT_ONE_SHOT)

#---------------------------------------------------------------------------------------------------
# draw_* variants to call inside draw or queue_draw
#---------------------------------------------------------------------------------------------------

func draw_line_3d(p0: Vector3, p1: Vector3, color:= Color.WHITE, width:= 1.0) -> void:
	var camera:= get_viewport().get_camera_3d()
	var pa:= camera.unproject_position(p0)
	var pb:= camera.unproject_position(p1)
	draw_line(pa, pb, color, width, false)


func draw_vector_3d(origin: Vector3, direction: Vector3, color:= Color.WHITE, width:= 5.0) -> void:
	if direction.length_squared() == 0: return
	var camera = get_viewport().get_camera_3d()
	var pa:= camera.unproject_position(origin)
	var pb:= camera.unproject_position(origin + direction)
	var fwd:= pa.direction_to(pb)
	var up:= fwd.rotated(PI*0.5)
	var p0:= pa + (up * width * 0.5)
	var p1:= pa - (up * width * 0.5)
	draw_polygon([p0,p1,pb], [color,color,color])
	draw_line(pa, pb, color, 1.0, false) # FIX: tip sometimes disappear if line too thin


func draw_point_3d(center: Vector3, color:= Color.WHITE, size:= 5.0, fill:= true, shape:= "circle") -> void:
	var p:= get_viewport().get_camera_3d().unproject_position(center)
	match shape:
		"circle":
			if fill:
				draw_circle(p, size*0.5, color)
			else:
				draw_arc(p, size*0.5, 0, 2*PI, 17, color, 1.0, false)
		"square":
			var s:= Vector2(size, size)
			draw_rect(Rect2(p - s*0.5, s), color, fill, 1.0)
		"triangle":
			var s:= size * 0.5
			var up:= Vector2.UP
			var a:= PI * (2.0/3.0)
			var p0:= p + up * s
			var p1:= p + up.rotated(a) * s
			var p2:= p + up.rotated(2*a) * s
			if fill:
				draw_polygon([p0,p1,p2], [color,color,color])
			else:
				draw_polyline([p0,p1,p2,p0], color, 1.0, false)
		"diamond":
			var s:= size * 0.5
			var p0:= p + Vector2.UP * s
			var p1:= p + Vector2.RIGHT * s
			var p2:= p + Vector2.DOWN * s
			var p3:= p + Vector2.LEFT * s
			if fill:
				draw_polygon([p0,p1,p2,p3], [color,color,color,color])
			else:
				draw_polyline([p0,p1,p2,p3,p0], color, 1.0, false)


func draw_circle_3d(center: Vector3, normal: Vector3, radius: float, color:= Color.WHITE, fill:= true) -> void:
	var camera:= get_viewport().get_camera_3d()
	var p0:= camera.unproject_position(center)
	var right:= Vector3.RIGHT if abs(normal.dot(Vector3.UP)) == 1 else Vector3.UP
	var fwd:= right.cross(normal)
	var resolution:= 32
	var angle_step:= (2*PI) / resolution
	var points:= PackedVector2Array()
	var colors:= PackedColorArray()
	for i in resolution:
		var p:= center + fwd.rotated(normal, i * angle_step) * radius
		points.push_back(camera.unproject_position(p))
		colors.push_back(color)
	if fill:
		draw_polygon(points, colors)
	else:
		points.push_back(points[0])
		draw_polyline(points, color, 1.0, false)


func draw_plane_3d(center: Vector3, normal: Vector3, right: Vector3, size: float, color:= Color.WHITE, fill:= true) -> void:
	var camera:= get_viewport().get_camera_3d()
	var fwd:= right.cross(normal)
	var points:= PackedVector2Array()
	var s:= size * 0.5
	points.push_back(camera.unproject_position(center + (fwd - right) * s))
	points.push_back(camera.unproject_position(center + (fwd + right) * s))
	points.push_back(camera.unproject_position(center - (fwd - right) * s))
	points.push_back(camera.unproject_position(center - (fwd + right) * s))
	if fill:
		draw_polygon(points, [color,color,color,color])
	else:
		points.push_back(points[0])
		draw_polyline(points, color, 1.0, false)


func draw_coil_3d(pa: Vector3, pb: Vector3, width: float, rounds: int, line_width:= 4.0, color:= Color.WHITE) -> void:
	var camera:= get_viewport().get_camera_3d()
	var p0:= camera.unproject_position(pa)
	var p1:= camera.unproject_position(pb)
	var dir:= p0.direction_to(p1)
	var length:= p0.distance_to(p1)
	var right:= dir.rotated(PI*0.5)
	var points:= PackedVector2Array()
	var w:= width * 0.5
	rounds += 4
	var step:= length / rounds
	var last_point: Vector2
	for i in rounds:
		var d:= 1 if i % 2 == 0 else -1
		if i == 0 or i == 1: d = 0
		if i == rounds - 2 or i == rounds - 1: d = 0
		if i > 1:
			points.push_back(last_point)
		last_point = p0 + (dir * (i * step)) + (right * w * d)
		points.push_back(last_point)
#	points.push_back(points[0])
	draw_multiline(points, color, line_width)

#---------------------------------------------------------------------------------------------------
# x_* variants to call them in one line outside a draw method
# this may cause some z-sorting artifacts between drawings since the call order is not preserved
#---------------------------------------------------------------------------------------------------

func x_draw_line_3d(p0: Vector3, p1: Vector3, color:= Color.WHITE, width:= 1.0) -> void:
	queue_draw(func(_dd): draw_line_3d(p0, p1, color, width))


func x_draw_vector_3d(origin: Vector3, direction: Vector3, color:= Color.WHITE, width:= 5.0) -> void:
	queue_draw(func(_dd): draw_vector_3d(origin, direction, color, width))


func x_draw_point_3d(origin: Vector3, color:= Color.WHITE, size:= 5.0, fill:=true, shape:= "circle") -> void:
	queue_draw(func(_dd): draw_point_3d(origin, color, size, fill, shape))


func x_draw_circle_3d(center: Vector3, normal: Vector3, radius: float, color:= Color.WHITE, fill:= true) -> void:
	queue_draw(func(_dd): draw_circle_3d(center, normal, radius, color, fill))


func x_draw_plane_3d(center: Vector3, normal: Vector3, right: Vector3, size: float, color:= Color.WHITE, fill:= true) -> void:
	queue_draw(func(_dd): draw_plane_3d(center, normal, right, size, color, fill))


func x_draw_coil_3d(pa: Vector3, pb: Vector3, width: float, rounds: int, line_width:= 4.0, color:= Color.WHITE) -> void:
	queue_draw(func(_dd): draw_coil_3d(pa, pb, width, rounds, line_width, color))

#---------------------------------------------------------------------------------------------------
# INTERNAL
#---------------------------------------------------------------------------------------------------

func _enter_tree():
	if not OS.is_debug_build():
		set_process(false)
	else:
		set_anchors_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta):
	if Engine.is_editor_hint(): return
	queue_redraw()
