extends PathFollow2D

const tile_size := 128
const speed = 0.25

var forward := true
var guard_pos_tween: Tween
var next_pos := Vector2(0,0)
var old_pos := Vector2(0,0)
var path: Path2D = null
var player_on_path := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	snap()
	path = get_parent()
	
	# face right direction from start
	calc_next()
	var move_dir = next_pos - global_position
	var targ_rot = Vector2(move_dir).angle() + PI/2
	$CharacterBody2D.global_rotation = targ_rot
	snap()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Move to next spot on path
func move():
	snap()
	if player_on_path:
		move_special()
		return
	# save old position
	old_pos = global_position
	var old_rot = $CharacterBody2D.global_rotation
	var move_dir = next_pos - global_position
	
	# move guard
	if forward:
		progress += tile_size
		if progress_ratio >= 1.0:
			forward = false 
	else:
		progress -= tile_size
		if progress_ratio <= 0.0:
			forward = true
			
	# rotate guard
	var targ_rot = Vector2(move_dir).angle() + PI/2
	$CharacterBody2D.global_rotation = targ_rot
	
	# tween movement and rotation for smoother visuals
	$CharacterBody2D/Sprite2D.global_position = old_pos
	$CharacterBody2D/Sprite2D.global_rotation = old_rot
	
	targ_rot = $CharacterBody2D/Sprite2D.global_rotation + angle_difference($CharacterBody2D/Sprite2D.global_rotation, targ_rot)
	
	if guard_pos_tween:
		guard_pos_tween.kill()
	guard_pos_tween = create_tween()
	guard_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	guard_pos_tween.set_parallel(true)
	guard_pos_tween.tween_property($CharacterBody2D/Sprite2D, "global_rotation", targ_rot, speed/2).set_delay(0.1)
	guard_pos_tween.set_trans(Tween.TRANS_SPRING)
	guard_pos_tween.tween_property($CharacterBody2D/Sprite2D, "global_position", global_position, speed).set_delay(0.1)

	# update next
	calc_next()

# Only rotate to face next direction, in case of player collision
func move_special():
	# no change in pos so use next and current
	var old_rot = $CharacterBody2D.global_rotation
	var move_dir = next_pos - global_position
	var targ_rot = Vector2(move_dir).angle() + PI/2
	$CharacterBody2D.global_rotation = targ_rot
	
	# tween for rotation smoother visuals
	$CharacterBody2D/Sprite2D.global_rotation = old_rot
	targ_rot = $CharacterBody2D/Sprite2D.global_rotation + angle_difference($CharacterBody2D/Sprite2D.global_rotation, targ_rot)
	
	if guard_pos_tween:
		guard_pos_tween.kill()
	guard_pos_tween = create_tween()
	guard_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	guard_pos_tween.tween_property($CharacterBody2D/Sprite2D, "global_rotation", targ_rot, speed/2).set_delay(0.1)
	
	# player shouldnt be on path anymore next move
	set_move_to_rotate()

# swap boolian value of player being on path or not
func set_move_to_rotate():
	player_on_path = not player_on_path

# calculate the next position on the path, for player collisions
func calc_next():
	if path is Path2D:
		var next = progress
		if forward:
			next += tile_size
		else:
			next -= tile_size
		
		next_pos = path.to_global(path.curve.sample_baked(next)).round()

# snap to grid
func snap():
	var tiles := Vector2(tile_size, tile_size)
	global_position = (global_position - (tiles / 2)).snapped(tiles) + (tiles / 2)

# check if player is on square in front of it
func spot_player() -> bool:
	$CharacterBody2D/vision.force_raycast_update()
	if $CharacterBody2D/vision.is_colliding():
		print("guard: player spotted")
		return true
	return false

func _on_temp_move_timer_timeout() -> void:
	pass # Replace with function body.
