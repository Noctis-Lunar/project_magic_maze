extends CharacterBody2D

const tile_size: Vector2 = Vector2(128,128)
const speed = 0.25

var input_dir
var moving = false
var player_pos_tween: Tween

func _physics_process(_delta: float) -> void:
	# reset input vector
	input_dir = Vector2.ZERO

	# get 4 directional movement
	if !player_pos_tween or !player_pos_tween.is_running():
		if Input.is_action_just_pressed("ui_up") and !$up.is_colliding():
			input_dir = Vector2(0,-1)
		elif Input.is_action_just_pressed("ui_down") and !$down.is_colliding():
			input_dir = Vector2(0,1)
		elif Input.is_action_just_pressed("ui_left") and !$left.is_colliding():
			input_dir = Vector2(-1,0)
		elif Input.is_action_just_pressed("ui_right") and !$right.is_colliding():
			input_dir = Vector2(1,0)
	
	# execute
	move()

func move():
	if input_dir:
		global_position += input_dir * tile_size
		$Sprite2D.global_position -= input_dir * tile_size
		
		var targ_rot = input_dir.angle() + PI/2
		targ_rot = $Sprite2D.rotation + angle_difference($Sprite2D.rotation, targ_rot)
		
		if player_pos_tween:
			player_pos_tween.kill()
		player_pos_tween = create_tween()
		player_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		player_pos_tween.set_parallel(true)
		player_pos_tween.tween_property($Sprite2D, "global_position", global_position, speed)
		player_pos_tween.tween_property($Sprite2D, "rotation", targ_rot, speed/2)
