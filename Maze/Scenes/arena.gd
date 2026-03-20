extends Node2D

@export var boss_scene : PackedScene
@export var archer_scene : PackedScene

func _ready() -> void:
	multiplayer.peer_connected.connect(spawn_player)

func spawn_boss():
	Lobby.start_server()
	
func spawn_player(id: int):
	Lobby.start_client()
	var player = archer_scene.instantiate()
	player.name = str(id)
	$Network.add_child(player)

func _on_server_pressed() -> void:
	Lobby.start_server()

func _on_client_pressed() -> void:
	Lobby.start_client()
