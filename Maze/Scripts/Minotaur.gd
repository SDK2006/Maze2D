extends CharacterBody2D

const SPEED = 100
const DASH_SPEED = 600
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
@onready var quake_cooldown_timer: Timer = $QuakeCooldownTimer

func _ready() -> void:
	position = GameState.coords / 2

	dash_cooldown_timer.wait_time = DASH_COOLDOWN
	dash_cooldown_timer.one_shot = true
	dash_cooldown_timer.timeout.connect(_on_dash_cooldown_finished)

	dash_duration_timer.wait_time = DASH_DURATION
	dash_duration_timer.one_shot = true
	dash_duration_timer.timeout.connect(_on_dash_finished)

	quake_cooldown_timer.wait_time = EARTHQUAKE_COOLDOWN
	quake_cooldown_timer.one_shot = true
	quake_cooldown_timer.timeout.connect(func(): can_quake = true)

	var shape = RectangleShape2D.new()
	shape.size = Vector2(20, 20)
	dash_cast.shape = shape
	dash_cast.target_position = Vector2(DASH_CAST_LENGTH, 0)
	dash_cast.collision_mask = 1

func _physics_process(_delta: float) -> void:
	if is_dashing:
		_process_dash()
	else:
		_process_movement()
	move_and_slide()

# ── Movement ───────────────────────────────────────────────────────────────────

func _process_movement() -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var directionx := Input.get_axis("ui_left", "ui_right")
	var directiony := Input.get_axis("ui_up", "ui_down")

	velocity.x = directionx * SPEED if directionx else move_toward(velocity.x, 0, SPEED)
	velocity.y = directiony * SPEED if directiony else move_toward(velocity.y, 0, SPEED)

	if Input.is_action_just_pressed("dash") and can_dash:
		_start_dash(direction if direction != Vector2.ZERO else Vector2.RIGHT.rotated(rotation))

	if Input.is_action_just_pressed("earthquake") and can_quake:
		_start_earthquake()

# ── Dash ───────────────────────────────────────────────────────────────────────

func _start_dash(direction: Vector2) -> void:
	is_dashing = true
	can_dash = false
	dash_direction = direction.normalized()
	_break_walls_ahead()
	dash_duration_timer.start()
	dash_cooldown_timer.start()

func _process_dash() -> void:
	velocity = dash_direction * DASH_SPEED
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is StaticBody2D and collider.is_in_group("breakable_wall"):
			_spawn_break_effect(collider)
			collider.ClearWall()

func _break_walls_ahead() -> void:
	dash_cast.rotation = 0.0
	dash_cast.force_shapecast_update()
	if not dash_cast.is_colliding():
		return
	for i in dash_cast.get_collision_count():
		var collider = dash_cast.get_collider(i)
		if collider is StaticBody2D and collider.is_in_group("breakable_wall"):
			_spawn_break_effect(collider)
			collider.ClearWall()

func _on_dash_finished() -> void:
	is_dashing = false
	velocity = Vector2.ZERO

func _on_dash_cooldown_finished() -> void:
	can_dash = true

# ── Earthquake ─────────────────────────────────────────────────────────────────

func _start_earthquake() -> void:
	can_quake = false
	quake_cooldown_timer.start()
	_break_walls_in_radius()
	_spawn_quake_debris()
	_shake_camera()
	_stun_theseus()

func _break_walls_in_radius() -> void:
	var space = get_world_2d().direct_space_state
	var shape = CircleShape2D.new()
	shape.radius = EARTHQUAKE_RANGE

	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, global_position)
	query.collision_mask = 1

	var results = space.intersect_shape(query)
	for result in results:
		var collider = result.collider
		if collider is StaticBody2D and collider.is_in_group("breakable_wall"):
			_spawn_break_effect(collider)
			collider.ClearWall()

func _stun_theseus() -> void:
	for node in get_tree().get_nodes_in_group("theseus"):
		if global_position.distance_to(node.global_position) <= EARTHQUAKE_RANGE:
			node.apply_stun(EARTHQUAKE_STUN_DURATION)

func _spawn_quake_debris() -> void:
	var effect_scene = load("res://Maze/WallBreakEffect.tscn")
	if effect_scene == null:
		return
	for i in 8:
		var angle = i * TAU / 8.0
		var offset = Vector2(cos(angle), sin(angle)) * randf_range(30, EARTHQUAKE_RANGE * 0.5)
		var effect = effect_scene.instantiate()
		get_tree().current_scene.add_child(effect)
		effect.global_position = global_position + offset
		effect.explode()

func _shake_camera() -> void:
	var camera = get_viewport().get_camera_2d()
	if camera == null:
		return
	var tween = create_tween()
	var original = camera.offset
	for i in 12:
		tween.tween_property(camera, "offset", Vector2(randf_range(-8, 8), randf_range(-8, 8)), 0.05)
	tween.tween_property(camera, "offset", original, 0.05)

# ── Wall break effect ──────────────────────────────────────────────────────────

func _spawn_break_effect(wall: StaticBody2D) -> void:
	var effect_scene = load("res://Maze/WallBreakEffect.tscn")
	if effect_scene == null:
		push_error("WallBreakEffect.tscn not found")
		return
	var effect = effect_scene.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.global_position = wall.global_position
	effect.explode()
