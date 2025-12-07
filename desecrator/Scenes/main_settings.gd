extends Control

func _ready():
	$Back.pressed.connect(_on_play_pressed)

func _on_play_pressed():
	$"..".get_node('mainMenu').show()
	$"..".get_node('MainSettings').hide()
