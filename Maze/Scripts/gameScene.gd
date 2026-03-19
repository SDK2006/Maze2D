extends Node2D

@onready var MPlayer = load("res://Maze/Scenes/Minotaur.tscn").instantiate()
@onready var TPlayer = load("res://Maze/Scenes/Theseus.tscn").instantiate()


func _ready() -> void:
	$FadeTransition/AnimationPlayer.play("fade_out")
	var generator = get_node("MazeGenerator")
	GameState.coords = Vector2(generator._mazeWidth*20-20, generator._mazeDepth*20-20)
	
	if GameState.playerSelection == "Minotaur":
		add_child(MPlayer)
	elif GameState.playerSelection == "Theseus":
		add_child(TPlayer)

func _process(_delta):
	var l = multiplayer.get_peers()
	print(l)
