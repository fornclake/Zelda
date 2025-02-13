class_name UI extends CanvasLayer

var target
@onready var hud = $HUD
@onready var hearts = $HUD/Hearts
@onready var inventory = $Inventory


func initialize(_target : Actor):
	target = _target
	_inventory_changed(target.items)
	inventory.inventory_changed.connect(_inventory_changed)
	target.item_received.connect(_inventory_changed)


func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		if inventory.visible:
			_close_inventory()
		else:
			_open_inventory()


func _inventory_changed(new_items):
	inventory.items = new_items # redundant
	target.items = new_items
	hud.items = new_items
	hud.queue_redraw()


func _open_inventory():
	get_tree().paused = true
	Sound.play(preload("res://data/sfx/LA_PauseMenu_Open.wav"))
	await ScreenFX.fade_white_in()
	inventory.show()
	ScreenFX.fade_white_out()


func _close_inventory():
	Sound.play(preload("res://data/sfx/LA_PauseMenu_Close.wav"))
	await ScreenFX.fade_white_in()
	inventory.hide()
	await ScreenFX.fade_white_out()
	get_tree().paused = false
