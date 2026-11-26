extends Node

const MUSIC := {
	"title": preload("res://audio/title.wav"),
	"story": preload("res://audio/story.wav"),
	"farm": preload("res://audio/farm.wav"),
}
const CLICK := preload("res://audio/click.wav")

var music := AudioStreamPlayer.new()
var effects := AudioStreamPlayer.new()
var current := ""


func _ready() -> void:
	add_child(music)
	add_child(effects)
	music.volume_db = -10.0
	effects.volume_db = -12.0
	effects.max_polyphony = 4
	effects.stream = CLICK


func play_music(track: String) -> void:
	if current == track:
		return
	current = track
	var loop: AudioStreamWAV = MUSIC[track].duplicate()
	loop.loop_mode = AudioStreamWAV.LOOP_FORWARD
	loop.loop_end = roundi(loop.get_length() * loop.mix_rate)
	music.stream = loop
	if DisplayServer.get_name() != "headless":
		music.play()


func click() -> void:
	if DisplayServer.get_name() != "headless":
		effects.play()


func _exit_tree() -> void:
	music.stop()
	effects.stop()
