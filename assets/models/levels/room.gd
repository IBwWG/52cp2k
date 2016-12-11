extends Spatial

var backMaterial = FixedMaterial.new()
var frontNormal = Vector3(0, 0, 1)
var backNormal = frontNormal * -1

func _ready():
	var tex = ImageTexture.new()
	tex.load("res://assets/textures/cards/back.png")
	backMaterial.set_texture(0, tex)
	#The initial seed
	#rand_seed(42)
	randomize()
	set_fixed_process(true)
	var suits = ["Clubs","Spades","Hearts","Diamonds"]
	var faces = ["A", "K", "Q", "J"]
	for i in range(9):
		faces.push_back(str(10-i))
	for i in range(4):
		for j in range(13):
			addCard(-7 + rand_range(0,14),2.5,-7 + rand_range(0,14), 0.2, faces[j] + " of " + suits[i], (j*4)+i+1)
	print("save46")

#func _integrate_forces(state):
#	for node in get_children():
#		if (node.has_meta("is_card")):
# paper falling physics here...

func addCard(x, y, z, scale, name, fileNumber):
	# new container node for the card
	var node = RigidBody.new()
	node.set_name(name)
#	node.set_gravity_scale(0.1)
	node.set_meta("is_card", true)
	add_child(node)
	
	# add card face to the node
	var tex = ImageTexture.new()
	tex.load("res://assets/textures/cards/" + str(fileNumber) + ".png")
	var material = FixedMaterial.new()
	material.set_texture(0, tex)
	var surface = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_material(material)
	var mesh = MeshInstance.new()
	surface.add_normal(frontNormal)
	var corners = Vector3Array([Vector3(0,1,0), Vector3(1,1,0), Vector3(1,0,0), Vector3(0,0,0)])
	var ratio = Vector3(1.5, 2.1, 0) * scale
#	for c in range(corners.size()):
#		corners[c] -= ratio
	add_quad(surface, corners, ratio)
	mesh.set_mesh(surface.commit())
	node.add_child(mesh)
	
	# add backing to the node
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_material(backMaterial)
	var backMesh = MeshInstance.new()
	surface.add_normal(backNormal)
	add_quad(surface,[corners[1],corners[0],corners[3],corners[2]], ratio)
	backMesh.set_mesh(surface.commit())
	node.add_child(backMesh)
	
	# add collision shape
	var box = BoxShape.new()
	# make a skinny prism
	box.set_extents(ratio / 2 + Vector3(0,0,0.01))
	node.add_shape(box, Transform(Vector3(1,0,0),Vector3(0,1,0),Vector3(0,0,1),Vector3(0,0,0)).translated(ratio / 2))
	node.set_translation(Vector3(x,y,z))
#	node.set_rotation(Vector3(rand_range(-PI/2,PI/2),0,0))
	if randi() % 2 == 0:
		node.set_rotation_deg(Vector3(85,0,0))
	else:
		node.set_rotation_deg(Vector3(-85,0,0))


func add_tri(s, pts, ratio):
	for h in range(pts.size()):
		s.add_uv(Vector2(-pts[h].x, pts[h].y).rotated(PI))
		s.add_vertex(pts[h]*ratio)
func add_quad(s, pts, ratio):
	add_tri(s, [pts[0], pts[1], pts[2]], ratio)
	add_tri(s, [pts[0], pts[2], pts[3]], ratio)