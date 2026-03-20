extends CharacterBody2D
class_name Player

var coords : Vector2
const SPEED = 100

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready():
	position = Vector2(100, 100)

func _physics_process(_delta: float) -> void:
	#if !is_multiplayer_authority(): return
	
	var direction := Input.get_vector("left", "right", "up", "down").normalized()
	velocity = direction * SPEED
	
	look_at(get_global_mouse_position())
	move_and_slide()
