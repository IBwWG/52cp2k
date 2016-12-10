extends Spatial

#1 meter = 0.01 units

##Flags, you can play with them
#When enabled, the structure of the buildings is drawn
var drawStructure = false

#When enabled, palms, antennas and some other details are added
var drawDetails = true

#Building color
var buildingColor = Color(1, 1, 1, 0.3)

#Building siluete color
var silueteColor = Color(1, 1, 1)

#Slab color
var slabColor = Color(1, 1, 1)

#Slab siluete color
var slabSilueteColor = Color(0, 0, 0)



##Counters
#Details
var palmCount = 0
var treeCount = 0

#Buildings
var blockyBuildingCount = 0
var houseCount = 0
var piramidalBuildingCount = 0
var residentialBuildingsCount = 0

#Actual code
func _ready():

	#The initial seed
	#rand_seed(42)
	randomize()
	set_fixed_process(true)
	
	#Trials
#	for i in range(4):
#		for j in range(13):
#			addCard(9 - j*4, 0, 9 - i*4, 1, 1, 0.80, 1.40)

#Appends a cube to an existing Surfacetool
func addCubeMesh(x, y, z, dx, dy, dz, color, surface, blendMode = "sub"):
	
	#This allows to use RGB colors instead of images. Spooner is a genius!
	var material = FixedMaterial.new()
	material.set_fixed_flag(FixedMaterial.FLAG_USE_COLOR_ARRAY, true)
	
	#Allow transparency
	material.set_fixed_flag(FixedMaterial.FLAG_USE_ALPHA, true)
	surface.set_material(material)
	
	#This is the central point in the base of the cube
	var base = Vector3(x, y + dy, z)
	
	##Corners of the cube
	var corners = []
	
	#Top
	corners.push_back(base + Vector3(-dx,  dy, -dz))
	corners.push_back(base + Vector3( dx,  dy, -dz))
	corners.push_back(base + Vector3( dx,  dy,  dz))
	corners.push_back(base + Vector3(-dx,  dy,  dz))
	
	#Bottom
	corners.push_back(base + Vector3(-dx, -dy, -dz))
	corners.push_back(base + Vector3( dx, -dy, -dz))
	corners.push_back(base + Vector3( dx, -dy,  dz))
	corners.push_back(base + Vector3(-dx, -dy,  dz))
	
	#Color red
	surface.add_color(color)

	##Adding the corners in order, calculated by hand
	#Top
	surface.add_normal(Vector3(0, 1, 0))
	surface.add_vertex(corners[0])
	surface.add_vertex(corners[1])
	surface.add_vertex(corners[2])
	surface.add_vertex(corners[2])
	surface.add_vertex(corners[3])
	surface.add_vertex(corners[0])
	
	#One side
	surface.add_vertex(corners[0])
	surface.add_vertex(corners[4])
	surface.add_vertex(corners[5])
	surface.add_vertex(corners[5])
	surface.add_vertex(corners[1])
	surface.add_vertex(corners[0])

	#Other side
	surface.add_vertex(corners[6])
	surface.add_vertex(corners[2])
	surface.add_vertex(corners[1])
	surface.add_vertex(corners[1])
	surface.add_vertex(corners[5])
	surface.add_vertex(corners[6])

	#Other side
	surface.add_vertex(corners[3])
	surface.add_vertex(corners[2])
	surface.add_vertex(corners[6])
	surface.add_vertex(corners[6])
	surface.add_vertex(corners[7])
	surface.add_vertex(corners[3])

	#Other side
	surface.add_vertex(corners[0])
	surface.add_vertex(corners[3])
	surface.add_vertex(corners[7])
	surface.add_vertex(corners[7])
	surface.add_vertex(corners[4])
	surface.add_vertex(corners[0])
	
	#Bottom
	surface.add_vertex(corners[6])
	surface.add_vertex(corners[5])
	surface.add_vertex(corners[7])
	surface.add_vertex(corners[5])
	surface.add_vertex(corners[4])
	surface.add_vertex(corners[7])




