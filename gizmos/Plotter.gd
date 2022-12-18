extends Object

const font = preload("../assets/Inconsolata-Regular.ttf")


class Plottable:
	var is_billboard: bool = false
	func get_mesh() -> Mesh: return null
	func get_transform() -> Transform3D: return Transform3D()


class Point extends Plottable:
	const POINT_RESOLUTION: int = 32
	var origin: Vector3
	var radius: float
	var color: Color
	var fill: bool
	var type: String

	func _init(origin: Vector3, color:= Color.WHITE, radius:= 0.025, fill:= true, type:= "circle"):
		super()
		is_billboard = true
		self.origin = origin
		self.radius = radius
		self.color = color
		self.fill = fill
		self.type = type

	func get_transform() -> Transform3D:
		return Transform3D(Basis.IDENTITY, origin)

	func get_mesh() -> Mesh:
		match type.to_lower():
			"circle": return _circle()
			"square": return _square()
			"triangle": return _triangle()
			"diamond": return _diamond()
			_: printerr("Unsupported point type: ", type)
		return null

	func _circle() -> void:
		var origin = Vector3.ZERO
		var im:= ImmediateMesh.new()
		var step = 2.0 * PI / POINT_RESOLUTION
		if fill:
			im.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
			im.surface_set_color(color)
			for i in POINT_RESOLUTION:
				im.surface_add_vertex(origin)
				im.surface_add_vertex(origin + Vector3.UP.rotated(Vector3.FORWARD, i * step) * radius)
				im.surface_add_vertex(origin + Vector3.UP.rotated(Vector3.FORWARD, (i+1) * step) * radius)
		else:
			im.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
			im.surface_set_color(color)
			for i in POINT_RESOLUTION+1:
				im.surface_add_vertex(origin + Vector3.UP.rotated(Vector3.FORWARD, i * step) * radius)
		im.surface_end()
		return im

	func _square() -> void:
		var origin = Vector3.ZERO
		var im:= ImmediateMesh.new()
		var r := radius
		if fill:
			im.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
			im.surface_set_color(color)
			im.surface_add_vertex(origin)
			im.surface_add_vertex(origin + (Vector3.UP + Vector3.LEFT) * r)
			im.surface_add_vertex(origin + (Vector3.UP + Vector3.RIGHT) * r)
			im.surface_add_vertex(origin)
			im.surface_add_vertex(origin + (Vector3.DOWN + Vector3.LEFT) * r)
			im.surface_add_vertex(origin + (Vector3.DOWN + Vector3.RIGHT) * r)
			im.surface_add_vertex(origin)
			im.surface_add_vertex(origin + Vector3.RIGHT * r + Vector3.UP * r)
			im.surface_add_vertex(origin + Vector3.RIGHT * r + Vector3.DOWN * r)
			im.surface_add_vertex(origin)
			im.surface_add_vertex(origin + Vector3.LEFT * r + Vector3.DOWN * r)
			im.surface_add_vertex(origin + Vector3.LEFT * r + Vector3.UP * r)
		else:
			im.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
			im.surface_set_color(color)
			im.surface_add_vertex(origin + (Vector3.UP + Vector3.LEFT) * r)
			im.surface_add_vertex(origin + (Vector3.UP + Vector3.RIGHT) * r)
			im.surface_add_vertex(origin + (Vector3.DOWN + Vector3.RIGHT) * r)
			im.surface_add_vertex(origin + (Vector3.DOWN + Vector3.LEFT) * r)
			im.surface_add_vertex(origin + (Vector3.UP + Vector3.LEFT) * r)
		im.surface_end()
		return im

	func _triangle() -> void:
		var origin = Vector3.ZERO
		var im:= ImmediateMesh.new()
		var step = 2.0 * PI / 3
		if fill:
			im.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
			im.surface_set_color(color)
			im.surface_add_vertex(origin + Vector3.UP * radius)
			im.surface_add_vertex(origin + Vector3.UP.rotated(Vector3.FORWARD, step) * radius)
			im.surface_add_vertex(origin + Vector3.UP.rotated(Vector3.FORWARD, 2 * step) * radius)
		else:
			im.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
			im.surface_set_color(color)
			im.surface_add_vertex(origin + Vector3.UP * radius)
			im.surface_add_vertex(origin + Vector3.UP.rotated(Vector3.FORWARD, step) * radius)
			im.surface_add_vertex(origin + Vector3.UP.rotated(Vector3.FORWARD, 2 * step) * radius)
			im.surface_add_vertex(origin + Vector3.UP * radius)
		im.surface_end()
		return im

	func _diamond() -> void:
		var origin = Vector3.ZERO
		var im:= ImmediateMesh.new()
		if fill:
			im.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
			im.surface_set_color(color)
			im.surface_add_vertex(origin)
			im.surface_add_vertex(origin + Vector3.UP * radius)
			im.surface_add_vertex(origin + Vector3.RIGHT * radius)
			im.surface_add_vertex(origin)
			im.surface_add_vertex(origin + Vector3.RIGHT * radius)
			im.surface_add_vertex(origin + Vector3.DOWN * radius)
			im.surface_add_vertex(origin)
			im.surface_add_vertex(origin + Vector3.DOWN * radius)
			im.surface_add_vertex(origin + Vector3.LEFT * radius)
			im.surface_add_vertex(origin)
			im.surface_add_vertex(origin + Vector3.LEFT * radius)
			im.surface_add_vertex(origin + Vector3.UP * radius)
		else:
			im.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
			im.surface_set_color(color)
			im.surface_add_vertex(origin + Vector3.UP * radius)
			im.surface_add_vertex(origin + Vector3.RIGHT * radius)
			im.surface_add_vertex(origin + Vector3.DOWN * radius)
			im.surface_add_vertex(origin + Vector3.LEFT * radius)
			im.surface_add_vertex(origin + Vector3.UP * radius)
		im.surface_end()
		return im


