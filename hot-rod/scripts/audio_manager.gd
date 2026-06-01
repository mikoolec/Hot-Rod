extends Node

@export_group ("SFX")
@export var click_sound : AudioStream
@export var explosion_sound : AudioStream
@export var lever_sound : AudioStream
@export var siren_sound : AudioStream

@export_group ("VOICES")
@export var game_start : AudioStream
@export var first_heat : AudioStream
@export var explosion_start : AudioStream
@export var explosion_over_bad : AudioStream
@export var explosion_over_good : AudioStream
@export var time_over_1 : AudioStream
@export var time_over_2 : AudioStream
@export var time_over_3 : AudioStream
@export var time_over_4 : AudioStream

@onready var menu_music_player: AudioStreamPlayer = $MenuMusicPlayer
@onready var game_music_player: AudioStreamPlayer = $GameMusicPlayer
@onready var sound_effects_player: AudioStreamPlayer = $SoundEffectsPlayer
@onready var voice_player: AudioStreamPlayer = $VoicePlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	print_tree_pretty()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func play_menu_music():
	if not menu_music_player.playing: # Kluczowe: gra tylko jeśli już nie leci
		game_music_player.stop()
		menu_music_player.play()

func play_game_music():
	menu_music_player.stop()
	game_music_player.play()

func _play_dynamic_sound(stream: AudioStream, bus_name: String):
	if stream == null:
		return
	var temp_player = AudioStreamPlayer.new()
	add_child(temp_player)
	temp_player.stream = stream
	temp_player.bus = bus_name
	temp_player.play()
	temp_player.finished.connect(func(): temp_player.queue_free())

func play_sfx(sound_type: String):
	var stream_to_play: AudioStream = null
	match sound_type:
		"click":
			stream_to_play = click_sound
		"explosion":
			stream_to_play = explosion_sound
		"siren":
			stream_to_play = siren_sound # Możesz podmienić na inny dźwięk syreny, jeśli masz
		"lever":
			stream_to_play = lever_sound
	_play_dynamic_sound(stream_to_play, "SFX")

func play_voice_line(sound_type: String):
	var stream_to_play: AudioStream = null
	match sound_type:
		"start":
			stream_to_play = game_start
		"first_heat":
			stream_to_play = first_heat
		"explosion_start":
			stream_to_play = explosion_start
		"explosion_over_bad":
			stream_to_play = explosion_over_bad
		"explosion_over_good":
			stream_to_play = explosion_over_good
		"time_over_1":
			stream_to_play = time_over_1
		"time_over_2":
			stream_to_play = time_over_2
		"time_over_3":
			stream_to_play = time_over_3
		"time_over_4":
			stream_to_play = time_over_4
	_play_dynamic_sound(stream_to_play, "VOICES")
