extends Player

@onready var attack_cooldown := $AttackCooldown

func attack():
	$AnimationPlayer.play("sword_swing")
	
func _input(event):
	if event.is_action_pressed("shoot") and attack_cooldown.is_stopped():
		attack()
		attack_cooldown.start()
func _on_hurtbox_body_entered(body: Node2D) -> void:
	body.queue_free()
