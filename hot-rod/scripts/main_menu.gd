extends Control
# Ścieżka do Twojej głównej sceny z reaktorem 3D. 
# UWAGA: Upewnij się, że ta ścieżka idealnie pokrywa się z lokalizacją Twojej sceny reaktora!
@export_file("*.tscn") var game_scene_path : String = "res://scenes/main_scene.tscn"
@export_file("*.tscn") var tut_scene_path : String = "res://scenes/tutorial.tscn"


func _ready() -> void:
	# Na wszelki wypadek upewniamy się, że kursor myszy jest widoczny w menu
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Szukamy przycisku i podpinamy sygnał kliknięcia bezpośrednio w kodzie
	if has_node("Play"):
		$Play.pressed.connect(_on_play_button_pressed)
	if has_node("Tutorial"):
		$Tutorial.pressed.connect(_on_tutorial_button_pressed)
	
	AudioManager.play_menu_music()

func _on_play_button_pressed() -> void:
	if game_scene_path != "":
		# Zmieniamy całą aktywną scenę w grze na scenę z reaktorem
		get_tree().change_scene_to_file(game_scene_path)
	else:
		print("Błąd: Nie ustawiono ścieżki do sceny gry w main_menu.gd!")

func _on_tutorial_button_pressed() -> void:
	if tut_scene_path != "":
		# Zmieniamy całą aktywną scenę w grze na scenę z reaktorem
		get_tree().change_scene_to_file(tut_scene_path)
	else:
		print("Błąd: Nie ustawiono ścieżki do sceny tutoriala w tutorial.gd!")
