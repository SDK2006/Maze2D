extends CharacterBody2D
class_name Player

var coords : Vector2
@export var speed = 100

var id : int

func _enter_tree() -> void:
	id = name.to_int()
	set_multiplayer_authority(id)

@rpc("any_peer", "call_local")
func set_health(new_value: int) -> void:
	Lobby.players[id].health = new_value
	$Stats/HealthBar.value = new_value
	if Lobby.players[id].health <= 0: die()
	
func get_health() -> int: return Lobby.players[id].health

func _ready():
	position = Vector2(100, 100)
	$Stats.top_level = true
	$Stats/Label.text = name
	set_health.rpc(100)

func _process(_delta: float) -> void:
	$Stats.global_position = global_position

func _physics_process(_delta: float) -> void:
	if !is_multiplayer_authority(): return
	var direction = Input.get_vector("left", "right", "up", "down").normalized()
	velocity = direction * speed
	if get_window().has_focus(): look_at(get_global_mouse_position())
	move_and_slide()
	
	Lobby.update_player.rpc(name.to_int(), global_position, global_rotation)

func die():
	Lobby.players.erase(id)
	queue_free()
