extends Node2D

@export var boss_scene : PackedScene
@export var archer_scene : PackedScene
@onready var spawner := $MultiplayerSpawner

func _ready() -> void:
	Lobby.server_started.connect(
		func() -> void:
			Lobby.add_player(1, "owner", 100, 0)
			spawn_boss(1))
	
	multiplayer.peer_connected.connect(
		func(id: int) -> void:
			if id == 1:
				print(id, " has joined.")
				spawn_player(id)
	)
	multiplayer.peer_disconnected.connect(
		func(id: int) -> void:
			print(id, " has left.")
			Lobby.players.erase(id)
			get_tree().current_scene.get_node(str(id)).queue_free()
	)

func _process(_delta: float) -> void:
	$UI/Label.text = str(Lobby.players)

func spawn_player(id : int) -> void:
	if multiplayer.is_server():
		#Lobby.sync_players.rpc_id(id, Lobby.players)
		Lobby.add_player(id, "nil", 100, 0)
		var player = archer_scene.instantiate()
		player.name = str(id)
		spawner.get_node(spawner.spawn_path).add_child(player)
	
func spawn_boss(id := 1) -> void:
	if !multiplayer.is_server(): return
	#Lobby.sync_players.rpc_id(id, Lobby.players)
	var boss = boss_scene.instantiate()
	boss.name = str(id)
	spawner.get_node(spawner.spawn_path).add_child(boss)

func _on_server_pressed() -> void:
	Lobby.create_server()

func _on_client_pressed() -> void:
	Lobby.create_client()
