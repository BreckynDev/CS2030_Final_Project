extends Node2D

@onready var Sprite = $Body
@onready var Arrow = $Body/Arrow
@onready var current_camera = get_viewport().get_camera_2d()

@export var zoomMax = 15
@export var zoomMin = 6 # shouldn't change this.
@export var zoomSpeed = 10
@export var compassTurnSpeed = 8
# Called when the node enters the scene tree for the first time.

func _ready():
	Sprite.modulate.a = 0

func getNearestObject():
	var nearest = null
	var shortest = INF
	var current_pos = global_position
	for obj in get_tree().get_nodes_in_group("DigZones"):
		if not obj or !obj.is_inside_tree():
			continue
		if obj.dug == true:
			continue
			
		var dist = current_pos.distance_to(obj.global_position)
		if dist < shortest:
			shortest = dist
			nearest = obj
	if !nearest:
		nearest = get_tree().get_first_node_in_group("Exit")
	return nearest


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var zoomX = current_camera.zoom.x
	var zoomY = current_camera.zoom.y
	if !Input.is_action_pressed("OpenCompass"): ## Compass not opened
		Sprite.modulate.a = max(Sprite.modulate.a - 0.1, 0)
		zoomX = max(zoomX - zoomSpeed * delta, zoomMin)
		zoomY = max(zoomY - zoomSpeed * delta, zoomMin)
		
		
	else:
		Sprite.modulate.a = min(Sprite.modulate.a + 0.1, 1)
		zoomX = min(zoomX + zoomSpeed * delta, zoomMax)
		zoomY = min(zoomY + zoomSpeed * delta, zoomMax)
		var nearestObject = getNearestObject()
		if nearestObject:
				Arrow.rotation = lerp_angle(Arrow.rotation, (nearestObject.global_position - Arrow.global_position).angle() + 90, compassTurnSpeed * delta)
		
	current_camera.zoom = Vector2(zoomX, zoomY)
