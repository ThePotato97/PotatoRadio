extends PlayerProp

var state = null


onready var _audio = $AudioStreamPlayer3D
onready var _interactable = $Interactable
onready var PlaySongGui = preload("res://mods/PotatoRadio/GUI/PlaySong.tscn")

onready var Lure = get_node("/root/SulayreLure")
onready var PotatoRadio = get_node("/root/PotatoRadio")

var _prop_gui
var prop_owner_name
func _ready():
	custom_valid_actions = ["stop_radio", "play_radio"]
	pass #print#("spawned radio")

	
	if PlaySongGui:
		_prop_gui = PlaySongGui.instance()
		_prop_gui.hide()
		get_tree().root.add_child(_prop_gui)
		_prop_gui.connect("play_url", self, "sync_radio_play")
		_prop_gui.connect("stop", self, "sync_radio_stop")
		_prop_gui.connect("set_volume", self, "set_radio_volume")
		var owner_name = Network._get_username_from_id(owner_id)
		if controlled:
			PotatoRadio.set_active_radio(actor_id)
		else:
			_prop_gui.set_unowned_radio()
		if owner_name:
			prop_owner_name = owner_name
			_prop_gui.set_owner_name(owner_name)

	var generator = AudioStreamGenerator.new()
	generator.buffer_length = 15
	_audio.stream = generator
	_audio.stream.mix_rate = PotatoRadio.SAMPLE_HZ

func _exit_tree():
	PotatoRadio.stop(actor_id)
	if _prop_gui:
		_prop_gui.queue_free()
		PotatoRadio.set_active_radio(null)

func stop_radio():
	PotatoRadio.stop(actor_id)

func sync_radio_stop():
	if controlled:
		stop_radio()
		Network._send_actor_action(actor_id, "stop_radio", [], true)
	else:
		stop_radio()
		PotatoRadio.set_active_radio(null)
		_prop_gui.hide()


func play_radio(url): # TODO: Add a check to see if the url is valid
	pass #print#("playing", url)
	if not url or not PotatoRadio: return
	_prop_gui.set_url(url)
	state = url
	PotatoRadio.play_url(actor_id, url, _audio)

func set_radio_volume(volume):
	_audio.unit_db = linear2db(volume)


func sync_radio_play(url):
	if not controlled: return
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


func _process(delta: float) -> void:
	if not _is_radio_available():
		return
		
	if PotatoRadio.is_radio_active(actor_id):
		_update_player_display()
		_interactable.text = "OPEN GUI\n%s's RADIO" % prop_owner_name
	else:
		_reset_display()
		
func _is_radio_available() -> bool:
	return PotatoRadio != null

func _update_player_display() -> void:
	var metadata = PotatoRadio.get_metadata()
	var current_position = PotatoRadio.get_playback_position()
	
	if not metadata or not current_position:
		_reset_display()
		return
		
	_update_track_info(metadata)
	_update_playback_progress(metadata, current_position)

func _update_track_info(metadata: Dictionary) -> void:
	var title = metadata.get("title", "Unknown")
	_prop_gui.set_title(title)
	
	var thumbnail = metadata.get("thumbnail")
	if thumbnail:
		_prop_gui.set_thumbnail(thumbnail)
	else:
		_prop_gui.set_thumbnail_default()

func _update_playback_progress(metadata: Dictionary, current_position: float) -> void:
	var duration = metadata.get("duration")
	if duration:
		_prop_gui.set_current_time(current_position / duration)
		_prop_gui.set_current_time_label(current_position)
	else:
		_prop_gui.set_current_time(0)
		_prop_gui.set_current_time_label(0)

func _reset_display() -> void:
	_prop_gui.set_thumbnail_default()
	_prop_gui.set_current_time(0)
	_prop_gui.set_current_time_label(0)
	_prop_gui.set_title("Nothing playing!")
	_interactable.text = "TURN ON\n%s's RADIO" % prop_owner_name
