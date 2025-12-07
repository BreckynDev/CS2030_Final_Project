extends Area2D

# Called when the node enters the scene tree for the first time.
func _on_body_entered(body):
	if body.name == "Player":
		$AudioStreamPlayer.play()

func _on_body_exited(body):
	if body.name == "Player":
		$AudioStreamPlayer.stop()
		
