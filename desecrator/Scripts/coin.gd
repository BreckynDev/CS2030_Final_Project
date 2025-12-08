extends Area2D

@onready var pickup: AudioStreamPlayer2D = $pickup

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.treasure += 1
		pickup.play()
		pickup.connect("finished", Callable(self, "_on_sound_finished"))

func _on_sound_finished():
	call_deferred("queue_free")
