extends Area2D

var player_in_range = false
var player_ref = null
var dug = false
var digProgress = 0
var digGoal = 100
var digStep = 10

@onready var progress_bar = $ProgressBar

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	
	if progress_bar:
		progress_bar.visible = false
		progress_bar.min_value = 0
		progress_bar.max_value = digGoal
		progress_bar.value = digProgress

func _process(delta):
	if player_in_range and not dug and Input.is_action_pressed("dig"):
		dig(delta)

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		player_ref = body
		body.current_interactable = self

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		if body.current_interactable == self:
			body.current_interactable = null
		player_ref = null

func dig(delta):
	if dug:
		return
	
	digProgress += digStep * delta
	if progress_bar:
		progress_bar.visible = true
		progress_bar.value = digProgress
	
	if digProgress >= digGoal:
		dug = true
		digProgress = digGoal
		print("You have finished digging!")
