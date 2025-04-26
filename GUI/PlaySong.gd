extends Control

signal play_url(url)

signal stop
signal set_volume(volume)
signal set_name(name)
signal set_current_time(time)
signal set_duration(time)

func show():
	visible = true

func hide():
	visible = false
	

func set_owner_name(name: String):
	$Panel/OwnerLabel.text = "%s's Radio" % name

var current_thumbnail = null

func set_thumbnail_default():
	if current_thumbnail == "": return
	current_thumbnail = ""
	$Panel/TextureRect.texture = preload("res://mods/PotatoRadio/Prop/prop_potato_radio.png")
	


func set_current_time(time: float):
	$Panel/PlaybackSlider.value = time
	
func set_current_time_label(seconds: int):
	var hours = seconds / 3600
	var minutes = (seconds / 60) % 60
	var sec = seconds % 60

	var formated = ""
	if hours > 0:
		formated = "%d:%02d:%02d" % [hours, minutes, sec]
	else:
		formated = "%d:%02d" % [minutes, sec]

	$Panel/CurrentTime.text = formated

func set_unowned_radio():
	$Panel/HBoxContainer/stop.text = "Stop Listening"
	$Panel/HBoxContainer/play.visible = false

func set_thumbnail(url: String):
	if current_thumbnail == url: return
	current_thumbnail = url
	pass #print#("setting thumbnail")
	# Create an HTTP request node and connect its completion signal.
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")

	# Perform the HTTP request. The URL below returns a PNG image as of writing.
	var error = http_request.request(url)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _http_request_completed(result, response_code, headers, body):
	var image = Image.new()
	var content_type = ""
	
	# Find the Content-Type header
	for header in headers:
		if header.begins_with("Content-Type:"):
			content_type = header.strip_edges().split(":")[1].strip_edges()
			break
	pass #print#(content_type)
	var error = ERR_UNAVAILABLE
	
	# Choose the loading method based on Content-Type
	match content_type:
		"image/png":
			error = image.load_png_from_buffer(body)
		"image/jpeg", "image/jpg":
			error = image.load_jpg_from_buffer(body)
		"image/bmp":
			error = image.load_bmp_from_buffer(body)
		"image/tga":
			error = image.load_tga_from_buffer(body)
		"image/webp":
			error = image.load_webp_from_buffer(body)
		_:
			push_error("Unsupported image format or Content-Type not found.")
			return
	
	if error != OK:
		push_error("Couldn't load the image from the buffer.")
		return

	var texture = ImageTexture.new()
	texture.create_from_image(image)
	$Panel/TextureRect.texture = texture


func set_title(name: String):
	$Panel/SongName.text = name

func _on_play_pressed():
	var url = $Panel/URL.text
	emit_signal("play_url", url)
	hide()

func set_url(url: String):
	var text_box = $Panel/URL
	if text_box:
		text_box.text = url

func _on_URL_text_changed(new_text):
	accept_event()

func _on_close_pressed():
	hide()


func _on_stop_pressed():
	emit_signal("stop")


func _on_music_vol_value_changed(value):
	var music_label = $Panel/muc_vol/VBoxContainer/music_label
	emit_signal("set_volume", value)
	music_label.text = str(value * 100.0) + "%"
