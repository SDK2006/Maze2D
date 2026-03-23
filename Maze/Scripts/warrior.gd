extends Player

@onready var hurtbox = $Sword/Hurtbox
@onready var attack_cooldown := $AttackCooldown
@onready var buff_duration := $BuffDurationTimer
@onready var buff_cooldown := $BuffCooldownTimer
@onready var sword := $Sword
@onready var buff_progress := $CanvasLayer/BuffUI

var dmg = 10
var _already_hit := []

func _enter_tree():
	set_multiplayer_authority(int(name))

func _ready():
	buff_cooldown.start()
	var cam = get_node_or_null("Camera2D")
	if cam:
		cam.enabled = is_multiplayer_authority()
		if is_multiplayer_authority():
			cam.make_current()
	
	
	'''if !is_multiplayer_authority:
		buff_progress.hide()
	if multiplayer.is_server():
		buff_progress.hide()'''

func attack():
	$AnimationPlayer.play("sword_swing")

func _input(event):
	if !is_multiplayer_authority():	return
	if event.is_action_pressed("shoot") and attack_cooldown.is_stopped():
		print(attack_cooldown.is_stopped())
		attack()
		attack_cooldown.start()
		_already_hit.clear()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body in _already_hit:
		return
	if body.is_in_group("boss"):
		_already_hit.append(body)
		_deal_damage.rpc_id(1, body.get_path(), dmg)
	if body.is_in_group("breakable_wall") and !buff_duration.is_stopped():
			_destroy_wall.rpc(get_path_to(body))

@rpc("any_peer", "call_remote", "reliable")
func _deal_damage(target_path: NodePath, damage: int) -> void:
	if not multiplayer.is_server():
		return
	var target = get_node_or_null(target_path)
	if target == null:
		return
	target.set_health.rpc(target.get_health() - damage)

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


func _on_buff_cooldown_timer_timeout() -> void:
	sword.scale.x = 1.8
	sword.scale.y = 1.8
	sword.get_node("Sprite/Sprite2D").modulate = Color(1.0, 0.0, 0.0, 1.0)
	#buff_progress.get_node("AnimationPlayer").play("animation")
	buff_duration.start()


func _on_buff_duration_timer_timeout() -> void:
	sword.scale.x = 1.5
	sword.scale.y = 1.5
	sword.get_node("Sprite/Sprite2D").modulate = Color(1.0, 1.0, 1.0, 1.0)
	buff_cooldown.start()
