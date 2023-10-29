extends CanvasLayer

signal restart


func _on_restar_button_pressed():
	restart.emit()