class Line extends Plottable:
	var p0: Vector3
	var p1: Vector3
	var color: Color

	func _init(p0: Vector3, p1: Vector3, color:= Color.WHITE):
		super()
		self.p0 = p0
		self.p1 = p1
		self.color = color

	func get_mesh() -> Mesh:
		var im := ImmediateMesh.new()
		im.surface_begin(Mesh.PRIMITIVE_LINES)
		im.surface_set_color(color)
		im.surface_add_vertex(p0)
		im.surface_add_vertex(p1)
		im.surface_end()
		return im


class Vector extends Plottable:
	const ARROW_BASE: float = 0.02
	const ARROW_LENGTH: float = 0.05
	const ARROW_TIP_RESOLUTION: int = 8
	var origin: Vector3
	var direction: Vector3
	var color: Color
	var arrow_scale: float

	func _init(origin: Vector3, direction: Vector3, color:= Color.WHITE, arrow_scale:= 1.0):
		super()
		self.origin = origin
		self.direction = direction
		self.color = color
		self.arrow_scale = arrow_scale

	func get_mesh() -> Mesh:
		if direction.length_squared() == 0:
			direction = Vector3.ONE * 0.0001

		var p0 = origin
		var p1 = origin + direction
		var forward = direction.normalized()

		var up = Vector3.UP if abs(forward.dot(Vector3.UP)) != 1 else Vector3.RIGHT
		var right = up.cross(forward)
		up = forward.cross(right)

		var im := ImmediateMesh.new()

		# main line
		im.surface_begin(Mesh.PRIMITIVE_LINES)
		im.surface_set_color(color)
		im.surface_add_vertex(origin)
		im.surface_add_vertex(p1)

		# arrow
		var pb = p1 - forward * ARROW_LENGTH * arrow_scale
		var step = (2.0*PI) / float(ARROW_TIP_RESOLUTION)
		var pl: Vector3
		for i in ARROW_TIP_RESOLUTION:
			var pbt = pb + up.rotated(forward, i * step) * ARROW_BASE * arrow_scale
			im.surface_add_vertex(pb)
			im.surface_add_vertex(pbt)
			im.surface_add_vertex(pbt)
			im.surface_add_vertex(p1)
			if i > 0:
				im.surface_add_vertex(pl)
				im.surface_add_vertex(pbt)
			pl = pbt
		im.surface_add_vertex(pb + up * ARROW_BASE * arrow_scale)
		im.surface_add_vertex(pl)
		im.surface_end()
		return im


