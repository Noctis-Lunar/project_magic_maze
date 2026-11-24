class_name Player
extends CharacterBody2D

@onready var map = $"../Map"
@onready var main = get_parent()

const tile_size: Vector2i = Vector2i(128,128)
const speed = 0.25

var input_dir
var moving = false
var player_pos_tween: Tween

func _physics_process(_delta: float) -> void:
	# reset input vector
	input_dir = Vector2i.ZERO

	# get 4 directional movement
	if !player_pos_tween or !player_pos_tween.is_running():
		if Input.is_action_just_pressed("ui_up") and !$up.is_colliding():
			input_dir = Vector2i(0,-1)
		elif Input.is_action_just_pressed("ui_down") and !$down.is_colliding():
			input_dir = Vector2i(0,1)
		elif Input.is_action_just_pressed("ui_left") and !$left.is_colliding():
			input_dir = Vector2i(-1,0)
		elif Input.is_action_just_pressed("ui_right") and !$right.is_colliding():
			input_dir = Vector2i(1,0)
	
	# execute
	if input_dir:
		move()
		map.move_guard()
		check_artifact()

func spawn():
	global_position = map.get_node("curr_card/spawn_point").global_position
	snap()

# move in given input direction
func move():
	snap()
	# check for future guard collision:
	var old_pos := global_position
	var next_pos := global_position + Vector2(input_dir * tile_size)
	if map.check_guard(next_pos, old_pos):
		no_move()
		return
	
	global_position = next_pos
	
	# tween movement and rotation for smoother visuals
	$Sprite2D.global_position = old_pos
	
	var targ_rot = Vector2(input_dir).angle() + PI/2
	targ_rot = $Sprite2D.rotation + angle_difference($Sprite2D.rotation, targ_rot)
	
	if player_pos_tween:
		player_pos_tween.kill()
	player_pos_tween = create_tween()
	player_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	player_pos_tween.set_parallel(true)
	player_pos_tween.tween_property($Sprite2D, "rotation", targ_rot, speed/2)
	player_pos_tween.set_trans(Tween.TRANS_SPRING)
	player_pos_tween.tween_property($Sprite2D, "global_position", global_position, speed)

	
	# Check if player went through an exit
	player_pos_tween.finished.connect(check_exit.bind(input_dir))

# check whether player walked into an exit
func check_exit(dir) -> void:
	var exit = $CheckExit.get_overlapping_areas()
	if exit.is_empty():
		return
	if exit[0].name == "final_exit":
		main.escape_maze()
		return
	global_position = map.change_card(dir)
	snap()

# check whether player walked onto artifact (aka picked it up)
func check_artifact() -> void:
	var artifact = $CheckArtifact.get_overlapping_areas()
	if artifact.is_empty():
		return
	main.steal_artifact()

# make the player only rotate to face the input direction, in case of guard collision
func no_move():
	# maybe add some other visual indicator later?
	var targ_rot = Vector2(input_dir).angle() + PI/2
	targ_rot = $Sprite2D.rotation + angle_difference($Sprite2D.rotation, targ_rot)
	if player_pos_tween:
		player_pos_tween.kill()
	player_pos_tween = create_tween()
	player_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	player_pos_tween.tween_property($Sprite2D, "rotation", targ_rot, speed/2)

# snap to center of grid
func snap():
	var tiles := Vector2(tile_size)
	global_position = (global_position - (tiles / 2)).snapped(tiles) + (tiles / 2)
