extends Node

signal server_started
signal client_started
signal client_ready

var arena_scene := preload("res://Maze/Scenes/arena.tscn")
var boss_scene := preload("res://Maze/Scenes/boss.tscn")
var archer_scene := preload("res://Maze/Scenes/archer.tscn")
var arrow_scene := preload("res://Maze/Scenes/arrow.tscn")
var warrior_scene := preload("res://Maze/Scenes/warrior.tscn")

var player_selections := {}

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
			player_selections[1] = GameState.playerSelection
			spawn_boss(1)
			multiplayer.peer_connected.connect(_on_peer_connected)
	)
	
	client_started.connect(
		func() -> void:
			get_tree().change_scene_to_packed(arena_scene)
			await get_tree().scene_changed
			spawner = get_tree().current_scene.get_node_or_null("MultiplayerSpawner")
	)
	
	
	
func _on_peer_connected(id: int) -> void:
	if not multiplayer.is_server():
		return
	add_player(id, "nil", 100, 0)
	for _id in players.keys():
		sync_players.rpc_id(_id, players)
	if id != 1:
		set_maze_seed.rpc_id(id, maze_seed)
	print(id, " has joined.")
	# Tell client server is ready to receive their selection
	_server_ready.rpc_id(id)

@rpc("authority", "call_remote", "reliable")
func _server_ready() -> void:
	# Client only sends selection after server confirms it's ready
	register_selection.rpc_id(1, multiplayer.get_unique_id(), GameState.playerSelection)





	
	
	'''multiplayer.peer_connected.connect(
		func(id: int) -> void:
			if multiplayer.is_server():
				add_player(id, "nil", 100, 0) # Adds player to server player list
				for _id in players:
					sync_players.rpc_id(_id, players) # Syncs server player list to client player list
				if id != 1: set_maze_seed.rpc_id(id, maze_seed)
				print(id, " has joined.")
				if id == multiplayer.get_unique_id(): client_ready.emit()
	)'''
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
	#checking for errors
	if is_instance_valid(get_tree().current_scene.get_node_or_null(str(id))):
		print("Already spawned: ", id)
		return
	var selection = player_selections.get(id, "")
	if selection == "":
		push_error("No selection for: " + str(id))
		return
	
	print("Spawning: ", selection, " for: ", id)
	print(selection)
	var hero
	if selection == "Archer":
		hero = archer_scene.instantiate()
		print(GameState.playerSelection)
	else:
		hero = warrior_scene.instantiate()
		print(GameState.playerSelection)
	hero.name = str(id)
	spawner.get_node(spawner.spawn_path).add_child(hero)

@rpc("any_peer", "call_remote", "reliable")
func register_selection(id: int, selection: String) -> void:
	if not multiplayer.is_server():
		return
	print("Player ", id, " selected: ", selection)
	player_selections[id] = selection
	spawn_player(id)

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
	if not is_instance_valid(player):
		return
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
