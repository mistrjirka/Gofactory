extends GridMap
#prepare Litenoise 3D for godot terrain generation
var HEIGHT = 100
static func sum_array(array):
	var sum = 0.0
	for element in array:
		sum += element
	return sum
func generate_terrain(boundaries : Vector2):
	#Godot Procedural generation of the terrain 
	#based on Perlin noise values.q
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.fractal_octaves = 6
	noise.fractal_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.02
	var lowFrequencyNoise = FastNoiseLite.new()
	
	lowFrequencyNoise.seed = randi()
	lowFrequencyNoise.fractal_octaves = 6
	lowFrequencyNoise.fractal_type = FastNoiseLite.TYPE_PERLIN
	lowFrequencyNoise.frequency = 0.00034
	
	var weights = [1, 3]
	var functions = [lowFrequencyNoise.get_noise_3d, noise.get_noise_3d]
	var activationFunctions = [
		func(y):
			return float(y)/HEIGHT,
		func(y):
			return clamp((50-float(y))/50, 0,1)
	]
	#get grass with id ground_grass
	#get stone with id cliff_rock
	#get it from the meshlibrary assosicatet with this gridmap
	var Grass = mesh_library.find_item_by_name("ground_grass")
	var Stone = mesh_library.find_item_by_name("cliff_block_rock")
	print(Grass)
	for x in range(-boundaries.x, boundaries.x):
		for z in range(-boundaries.y, boundaries.y):
			for y in range(HEIGHT):
				#generate terrain based on noise
				var v = 0.0
				var divider = 0.0
				for i in range(functions.size()):
					v += (functions[i].call(x,z,y)+1)/2 * activationFunctions[i].call(y)

					divider += activationFunctions[i].call(y)
				v /= divider
				print("divider: %s"% divider)
				print("v: %s"% v)

				
				
				var location: Vector3 = Vector3(x,y,z)

				#print("Location: %s" % location)
				#print("limit %s" %limit)
				var limit = float(y)/HEIGHT
				if v > limit:
					set_cell_item(location, Stone)
				
				#else:
				#	set_cell_item(location, Stone)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_terrain(Vector2(50, 50))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
