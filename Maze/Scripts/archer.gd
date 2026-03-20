extends Player

@export var arrow_scene : PackedScene
@onready var attack_cooldown := $AttackCooldown

func shoot():
	var arrow = arrow_scene.instantiate()
	arrow.global_position = global_position
	arrow.direction = (get_global_mouse_position() - global_position).normalized()
	arrow.rotation = arrow.direction.angle()
	
	get_tree().current_scene.add_child(arrow)

func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority(): return
	if event.is_action_pressed("shoot") and attack_cooldown.is_stopped():
		var dir = (get_global_mouse_position() - global_position).normalized()
		Lobby.player_shoot.rpc(name.to_int(), global_position, dir)
		attack_cooldown.start()
