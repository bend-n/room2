extends Control

onready var labels = find_node("labels")
onready var whoami = find_node("whoami")
onready var text = find_node("text")
onready var scroller = find_node("scroller")
onready var tween = find_node("Tween")
onready var scrollbar = scroller.get_v_scrollbar()


func _ready():
	add_label(
		"[b]server[color=#f0e67e]:[/color] [matrix]welcome to[/matrix] [rainbow freq=.3 sat=.7][shake rate=20 level=25]room 2!",
		"server"
	)


func _on_Main_recieved(data):
	var string = "[b]%s[color=#f0e67e]:[/color][/b] %s" % [data.who, data.text]
	add_label(string)


func add_label(bbcode: String, name = "richtextlabel"):
	var l = RichTextLabel.new()
	l.name = name
	l.rect_min_size = Vector2(1000, 40)
	l.install_effect(RichTextMatrix.new())
	l.bbcode_enabled = true
	labels.add_child(l)
	l.append_bbcode(bbcode)
	tween.interpolate_property(
		scrollbar, "value", scrollbar.value, scrollbar.max_value, .5, Tween.TRANS_BOUNCE
	)
	tween.start()


func _on_text_entered(t):
	if !t:
		return
	t = t.strip_edges()
	text.text = ""
	get_parent().send_packet({"who": whoami.text, "text": t, "header": "C"})


func _on_send_pressed():
	_on_text_entered(text.text)


func _on_whoami_text_entered(t):
	if !t:
		whoami.text = "Anonymous"
	t = t.strip_edges()
	whoami.text = t
