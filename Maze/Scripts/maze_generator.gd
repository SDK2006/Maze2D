
extends Node2D
@export var _MazeCellPrefab : PackedScene
@export var _mazeWidth : int
@export var _mazeDepth : int

@export var bruhTexture : CompressedTexture2D

var _mazeGrid = Array()

@export var chamberRadius : int

var rng = RandomNumberGenerator.new()



var time = 0

func _ready():
	build_maze()

func build_maze() -> void:
	for i in range(_mazeWidth):
		_mazeGrid.append([])
		for j in range(_mazeDepth):
			var newInstance = _MazeCellPrefab.instantiate()
			newInstance.name = "MazeCell%d%d"%[i,j]
			newInstance.position = Vector2(i*40, j*40)
			_mazeGrid[i].append(newInstance)
	_GenerateMaze(_mazeGrid[0][0])
	
	#Creating Minotaur Chamber
	var midWidth = int(_mazeWidth/2.0)
	var midDepth = int(_mazeWidth/2.0)
	for i in range(midDepth-chamberRadius, midDepth+chamberRadius):
		for j in range(midWidth-chamberRadius, midWidth+chamberRadius):
			_mazeGrid[i][j].ClearAll()
	
	#Creating breakable and unbreakable walls and adding maze as child
	for i in range(0, _mazeWidth):
		for j in range(0, _mazeDepth):
			_mazeGrid[0][j].get_node("LeftWall").remove_from_group("breakable_wall")
			_mazeGrid[0][j].get_node("LeftWall").add_to_group("unbreakable_wall")
			_mazeGrid[_mazeWidth-1][j].get_node("RightWall").remove_from_group("breakable_wall")
			_mazeGrid[_mazeWidth-1][j].get_node("RightWall").add_to_group("unbreakable_wall")
			_mazeGrid[j][0].get_node("FrontWall").remove_from_group("breakable_wall")
			_mazeGrid[j][0].get_node("FrontWall").add_to_group("unbreakable_wall")
			_mazeGrid[j][_mazeDepth-1].get_node("BackWall").remove_from_group("breakable_wall")
			_mazeGrid[j][_mazeDepth-1].get_node("BackWall").add_to_group("unbreakable_wall")
			add_child(_mazeGrid[i][j])

func _GenerateMaze(startCell: MazeCell):
	# Each stack entry is [previousCell, currentCell]
	var stack = []
	stack.append([null, startCell])
	
	
	while stack.size() > 0:
		var entry = stack.back()
		var previousCell : MazeCell = entry[0]
		var currentCell  : MazeCell = entry[1]

		if not currentCell.IsVisited:
			currentCell.Visit()
			_ClearWalls(previousCell, currentCell)

		var nextCell = _GetNextUnvisitedCell(currentCell)

		if nextCell != null:
			# Push next cell onto stack (keep current for backtracking)
			stack.append([currentCell, nextCell])
		else:
			# No unvisited neighbours — backtrack
			stack.pop_back()

func _GetNextUnvisitedCell(currentCell: MazeCell):
	var unvisitedCells = _GetUnvisitedCells(currentCell)
	if unvisitedCells.size() != 0:
		return unvisitedCells.pick_random()
	else:
		return null

func _GetUnvisitedCells(currentCell: MazeCell):
	var x: int = int(currentCell.position.x / 40)
	var y: int = int(currentCell.position.y /40)
	var cells = []

	if x + 1 < _mazeWidth:
		var cellToRight = _mazeGrid[x+1][y]
		if not cellToRight.IsVisited:
			cells.append(cellToRight)
	if x - 1 >= 0:
		var cellToLeft = _mazeGrid[x-1][y]
		if not cellToLeft.IsVisited:
			cells.append(cellToLeft)
	if y + 1 < _mazeDepth:
		var cellToBack = _mazeGrid[x][y+1]
		if not cellToBack.IsVisited:
			cells.append(cellToBack)
	if y - 1 >= 0:
		var cellToFront = _mazeGrid[x][y-1]
		if not cellToFront.IsVisited:
			cells.append(cellToFront)
	print("Bruh")
	return cells

func _ClearWalls(previousCell: MazeCell, currentCell: MazeCell):
	if previousCell == null:
		return
	if previousCell.position.x > currentCell.position.x:
		previousCell.ClearLeftWall()
		currentCell.ClearRightWall()
		return
	if previousCell.position.x < currentCell.position.x:
		previousCell.ClearRightWall()
		currentCell.ClearLeftWall()
		return
	if previousCell.position.y > currentCell.position.y:
		previousCell.ClearFrontWall()
		currentCell.ClearBackWall()
		return
	if previousCell.position.y < currentCell.position.y:
		previousCell.ClearBackWall()
		currentCell.ClearFrontWall()
		return
