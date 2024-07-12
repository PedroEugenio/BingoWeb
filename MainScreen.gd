extends Control

const GRID_SIZE_X = 5
const GRID_SIZE_Y = 3
const CELL_SIZE = Vector2(100, 100)
@export var BALL_NUMBER_RANGE_LIMIT = 60

var bingo_card = []
var bingo_card_cells = []
var available_numbers = []
var output_numbers = []
var called_numbers = []
var game_active = false
var actualSolutionSize = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$CenterContainer/HBoxContainer/StartGame.connect("pressed", _on_StartGame_pressed)
	$CenterContainer/HBoxContainer/ResetButton.connect("pressed", _on_ResetButton_pressed)
	$CalledNumber.connect("pressed", _on_CallNumber_pressed)
	$Timer.connect("timeout", _on_CallNumber_pressed)
	generate_bingo_card()

func sort_ascending(a, b):
	if a > b:
		return true
	return false

func generate_bingo_card():
	var sorted_filter_numbers = []
	for i in range(1, BALL_NUMBER_RANGE_LIMIT):
		available_numbers.append(i)
	available_numbers.shuffle()
	output_numbers = available_numbers
	sorted_filter_numbers = available_numbers.slice(0, GRID_SIZE_X *  GRID_SIZE_Y)
	sorted_filter_numbers.sort_custom(sort_ascending)

	for i in range(GRID_SIZE_Y):
		var row = []
		var row_cell = []
		for j in range(GRID_SIZE_X):
			var number = sorted_filter_numbers.pop_back()
			row.append(number)
			var cell = Button.new()
			cell.text = str(number)
			cell.custom_minimum_size = CELL_SIZE
			cell.connect("pressed", _on_cell_pressed.bind(number, cell))
			$CenterContainer2/GridContainer.add_child(cell)
			row_cell.append(cell)
		bingo_card.append(row)
		bingo_card_cells.append(row_cell)

func _on_cell_pressed(number, cell):
	if game_active:
		cell.modulate = Color(0, 1, 0)
		called_numbers.append(number)
		check_bingo()

func _on_StartGame_pressed():
	game_active = not game_active
	$Timer.start()
	if not game_active:
		print("Game Paused!!")
		$Timer.set_paused(true)
		$CenterContainer/HBoxContainer/StartGame.text = "RESUME"
	else:
		print("Game Resumed!!")
		$Timer.set_paused(false)
		$CenterContainer/HBoxContainer/StartGame.text = "PAUSE"
	#$Bingo.disabled = false

func clearGridContainer():
	var children = $CenterContainer2/GridContainer.get_children()
	for child in children:
		child.queue_free()

func _on_ResetButton_pressed():
	game_active = false
	$Timer.stop()
	$CenterContainer/HBoxContainer/StartGame.text = "START"
	$CalledNumber/Label.text = "Number"
	$BingoResult.text = "Result: No Bingo!"
	bingo_card.clear()
	bingo_card_cells.clear()
	called_numbers.clear()
	available_numbers.clear()
	output_numbers.clear()
	clearGridContainer()
	generate_bingo_card()

func _on_CallNumber_pressed():
	if not output_numbers.is_empty():
		output_numbers.shuffle()
		var new_number = output_numbers.pop_back()
		$CalledNumber/Label.text = str(new_number)
		hasSelectedNumber(new_number)

func check_bingo():
	# Check rows, columns for a bingo
	var solutionSize = GRID_SIZE_X * GRID_SIZE_Y
	if actualSolutionSize == solutionSize:
		$BingoResult.text = "Result: Bingo!"
		print("Bingo!!")
		return true
	return false

func hasSelectedNumber(number):
	#var solutionSize = GRID_SIZE_X * GRID_SIZE_Y	
	var itI=0
	for i in bingo_card:
		var itJ=0	
		for j in i:
			if j == number:
				actualSolutionSize += 1
				_on_cell_pressed(number, bingo_card_cells[itI][itJ])
			itJ+=1
		itI+=1
