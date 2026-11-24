extends ColorRect

func start():
	$blink.start()

func stop():
	$blink.stop()
	
func _on_blink_timeout() -> void:
	visible = not visible
