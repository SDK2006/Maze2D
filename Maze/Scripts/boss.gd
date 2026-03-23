extends Player

const SPEED = 200
const DASH_SPEED = 2400
const DASH_DURATION = 0.5
const DASH_COOLDOWN = 6
const DASH_CAST_LENGTH = 20

var is_dashing := false
var dash_direction := Vector2.ZERO
var can_dash := true
var is_attacking := false
var can_attack := true
var is_dash_waiting := false

const MELEE_DAMAGE = 20
const MELEE_COOLDOWN = 0.8

@onready var DashProgress = $CanvasLayer/Control/DashUI

@onready var dash_cast: ShapeCast2D = $DashCast
@onready var dash_cooldown_timer: Timer = $DashCast/DashCooldownTimer
@onready var dash_duration_timer: Timer = $DashCast/DashDurationTimer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_cooldown_timer: Timer = $AttackCooldown
@onready var melee_hitbox: Area2D = $Hurtbox
@onready var dash_wait_timer: Timer = $DashCast/DashWaitTimer

func enter_tree():
	set_multiplayer_authority(int(name))

func _ready() -> void:
	position = GameState.boss_coords / 2
	
	DashProgress.get_node("TextureProgressBar").value = 0
	
	if !is_multiplayer_authority():	DashProgress.hide()
	
	melee_hitbox.monitoring = false
	melee_hitbox.body_entered.connect(_on_melee_hit)
	sprite.animation_finished.connect(_on_animation_finished)
	attack_cooldown_timer.wait_time = MELEE_COOLDOWN
	attack_cooldown_timer.one_shot = true
	attack_cooldown_timer.timeout.connect(func(): can_attack = true)
	
	var shape = RectangleShape2D.new()
	shape.size = Vector2(30, 40)
	dash_cast.shape = shape
	dash_cast.target_position = Vector2(DASH_CAST_LENGTH, 0)
	dash_cast.collision_mask = 1

	dash_cooldown_timer.wait_time = DASH_COOLDOWN
	dash_cooldown_timer.one_shot = true
	dash_cooldown_timer.timeout.connect(_on_dash_cooldown_finished)

	dash_duration_timer.wait_time = DASH_DURATION
	dash_duration_timer.one_shot = true
	dash_duration_timer.timeout.connect(_on_dash_finished)
	


	var cam = get_node_or_null("Camera2D")
	if cam:
		if is_multiplayer_authority():
			cam.enabled = true
			cam.make_current()
		else:
			cam.enabled = false

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return
	if is_attacking or is_dash_waiting:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if is_dashing:
		_process_dash()
	else:
		_process_movement()
		_check_attack_input()
	move_and_slide()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("view"):
		var init_zoom = $Camera2D.zoom
		var tween = create_tween()
		tween.tween_property($Camera2D, "zoom", Vector2(0.2, 0.2), 0.1)
		await get_tree().create_timer(3).timeout
		tween = create_tween()
		tween.tween_property($Camera2D, "zoom", init_zoom, 0.2)

func _check_attack_input() -> void:
	if Input.is_action_just_pressed("attack") and can_attack and not is_attacking:
		_start_attack()

func _process_movement() -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		sprite.play("walk")
		if direction.x < 0:
			sprite.flip_h = true
			melee_hitbox.position.x = -40
		elif direction.x > 0:
			sprite.flip_h = false
			melee_hitbox.position.x = 40
	else:
		velocity = Vector2.ZERO
		sprite.play("idle")
	
	if Input.is_action_just_pressed("dash") and can_dash:
		_start_dash(direction if direction != Vector2.ZERO else Vector2.RIGHT.rotated(rotation))

func _start_attack() -> void:
	is_attacking = true
	can_attack = false
	sprite.play("attack")
	_sync_attack.rpc()
	# Enable hitbox at 40% through animation
	var frame_count = sprite.sprite_frames.get_frame_count("attack")
	var fps = sprite.sprite_frames.get_animation_speed("attack")
	var mid_time = (frame_count / fps) * 0.1
	await get_tree().create_timer(mid_time).timeout
	melee_hitbox.monitoring = true
	await get_tree().create_timer(0.1).timeout
	melee_hitbox.monitoring = false

func _on_animation_finished() -> void:
	if sprite.animation == "attack":
		is_attacking = false
		attack_cooldown_timer.start()
		sprite.play("idle")

func _on_melee_hit(body: Node2D) -> void:
	if not is_multiplayer_authority():
		return
	if body.is_in_group("hero"):
		body.set_health.rpc(body.get_health() - MELEE_DAMAGE)

@rpc("authority", "call_remote", "reliable")
func _sync_attack() -> void:
	sprite.play("attack")






func _process_dash() -> void:
	velocity = dash_direction * DASH_SPEED
	sprite.play("dash")
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if not is_instance_valid(collider):
			continue
		if collider.is_in_group("hero"):
			collider.set_health.rpc(collider.get_health() - MELEE_DAMAGE * 2)
		if collider is StaticBody2D and collider.is_in_group("breakable_wall"):
			_spawn_break_effect(collider)
			# Use scene root path not relative path
			_destroy_wall.rpc(get_tree().current_scene.get_path_to(collider))

func _start_dash(direction: Vector2) -> void:
	if is_dash_waiting:
		return
	is_dash_waiting = true
	can_dash = false
	dash_direction = direction.normalized()

	# Play wind up animation during the pause
	sprite.play("dash_prep")

	dash_wait_timer.start()
	await dash_wait_timer.timeout

	# Now actually dash
	is_dash_waiting = false
	is_dashing = true
	_break_walls_ahead()
	sprite.play("walk")
	dash_duration_timer.start()
	dash_cooldown_timer.start()
	DashProgress.get_node("AnimationPlayer").play("cooldown")

func _on_dash_finished() -> void:
	is_dashing = false
	velocity = Vector2.ZERO

func _on_dash_cooldown_finished() -> void:
	can_dash = true

func _break_walls_ahead() -> void:
	dash_cast.rotation = 0.0
	dash_cast.force_shapecast_update()
	if not dash_cast.is_colliding():
		return
	for i in dash_cast.get_collision_count():
		var collider = dash_cast.get_collider(i)
		if collider is StaticBody2D and collider.is_in_group("breakable_wall"):
			_spawn_break_effect(collider)
			_destroy_wall.rpc(get_tree().current_scene.get_path_to(collider))

@rpc("authority", "call_local", "reliable")
func _destroy_wall(wall_path: NodePath) -> void:
	var wall = get_tree().current_scene.get_node_or_null(wall_path)
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
