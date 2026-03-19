extends Node2D

func _ready() -> void:
	$FadeTransition/AnimationPlayer.play("fade_out")
	var generator = get_node("MazeGenerator")
	GameState.coords = Vector2(generator._mazeWidth*20-20, generator._mazeDepth*20-20)
	if GameState.playerSelection=="Minotaur":
		var MPlayer = load("res://Maze/Scenes/Minotaur.tscn").instantiate()
		add_child(MPlayer)
	if GameState.playerSelection=="Theseus":
		var TPlayer = load("res://Maze/Scenes/Theseus.tscn").instantiate()
		add_child(TPlayer)
	print(GameState.coords)
