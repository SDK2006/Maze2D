extends Control

var ip_address := "localhost"
var port := 9999

func start_server(_port):
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(_port)
	multiplayer.multiplayer_peer = peer
	Server.server_started.emit()
	
func start_client(_ip_address, _port):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(_ip_address, _port)
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(func():
		print("Connected — sending selection: ", GameState.playerSelection)
		Server.register_selection.rpc_id(1, multiplayer.get_unique_id(), GameState.playerSelection), CONNECT_ONE_SHOT)
	Server.client_started.emit()

func _on_start_server_pressed() -> void:
	#ip_address = $NetworkContainer/ServerContainer/HBoxContainer/ip_edit.text
	port = int($NetworkContainer/ServerContainer/HBoxContainer/port_edit.text)
	Server.friendly_fire = $NetworkContainer/ServerContainer/CheckBox.button_pressed
	start_server(port)

func _on_start_client_pressed() -> void:
	ip_address = $NetworkContainer/ClientContainer/HBoxContainer/ip_edit.text
	port = int($NetworkContainer/ClientContainer/HBoxContainer/port_edit.text)
	start_client(ip_address, port)

func _on_item_list_item_activated(index: int) -> void:
	GameState.playerSelection = $NetworkContainer/ClientContainer/ItemList.get_item_text(index)
	print(GameState.playerSelection)
