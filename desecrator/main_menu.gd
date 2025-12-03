extends Control

func _ready():
	$Button.pressed.connect(_on_play_pressed)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