func addCard(x, y, z, dx, dz, minHeight, maxHeight):

	var buildingName = "bunch" + str(residentialBuildingsCount)

	#The surfacetool that will be used to generate the whole building
	var surface = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	#Create a node building that will hold the mesh
	var node = MeshInstance.new()
	node.set_name(buildingName)
	add_child(node)
	
	#Floor
	addCubeMesh(x, y, z, dx, 0.005, dz, buildingColor, surface)
	
	##Add row of buildings in Z axis
	#Widths
	var widths = []
	var widthLeft = dz
	
	while(widthLeft > 0.30):
		var w = rand_range(0.20, 0.28)
		widths.push_back(w)
		widthLeft -= w
	
	#Add the rest
	widths.push_back(widthLeft)
	
	#Create the blocks
	var acumWidth = 0
	for width in widths:
	
		var localDy = rand_range(minHeight, maxHeight)
		addTower(x + dx - 0.2 * dx, y, z + dz - width - acumWidth, 0.2 * dx, localDy, width, surface)
		acumWidth += width * 2
	
	##Add row of buildings in the other side of the Z axis
	#Widths
	var widths = []
	var widthLeft = dz
	
	while(widthLeft > 0.30):
		var w = rand_range(0.20, 0.28)
		widths.push_back(w)
		widthLeft -= w
	
	#Add the rest
	widths.push_back(widthLeft)

	#Create the blocks
	var acumWidth = 0
	for width in widths:
		
		var localDy = rand_range(minHeight, maxHeight)
		addTower(x - dx + 0.2 * dx, y, z + dz - width - acumWidth, 0.2 * dx, localDy, width, surface)
		acumWidth += width * 2
		
	##Add row of buildings in the X axis
	#Widths
	var widths = []
	var widthLeft = dx - dx * 0.4
	
	while(widthLeft > 0.30):
		var w = rand_range(0.18, 0.23)
		widths.push_back(w)
		widthLeft -= w
	
	#Add the rest
	widths.push_back(widthLeft)

	#Create the blocks
	var acumWidth = 0
	for width in widths:
	
		var localDy = rand_range(minHeight, maxHeight)
		addTower(x + dx - width - 0.4 * dx - acumWidth, y, z + dz - 0.2 * dz, width, localDy, 0.2 * dz, surface)
		acumWidth += width * 2

	##Add the other row of buildings in the X axis
	#Widths
	var widths = []
	var widthLeft = dx - dx * 0.4
	
	while(widthLeft > 0.30):
		var w = rand_range(0.18, 0.23)
		widths.push_back(w)
		widthLeft -= w
	
	#Add the rest
	widths.push_back(widthLeft)

	#Create the blocks
	var acumWidth = 0
	for width in widths:
	
		var localDy = rand_range(minHeight, maxHeight)
		addTower(x + dx - width - 0.4 * dx - acumWidth, y, z - dz + 0.2 * dz, width, localDy, 0.2 * dz, surface)
		acumWidth += width * 2
		
	residentialBuildingsCount += 1
	
	#Set the created mesh to the node
	node.set_mesh(surface.commit())
#This adds the cubes of the buildings, this kinda works as an alias for addCube but I can add slabs here
func addTower(x, y, z, dx, dy, dz, buildingSurface, useAlpha = true):

	#I have to draw them 0.005 more in the y axis to avoid collision with the floor
	y += 0.005

	if not drawStructure:
	
		addCubeMesh(x, y, z, dx, dy, dz, buildingColor, buildingSurface)
		
	else:
		#Add a big transparent cube and then the structure
		addCubeMesh(x, y, z, dx, dy, dz, buildingColor, buildingSurface)
		
		#The slabs
		var heightLeft = dy * 2
		var accumHeight = 0

		while(heightLeft > 0.03):

			addCubeMesh(x, y + 0.03/2 + accumHeight, z, dx, 0.003, dz, slabColor, buildingSurface)

			heightLeft -= 0.03
			accumHeight += 0.03

		addCubeMesh(x, y + dy*2.0, z, dx, 0.003, dz, slabColor, buildingSurface)

#func _fixed_process(delta):
#	var space_state = get_world().get_direct_space_state()
#	var player = get_node("root/main/env/player")
#	var result = space_state.intersect_ray( player.get_translation(), get_node("root/main/env/level_test/floaty"), [ player ] )
#	print(result)