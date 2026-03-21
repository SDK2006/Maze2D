extends Node

signal server_started
signal client_started
signal client_ready

var arena_scene := preload("res://Maze/Scenes/arena.tscn")
var boss_scene := preload("res://Maze/Scenes/boss.tscn")
var archer_scene := preload("res://Maze/Scenes/archer.tscn")
var arrow_scene := preload("res://Maze/Scenes/arrow.tscn")
var warrior_scene := preload("res://Maze/Scenes/warrior.tscn")

var spawner : MultiplayerSpawner

var friendly_fire := false
var players := {}
var maze_seed : int

func _ready() -> void:
	server_started.connect(
		func() -> void:
			get_tree().change_scene_to_packed(arena_scene)
			await get_tree().scene_changed
			spawner = get_tree().current_scene.get_node_or_null("MultiplayerSpawner")
			Server.add_player(1, "owner", 100, 0)
			spawn_boss(1)
	)
	
	client_started.connect(
		func() -> void:
			get_tree().change_scene_to_packed(arena_scene)
			await get_tree().scene_changed
			spawner = get_tree().current_scene.get_node_or_null("MultiplayerSpawner")
	)
	
	multiplayer.peer_connected.connect(
		func(id: int) -> void:
			if multiplayer.is_server():
				add_player(id, "nil", 100, 0) # Adds player to server player list
				for _id in players:
					sync_players.rpc_id(_id, players) # Syncs server player list to client player list
				if id != 1: set_maze_seed.rpc_id(id, maze_seed)
				print(id, " has joined.")
				if id == multiplayer.get_unique_id(): client_ready.emit()
				spawn_player(id)
	)
	multiplayer.peer_disconnected.connect(
		func(id: int) -> void:
			print(id, " has left.")
			Server.players.erase(id)
			for _id in players:
				sync_players.rpc_id(_id, players)
			get_tree().current_scene.get_node(str(id)).queue_free() # ERROR PRONE
	)

func add_player(id: int, username: String, health: int, score: int):
	players[id] = {
		"username": username,
		"health": health,
		"score": score
	}
	
func spawn_player(id : int) -> void:
	var hero = archer_scene.instantiate()
	hero.name = str(id)
	spawner.get_node(spawner.spawn_path).add_child(hero)
	
func spawn_boss(id := 1) -> void:
	var boss = boss_scene.instantiate()
	boss.name = str(id)
	spawner.get_node(spawner.spawn_path).add_child(boss)

@rpc("authority")
func sync_players(server_players: Dictionary) -> void:
	players = server_players

@rpc("any_peer", "call_local")
func update_player(id : int, pos: Vector2, rot: float):
	var player = get_tree().current_scene.get_node(str(id))
	player.global_position = pos
	player.global_rotation = rot
	
@rpc("any_peer", "call_local")
func player_shoot(id: int, origin: Vector2, direction: Vector2, specialArrow):
	var arrow = arrow_scene.instantiate()
	arrow.shooter_id = id
	arrow.global_position = origin
	arrow.global_rotation = direction.angle()
	arrow.direction = direction
	if specialArrow == 5:
		arrow.scale = Vector2(2, 2)
		arrow.get_node("Sprite2D").modulate = Color("ffff00ff")
		arrow.dmg = 20
		get_tree().current_scene.add_child(arrow)
		print("The arrows came lool")
	else:
		get_tree().current_scene.add_child(arrow)
		print(specialArrow)
	
@rpc("authority", "call_remote")
func set_maze_seed(new_seed: int):
	maze_seed = new_seed
	
