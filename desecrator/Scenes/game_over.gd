extends Control

func _ready():
	$Menu.pressed.connect(_on_play_pressed)
	$Quit.pressed.connect(_on_quit_pressed)
	
func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/game_root.tscn") 

func _on_quit_pressed():
	get_tree().quit()
