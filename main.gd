extends Node

@export var circle_scene : PackedScene
@export var cross_scene : PackedScene

var player : int
var moves : int
var winner : int
var temp_marker
var player_panel_pos : Vector2i
var grid_data : Array
var grid_pos: Vector2i
var board_size: int
var cell_size: int
var row_sum : int
var col_sum : int
var diagonal1_sum : int
var diagonal2_sum : int


# Called when the node enters the scene tree for the first time.
func _ready():
	board_size = $Board.texture.get_width()
	
	#divide board size by 3 to get the size of individual cell
	cell_size = board_size / 3
	#get coordinates of small panel on right side of window
	player_panel_pos = $PlayerPanel.get_position()
	new_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			#check if mouse is on the game board
			if event.position.x < board_size:
				#convert mouse position into grid location
				grid_pos = Vector2i(event.position / cell_size)
				# Checking the grid data if its nothing there we populate with the player variable
				if grid_data[grid_pos.y][grid_pos.x] == 0:
					moves += 1
					grid_data[grid_pos.y][grid_pos.x] = player
					# Ketika player bernilai 1 dan dikalikan dengan -1 , maka player akan menjadi 2 orang.
					# Dan player akan bernilai 1 lagi karena akan membaca ulang program
					# Place that player's marker
					create_marker(player, grid_pos * cell_size + Vector2i(cell_size/2, cell_size/2))
					if check_win() != 0:
						get_tree().paused = true
						$GameOverMenu.show()
						if winner == 1:
							# Check the winner but from the different scene , call it first with code below
							$GameOverMenu.get_node("ResultLabel").text = "Player 1 Wins"
						elif winner == -1:
							$GameOverMenu.get_node("ResultLabel").text = "Player 2 Wins"
					# Check if board has been filled
					elif moves == 9:
						get_tree().paused = true
						$GameOverMenu.show()
						$GameOverMenu.get_node("ResultLabel").text = "It's a Tie"
					player *= -1
					# Upadte the panel marker
					temp_marker.queue_free() # Kosong in marker di panel 
					create_marker(player, player_panel_pos + Vector2i(cell_size/2, cell_size/2),true)
					print(grid_data)

func new_game():
	player = 1
	moves  = 0
	winner = 0
	grid_data = [
		[0,0,0],
		[0,0,0],
		[0,0,0]
		]
	row_sum = 0
	col_sum = 0
	diagonal1_sum = 0
	diagonal2_sum = 0
	# Clear existing markers
	get_tree().call_group("circles", "queue_free")
	get_tree().call_group("crosses", "queue_free")
	# Create a marker to show starting player's turn
	create_marker(player, player_panel_pos + Vector2i(cell_size/2 , cell_size/2), true)
	$GameOverMenu.hide()
	get_tree().paused = false
func create_marker(player,position, temp = false):
	# Create a marker node and add it as a child 
	# (circle_scene.instantiate()) --> cara untuk child node ke main scene dengan coding 
	if player == 1:
		var circle = circle_scene.instantiate()
		circle.position = position
		add_child(circle)
		if temp:
			temp_marker = circle
	
	else:
		var cross = cross_scene.instantiate()
		cross.position = position
		add_child(cross)
		if temp:
			temp_marker = cross

func check_win():
	# Add up the markers in each row , coloumn and diagonal
	for i in len(grid_data):
		row_sum = grid_data[i][0] + grid_data[i][1] + grid_data[i][2]
		col_sum = grid_data[0][i] + grid_data[1][i] + grid_data[2][i]
		diagonal1_sum = grid_data[0][0] + grid_data[1][1] + grid_data[2][2]
		diagonal2_sum = grid_data[0][2] + grid_data[1][1] + grid_data[2][0]
		
		# Check if either player has all of the markers in one line
		if row_sum == 3 or col_sum == 3 or diagonal1_sum == 3 or diagonal2_sum == 3:
			winner = 1
		elif row_sum == -3 or col_sum == -3 or diagonal1_sum == -3 or diagonal2_sum == -3:
			winner = -1
	return winner


func _on_game_over_menu_restart():
	new_game()
