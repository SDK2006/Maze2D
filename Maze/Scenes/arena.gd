extends Node2D

func _process(_delta: float) -> void:
	$UI/Label.text = "Seed: " + str(Server.maze_seed) + "\n" + str(Server.players)
