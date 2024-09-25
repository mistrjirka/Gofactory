@tool
extends "res://addons/copilot-advanced/LLM.gd"

@onready var URL = $"../../VBoxParent/ModelSetting3/URL".text
const PROMPT_PREFIX = """#This is a GDScript script using Godot 4.0. 
#That means the new GDScript 2.0 syntax is used. Here's a couple of important changes that were introduced:
#- Use @export annotation for exports
#- Use Node3D instead of Spatial, and position instead of translation
#- Use randf_range and randi_range instead of rand_range
#- Connect signals via node.SIGNAL_NAME.connect(Callable(TARGET_OBJECT, TARGET_FUNC))
#- Connect signals via node.SIGNAL_NAME.connect(Callable(TARGET_OBJECT, TARGET_FUNC))
#- Use rad_to_deg instead of rad2deg
#- Use PackedByteArray instead of PoolByteArray
#- Use instantiate instead of instance
#- Use FastNoiseLite instead of Noise3D or SimplexNoise
#- You can't use enumerate(OBJECT). Instead, use "for i in len(OBJECT):"
#- Grid map has this documentation:
	clear(): Clears the map.
	get_cell_item(x, y, z): Returns the item ID at the specified cell.
	set_cell_item(x, y, z, item): Places an item in the specified cell.
	resource_changed(): Reapplies the MeshLibrary to existing cells.
	Properties:
		cell_size: Controls the grid cell dimensions.
		mesh_library: Assigns the MeshLibrary used for the grid.
MeshLibrary:
	Functions

	clear(): Clears all items in the MeshLibrary.
	create_item(id: int): Creates a new item with the specified ID.
	remove_item(id: int): Removes the item with the specified ID.
	set_item_name(id: int, name: String): Sets the name for the specified item.
	set_item_mesh(id: int, mesh: Mesh): Sets the mesh for the specified item.
	set_item_preview(id: int, texture: Texture): Sets a preview texture for the specified item.
	set_item_shapes(id: int, shapes: Array): Sets collision shapes for the specified item.

Properties

	item_meshes: Array of Meshes; stores the meshes used in items.
	item_names: Dictionary; maps item IDs to their names.
	item_previews: Dictionary; maps item IDs to their preview textures.
	item_shapes: Dictionary; maps item IDs to their collision shapes.
#- Remember, this is not Python. It's GDScript for use in Godot. And remember that Godot is Righthanded Y up engine.
"""
const MAX_LENGTH = 15000

func _get_models():
	return [
		"custom",
		"text-davinci-003"
	]

func _set_model(model_name):
	model = model_name

func _send_user_prompt(user_prompt, user_suffix):
	get_completion(user_prompt, user_suffix)

func get_completion(_prompt, _suffix):
	var prompt = _prompt
	var suffix = _suffix
	var combined_prompt = prompt + suffix
	var diff = combined_prompt.length() - MAX_LENGTH
	if diff > 0:
		if suffix.length() > diff:
			suffix = suffix.substr(0,diff)
		else:
			prompt = prompt.substr(diff - suffix.length())
			suffix = ""
	var calculated_model = model
	if model == "custom":
		calculated_model = custom_model_text	
	var body = {
		"model": calculated_model,
		"prompt": PROMPT_PREFIX + prompt,
		"suffix": suffix,
		"temperature": 0.7,
		"max_tokens": 500,
		"stop": "\n\n" if allow_multiline else "\n" 
	}
	var headers = [
		"Content-Type: application/json"
	]
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed",on_request_completed.bind(prompt, suffix, http_request))
	var json_body = JSON.stringify(body)
	var error = http_request.request(URL, headers, HTTPClient.METHOD_POST, json_body)
	print(URL)
	if error != OK:
		emit_signal("completion_error", null)

func on_request_completed(result, response_code, headers, body, pre, post, http_request):
	var test_json_conv = JSON.new()
	test_json_conv.parse(body.get_string_from_utf8())
	var json = test_json_conv.get_data()
	var response = json
	if !response.has("choices"):
		emit_signal("completion_error", response)
		return
	var completion = response.choices[0].text
	if is_instance_valid(http_request):
		http_request.queue_free()
	emit_signal("completion_received", completion, pre, post)

func _on_url_text_changed(new_text):
	URL = new_text
