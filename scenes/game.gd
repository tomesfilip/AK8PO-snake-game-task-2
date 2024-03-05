extends Node2D

@export var snake_scene: PackedScene

var score: int
var game_started: bool = false

var cells: int = 20
var cell_size: int = 50

var snake_old_data: Array
var snake_data: Array
var snake: Array

var start_pos = Vector2(9,9)

var up = Vector2(0, -1)
var down = Vector2(0, 1)
var left = Vector2(1, 0)
var right = Vector2(0, 1)

var move_direction: Vector2
var can_move: bool


func new_game():
	score = 0
	$Hud.get_node("ScorePanel/ScoreLabel").text = "Score: " + str(score)
	move_direction = right
	can_move = true
	generate_snake()
	

func generate_snake():
	snake_old_data.clear()
	snake_data.clear()
	snake.clear()
	
	for i in range(3):
		add_segment(start_pos + Vector2(i, 0))
		

func add_segment(pos):
	snake_data.append(pos)
	var SnakeSegment = snake_scene.instantiate()
	SnakeSegment.position = (pos * cell_size) + Vector2(cell_size, 0)
	add_child(SnakeSegment)
	snake.append(SnakeSegment)

func _on_quit_pressed():
	get_tree().quit()

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("quit_game"):
		_on_quit_pressed()
	
	
