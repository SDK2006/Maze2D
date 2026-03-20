extends CharacterBody2D

var coords : Vector2

@export var arrow_scene : PackedScene
@onready var attack_cooldown := $AttackCooldown

const SPEED = 100

func _ready():
	position = GameState.coords

func _physics_process(_delta: float) -> void:
	
	var direction := Input.get_vector("left", "right", "up", "down").normalized()
	velocity = direction * SPEED
	
	look_at(get_global_mouse_position())
	move_and_slide()
	
func shoot():
	var arrow = arrow_scene.instantiate()
	arrow.global_position = global_position
	arrow.direction = (get_global_mouse_position() - global_position).normalized()
	arrow.rotation = arrow.direction.angle()
	
	get_tree().current_scene.add_child(arrow)

func attack():
	$AnimationPlayer.play("sword_swing")
	
func _input(event):
	if event.is_action_pressed("shoot") and attack_cooldown.is_stopped():
		shoot()
		attack_cooldown.start()
	if event.is_action_pressed("shoot"):
		attack()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	body.queue_free()
