extends AudioStreamPlayer

@export var song1: AudioStream
@export var song2: AudioStream

var current_song: int = 1

func _ready():
	finished.connect(_on_song_finished)

	current_song = randi() % 2
	_play_current_song()


func _play_current_song():
	if current_song == 0:
		stream = song1
	else:
		stream = song2
	play()

func _on_song_finished():
	current_song = 1 - current_song
	_play_current_song()
