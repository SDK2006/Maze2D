extends CharacterBody2D
class_name Boss

var coords : Vector2
const SPEED = 50

func _enter_tree() -> void:
	set_multiplayer_authority(1)

func _ready():
	position = Vector2(50, 50)

func _physics_process(_delta: float) -> void:
	if !is_multiplayer_authority(): return
	
	var direction := Input.get_vector("left", "right", "up", "down").normalized()
	velocity = direction * SPEED
	
	look_at(get_global_mouse_position())
	move_and_slide()
