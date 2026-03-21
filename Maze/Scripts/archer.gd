extends Player

@export var arrow_scene : PackedScene
@onready var attack_cooldown := $AttackCooldown

var specialArrow = 0

var specialArrowCount = 0

func enter_tree():
	set_multiplayer_authority(int(name))

func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority(): return
	if event.is_action_pressed("shoot") and attack_cooldown.is_stopped():
		var dir = (get_global_mouse_position() - global_position).normalized()
		Server.player_shoot.rpc(name.to_int(), global_position, dir, specialArrow)
		specialArrow += 1
		if specialArrow == 6:	specialArrow = 0
		attack_cooldown.start()
