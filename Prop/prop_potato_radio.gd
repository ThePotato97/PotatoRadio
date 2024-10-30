extends PlayerProp

var state = - 1

onready var audio = $AudioStreamPlayer3D
onready var gui_scene = preload("res://mods/PotatoRadio/GUI/PlaySong.tscn")

var gui

func _ready():
	gui = gui_scene.instance()
	get_tree().current_scene.add_child(gui)

func _sync_add_state():
	var new_state = state + 1
	if new_state > 4: new_state = - 1
	_set_state(new_state)
	Network._send_actor_action(actor_id, "_set_state", [new_state], true)

func _set_state(new):
	print("SETTING STATE")
	state = new

	$Interactable.text = "OPEN GUI"
	
	match state:
		- 1:
			audio.playing = false
		0:
			audio.stream = preload("res://Sounds/Fluffing a Duck.mp3")
			audio.playing = true
		1:
			audio.stream = preload("res://Sounds/Carefree.mp3")
			audio.playing = true
		2:
			audio.stream = preload("res://Sounds/Heartbreaking.mp3")
			audio.playing = true
		3:
			audio.stream = preload("res://Sounds/Sneaky Snitch.mp3")
			audio.playing = true
		4:
			audio.stream = preload("res://Sounds/Meatball Parade.mp3")
			audio.playing = true

func _on_Interactable__activated():
	_sync_add_state()
