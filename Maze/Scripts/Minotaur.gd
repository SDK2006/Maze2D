extends CharacterBody2D

var coords : Vector2 

const SPEED = 100

const DASH_SPEED = 600
const DASH_DURATION = 0.5
const DASH_COOLDOWN = 1.0
const DASH_CAST_LENGTH = 50 

var is_dashing := false
var dash_direction := Vector2.ZERO
var can_dash := true

@onready var dash_cast: ShapeCast2D = $DashCast
@onready var dash_cooldown_timer: Timer = $DashCast/DashCooldownTimer
@onready var dash_duration_timer: Timer = $DashCast/DashDurationTimer

func _ready():
	position = GameState.coords/2
	
	dash_cooldown_timer.wait_time = DASH_COOLDOWN
	dash_cooldown_timer.one_shot = true
	dash_cooldown_timer.timeout.connect(_on_dash_cooldown_finished)
	
	dash_duration_timer.wait_time = DASH_DURATION
	dash_duration_timer.one_shot = true
	dash_duration_timer.timeout.connect(_on_dash_finished)
	
	dash_cast.target_position = Vector2(DASH_CAST_LENGTH, 0)
	dash_cast.collision_mask = 1

func _physics_process(_delta: float) -> void:
	
	if is_dashing:
		_process_dash()
	else:
		_process_movement()
	
	move_and_slide()

func _process_movement():
	var directiony := Input.get_axis("ui_up", "ui_down")
	var directionx := Input.get_axis("ui_left", "ui_right")
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if directiony:
		velocity.y = directiony * SPEED
	else:
		velocity.y = move_toward(velocity.x, 0, SPEED)
	
	if directionx:
		velocity.x = directionx * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if Input.is_action_just_pressed("dash") and can_dash:
		_start_dash(direction)

func _start_dash(direction: Vector2) -> void:
	is_dashing = true
	can_dash = false
	dash_direction = direction.normalized()
	_break_walls_ahead()
	
	dash_duration_timer.start()
	dash_cooldown_timer.start()

func _process_dash() -> void:
	velocity = dash_direction * DASH_SPEED
	
	# Keep breaking walls mid-dash if we're still hitting them
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is StaticBody2D and collider.is_in_group("breakable_wall"):
			_spawn_break_effect(collider)
			collider.queue_free()

func _break_walls_ahead() -> void:
	# Force shape cast to update this frame
	dash_cast.rotation = 0.0  # cast is local — already faces forward with the node
	dash_cast.force_shapecast_update()
	
	if not dash_cast.is_colliding():
		return
	
	for i in dash_cast.get_collision_count():
		var collider = dash_cast.get_collider(i)
		if collider is StaticBody2D and collider.is_in_group("breakable_wall"):
			_spawn_break_effect(collider)
			collider.ClearWall()

func _spawn_break_effect(wall: StaticBody2D) -> void:
	var effect_scene = load("res://Maze/WallBreakEffect.tscn")
	if effect_scene == null:
		push_error("WallBreakEffect.tscn not found — check the path in minotaur.gd")
		return
	
	var effect = effect_scene.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.global_position = wall.global_position
	effect.explode()

func _on_dash_finished() -> void:
	is_dashing = false
	velocity = Vector2.ZERO

func _on_dash_cooldown_finished() -> void:
	can_dash = true
