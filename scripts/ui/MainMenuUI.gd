class_name MainMenuUI
extends CanvasLayer

func _ready() -> void:
	var start_btn = $Panel/VBox/StartBtn
	start_btn.pressed.connect(func():
		visible = false
		GameManager.start_game()
	)
