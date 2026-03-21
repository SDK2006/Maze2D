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
