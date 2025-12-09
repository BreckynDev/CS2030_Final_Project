extends CharacterBody2D

var SPEED: float = 80.0
@export var player: Node2D
@onready var monster: AnimatedSprite2D = $AnimatedSprite2D

@onready var footstepPlayer: AudioStreamPlayer2D = $FootstepPlayer
@export var footstep_sounds: Array[AudioStream] = []
var footstep_cooldown := 0.8
var footstep_timer := 0.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _physics_process(delta: float) -> void:
	if player.flashlightEnabled:
		velocity = Vector2.ZERO
		monster.animation = "Idle" 
		monster.stop()        
		return
		
	monster.play()
	var next_point = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_point)
	velocity = direction * SPEED
	move_and_slide()
	
		
	footstep_timer -= delta
	if footstep_timer <= 0:
			play_footstep()
			footstep_timer = footstep_cooldown
			
func path() -> void:
	nav_agent.target_position = player.global_position

func _on_timer_timeout() -> void:
	path()

func play_footstep() -> void:
	if footstepPlayer == null:
		return
	if footstep_sounds.size() == 0:
		return
	footstepPlayer.stream = footstep_sounds[randi() % footstep_sounds.size()]
	footstepPlayer.play()
