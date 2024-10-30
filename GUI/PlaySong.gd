extends Control

var target = null

func set_target(new_target):
	target = new_target

func _on_Button_pressed():
	if target:
		target._sync_add_state()  # Call the function to change state

func update_label(text):
	$Label.text = text  # Update the label with the current state


func _on_play_pressed():
	print("play pressed")
	pass # Replace with function body.


func _on_URL_text_changed(new_text):
	print(new_text)
	accept_event()
	pass # Replace with function body.
