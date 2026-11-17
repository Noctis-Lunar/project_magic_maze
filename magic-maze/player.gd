class_name Player
extends CharacterBody2D

@onready var map = $"../Map"

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


func move():
	global_position += Vector2(input_dir * tile_size)
	$Sprite2D.global_position -= Vector2(input_dir * tile_size)
	
	var targ_rot = Vector2(input_dir).angle() + PI/2
	targ_rot = $Sprite2D.rotation + angle_difference($Sprite2D.rotation, targ_rot)
	
	if player_pos_tween:
		player_pos_tween.kill()
	player_pos_tween = create_tween()
	player_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	player_pos_tween.set_parallel(true)
	player_pos_tween.tween_property($Sprite2D, "global_position", global_position, speed)
	player_pos_tween.tween_property($Sprite2D, "rotation", targ_rot, speed/2)
	
	# Check if player went through an exit
	player_pos_tween.finished.connect(check_exit.bind(input_dir))


func check_exit(dir) -> void:
	var exit = $CheckExit.get_overlapping_areas()
	if exit.is_empty():
		return
	global_position = map.change_card(dir)
