extends Control

signal play_url(url)

signal stop

func show():
	visible = true

func hide():
	visible = false

func _on_play_pressed():
	var url = $Panel/URL.text
	emit_signal("play_url", url)
	hide()

func set_url(url: String):
	var text_box = $Panel/URL
	if text_box:
		text_box.text = url

func _on_URL_text_changed(new_text):
	print(new_text)
	accept_event()

func _on_close_pressed():
	hide()


func _on_stop_pressed():
	emit_signal("stop")
