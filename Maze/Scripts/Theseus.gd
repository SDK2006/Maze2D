extends CharacterBody2D

var coords : Vector2

const SPEED = 100

const MIN_POINT_DISTANCE = 1
const MAX_POINTS = 10000
const REWIND_DISTANCE = 12.0
const SMOOTH_ITERATIONS = 1

var _string_points: PackedVector2Array = []
var _start_position: Vector2

@onready var string_line: Line2D = get_node("TheseusString")
	
func _ready():
	position = GameState.coords
	_start_position = global_position
	_string_points.append(_start_position)
	_update_line_with_tail(global_position)

func _physics_process(_delta: float) -> void:
	var directiony := Input.get_axis("ui_up", "ui_down")
	var directionx := Input.get_axis("ui_left", "ui_right")
	if directiony:
		velocity.y = directiony * SPEED
	else:
		velocity.y = move_toward(velocity.x, 0, SPEED)
	
	if directionx:
		velocity.x = directionx * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	
	_check_rewind()
	_record_position()

func _record_position() -> void:
	if _string_points.is_empty():
		_string_points.append(global_position)
		return
	
	var last = _string_points[-1]
	if global_position.distance_to(last) >= MIN_POINT_DISTANCE:
		_string_points.append(global_position)
		if _string_points.size() > MAX_POINTS:
			_string_points.remove_at(1)
		
		_update_line_with_tail(global_position)
	
	_string_points.append(global_position)
	
	if _string_points.size() > MAX_POINTS:
		_string_points.remove_at(1)
	
	_update_line(_string_points)

func _update_line(points: PackedVector2Array) -> void:
	if string_line == null:
		return
	string_line.clear_points()
	for p in points:
		string_line.add_point(string_line.to_local(p))

func _update_line_with_tail(tail: Vector2) -> void:
	if string_line == null:
		return
	var raw := _string_points.duplicate()
	raw.append(tail)
	var smoothed := _smooth_points(raw)
	string_line.clear_points()
	for p in smoothed:
		string_line.add_point(string_line.to_local(p))

func _check_rewind() -> void:
	if _string_points.size() < 3:
		return
	
	var check_until = _string_points.size() - 5
	for i in range(1, check_until):   # skip index 0 (the fixed start point)
		if global_position.distance_to(_string_points[i]) < REWIND_DISTANCE:
			_string_points.resize(i + 1)
			break   # only rewind to the nearest match per frame

func _smooth_points(points: PackedVector2Array) -> PackedVector2Array:
	if points.size() < 3:
		return points
	var smoothed := points
	for _i in SMOOTH_ITERATIONS:
		var result := PackedVector2Array()
	# Always keep the fixed start anchor
		result.append(smoothed[0])
		for j in range(1, smoothed.size() - 1):
			var p0 = smoothed[j - 1]
			var p1 = smoothed[j]
			var p2 = smoothed[j + 1]
			result.append(p0.lerp(p1, 0.75))
			result.append(p1.lerp(p2, 0.25))
		result.append(smoothed[-1])
		smoothed = result
	return smoothed
