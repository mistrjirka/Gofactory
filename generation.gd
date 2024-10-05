extends GridMap
#prepare Litenoise 3D for godot terrain generation
var HEIGHT = 100
var noise: FastNoiseLite

var generatedChunks: Dictionary
static func sum_array(array):
	var sum = 0.0
	for element in array:
		sum += element
	return sum


func generate_terrain(start : Vector2, end: Vector2):
	#Godot Procedural generation of the terrain 
	#based on Perlin noise values.q
	#get grass with id ground_grass
	#get stone with id cliff_rock
	#get it from the meshlibrary assosicatet with this gridmap
	var Grass = mesh_library.find_item_by_name("ground_grass")
	var Stone = mesh_library.find_item_by_name("cliff_block_rock")
	print(Grass)
	for x in range(start.x, end.x):
		for z in range(start.y, end.y):
			for y in range(HEIGHT):
				var location = Vector3(x,y,z)
				#generate terrain based on noise
				var v = noise.get_noise_3d(x,z,y)
				#print("Location: %s" % location)
				#print("limit %s" %limit)
				var limit = float(y)/HEIGHT
				if v > limit:
					set_cell_item(location, Stone)
				
				#else:
				#	set_cell_item(location, Stone)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.fractal_octaves = 1
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.06
	generate_terrain(Vector2(-50, -50),Vector2(50, 50))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		pass
