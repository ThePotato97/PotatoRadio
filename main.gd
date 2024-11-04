extends Node


const ID = "PotatoRadio"

const SAMPLE_HZ = 44100.0 

var YTStream = preload("res://mods/PotatoRadio/YTPStream/YTPStream.gdns")

var _yt_stream
var _generator

var _current_radio

onready var Lure = get_node("/root/SulayreLure")

func make_generator(audio_player):
	var generator = AudioStreamGenerator.new()
	generator.buffer_length = 1
	audio_player.stream = generator

func set_active_radio(id):
	_current_radio = id

func is_radio_active(id):
	return _current_radio == id

func stop(id):
	if id != _current_radio: return
	if _yt_stream:
		_yt_stream.stop()

func play_url(id, url: String, player):
	if id != _current_radio: return
	print("playing url", url)
	if _yt_stream:
		_yt_stream.stop()
		make_generator(player)
		var playback = player.get_stream_playback()
		_yt_stream.set_player(player)
		_yt_stream.set_audio_stream(playback)
		var success = _yt_stream.play_youtube_audio(url)
		print("success", success)

func _ready():
	if Lure:
		
		Lure.add_content(ID,"potato_radio", "mod://Prop/prop_potato_radio.tres", [Lure.LURE_FLAGS.SHOP_POSSUM, Lure.LURE_FLAGS.FREE_UNLOCK])
		Lure.add_actor(ID, "potato_radio", "mod://Prop/prop_potato_radio.tscn")
		
	_yt_stream = YTStream.new()
	add_child(_yt_stream)
	_yt_stream.set_root_path(OS.get_user_data_dir() + "/PotatoRadio/")
