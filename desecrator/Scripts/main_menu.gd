extends Control

func _ready():
	$New_game.pressed.connect(_on_play_pressed)
	$Settings.pressed.connect(_on_settings_pressed)
	$Quit.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_settings_pressed():
	$"..".get_node('MainSettings').show()
	$"..".get_node('mainMenu').hide()
	

func _on_quit_pressed():
	get_tree().quit()
	
