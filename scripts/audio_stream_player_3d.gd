extends AudioStreamPlayer3D

@export var playlist: Array[AudioStream] = []

var index := 0
var enable := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	finished.connect(_next_music)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
 
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
	_play_music()
	
func _play_music():
		if playlist.is_empty():
			return
		stream = playlist[index]
		stream_paused = false
		play()
		
	
