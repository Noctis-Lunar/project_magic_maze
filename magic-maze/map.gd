extends Node2D

var dir_path = "res://tiles/"
var tile_deck = dir_contents(dir_path)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# random shuffle of the deck
	tile_deck.shuffle()
	
	play_card()
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func dir_contents(path):
	var scene_loads = []
	
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				if file_name.get_extension() == "tscn":
					var full_path = path.path_join(file_name)
					scene_loads.append(load(full_path))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	
	return scene_loads

func play_card():
	var card = tile_deck.pop_front()
	var card_instance = card.instantiate()
	add_child(card_instance)
	
	
