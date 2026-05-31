extends Node3D

# Referencje do wewnętrznych węzłów
@onready var viewport: SubViewport = $SubViewport
@onready var mesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	# Szukamy skryptu 2D wewnątrz viewportu
	var panel_2d = viewport.get_node_or_null("PanelControl2d")
	if panel_2d:
		# Przechwytujemy sygnał wyboru z 2D i podpinamy pod lokalną funkcję
		panel_2d.coordinates_selected.connect(_on_panel_2d_coordinates_selected)
	else:
		print("Błąd: Nie znaleziono węzła PanelControl2D wewnątrz SubViewport!")

func _on_panel_2d_coordinates_selected(x: int, y: int) -> void:
	# Przykładowy print – tutaj Twoja scena główna będzie nasłuchiwać tego panelu
	print("Fizyczny Panel 3D: Gracz wybrał współrzędne: ", x, ", ", y)

# Ta funkcja przekazuje ruch i kliknięcia myszy z przestrzeni 3D prosto do przycisków UI
func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	# Pobieramy lokalną pozycję uderzenia promienia myszy w płaszczyznę
	var local_pos = mesh.global_transform.affine_inverse() * event_position
	var viewport_size = viewport.size
	
	# Mapowanie pozycji z układu 3D (gdzie środek QuadMesh to 0,0) na piksele 2D (0 do size)
	var x2d = (local_pos.x + 0.5) * viewport_size.x
	# Oś Y w 3D idzie w górę, a w 2D w dół, stąd minus
	var y2d = (-local_pos.y + 0.5) * viewport_size.y
	
	# Modyfikujemy pozycję oryginalnego zdarzenia (kliknięcia/ruchu) i wpychamy do Viewportu
	event.position = Vector2(x2d, y2d)
	if event is InputEventMouse:
		event.global_position = Vector2(x2d, y2d)
		
	viewport.push_input(event)