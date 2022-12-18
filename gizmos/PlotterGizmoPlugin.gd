extends EditorNode3DGizmoPlugin

const METHOD_NAME = "_debug_draw"
const Plotter = preload("./Plotter.gd")

var plotter: Plotter


func _init():
	create_material("main", Color(1, 1, 1), false, true, true)
	create_material("billboard", Color(1, 1, 1), true, false, true)
	plotter = Plotter.new()


func _get_gizmo_name():
	return "RechutoX.DebugDraw"


func _has_gizmo(for_node_3d):
	return for_node_3d.has_method(METHOD_NAME)


func _redraw(gizmo):
	var node: Node3D = gizmo.get_node_3d()
	plotter._clear(gizmo)
	node.call(METHOD_NAME, plotter)
	plotter._plot(gizmo, get_material("main", gizmo), get_material("billboard", gizmo))
