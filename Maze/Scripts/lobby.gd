extends Node

const IP_ADDRESS := "localhost"
const PORT := 9999
var pvp := false

var arrow_scene := preload("res://Maze/Scenes/arrow.tscn")

signal server_started

var players := {}
func add_player(id: int, username: String, health: int, score: int):
	players[id] = {
		"username": username,
		"health": health,
		"score": score
	}

@rpc("authority")
func sync_players(server_players: Dictionary) -> void:
	Lobby.players = server_players

func create_server():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	server_started.emit()
	
func create_client():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer

@rpc("any_peer", "call_local")
func update_player(id : int, pos: Vector2, rot: float):
	var player = get_tree().current_scene.get_node(str(id))
	player.global_position = pos
	player.global_rotation = rot
	
@rpc("any_peer", "call_local")
func player_shoot(id: int, origin: Vector2, direction: Vector2):
	var arrow = arrow_scene.instantiate()
	arrow.shooter_id = id
	arrow.global_position = origin
	arrow.global_rotation = direction.angle()
	arrow.direction = direction
	get_tree().current_scene.add_child(arrow)
	
