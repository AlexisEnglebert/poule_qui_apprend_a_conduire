extends AudioStreamPlayer3D

@export var playlist: Array[AudioStream] = []
@export_dir var music_folder := "res://music/"

var index := 0
var enable := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music_load()
	finished.connect(_next_music)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
 
func music_load():
	playlist.clear()
	for fichier in ResourceLoader.list_directory(music_folder):
		if fichier.ends_with(".ogg") or fichier.ends_with(".mp3") or fichier.ends_with(".wav"):
			playlist.append(load(music_folder.path_join(fichier)))
		print("📻 ", playlist.size(), " musiques chargées depuis ", music_folder)

func _unhandled_input(event):
	if event.is_action_pressed("radio_on_off"):
		switch()
	elif event.is_action_pressed("radio_next") and enable:
		_next_music()

func switch():
	enable = not enable
	if enable:
		if stream == null:
			_play_music()
		else:
			stream_paused = false
	else:
		stream_paused = true

func _next_music():
	if playlist.is_empty():
		return
	index = (index + 1) % playlist.size()
	print("next music")
	_play_music()
	
func _play_music():
		if playlist.is_empty():
			return
		stream = playlist[index]
		stream_paused = false
		print("music played")
		play()
		
	
