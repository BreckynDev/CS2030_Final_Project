extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player") and body.treasure >= body.treasureGoal:
		get_tree().change_scene_to_file("res://Scenes/end.tscn")
