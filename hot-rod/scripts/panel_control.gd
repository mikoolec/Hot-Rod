extends Control

# Sygnał, który wyślemy do świata gry, gdy gracz wybierze komplet współrzędnych
# x = kolumna (0 do 4), y = rząd (0 do 4)
signal coordinates_selected(x: int, y: int)

# Zmienne przechowujące indeksy aktualnie wciśniętych przycisków
var selected_letter_index: int = 0
var selected_number_index: int = 0

# Odwołania do Twoich kontenerów przy użyciu ścieżek z Twojego drzewa sceny
@onready var letters_container = $VBoxContainer/RowLetters
@onready var numbers_container = $VBoxContainer/RowNumbers

func _ready() -> void:
	# 1. Tworzymy automatyczne grupy dla przycisków
	var letters_group = ButtonGroup.new()
	var numbers_group = ButtonGroup.new()
	
	# Kluczowe ustawienie: nie pozwalamy na odznaczenie jedynego wciśniętego guzika
	letters_group.allow_unpress = false
	numbers_group.allow_unpress = false
	
	# 2. Konfigurujemy przyciski liter
	var letter_buttons = letters_container.get_children()
	for i in range(letter_buttons.size()):
		if letter_buttons[i] is Button:
			letter_buttons[i].toggle_mode = true
			letter_buttons[i].button_group = letters_group
			# Podpinamy prosty sygnał wciśnięcia (pressed)
			letter_buttons[i].pressed.connect(_on_letter_pressed.bind(i))
			
	# 3. Konfigurujemy przyciski cyfr
	var number_buttons = numbers_container.get_children()
	for i in range(number_buttons.size()):
		if number_buttons[i] is Button:
			number_buttons[i].toggle_mode = true
			number_buttons[i].button_group = numbers_group
			number_buttons[i].pressed.connect(_on_number_pressed.bind(i))

	# 4. Wymuszamy zaznaczenie pierwszych przycisków (A1) na start gry
	if letter_buttons.size() > 0:
		letter_buttons[0].button_pressed = true
	if number_buttons.size() > 0:
		number_buttons[0].button_pressed = true
		
	# Emitujemy sygnał początkowy, żeby gra wiedziała, że domyślnie wybrany jest rdzeń (0,0)
	coordinates_selected.emit(selected_letter_index, selected_number_index)

func _on_letter_pressed(index: int) -> void:
	selected_letter_index = index
	coordinates_selected.emit(selected_letter_index, selected_number_index)

func _on_number_pressed(index: int) -> void:
	selected_number_index = index
	coordinates_selected.emit(selected_letter_index, selected_number_index)