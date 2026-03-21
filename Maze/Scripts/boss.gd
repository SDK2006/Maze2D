extends Player

const SPEED = 200
const DASH_SPEED = 2400
const DASH_DURATION = 0.5
const DASH_COOLDOWN = 1.0
const DASH_CAST_LENGTH = 50

const EARTHQUAKE_RANGE = 200.0
const EARTHQUAKE_COOLDOWN = 5.0
const EARTHQUAKE_STUN_DURATION = 2.0

var is_dashing := false
var dash_direction := Vector2.ZERO
var can_dash := true
var can_quake := true

@onready var dash_cast: ShapeCast2D = $DashCast
@onready var dash_cooldown_timer: Timer = $DashCast/DashCooldownTimer
@onready var dash_duration_timer: Timer = $DashCast/DashDurationTimer
@onready var sprite = $AnimatedSprite2D

func enter_tree():
	set_multiplayer_authority(int(name))

func _ready() -> void:
	position = GameState.coords / 2

	var shape = RectangleShape2D.new()
	shape.size = Vector2(20, 20)
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
	if !is_multiplayer_authority(): return
	var direction = Input.get_vector("left", "right", "up", "down").normalized()
	velocity = direction * speed
	if is_dashing:
		_process_dash()
	else:
		_process_movement()
	move_and_slide()

func _process_movement() -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		sprite.play("walk")
		if direction.x < 0:
			sprite.flip_h = true
		elif direction.x > 0:
			sprite.flip_h = false
	else:
		velocity = Vector2.ZERO
		sprite.play("idle")

	if Input.is_action_just_pressed("dash") and can_dash:
		_start_dash(direction if direction != Vector2.ZERO else Vector2.RIGHT.rotated(rotation))


func _process_dash() -> void:
	velocity = dash_direction * DASH_SPEED
	sprite.play("dash")
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is StaticBody2D and collider.is_in_group("breakable_wall"):
			_spawn_break_effect(collider)
			_destroy_wall.rpc(get_path_to(collider))

func _start_dash(direction: Vector2) -> void:
	is_dashing = true
	can_dash = false
	dash_direction = direction.normalized()
	_break_walls_ahead()
	dash_duration_timer.start()
	dash_cooldown_timer.start()

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
			_destroy_wall.rpc(get_path_to(collider))

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
