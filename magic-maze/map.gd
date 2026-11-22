extends Node2D

var folder_path = "res://tiles/"
var tile_deck = folder_contents(folder_path)
var cards: Dictionary[Vector2i, Dictionary] = {}
var curr_cords := Vector2i.ZERO
var curr_card: Node2D
var cardinal_directions := {Vector2i.UP: "up", Vector2i.DOWN: "down", Vector2i.LEFT: "left", Vector2i.RIGHT: "right"}

### SETUP ###

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# load initial room
	play_card(curr_cords)
	load_card(curr_cords, Vector2i.ZERO)
	
	# random shuffle of the deck
	tile_deck.shuffle()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Load in all tiles
func folder_contents(path):
	var scene_loads = []
	
	var folder = DirAccess.open(path)
	if folder:
		folder.list_dir_begin()
		var file_name = folder.get_next()
		while file_name != "":
			if folder.current_is_dir():
				print("Found directory: " + file_name)
			else:
				if file_name.get_extension() == "tscn":
					var full_path = path.path_join(file_name)
					scene_loads.append(load(full_path))
			file_name = folder.get_next()
	else:
		print("An error occurred when trying to access the path.")
	
	return scene_loads


### CARD PLAYING ###

# Pick a card at random to play
func play_card(cords):
	var card = tile_deck.pop_front()
	if card:
		cards[cords] = {"tile": card}

# Load new card into scene	
func load_card(cords, input_dir):
	if curr_card:
		remove_child(curr_card)
		curr_card.queue_free()
	curr_cords = cords
	curr_card = cards[curr_cords]["tile"].instantiate()
	curr_card.name = "curr_card"
	add_child(curr_card)
	rotate_card(cards[curr_cords], input_dir)
	$curr_card.mark_exits()
	
	# store exits in cards dict
	var exits_dict = {}
	for exit in $curr_card.exits:
		exits_dict[exit] = $curr_card.exits[exit] != null
	cards[curr_cords]["exits"] = exits_dict
	check_exits()
	
	# block all remaining exits if the deck has run out
	if tile_deck.is_empty():
		curr_card.block_exits()
	
	# colour exits according to state
	$curr_card.mark_exits()
	
	# update guards next position
	if curr_card.guard:
		curr_card.guard.calc_next()


### PLAYER MOVEMENT THROUGH MAP ###

# Change card when player walks through exit
func change_card(input_dir) -> Vector2i:
	var next = curr_cords + input_dir
	var new = false
	var entry_point: Vector2
	if not cards.has(next):
		play_card(next)
		new = true
	load_card(next, input_dir)
	if new:
		entry_point = $curr_card/spawn_point.global_position
	else:
		entry_point = get_entry_point(next, input_dir)
	
	return entry_point

# Get the correct entry the player walked through
func get_entry_point(next, input_dir) -> Vector2:
	var next_card = cards[next]
	var entry_dir = _rotate_vect(-input_dir, -next_card["rotation"])
	var entry_name = cardinal_directions[entry_dir]
	var entry_point = $curr_card.get_node("exit_"+entry_name).get_node("entry_point")
	return entry_point.global_position


### ROTATION OF TILES ###

# Calc the appropriate rotation of the tile 
func _quarter_turns(from, to) -> int:
	return posmod(roundi(Vector2(from).angle_to(Vector2(to)) / (PI / 2.0)), 4)

# Rotate a vector by a set ammount of quarter turns
func _rotate_vect(dir, turns) -> Vector2i:
	return Vector2i(Vector2(dir).rotated(turns * PI / 2.0).round())

# Rotate the tile to have its local south face the exit player walked through the first time	
func rotate_card(card, input_dir) -> void:
	if not card.has("rotation"):
		card["rotation"] = _quarter_turns($curr_card/exit_down.dir, -input_dir)
	$curr_card.rotation = card["rotation"] * PI / 2.0
	
	# Align card with screen
	var offsets := [Vector2i(0, 0), Vector2i(512, 0), Vector2i(512, 512), Vector2i(0, 512)]
	$curr_card.global_position = offsets[card["rotation"]]
	

### STATES OF CARDS ###

# Check whether exits should be linked or blocked
func check_exits():
	var exits = curr_card.exits
	for exit in exits:
		exit = exits[exit]
		if exit:
			var exit_dir = _rotate_vect(exit.dir, cards[curr_cords]["rotation"])
			var neighbour = exit_dir + curr_cords
			if cards.has(neighbour):
				neighbour = cards[neighbour]
				var opp_exit_dir = _rotate_vect(-exit_dir, -neighbour["rotation"])
				var opp_exit = cardinal_directions[opp_exit_dir]
				if neighbour["exits"][opp_exit]:
					exit.linked = true
				else:
					curr_card.block_exit(exit)

### GUARD INTERACTIONS ###

func move_guard():
	if curr_card.guard:
		curr_card.guard.move()

func check_guard(player_next, player_old) -> bool:
	if curr_card.guard:
		var guard = curr_card.guard
		print("guard now ", guard.global_position.round(), " next ", guard.next_pos, " | player old ", player_old, " next ", player_next)
		if guard.next_pos == player_next:
			guard.set_move_to_rotate()
		elif (guard.next_pos == player_old) and (guard.global_position == player_next):
			guard.set_move_to_rotate()
			return true
	return false
