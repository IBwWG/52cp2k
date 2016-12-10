
extends RigidBody

# Member variables
var green_mat = FixedMaterial.new()
var selected = false


func _input_event(camera, event, pos, normal, shape):
	if (event.type==InputEvent.MOUSE_BUTTON and event.pressed):
		if (not selected):
			green_mat.set_parameter(green_mat.PARAM_DIFFUSE, Color(0, 1, 0, 1))
			get_node("mesh").set_material_override(green_mat)
		else:
			get_node("mesh").set_material_override(null)
		
		selected = not selected


func _mouse_enter():
	get_node("mesh").set_scale(Vector3(1.1, 2.1, 1.1))


func _mouse_exit():
	get_node("mesh").set_scale(Vector3(1, 1, 1))
