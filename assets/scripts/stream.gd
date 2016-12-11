extends StreamPlayer

var welcomeDone = false

func _ready():
	set_process(true)
   
func _process(delta):
	if(self.is_playing() != true):
		if (!welcomeDone):
			welcomeDone = true
			self.set_stream(load("res://assets/music/bg.ogg"))
			self.play()
			self.set_volume_db(-10)
		else:
			get_node("/root/main").set_meta("done", true)