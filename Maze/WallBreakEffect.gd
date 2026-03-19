extends Node2D

# Shard count and how far they fly
const SHARD_COUNT = 8
const SHARD_SPEED_MIN = 80.0
const SHARD_SPEED_MAX = 220.0
const SHARD_LIFETIME = 0.5

# Match this to your wall's colour
const SHARD_COLOR = Color(0.6, 0.45, 0.3)   # brownish stone

var _shards: Array = []

func explode() -> void:
	for i in SHARD_COUNT:
		var shard = _make_shard()
		add_child(shard)
		_shards.append(shard)

func _make_shard() -> Node2D:
	var shard = Node2D.new()

	# Random rectangular piece
	var rect = ColorRect.new()
	rect.size = Vector2(randf_range(6, 18), randf_range(6, 18))
	rect.position = -rect.size / 2.0
	rect.color = SHARD_COLOR.darkened(randf_range(0.0, 0.3))
	shard.add_child(rect)

	# Random outward velocity
	var angle = randf_range(0.0, TAU)
	var speed = randf_range(SHARD_SPEED_MIN, SHARD_SPEED_MAX)
	shard.set_meta("velocity", Vector2(cos(angle), sin(angle)) * speed)
	shard.set_meta("rotation_speed", randf_range(-6.0, 6.0))
	shard.set_meta("lifetime", SHARD_LIFETIME)
	shard.set_meta("age", 0.0)

	return shard

func _process(delta: float) -> void:
	var all_done = true

	for shard in _shards:
		var age: float = shard.get_meta("age") + delta
		shard.set_meta("age", age)

		var t = age / SHARD_LIFETIME

		if t < 1.0:
			all_done = false
			# Move outward
			shard.position += shard.get_meta("velocity") * delta
			# Spin
			shard.rotation += shard.get_meta("rotation_speed") * delta
			# Fade and shrink
			shard.modulate.a = 1.0 - t
			shard.scale = Vector2.ONE * (1.0 - t * 0.5)

	if all_done:
		queue_free()
