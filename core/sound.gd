extends Node


func play(sound):
	var audio := AudioStreamPlayer.new()
	audio.stream = sound
	#audio.volume_db = -25
	audio.finished.connect(audio.queue_free)
	add_child(audio)
	audio.play()
