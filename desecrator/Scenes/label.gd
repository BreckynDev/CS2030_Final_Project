extends Label

@export var delay_seconds: float = 30.0
@export var fade_duration: float = 1.0

func _ready() -> void:
	# Wait the delay, then start fading
	await get_tree().create_timer(delay_seconds).timeout
	fade_out()

func fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
