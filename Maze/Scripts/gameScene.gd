extends Node2D

func _ready() -> void:
	$FadeTransition/AnimationPlayer.play("fade_out")
	var generator = get_node("MazeGenerator")
	GameState.coords = Vector2(generator._mazeWidth*40-20, generator._mazeDepth*40-20)
	if GameState.playerSelection=="Minotaur":
		var MPlayer = load("res://Maze/Scenes/Minotaur.tscn").instantiate()
		add_child(MPlayer)
	if GameState.playerSelection=="Theseus":
		var TPlayer = load("res://Maze/Scenes/warrior.tscn").instantiate()
		add_child(TPlayer)
	if GameState.playerSelection=="Odysseus":
		var TPlayer = load("res://Maze/Scenes/archer.tscn").instantiate()
		add_child(TPlayer)
	print(GameState.coords)
