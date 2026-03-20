extends Node2D
class_name MazeCell

#@export var _UnvisitedBlock:Node2D
@export var _FrontWall:Node2D
@export var _BackWall:Node2D
@export var _LeftWall:Node2D
@export var _RightWall:Node2D

var IsVisited : bool = false

func Visit():
	IsVisited = true;

func ClearAll():
	ClearLeftWall()
	ClearRightWall()
	ClearFrontWall()
	ClearBackWall()

func ClearLeftWall():
	_LeftWall.collision_layer = 0
	_LeftWall.collision_mask = 0
	_LeftWall.hide()

func ClearRightWall():
	_RightWall.collision_layer = 0
	_RightWall.collision_mask = 0
	_RightWall.hide()

func ClearFrontWall():
	_FrontWall.collision_layer = 0
	_FrontWall.collision_mask = 0
	_FrontWall.hide()
func ClearBackWall():
	_BackWall.collision_layer = 0
	_BackWall.collision_mask = 0
	_BackWall.hide()
