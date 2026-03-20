extends Node2D
class_name MazeCell

@export var _UnvisitedBlock:Node2D
@export var _FrontWall:Node2D
@export var _BackWall:Node2D
@export var _LeftWall:Node2D
@export var _RightWall:Node2D

var IsVisited : bool = false

func Visit():
	IsVisited = true;

func ClearAll():
	_LeftWall.set_process_mode(Node.PROCESS_MODE_DISABLED)
	_LeftWall.hide()
	_RightWall.set_process_mode(Node.PROCESS_MODE_DISABLED)
	_RightWall.hide()
	_FrontWall.set_process_mode(Node.PROCESS_MODE_DISABLED)
	_FrontWall.hide()
	_BackWall.set_process_mode(Node.PROCESS_MODE_DISABLED)
	_BackWall.hide()

func CreateAll():
	_LeftWall.set_process_mode(Node.PROCESS_MODE_INHERIT)
	_LeftWall.show()
	_RightWall.set_process_mode(Node.PROCESS_MODE_INHERIT)
	_RightWall.show()
	_FrontWall.set_process_mode(Node.PROCESS_MODE_INHERIT)
	_FrontWall.show()
	_BackWall.set_process_mode(Node.PROCESS_MODE_INHERIT)
	_BackWall.show()

func ClearLeftWall():
	_LeftWall.set_process_mode(Node.PROCESS_MODE_DISABLED)
	_LeftWall.hide()

func ClearRightWall():
	_RightWall.set_process_mode(Node.PROCESS_MODE_DISABLED)
	_RightWall.hide()

func ClearFrontWall():
	_FrontWall.set_process_mode(Node.PROCESS_MODE_DISABLED)
	_FrontWall.hide()

func ClearBackWall():
	_BackWall.set_process_mode(Node.PROCESS_MODE_DISABLED)
	_BackWall.hide()

func CreateLeftWall():
	_LeftWall.set_process_mode(Node.PROCESS_MODE_INHERIT)
	_LeftWall.show()

func CreateRightWall():
	_RightWall.set_process_mode(Node.PROCESS_MODE_INHERIT)
	_RightWall.show()

func CreateFrontWall():
	_FrontWall.set_process_mode(Node.PROCESS_MODE_INHERIT)
	_FrontWall.show()

func CreateBackWall():
	_BackWall.set_process_mode(Node.PROCESS_MODE_INHERIT)
	_BackWall.show()
