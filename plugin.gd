@tool
extends EditorPlugin

const GizmoPlugin = preload("./gizmos/PlotterGizmoPlugin.gd")
const DebugDraw = preload("./nodes/DebugDraw.gd")
const DebugDrawIcon = preload("./assets/debug_draw_icon.svg")

var gizmo_plugin: GizmoPlugin


func _enter_tree():
	gizmo_plugin = GizmoPlugin.new()
	add_node_3d_gizmo_plugin(gizmo_plugin)
	add_custom_type("DebugDraw", "Control", DebugDraw, DebugDrawIcon)


func _exit_tree():
	remove_node_3d_gizmo_plugin(gizmo_plugin)
	remove_custom_type("DebugDraw")
