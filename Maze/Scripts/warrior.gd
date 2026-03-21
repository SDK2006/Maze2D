extends Player

@onready var attack_cooldown := $AttackCooldown

func attack():
	$AnimationPlayer.play("sword_swing")

func _input(event):
	if event.is_action_pressed("shoot") and attack_cooldown.is_stopped():
		print(attack_cooldown.is_stopped())
		attack()
		attack_cooldown.start()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	
	#all walls except border walls are in the group "breakable_wall" so only those walls will break(SDK)
	#ClearWall() is a function attached to each wall that queue_free()
	if body.is_in_group("breakable_wall") and !attack_cooldown.is_stopped():
		_destroy_wall.rpc(get_path_to(body))

@rpc("authority", "call_local", "reliable")
func _destroy_wall(wall_path: NodePath) -> void:
	var wall = get_node_or_null(wall_path)
	if wall == null:
		return
	_spawn_break_effect(wall)
	wall.ClearWall()

func _spawn_break_effect(wall: StaticBody2D) -> void:
	var effect_scene = load("res://Maze/WallBreakEffect.tscn")
	if effect_scene == null:
		push_error("WallBreakEffect.tscn not found")
		return
	var effect = effect_scene.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.global_position = wall.global_position
	effect.explode()