class Disk extends Plottable:
	const RESOLUTION: int = 64
	var origin: Vector3
	var normal: Vector3
	var forward: Vector3
	var radius: float
	var inner_radius: float
	var angle_start: float
	var angle_end: float
	var color: Color
	var fill: bool

	func _init(origin: Vector3, normal: Vector3, radius: float, color:= Color.WHITE, fill:= true,
		inner_radius:= 0.0, forward:= Vector3.ZERO, angle_start:= 0.0, angle_end:= 2*PI):
		super()
		self.origin = origin
		self.normal = normal
		self.radius = radius
		self.color = color
		self.fill = fill
		self.inner_radius = inner_radius
		self.forward = forward
		self.angle_start = angle_start
		self.angle_end = angle_end

	func get_mesh() -> Mesh:
		var im:= ImmediateMesh.new()
		var span: float = clamp(angle_end - angle_start, -2*PI, 2*PI)
		var resolution: float = max(1.0, round((abs(span) / (2.0 * PI)) * RESOLUTION))
		var step:= span / resolution
		var n:= -normal

		var fwd: Vector3
		if forward == Vector3.ZERO:
			var up:= Vector3.RIGHT if abs(normal.normalized().dot(Vector3.UP)) == 1 else Vector3.UP
			fwd = up.cross(normal)
		else:
			fwd = forward

		if fill:
			im.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
			im.surface_set_color(color)
			if inner_radius == 0:
				for i in resolution:
					var d0 = fwd.rotated(n, angle_start + i * step) * radius
					var d1 = fwd.rotated(n, angle_start + (i+1) * step) * radius
					im.surface_add_vertex(origin)
					im.surface_add_vertex(origin + d0)
					im.surface_add_vertex(origin + d1)
			else:
				for i in resolution:
					var d0 = fwd.rotated(n, angle_start + i * step)
					var d1 = fwd.rotated(n, angle_start + (i+1) * step)
					var p0 = d0 * inner_radius
					var p1 = d0 * radius
					var p2 = d1 * inner_radius
					var p3 = d1 * radius
					im.surface_add_vertex(p0)
					im.surface_add_vertex(p1)
					im.surface_add_vertex(p2)
					im.surface_add_vertex(p2)
					im.surface_add_vertex(p1)
					im.surface_add_vertex(p3)
		else:
			if inner_radius == 0:
				im.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
				im.surface_set_color(color)
				im.surface_add_vertex(origin)
				for i in resolution + 1:
					im.surface_add_vertex(origin + fwd.rotated(n, angle_start + i * step) * radius)
				im.surface_add_vertex(origin)
			else:
				im.surface_begin(Mesh.PRIMITIVE_LINES)
				im.surface_set_color(color)
				for i in resolution:
					var d0 = fwd.rotated(n, angle_start + i * step)
					var d1 = fwd.rotated(n, angle_start + (i+1) * step)
					var p0 = d0 * inner_radius
					var p1 = d0 * radius
					var p2 = d1 * inner_radius
					var p3 = d1 * radius
					if i == 0:
						im.surface_add_vertex(p0)
						im.surface_add_vertex(p1)
					if i == resolution - 1:
						im.surface_add_vertex(p2)
						im.surface_add_vertex(p3)
					im.surface_add_vertex(p1)
					im.surface_add_vertex(p3)
					im.surface_add_vertex(p0)
					im.surface_add_vertex(p2)
				pass

		im.surface_end()
		return im


class Text extends  Plottable:
	var text: String
	var position: Vector3
	var size: float
	var color: Color

	func _init(text: String, position: Vector3, size:= 0.05, color:= Color.WHITE):
		is_billboard = true
		self.text = text
		self.position = position
		self.size = size
		self.color = color

	func get_transform() -> Transform3D:
		return Transform3D(Basis.IDENTITY, position)

	func get_mesh() -> Mesh:
		var m:= TextMesh.new()
		m.text = text
		m.pixel_size = size / 10.0 # magic number to adjust to text height
		m.depth = 0
		m.font = font
		return m


var _plottables: Array = []

# draws a point
func draw_point(origin: Vector3, color:= Color.WHITE, radius:= 0.025, fill:= true, type:= "circle") -> void:
	_plottables.push_back(Point.new(origin, color, radius, fill, type))

# draws a 3d line from p0 to p1
func draw_line(p0: Vector3, p1: Vector3) -> void:
	_plottables.push_back(Line.new(p0, p1))

# draws a 3d vector
func draw_vector(origin: Vector3, direction: Vector3, color:= Color.WHITE, arrow_scale:= 1.0) -> void:
	_plottables.push_back(Vector.new(origin, direction, color, arrow_scale))

# draws a 3d disk
func draw_disk(origin: Vector3, normal: Vector3, radius: float, color:= Color.WHITE, fill:= true,
	inner_radius:= 0.0, forward:= Vector3.ZERO, angle_start:= 0.0, angle_end:= 2*PI) -> void:
	_plottables.push_back(Disk.new(origin, normal, radius, color, fill, inner_radius, forward, angle_start, angle_end))

# draws a billboard text
func draw_text(text: String, position: Vector3, size:= 0.05, color:= Color.WHITE) -> void:
	_plottables.push_back(Text.new(text, position, size, color))

# clear all drawings
func _clear(gizmo: EditorNode3DGizmo):
	gizmo.clear()
	_plottables = []

var billmat: StandardMaterial3D

# called by the plugin to plot the gizmo
func _plot(gizmo: EditorNode3DGizmo, material: Material, material_billboard: Material):
	for plottable in _plottables:
		var transform: Transform3D = plottable.get_transform()
		var mesh: Mesh = plottable.get_mesh()
		gizmo.add_mesh(mesh, material_billboard if plottable.is_billboard else material, transform)
