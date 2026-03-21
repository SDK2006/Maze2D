extends Player

@export var arrow_scene : PackedScene
@onready var attack_cooldown := $AttackCooldown

func enter_tree():
	set_multiplayer_authority(int(name))

func shoot():
	var arrow = arrow_scene.instantiate()
	arrow.global_position = global_position
	arrow.direction = (get_global_mouse_position() - global_position).normalized()
	arrow.rotation = arrow.direction.angle()
	
	var cam = get_node_or_null("Camera2D")
	if cam:
		if is_multiplayer_authority():
			cam.enabled = true
			cam.make_current()
		else:
			cam.enabled = false
	
	get_tree().current_scene.add_child(arrow)

func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority(): return
	if event.is_action_pressed("shoot") and attack_cooldown.is_stopped():
		var dir = (get_global_mouse_position() - global_position).normalized()
		Server.player_shoot.rpc(name.to_int(), global_position, dir)
		attack_cooldown.start()
