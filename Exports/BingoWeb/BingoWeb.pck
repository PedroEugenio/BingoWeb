GDPC                �                                                                         X   res://.godot/exported/133200997/export-7f85004d6ad36341f68e3bad7c9f3d57-MainScreen.scn  �      �	      h�
sр��u{����QD    ,   res://.godot/global_script_class_cache.cfg  �             ��Р�8���8~$}P�       res://.godot/uid_cache.bin  �      j       �'I@k��v�       res://MainScreen.gd P      �      \���{譊�tʤ�+`       res://MainScreen.tscn.remap 0      g       �{y�Z�#�j�B�?�(C       res://icon.svg          �      k����X3Y���f       res://icon.svg  �      �      k����X3Y���f       res://project.binary�      �      �R�a0��1�����P            <svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="124" height="124" rx="14" fill="#363d52" stroke="#212532" stroke-width="4"/><g transform="scale(.101) translate(122 122)"><g fill="#fff"><path d="M105 673v33q407 354 814 0v-33z"/><path d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 814 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H446l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z" fill="#478cbf"/><path d="M483 600c0 34 58 34 58 0v-86c0-34-58-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></g></svg>
           RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://MainScreen.gd ��������      local://PackedScene_qvv80          PackedScene          	         names "   $      Control    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    script    BALL_NUMBER_RANGE_LIMIT    CenterContainer2    offset_bottom    CenterContainer    GridContainer &   theme_override_constants/h_separation &   theme_override_constants/v_separation    columns    anchor_top    offset_top    HBoxContainer $   theme_override_constants/separation 
   StartGame    custom_minimum_size    Button    Label    text    horizontal_alignment    vertical_alignment 
   uppercase    ResetButton    Timer 
   wait_time    CalledNumber    anchor_left    offset_left    BingoResult    offset_right    	   variants                        �?                   Z            
        �C                 ��      �             
     HC  �B      Start             Reset )   �������?     H�     �B      Number       B     �A      Result: No Bingo       node_count             nodes     �   ��������        ����                                                                   	   ����                     
                             ����                        	                     ����	            
                           
                                   ����                                ����                                ����
                                                                                ����                                ����
                                                                                 ����                           ����                                  !      
                
             ����
                                                                              "   ����         #      
                      conn_count              conns               node_paths              editable_instances              version             RSRC              extends Control

const GRID_SIZE_X = 5
const GRID_SIZE_Y = 3

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
			cell.custom_minimum_size = Vector2(100, 100)
			cell.connect("pressed", _on_cell_pressed.bind(number, cell))
			$CenterContainer2/GridContainer.add_child(cell)
			row_cell.append(cell)
		bingo_card.append(row)
		bingo_card_cells.append(row_cell)

func _on_cell_pressed(number, cell):
	print("Cell Pressed!! %d" % number)
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
		$CenterContainer/HBoxContainer/StartGame/Label.text = "Resume"
	else:
		print("Game Resumed!!")
		$Timer.set_paused(false)
		$CenterContainer/HBoxContainer/StartGame/Label.text = "Pause"
	#$Bingo.disabled = false

func clearGridContainer():
	var children = $CenterContainer2/GridContainer.get_children()
	for child in children:
		child.queue_free()

func _on_ResetButton_pressed():
	game_active = false
	$Timer.stop()
	$CenterContainer/HBoxContainer/StartGame/Label.text = "Start"
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
       [remap]

path="res://.godot/exported/133200997/export-7f85004d6ad36341f68e3bad7c9f3d57-MainScreen.scn"
         list=Array[Dictionary]([])
     <svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="124" height="124" rx="14" fill="#363d52" stroke="#212532" stroke-width="4"/><g transform="scale(.101) translate(122 122)"><g fill="#fff"><path d="M105 673v33q407 354 814 0v-33z"/><path d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 814 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H446l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z" fill="#478cbf"/><path d="M483 600c0 34 58 34 58 0v-86c0-34-58-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></g></svg>
              [u��G�u   res://icon.svg�pW���R   res://MainScreen.tscn[u��G�u   res://Exports/BingoWeb/icon.svg      ECFG      application/config/name         Bingo      application/run/main_scene          res://MainScreen.tscn      application/config/features(   "         4.2    GL Compatibility       application/config/icon         res://icon.svg  #   rendering/renderer/rendering_method         gl_compatibility*   rendering/renderer/rendering_method.mobile         gl_compatibility4   rendering/textures/vram_compression/import_etc2_astc             