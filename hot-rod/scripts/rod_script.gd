extends Node3D

# Ładujemy scenę rdzenia (upewnij się, że ścieżka jest poprawna!)
const CONTROL_ROD_SCENE = preload("res://scenes/control_rod.tscn")

# Odstęp między rdzeniami w metrach (dostosuj do wielkości swojego modelu)
const SPACING = 0.994 
const offsetX = -0.2
const offsetZ = -2.4

# Słownik/Tablica, w której będziemy trzymać referencje do wszystkich 16 rdzeni
var reactor_grid = {}

func _ready() -> void:
	generate_grid()

	

func generate_grid() -> void:
	var columns = ["A", "B", "C", "D"]
	
	for row in range(1, 5): # Wiersze 1, 2, 3, 4
		for col_idx in range(4): # Kolumny 0, 1, 2, 3 (odpowiadające A, B, C, D)
			var col_letter = columns[col_idx]
			var coords = col_letter + str(row) # Np. "A1", "C2"
			
			# 1. Tworzymy instancję
			var rod_instance = CONTROL_ROD_SCENE.instantiate()

			# 2. Ustawiamy nazwę ZANIM trafi do drzewa sceny	
			rod_instance.name = "Rod_" + coords

			# 3. Ustalamy pozycję
			var x_pos = (col_idx - 1.5) * SPACING + offsetX
			var z_pos = (row - 2.5) * SPACING + offsetZ
			rod_instance.position = Vector3(x_pos, -1, z_pos)

			# 4. Dopiero teraz dodajemy do sceny
			add_child(rod_instance)

			# 5. Zapis do słownika
			reactor_grid[coords] = rod_instance