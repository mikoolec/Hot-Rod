extends Node3D

# --- LOGIKA ROZGRYWKI ---
var score : float = 0.0
var game_timer : float = 90.0 # 1 minuta na rundę
var soviet_quota : float = 9.0 # Wymagana energia na sekundę (do balansu)
var current_energy_production : float = 0.0
var is_game_over : bool = false

# Eksportujemy zmienną, aby móc łatwo podpiąć scenę pręta w edytorze
@export var control_rod_scene : PackedScene

# Stałe definiujące rozmiar siatki i odstępy między prętami w przestrzeni 3D
const GRID_SIZE : int = 5
const SPACING : float = 0.95  # Odległość między środkami prętów

const movex : float = -0.3
const movez : float = -2.2

# Dwuwymiarowa tablica (słownik), która będzie przechowywać referencje do prętów
var rods_grid : Dictionary = {}

# --- NOWE REFERENCJE DO SYSTEMÓW STEROWANIA ---
@onready var panel_3d = $Panel3D
@onready var power_lever = $lever

@onready var power_bar = $UI/PowerBar
@onready var quota_marker = $UI/PowerBar/QuotaMarker

@onready var quota_label = $UI/QuotaLabel # Nowa linijka

@onready var score_label = $UI/ScoreLabel
@onready var timer_label = $UI/TimerLabel

# Referencja do aktualnie kontrolowanego pręta reaktora
var active_control_rod : Node3D = null

func _ready() -> void:
	if not control_rod_scene:
		print("Błąd: Nie przypisano sceny 'control_rod_scene' w edytorze!")
		return
	
	if power_bar:
		power_bar.value = 12.5 
		print("TEST: Wysłano 12.5 do paska. Aktualna wartość paska to: ", power_bar.value)
	
	

	generate_grid()
	_connect_control_systems()

	

func generate_grid() -> void:
	var container = $RodsContainer
	
	for x in range(GRID_SIZE):
		rods_grid[x] = {} # Inicjalizacja kolumny w słowniku
		
		for z in range(GRID_SIZE):
			# Instancjowanie nowej sceny pręta
			var rod_instance = control_rod_scene.instantiate()
			
			# Obliczanie pozycji w przestrzeni 3D
			var pos_x = (x - (GRID_SIZE - 1) / 2.0) * SPACING + movex
			var pos_z = (z - (GRID_SIZE - 1) / 2.0) * SPACING + movez
			rod_instance.position = Vector3(pos_x, -1, pos_z)
			rod_instance.power_level = 0.29
			
			# Dodanie instancji do drzewa sceny (pod kontener)
			container.add_child(rod_instance)
			
			# Zapisanie referencji do pręta w naszej strukturze danych
			rods_grid[x][z] = rod_instance
			
			# Nadanie unikalnej nazwy dla podglądu w edytorze podczas uruchomienia
			rod_instance.name = "Rod_" + str(x) + "_" + str(z)

	active_control_rod = rods_grid[0][0]

# --- NOWA LOGIKA: ŁĄCZENIE SYSTEMÓW ---

func _connect_control_systems() -> void:
	# Pobieramy panel 2D siedzący wewnątrz SubViewportu w Panel3D i podpinamy sygnał wyboru
	var panel_2d = panel_3d.find_child("PanelControl2d")
	if panel_2d:
		panel_2d.coordinates_selected.connect(_on_panel_rod_selected)
	
	# Podpinamy sygnał ruchu wajchy
	if power_lever:
		power_lever.power_changed.connect(_on_lever_power_changed)

func _process(delta: float) -> void:
	if is_game_over:
		return
	
	_update_quota_marker_position()

	# 1. Aktualizacja wajchy (Twój dotychczasowy kod)
	if active_control_rod and not power_lever.is_dragging:
		power_lever.set_lever_angle_from_power(active_control_rod.power_level)
		
	# 2. Obliczanie całkowitej produkcji energii i sprawdzanie przegranej
	_game_loop_logic(delta)

