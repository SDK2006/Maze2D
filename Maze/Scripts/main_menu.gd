extends Node2D

var buttonType = null
var playersReady = true

func _on_start_pressed() -> void:
	if playersReady:
		buttonType = "start"
		$FadeTransition.show()
		$FadeTransition/FadeTimer.start()
		$FadeTransition/AnimationPlayer.play("fade_in")
	 
func _on_choose_player_pressed() -> void:
	$PlayerSelectionGUI.show()

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_fade_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Maze/Scenes/gameScene.tscn")


func _on_theseus_pressed() -> void:
	NetworkHandler.start_client()
	GameState.playerSelection = "Theseus"
	$PlayerSelectionGUI.hide()
	$ButtonManager/Choose_Player.text = "Player : Theseus"


func _on_minotaur_pressed() -> void:
	NetworkHandler.start_server()
	GameState.playerSelection = "Minotaur"
	$PlayerSelectionGUI.hide()
	$ButtonManager/Choose_Player.text = "Player : Minotaur"

func _on_odysseus_pressed() -> void:
	NetworkHandler.start_client()
	GameState.playerSelection = "Odysseus"
	$PlayerSelectionGUI.hide()
	$ButtonManager/Choose_Player.text = "Player : Odysseus"
