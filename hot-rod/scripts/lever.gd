extends Node3D

# Sygnał wysyłany podczas przeciągania wajchy przez gracza
signal power_changed(new_value: float)

# --- TWOJA KONFIGURACJA OSI I KĄTÓW ---
const MIN_ANGLE_DEG : float = -35.0  # Kąt dla power_level = 0.0
const MAX_ANGLE_DEG : float = 35.0   # Kąt dla power_level = 1.0

# --- NOWE: Parametr prędkości płynnego ruchu (Zmień w Inspektorze jeśli za wolno/szybko) ---
@export var lerp_speed : float = 15.0

# Flaga sprawdzająca, czy gracz aktualnie trzyma wajchę
var is_dragging : bool = false
var current_power : float = 0.0

# --- NOWE: Przechowuje kąt, do którego wajcha ma dążyć ---
var target_rotation_z : float = 0.0

# Dostosuj nazwę węzła do swojej wajchy, jeśli nazywa się inaczej (np. $Uchwyt itp.)
@onready var wajcha_mesh : MeshInstance3D = $handle

func _ready() -> void:
	# Ustawiamy pozycję startową na bazie bazowego stanu (główny skrypt wymusi tu 0.3)
	set_lever_angle_from_power(current_power)
	# Na sam start gry ustawiamy rotację natychmiast na pozycję startową, żeby nie było lerpowania od 0
	if wajcha_mesh:
		wajcha_mesh.rotation.z = target_rotation_z

# --- NOWE: Funkcja process wykonuje płynne przejście w każdej klatce ---
func _process(delta: float) -> void:
	if wajcha_mesh:
		# Płynnie zmierzamy z aktualnej rotacji do rotacji docelowej
		wajcha_mesh.rotation.z = lerp(wajcha_mesh.rotation.z, target_rotation_z, lerp_speed * delta)

# 1. FUNKCJA DLA REAKTORA: Aktualizuje wygląd wajchy na bazie stanu rdzenia
func set_lever_angle_from_power(power: float) -> void:
	if is_dragging: 
		return # Nie pozwalamy reaktorowi "szarpać" wajchą, gdy gracz ją trzyma
		
	current_power = clamp(power, 0.0, 1.0)
	
	# Zamieniamy power_level (0-1) na odpowiedni kąt w stopniach, a potem na radiany
	var target_angle_deg = lerp(MIN_ANGLE_DEG, MAX_ANGLE_DEG, current_power)
	
	# ZMIANA: Zamiast natychmiast obracać mesh, ustawiamy cel dla funkcji _process
	target_rotation_z = deg_to_rad(target_angle_deg)

# Wykrywanie kliknięcia na Area3D wajchy
func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)

# Obsługa puszczenia myszki oraz precyzyjnego przeciągania
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and is_dragging:
			is_dragging = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
	# Logika ruchu myszką
	if event is InputEventMouseMotion and is_dragging:
		var mouse_y_motion = event.relative.y
		var sensitivity = 0.01 
		current_power -= mouse_y_motion * sensitivity
		current_power = clamp(current_power, 0.0, 1.0)
		
		var target_angle_deg = lerp(MIN_ANGLE_DEG, MAX_ANGLE_DEG, current_power)
		
		# ZMIANA: Kiedy gracz sam rusza wajchą, też aktualizujemy target_rotation_z,
		# dzięki czemu po puszczeniu myszki wajcha nie "odskoczy" brzydko w tył.
		target_rotation_z = deg_to_rad(target_angle_deg)
		
		power_changed.emit(current_power)