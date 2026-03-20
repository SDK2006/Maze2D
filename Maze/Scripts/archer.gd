extends Player

@export var arrow_scene : PackedScene
@onready var attack_cooldown := $AttackCooldown

func shoot():
	var arrow = arrow_scene.instantiate()
	arrow.global_position = global_position
	arrow.direction = (get_global_mouse_position() - global_position).normalized()
	arrow.rotation = arrow.direction.angle()
	
	get_tree().current_scene.add_child(arrow)

func _input(event):
	if event.is_action_pressed("shoot") and attack_cooldown.is_stopped():
		shoot()
		attack_cooldown.start()
