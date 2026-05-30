extends Node3D

var power_level : float = 0.5

var material : StandardMaterial3D
var r = 38
var g = 45
var b = 50
var nr = 0
var ng = 0
var nb = 0

const MAX_HEIGHT = 1.0

var mesh_node : MeshInstance3D
var mesh_node2 : MeshInstance3D

func _ready() -> void:
	mesh_node = get_node_or_null("Cube") as MeshInstance3D
	mesh_node2 = get_node_or_null("Cube_001") as MeshInstance3D
	
	# Fallback, jeśli nazwy się nie zgadzają
	if not mesh_node:
		for child in get_children():
			if child is MeshInstance3D:
				if not mesh_node: mesh_node = child
				elif not mesh_node2: mesh_node2 = child

	if mesh_node:
		material = mesh_node.material_override as StandardMaterial3D

	# --- WIZUALNY TEST NA EKRANIE ---
	var tekst_testowy = Label3D.new()
	tekst_testowy.billboard = BaseMaterial3D.BILLBOARD_ENABLED # Obraca tekst do kamery
	tekst_testowy.font_size = 64
	
	if mesh_node != null:
		tekst_testowy.text = name + ": ZNALEZIONO MESH"
		tekst_testowy.modulate = Color(0, 1, 0) # Zielony napisz
	else:
		tekst_testowy.text = name + ": BRAK MESHA!"
		tekst_testowy.modulate = Color(1, 0, 0) # Czerwony napis
		
	add_child(tekst_testowy)
	tekst_testowy.position = Vector3(0, 2.0, 0) # Wyciągamy tekst wysoko w górę nad podłogę

func _process(delta: float) -> void:
	update_reactor_look()
	update_reactor_pos()

func update_reactor_look() -> void:
	if not material:
		return
	
	nr = ( power_level * 255 ) + ( ( 1 - power_level ) * r )
	ng = ( power_level * 0 ) + ( ( 1 - power_level ) * g )
	nb = ( power_level * 0 ) + ( ( 1 - power_level ) * b )
	material.albedo_color = Color(nr/255, ng/255, nb/255)
	material.emission_energy_multiplier = power_level * 8.0

func update_reactor_pos() -> void:
	if mesh_node:
		mesh_node.position.y = power_level * MAX_HEIGHT
	if mesh_node2:
		mesh_node2.position.y = power_level * MAX_HEIGHT