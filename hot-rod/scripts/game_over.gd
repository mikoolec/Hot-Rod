extends Control

@onready var status_label : Label = $maintext
@onready var points : Label = $pointscollected

@onready var leaderboard_label : Label = $LeaderboardLabel
@onready var leaderboard_label_2 : Label = $LeaderboardLabel2
@onready var name_input : LineEdit = $NameInput
@onready var submit_button : Button = $SubmitButton

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Podpięcie guzika powrotu do menu głównego
	if has_node("MenuButton"):
		$MenuButton.pressed.connect(_on_menu_button_pressed)
	
	if submit_button:
		submit_button.pressed.connect(_on_submit_button_pressed)
	
	# Odczytujemy stan globalny (zaraz go utworzymy)
	setup_screen(GlobalGameStats.was_victory)

	AudioManager.play_menu_music()

	_load_leaderboard()

func setup_screen(is_victory: bool) -> void:
	if is_victory:
		# WERSJA 1: Wygrana (Koniec czasu przy spełnionej normie)
		status_label.text = "SUKCES"
		status_label.modulate = Color.GREEN
	else:
		# WERSJA 2: Przegrana (Przegrzanie / Wybuch)
		status_label.text = "EKSPLOZJA"
		status_label.modulate = Color.RED

		AudioManager.play_sfx("explosion") # Odtwarzamy dźwięk eksplozji przy przegranej
		AudioManager.play_sfx("siren") # Odtwarzamy dźwięk syreny przy przegranej

		GlobalGameStats.final_score = (GlobalGameStats.final_score - 1500)/2
		if GlobalGameStats.final_score < 0:
			GlobalGameStats.final_score = 0
	points.text = str(GlobalGameStats.final_score)
		
func _on_menu_button_pressed() -> void:
	# Powrót do menu głównego
	get_tree().change_scene_to_file("res://scenes/menu.tscn") # Upewnij się, że nazwa pliku menu jest dobra

func _on_submit_button_pressed() -> void:
	var player_name : String = name_input.text.strip_edges()
	if player_name == "":
		player_name = "Anonimowy Towarzysz"
		
	var player_score : int = GlobalGameStats.final_score
	
	submit_button.disabled = true
	name_input.editable = false
	submit_button.text = "Wysyłanie..."

	# Jeśli Talo jeszcze nie zidentyfikowało gracza, robimy to ręcznie:
	if Talo.identity_check() != OK:
		var unique_id = Talo.players.generate_identifier()
		await Talo.players.identify("username", unique_id)

	# Tworzymy Typed Dictionary zgodny z sygnaturą Talo: Dictionary[String, Variant]
	var entry_metadata : Dictionary[String, Variant] = { "display_name": player_name }

	await Talo.leaderboards.add_entry("nuclear_score", player_score, entry_metadata)
	
	submit_button.text = "Raport dostarczony!"
	
	# Odświeżamy tabelę na ekranie
	_load_leaderboard()

# --- DOPISUJEMY: Funkcja pobierania Top 10 z serwera ---
func _load_leaderboard() -> void:
	if not leaderboard_label:
		return
		
	leaderboard_label.text = "Ładowanie danych z Centrali..."
	
	var page = await Talo.leaderboards.get_entries("nuclear_score")
	
	if page == null or page.entries.size() == 0:
		leaderboard_label.text = "--- BRAK WPISÓW W BAZIE ---"
		return
		
	leaderboard_label.text = ""
	leaderboard_label_2.text = ""
	
	var pos = 1
	for entry in page.entries:
		# Wyciągamy zapisane w metadanych imię
		var p_name = entry.get_prop("display_name", "Nieznany Robotnik")

		if pos>10:
			break

		if pos <= 5:
			leaderboard_label.text += str(pos) + ". " + p_name + " - " + str(entry.score) + "\n"
		else:
			leaderboard_label_2.text += str(pos) + ". " + p_name + " - " + str(entry.score) + "\n"		
		pos += 1
