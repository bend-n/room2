extends Control

onready var labels = find_node("labels")
onready var whoami = find_node("whoami")
onready var text = find_node("text")
onready var scroller = find_node("scroller")
onready var tween = find_node("Tween")
onready var scrollbar = scroller.get_v_scrollbar()


func _ready():
	text.context_menu_enabled = false


func _on_Main_recieved(data):
	var l = Label.new()
	l.text = data
	labels.add_child(l)
	tween.interpolate_property(
		scrollbar, "value", scrollbar.value, scrollbar.max_value, .5, Tween.TRANS_BOUNCE
	)
	tween.start()


func _on_text_entered(t):
	t = t.strip_edges()
	if !t:
		return
	text.text = ""
	get_parent().send_packet(whoami.text + ": " + t)


func _on_send_pressed():
	_on_text_entered(text.text)
