extends Area2D

@export var speed = 300
var direction = Vector2.ZERO
var stop = false

func _ready() -> void:
	await get_tree().create_timer(5).timeout
	despawn()

func _process(delta):
	if not stop:position += direction * speed * delta

func despawn():
	var tween = create_tween()
	tween.tween_property($Sprite2D, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("breakable_wall") or body.is_in_group("enemy"):
		#queue_free()
		stop = true
