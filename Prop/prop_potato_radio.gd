extends PlayerProp

var state = null


onready var _audio = $AudioStreamPlayer3D
onready var _interactable = $Interactable
onready var PlaySongGui = preload("res://mods/PotatoRadio/GUI/PlaySong.tscn")

onready var Lure = get_node("/root/SulayreLure")
onready var PotatoRadio = get_node("/root/PotatoRadio")

var _prop_gui

func _ready():
	print("spawned radio")

	if PlaySongGui:
		_prop_gui = PlaySongGui.instance()
		_prop_gui.hide()
		get_tree().root.add_child(_prop_gui)
		_prop_gui.connect("play_url", self, "sync_radio_play")
		_prop_gui.connect("stop", self, "sync_radio_stop")

	var generator = AudioStreamGenerator.new()
	generator.buffer_length = 15
	_audio.stream = generator
	_audio.stream.mix_rate = PotatoRadio.SAMPLE_HZ

func _exit_tree():
	PotatoRadio.stop(actor_id)
	if _prop_gui:
		_prop_gui.queue_free()

func stop_radio():
	PotatoRadio.stop(actor_id)

func sync_radio_stop():
	stop_radio()
	Network._send_actor_action(actor_id, "stop_radio", [], true)

func play_radio(url):
	if not url or not PotatoRadio: return
	PotatoRadio.play_url(actor_id, url, _audio)

func _process(delta):
	if not PotatoRadio: return
	var is_active = PotatoRadio.is_radio_active(actor_id)
	if is_active:
		_interactable.text = "OPEN GUI"
	else:
		_interactable.text = "TURN ON"

func sync_radio_play(url):
	play_radio(url)
	Network._send_actor_action(actor_id, "play_radio", [url], true)


func _on_Interactable__activated():
	var is_active = PotatoRadio.is_radio_active(actor_id)
	if is_active:
		_prop_gui.show()
	else:
		PotatoRadio.set_active_radio(actor_id)
		if state != null:
			_prop_gui.set_url(state)
			play_radio(state)

