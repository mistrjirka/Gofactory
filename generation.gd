extends GridMap
#prepare Litenoise 3D for godot terrain generation
var current_position: Vector3
var chunk_size: int = 16
var render_distance: int = 5
var render_center_position: Vector2
var current_camera

var noise
#var generated_hashmap = {}
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
				var v = noise.get_noise_3d(location.x, location.z, location.y)
				var limit = float(y)/HEIGHT
				if v > limit:
					set_cell_item(location, Stone)
				
				#else:
				#	set_cell_item(location, Stone)
	
func generation():
	current_position = current_camera.transform.origin
	#rounded to whole numbers
	var chunk_player_position = Vector2(int(current_position.x/chunk_size), int(current_position.z/chunk_size))
	var direction = Vector2(chunk_player_position.x - render_center_position.x, chunk_player_position.y - render_center_position.y)
	if direction.x > 0:
		#kinda left bottom corner
		var start_corner: Vector2 = Vector2(render_center_position.x + render_distance*direction.x, render_center_position.y - render_distance)
		print("start corner", start_corner)
		#kinda right top corner
		var end_corner: Vector2 = Vector2(render_center_position.x + render_distance*direction.x + direction.x, render_center_position.y + render_distance)
		print("end corner", end_corner)
		print("square SIZE: ",  end_corner - start_corner)
		generate_terrain(start_corner*chunk_size, end_corner*chunk_size)
		render_center_position = Vector2(render_center_position.x + direction.x, render_center_position.y)
	
	
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
