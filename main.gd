extends Node

const YT_DLP = preload("res://mods/PotatoRadio/yt-dlp/yt_dlp.gd")

const ID = "PotatoRadio"

onready var Lure = get_node("/root/SulayreLure")

func _ready():
	if Lure:
		Lure.add_content(ID,"Youtube Boombox", "mod://Prop/prop_yt_boombox.tres", ["FREE_UNLOCK"])
	var yt_dlp = YT_DLP.new()
	print("PotatoRadio mod loaded")

	
	yield(yt_dlp, "ready")

	yt_dlp.download("https://www.youtube.com/watch?v=ZsuBqtfvTwc", OS.get_user_data_dir(), "audio_clip", true)

	yield(yt_dlp, "download_completed")

	var ogg_file := File.new()

	ogg_file.open("user://audio_clip.ogg", File.READ)

	var stream = AudioStreamOGGVorbis.new()
	stream.data = ogg_file.get_buffer(ogg_file.get_len())
	ogg_file.close()

	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = stream
	audio_player.play()
	get_tree().get_root().add_child(audio_player)

