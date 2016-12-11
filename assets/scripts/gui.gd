extends Control

func _ready():
	set_process_input(true);

func _input(ie):
	if ie.type == InputEvent.KEY:
		if ie.pressed:
			if ie.scancode == KEY_ESCAPE:
				if get_node("/root/main").has_meta("done"):
					get_tree().call_deferred("quit");
				else:
					get_node("/root/main").set_meta("done", true)