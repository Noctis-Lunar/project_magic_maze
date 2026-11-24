extends CanvasLayer

# display appropriate message
func display(artifact_aquired, escaped):
	if artifact_aquired and escaped:
		$succes.show()
	elif escaped:
		$fail.show()
	else:
		$game_over.show()
	$display_timer.start()

# hide message after timeout
func _on_display_timer_timeout() -> void:
	$succes.hide()
	$fail.hide()
	$game_over.hide()
