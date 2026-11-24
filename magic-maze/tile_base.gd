extends Node2D

@export var exits = {}
var guard = null
var artifact = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Read exits of tile
	exits = {
		"up": get_node_or_null("exit_up"), 
		"down": get_node_or_null("exit_down"), 
		"left": get_node_or_null("exit_left"), 
		"right": get_node_or_null("exit_right")
	}
	
	# Get guard if present
	guard = get_node_or_null("guard_path/Guard")
	artifact = get_node_or_null("artifact")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Change exit colours depending on their states
func mark_exits() -> void:
	for exit in exits:
		exit = exits[exit]
		if exit: 
			var marker = exit.get_node("entry_point")
			var cell: Vector2i = $Base.local_to_map($Base.to_local(marker.global_position))
			$Base.mark_cell(cell, exit.linked, exit.blocked)

# Block all exits
func block_exits():
	for exit in exits:
		exit = exits[exit]
		if exit:
			block_exit(exit)

# Block given exit
func block_exit(exit):
	if exit.linked:
		return
	exit.blocked = true
	exit.set_collision_layer_value(2, true)
	
	
