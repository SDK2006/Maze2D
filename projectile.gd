extends Area2D

@export var speed = 300

var shooter_id : int
var direction = Vector2.ZERO

var dmg = 10

var stop = false

func _ready() -> void:
	if !multiplayer.is_server(): monitoring = false
	
	await get_tree().create_timer(5).timeout
	despawn()

func _process(delta):
	if not stop:position += direction * speed * delta

func despawn():
	var tween = create_tween()
	tween.tween_property($Sprite2D, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)

func _on_body_entered(body: Node2D) -> void:
	if (Server.friendly_fire and body.is_in_group("hero") and body.id != shooter_id) or body.is_in_group("boss"):
		body.set_health.rpc(body.get_health() - dmg)
	if body.is_in_group("breakable_wall") or body.is_in_group("unbreakable_wall"):
		#queue_free()
		_sync_stop.rpc()

@rpc("authority", "call_local", "reliable")
func _sync_stop() -> void:
	stop = true
