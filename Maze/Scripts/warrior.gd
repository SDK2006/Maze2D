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
		body.ClearWall()
