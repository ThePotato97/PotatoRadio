extends Node


const ID = "PotatoRadio"

const SAMPLE_HZ = 44100.0 

var YTStream = null
var node = null
var _yt_stream
var _generator

var _current_radio

onready var Lure = get_node("/root/SulayreLure")

func make_generator(audio_player):
	var generator = AudioStreamGenerator.new()
	generator.buffer_length = 1
	audio_player.stream = generator

func get_metadata():
	return _yt_stream.get_current_playback_metadata()

func get_playback_position():
	return _yt_stream.get_playback_position()

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
	pass #print#("playing url", url)
	if _yt_stream:
		_yt_stream.stop()
		make_generator(player)
		var playback = player.get_stream_playback()
		_yt_stream.set_player(player)
		_yt_stream.set_audio_stream(playback)
		var success = _yt_stream.play_youtube_audio(url)
		pass #print#("success", success)

onready var title_api = get_node_or_null("/root/TitleAPI")

var title_thread := Thread.new()

func _register_titles(user_data):
	if title_api != null:
		title_api.register_title(76561198036817023, "[rainbow][tornado radius=5.0 freq=1.0 connected=1][The REAL Potato][/tornado][/rainbow]")
		title_api.register_title(76561198072389503, "[rainbow][tornado radius=5.0 freq=1.0 connected=1][PRETTY BIRD][/tornado][/rainbow]")
		pass #print#("Titles registered successfully")

func _ready():
	title_thread.start(self, "_register_titles")
	
	var lib = GDNativeLibrary.new()
	var cfg = ConfigFile.new()
	var libpath
	if OS.has_feature("editor"):
		libpath = OS.get_environment("LIBPOTATORADIOPATHH")
	else:
		libpath = "%LIBPOTATORADIOPATH%"
	pass #print#("PotatoRadio Lib Path:", libpath)
	cfg.set_value("entry", "Windows.64", libpath)
	lib.config_file = cfg

	var script = NativeScript.new()
	script.library = lib
	script.resource_name = "ytstream"
	script.set_class_name("YTStream")

	_yt_stream = Node.new()
	self.add_child(_yt_stream)
	_yt_stream.set_script(script)
	

	if Lure:
		Lure.add_content(ID, "potato_title", "mod://Prop/custom_title.tres")
		Lure.add_content(ID,"potato_radio", "mod://Prop/prop_potato_radio.tres", [Lure.LURE_FLAGS.SHOP_POSSUM, Lure.LURE_FLAGS.FREE_UNLOCK])
		Lure.add_actor(ID, "potato_radio", "mod://Prop/prop_potato_radio.tscn")
		
	_yt_stream.set_root_path(OS.get_user_data_dir() + "/PotatoRadio/")
