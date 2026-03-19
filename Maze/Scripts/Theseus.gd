extends CharacterBody2D

var coords : Vector2

const SPEED = 100

func _ready():
	position = GameState.coords

func _physics_process(_delta: float) -> void:
	
	var directiony := Input.get_axis("ui_up", "ui_down")
	var directionx := Input.get_axis("ui_left", "ui_right")
	if directiony:
		velocity.y = directiony * SPEED
	else:
		velocity.y = move_toward(velocity.x, 0, SPEED)
	
	if directionx:
		velocity.x = directionx * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