func _game_loop_logic(delta: float) -> void:
	current_energy_production = 0.0
	var core_overloaded : bool = false


	
	# Przechodzimy po wszystkich prętach
	for x in rods_grid:
		for z in rods_grid[x]:
			var rod = rods_grid[x][z]
			
			# Sumujemy energię (generowana na podstawie ich power_level)
			current_energy_production += rod.power_level
			
			# Sprawdzamy, czy któryś pręt wybuchł (temperatura >= 1.0)
			if rod.temperature >= 1.0:
				core_overloaded = true

	_update_ui_bars()
				
	# 3. Naliczanie punktów, jeśli spełniamy normę
	if current_energy_production >= soviet_quota:
		score += delta * 10.0 * ( current_energy_production - soviet_quota )  # Punkty za każdą sekundę powyżej normy
		
	# 4. Obsługa timera rundy
	game_timer -= delta
	if game_timer <= 0.0:
		trigger_game_over(true) # Wygrana/Koniec czasu
		
	if core_overloaded:
		trigger_game_over(false) # Przegrana - wybuch

func trigger_game_over(is_victory: bool) -> void:
	is_game_over = true
	
	# Zapisujemy informację o typie zakończenia gry do pamięci globalnej
	GlobalGameStats.was_victory = is_victory
	GlobalGameStats.final_score = int(score)
	
	# Ładujemy ekran końcowy
	get_tree().change_scene_to_file("res://scenes/game_over.tscn") # Wpisz swoją ścieżkę do nowej sceny

# Wywoływane, gdy gracz kliknie parę guzików na panelu (np. C i 2)
func _on_panel_rod_selected(x: int, z: int) -> void:
	if rods_grid.has(x) and rods_grid[x].has(z):
		active_control_rod = rods_grid[x][z]
		print("Główny skrypt: Aktywowano pręt: Rod_", x, "_", z)
		
		# Ustawiamy wajchę w pozycji, jaką ten konkretny pręt miał dotychczas
		power_lever.set_lever_angle_from_power(active_control_rod.power_level)
	else:
		print("Błąd sygnału: Pozycja poza siatką reaktora: ", x, ", ", z)

# Wywoływane, gdy gracz fizycznie przeciąga wajchę myszką
func _on_lever_power_changed(new_power_value: float) -> void:
	if active_control_rod:
		active_control_rod.power_level = new_power_value

# Twoja stara funkcja pomocnicza (zachowana, na wypadek gdybyś jej używał w innych skryptach)
func set_rod_power(x: int, z: int, power: float) -> void:
	if rods_grid.has(x) and rods_grid[x].has(z):
		rods_grid[x][z].power_level = clamp(power, 0.0, 1.0)
	else:
		print("Błąd: Współrzędne ", x, ", ", z, " są poza siatką.")

func _update_quota_marker_position() -> void:
	if power_bar and quota_marker:
		# Obliczamy stosunek normy do maksymalnej wartości paska (procent od 0.0 do 1.0)
		var quota_ratio = soviet_quota / power_bar.max_value
		
		# Sprawdzamy fizyczną szerokość paska w pikselach
		var bar_width = power_bar.size.x
		
		# Przesuwamy znacznik w osi X o odpowiednią liczbę pikseli
		# Odejmujemy połowę szerokości znacznika, żeby kreska była idealnie wycentrowana
		quota_marker.position.x = (bar_width * quota_ratio) - (quota_marker.size.x / 2.0)

func _update_ui_bars() -> void:
	if power_bar:
		power_bar.value = current_energy_production
		
		var quota_percentage : int = 0
		if soviet_quota > 0:
			quota_percentage = int((current_energy_production / soviet_quota) * 100.0)
		
		# Bezpośrednia aktualizacja napisu
		if quota_label:
			quota_label.text = str(quota_percentage) + "% normy"
			#print("Wysłano do UI: ", quota_label.text)

	if score_label:
		score_label.text = "Ocena pracownika: " + str(int(score))

	if timer_label:
		# Zabezpieczamy się, żeby timer nie pokazywał wartości ujemnych
		var time_left = max(0.0, game_timer)
		
		# Wyliczamy pełne minuty i sekundy
		var minutes : int = int(time_left) / 60
		var seconds : int = int(time_left) % 60
		
		# Formatujemy tekst, aby zawsze miał dwie cyfry (np. "05" zamiast "5")
		timer_label.text = "Do fajrantu: %02d:%02d" % [minutes, seconds]
