extends Node2D

@export var snake_scene: PackedScene

var score: int
var game_started: bool = false

var cells: int = 20
var cell_size: int = 50

var food_pos: Vector2
var should_generate_food: bool = true

var snake_old_data: Array
var snake_data: Array
var snake: Array

var start_pos = Vector2(9,9)

var up = Vector2(0, -1)
var down = Vector2(0, 1)
var left = Vector2(-1, 0)
var right = Vector2(1, 0)

var move_direction: Vector2
var can_move: bool


func new_game():
	score = 0
	$Hud.get_node("ScorePanel/ScoreLabel").text = "Score: " + str(score)
	move_direction = right
	can_move = true
	generate_snake()
	generate_food()
	

func generate_snake():
	snake_old_data.clear()
	snake_data.clear()
	snake.clear()
	
	for i in range(3):
		add_segment(start_pos + Vector2(i, 0))
		

func add_segment(pos):
	snake_data.append(pos)
	var SnakeSegment = snake_scene.instantiate()
	SnakeSegment.position = (pos * cell_size) + Vector2(0, cell_size)
	add_child(SnakeSegment)
	snake.append(SnakeSegment)

func _on_quit_pressed():
	get_tree().quit()
	
	
func move_snake():
	if can_move:
		if Input.is_action_just_pressed("move_left") and move_direction != right:
			move_direction = left
			can_move = false
			if not game_started:
				start_game()
		if Input.is_action_just_pressed("move_right") and move_direction != left:
			move_direction = right
			can_move = false
			if not game_started:
				start_game()		
		if Input.is_action_just_pressed("move_up") and move_direction != down:
			move_direction = up
			can_move = false
			if not game_started:
				start_game()	
		if Input.is_action_just_pressed("move_down") and move_direction != up:
			move_direction = down
			can_move = false
			if not game_started:
				start_game()
				
func start_game():
	game_started = true
	$MovementTimer.start()
			

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_snake()
	if Input.is_action_just_pressed("quit_game"):
		_on_quit_pressed()
	

func _on_movement_timer_timeout():	
	can_move = true
	snake_old_data = [] + snake_data
	snake_data[0] += move_direction
	
	for i in range(len(snake_data)):
		if i > 0:
			snake_data[i] = snake_old_data[i-1]
		snake[i].position = (snake_data[i] * cell_size) + Vector2(0, cell_size) 
		
		check_out_of_bounds()
		check_self_eaten()
		check_food_eaten()


func check_out_of_bounds():
	pass
	
func check_food_eaten():
	pass

func check_self_eaten():
	for i in range(1, len(snake_data)):
		if snake_data[0] == snake_data[i]:
			end_game()
			
func end_game():
	pass
	
func generate_food():
	while should_generate_food:
		should_generate_food = false
		food_pos = Vector2(randi_range(0, cells - 1), randi_range(0, cells - 1))
		for i in snake_data:
			if food_pos == i:
				should_generate_food = true
	$Food.position = (food_pos * cell_size) + Vector2(0, cell_size)
	should_generate_food = true
