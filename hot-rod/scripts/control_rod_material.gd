extends Node3D

var power_level : float = 0.0
var temperature : float = 0.0 # Nowa zmienna w zakresie 0.0 - 1.0

# --- Twoje zmienne kolorów i meshów bez zmian ---
var material : StandardMaterial3D
var r = 65.0
var g = 75.0
var b = 80.0

var r2 = 255.0
var g2 = 125.0
var b2 = 108.0

const MAX_HEIGHT = 1.0
var mesh_node : MeshInstance3D
var mesh_node2 : MeshInstance3D

var target_rotation_x : float = 0.0
@export var lerp_speed : float = 15.0 # Prędkość ruchu (wyższa = szybszy dojazd)

func _ready() -> void:
	# 1. Szukamy głównego mesha pręta wewnątrz tej sceny.
	# Zakładam, że nazywa się "MeshInstance3D". Jeśli nazwa jest inna, wpisz ją poniżej.
	if has_node("Cube"):
		mesh_node = $Cube
	
	# Opcjonalny drugi mesh (jeśli Twój pręt składa się z dwóch osobnych części)
	if has_node("Cube_001"):
		mesh_node2 = $Cube_001

	# 2. Jeśli znaleźliśmy mesh, wyciągamy z niego materiał do edycji
	if mesh_node:
		var base_material : Material = null
		
		# Sprawdzamy najpierw nadpisanie materiału, potem materiał bazowy modelu
		if mesh_node.material_override:
			base_material = mesh_node.material_override
		elif mesh_node.mesh and mesh_node.mesh.surface_get_material(0):
			base_material = mesh_node.mesh.surface_get_material(0)
		
		# 3. Jeśli materiał istnieje, duplikujemy go, aby każdy pręt grzał się niezależnie
		if base_material:
			material = base_material.duplicate() as StandardMaterial3D
			mesh_node.material_override = material
			
			if mesh_node2:
				mesh_node2.material_override = material
				
			# Wstępna konfiguracja właściwości fizycznych materiału
			material.metallic = 0.6
			material.roughness = 0.3
			material.metallic_specular = 0.5
		else:
			print("Błąd [", name, "]: Nie znaleziono materiału w MeshInstance3D. Dodaj go w edytorze!")
	else:
		print("Błąd [", name, "]: Brak węzła MeshInstance3D wewnątrz pręta!")

func _process(delta: float) -> void:
	_calculate_temperature(delta)
	update_reactor_look()
	update_reactor_pos()

# Logika nagrzewania i chłodzenia
func _calculate_temperature(delta: float) -> void:
	# Szukamy odchylenia od punktu równowagi (0.5)
	# Jeśli power_level = 1.0 -> zmiana wynosi +0.5 (grzanie)
	# Jeśli power_level = 0.0 -> zmiana wynosi -0.5 (chłodzenie)
	var temperature_change = power_level - 0.3
	
	# Mnożnik określa jak szybko rośnie/spada temperatura (0.2 oznacza, że pełne nagrzanie zajmie ok. 10 sekund)
	var speed_multiplier = 0.05
	
	temperature += temperature_change * speed_multiplier * delta
	temperature = clamp(temperature, 0.0, 1.0)

func update_reactor_look() -> void:
	if not material:
		return
	
	# ZMIANA: Kolor albedo zależy teraz od TEMPERATURE
	var albedo_start = Color(r / 255.0, g / 255.0, b / 255.0)
	var albedo_end = Color(255.0 / 255.0, 0.0 / 255.0, 0.0 / 255.0)
	material.albedo_color = albedo_start.lerp(albedo_end, temperature)
	
	# ZMIANA: Emisja również świeci na podstawie TEMPERATURE
	var emission_start = Color(0.0, 0.0, 0.0)
	var emission_end = Color(r2 / 255.0, g2 / 255.0, b2 / 255.0)
	material.emission = emission_start.lerp(emission_end, temperature)
	
	material.emission_energy_multiplier = temperature * 3.0

func update_reactor_pos() -> void:
	# ZMIANA: Wysokość pręta wysuwa się wraz z TEMPERATURE
	if mesh_node:
		mesh_node.position.y = temperature * MAX_HEIGHT
	if mesh_node2:
		mesh_node2.position.y = temperature * MAX_HEIGHT
