extends Node

@export_dir var music_folder := "res://music_intro/"
@export var music_volume_db := -10.0

var _music_player: AudioStreamPlayer


func _ready() -> void:
	var music := _find_first_music(music_folder)
	if music == null:
		push_warning("No music found in " + music_folder)
		return

	_music_player = AudioStreamPlayer.new()
	_music_player.stream = music
	_music_player.volume_db = music_volume_db
	_music_player.finished.connect(_music_player.play)
	add_child(_music_player)
	_music_player.play()


func _find_first_music(folder: String) -> AudioStream:
	for file in ResourceLoader.list_directory(folder):
		if file.ends_with(".ogg") or file.ends_with(".mp3") or file.ends_with(".wav"):
			return load(folder.path_join(file))
	return null
