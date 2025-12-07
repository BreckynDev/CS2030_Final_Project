extends CharacterBody2D

@export var move_speed: float = 80.0
@export var follow_range: float = 300.0
@export var stop_distance: float = 12.0

@onready var enemySprite: AnimatedSprite2D = $AnimatedSprite2D
var player: CharacterBody2D

func _ready():
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("No player found! Make sure your player is in the 'player' group.")


func _physics_process(delta):
	if player == null:
		return

	var distance = global_position.distance_to(player.global_position)

	# --- Stop and freeze on Idle if flashlight is on ---
	if player.flashlightEnabled:
		velocity = Vector2.ZERO
		enemySprite.animation = "Idle"  # switch to idle animation
		enemySprite.stop()              # freeze on current frame
		return
	# ---------------------------------------------------

	# If player in range, move toward them
	if distance <= follow_range and distance > stop_distance:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * move_speed
		move_and_slide()
		if enemySprite.animation != "Teleport":
			if not enemySprite.is_playing():
				enemySprite.play("Idle")  # keep subtle idle when moving normally
	else:
		velocity = Vector2.ZERO
		if enemySprite.animation != "Teleport":
			enemySprite.animation = "Idle"
			enemySprite.stop()  # freeze when not moving
