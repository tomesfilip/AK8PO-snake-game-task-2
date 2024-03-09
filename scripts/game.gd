extends Node2D

@export var snake_scene: PackedScene

var score: int
var game_started: bool = false

const CELLS: int = 20
const CELL_SIZE: int = 50
const INITIAL_SNAKE_LENGTH = 3

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
	get_tree().paused = false
	get_tree().call_group("segments", "queue_free")
	$GameOverMenu.hide()
	score = 0
	$Hud.get_node("ScorePanel/ScoreLabel").text = "Score: " + str(score)
	move_direction = right
	can_move = true
	generate_snake()
	generate_food()
	start_game()
	

func generate_snake():
	snake_old_data.clear()
	snake_data.clear()
	snake.clear()
	
	for i in range(INITIAL_SNAKE_LENGTH):
		add_segment(start_pos - Vector2(i, 0))
		

func add_segment(pos):
	snake_data.append(pos)
	var SnakeSegment = snake_scene.instantiate()
	SnakeSegment.position = (pos * CELL_SIZE) + Vector2(0, CELL_SIZE)
	if snake.size() == 0:
		SnakeSegment.modulate = Color(0, 0, 0, 1)
	add_child(SnakeSegment)
	snake.append(SnakeSegment)

func _on_quit_pressed():
	get_tree().quit()
	
	
func move_snake():
	var direction_mapping = {
		"move_left": left,
		"move_right": right,
		"move_up": up,
		"move_down": down
	}

	for action in direction_mapping.keys():
		if Input.is_action_just_pressed(action) and move_direction != direction_mapping[action]:
			move_direction = direction_mapping[action]
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
		snake[i].position = (snake_data[i] * CELL_SIZE) + Vector2(0, CELL_SIZE)
		
		check_collisions()

func check_collisions():
	check_out_of_bounds()
	check_self_eaten()
	check_food_eaten()

func check_out_of_bounds():
	if snake_data[0].x < 0 or snake_data[0].x >= CELLS or snake_data[0].y < 0 or snake_data[0].y >= CELLS:
		end_game()
		
func check_self_eaten():
	for i in range(1, len(snake_data)):
		if snake_data[0] == snake_data[i]:
			end_game()
	
func check_food_eaten():
	if snake_data[0] == food_pos:
		score += 1
		$Hud.get_node("ScorePanel/ScoreLabel").text = "Score: " + str(score)
		add_segment(snake_old_data[-1])
		generate_food()
		
func end_game():
	$GameOverMenu.show()
	$MovementTimer.stop()
	game_started = false
	get_tree().paused = true
	
func generate_food():
	while should_generate_food:
		should_generate_food = false
		food_pos = Vector2(randi_range(0, CELLS - 1), randi_range(0, CELLS - 1))
		for i in snake_data:
			if food_pos == i:
				should_generate_food = true
	$Food.position = (food_pos * CELL_SIZE) + Vector2(0, CELL_SIZE)
	should_generate_food = true


func _on_game_over_menu_restart():
	new_game()
