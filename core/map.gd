@icon("res://editor/svg/Map.svg")
@tool
class_name Map extends TileMap

@export var exits = {}

enum Layer {DYNAMIC, STATIC}

class UniqueTile:
	var source_id : int
	var atlas_coords : Vector2i
	var alternative_tile : int
	
	func _init(id, ac, at) -> void:
		source_id = id
		atlas_coords = ac
		alternative_tile = at


class Exit:
	var map_path : String
	
	func _init(mp) -> void:
		map_path = mp


func _ready():
	for cell in _get_exit_cells():
		exits[cell] = Exit.new("res://")
	
	print(exits)


func _get_exit_tiles() -> Array:
	var exit_tiles = []
	
	for source_id in tile_set.get_source_count():
		var source = tile_set.get_source(source_id)
		
		for tile_id in source.get_tiles_count():
			var atlas_coords = source.get_tile_id(tile_id)
			
			for alternative_tile in source.get_alternative_tiles_count(atlas_coords):
				var data = source.get_tile_data(atlas_coords, 0)
				
				if data and data.get_custom_data("is_exit"):
					exit_tiles.append(UniqueTile.new(source_id, atlas_coords, alternative_tile))
	
	return exit_tiles


func _get_exit_cells() -> Array:
	var exit_cells = []
	
	for tile in _get_exit_tiles():
		for cell in get_used_cells_by_id(Layer.STATIC, tile.source_id, tile.atlas_coords, tile.alternative_tile):
			exit_cells.append(cell)
	
	return exit_cells


func on_step(actor : Actor) -> String:
	var data = get_cell_tile_data(Layer.STATIC, local_to_map(actor.position))
	
	if data:
		return data.get_custom_data("on_step")
	
	return ""


func slash(cell : Vector2i) -> void:
	var data = get_cell_tile_data(Layer.DYNAMIC, cell)
	
	if data and data.get_custom_data("is_cuttable"):
		var cut_fx = preload("res://core/vfx/grass_cut.tscn").instantiate()
		
		cut_fx.position = map_to_local(cell)
		add_child(cut_fx)
		erase_cell(Layer.DYNAMIC, cell)
