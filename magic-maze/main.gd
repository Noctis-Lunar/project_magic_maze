extends Node2D

const spot_penalty := 5
const alrt_speed := 1
const alrt_max := 50
const escape_time := 120

var guard_allertness := 0
var escape := false
var artifact_aquired := false
var game_running := false

var artifact_id = "artifact_01"

@onready var hud: CanvasLayer = get_tree().get_first_node_in_group("hud")
@onready var start_screen: TextureRect = hud.get_node("start_screen")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer_settings()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if game_running:
		timer_update()

### PLAYER INITIATED ACTIONS ###

# When player walks through final exit, check win condition and exit game
func escape_maze() -> void:
	var escaped = true
	
	# stop any going timers and associated functions
	$escape_timer.stop()
	$allert_timer.stop()
	hud.get_node("allarm").stop()
	hud.get_node("allarm").hide()
	
	# display message
	hud.get_node("end_message").display(artifact_aquired, escaped)

# Set of allarm when player steals artifact, save this
func item_interact(id) -> void:
	# play fun sound effect here
	print("encountered item")
	if id == artifact_id:
		artifact_aquired = true
		allarm()
	$Map.item_interact(id)

### TIMERS VISIBLE TO PLAYER ###

# Set timer settings
func timer_settings() -> void:
	hud.get_node("escape_bar").hide()
	hud.get_node("allert_bar").hide()
	hud.get_node("escape_bar").max_value = escape_time
	hud.get_node("allert_bar").max_value = alrt_max
	$escape_timer.wait_time = escape_time

# Update timers while game is running
func timer_update() -> void:
	if not escape:
		hud.get_node("allert_bar").value = guard_allertness
		if guard_allertness >= alrt_max:
			allarm()
	else:
		hud.get_node("escape_bar").value = $escape_timer.time_left

# Set off timer for escape
func allarm() -> void:
	escape = true
	$allert_timer.stop()
	$escape_timer.start()
	hud.get_node("escape_bar").show()
	hud.get_node("allert_bar").hide()
	hud.get_node("allarm").start()
	# add sound effect

### CONTROLL ###

# Stop the game and go back to start screen
func exit_game() -> void:
	# reset variables
	timer_settings()
	game_running = false
	artifact_aquired = false
	guard_allertness = 0
	hud.get_node("allert_bar").value = 0
	
	# go back to start screen
	start_screen.get_node("start_button").disabled = false
	start_screen.show()
	hud.get_node("allert_bar").hide()
	hud.get_node("escape_bar").hide()
	hud.get_node("allarm").hide()
	
# Start up the game
func _on_start_button_pressed() -> void:
	start_screen.get_node("start_button").disabled = true
	game_running = true
	$Map.start()
	$Player.spawn()
	start_screen.hide()
	hud.get_node("allert_bar").visible = true
	$allert_timer.start()
	
# Hide whichever message was displayed
func _on_display_timer_timeout() -> void:
	exit_game()

### ALLERT LEVELS ###

# Guard spotted player
func _on_map_player_spotted() -> void:
	print("main: player spotted")
	guard_allertness += spot_penalty

# Constant slow increase of guard allertness	
func _on_allert_timer_timeout() -> void:
	guard_allertness += alrt_speed

# Game over if time runs out
func _on_escape_timer_timeout() -> void:
	var escaped = false
	hud.get_node("allarm").stop()
	hud.get_node("allarm").hide()
	hud.get_node("end_message").display(artifact_aquired, escaped)
	
