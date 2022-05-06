extends Control

onready var labels = find_node("labels")
onready var whoami = find_node("whoami")
onready var text = find_node("text")
onready var scroller = find_node("scroller")
onready var tween = find_node("Tween")
onready var scrollbar = scroller.get_v_scrollbar()

const server_says = "[b]server[color=#f0e67e]:[/color][/b] "


func _ready():
	add_label(
		(
			"%s[b][matrix]welcome to [/matrix][rainbow freq=.3 sat=.7][shake rate=20 level=25]room 2!"
			% server_says
		),
		"server"
	)
	add_label(
		(
			"%s[b][tornado freq=5 radius=10] you can use [/tornado][wave amp=20 freq=20][url=https://en.wikipedia.org/wiki/BBCode]bbcode"
			% server_says
		),
		"howto",
		Vector2(1000, 80)
	)


func _on_Main_recieved(data):
	var string = "[b]%s[color=#f0e67e]:[/color][/b] %s" % [data.who, data.text]
	add_label(string)


func add_label(bbcode: String, name = "richtextlabel", size = Vector2(1000, 40)) -> RichTextLabel:
	var l = RichTextLabel.new()
	l.name = name
	l.rect_min_size = size
	l.install_effect(RichTextMatrix.new())
	l.bbcode_enabled = true
	l.scroll_active = false
	labels.add_child(l)
	l.connect("meta_clicked", self, "open_url")
	l.bbcode_text = bbcode
	l.fit_content_height = true
	tween.interpolate_property(
		scrollbar, "value", scrollbar.value, scrollbar.max_value, .5, Tween.TRANS_BOUNCE
	)
	tween.start()
	return l


func open_url(meta):
	var err = OS.shell_open(meta)
	if err == OK:
		print("Opened link '%s' successfully!" % meta)
	else:
		printerr("Failed opening the link '%s'!" % meta)


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


func _on_Main_err(err: String):
	add_label("[b][color=#ff6347]error:[i] %s" % err)
	text.editable = false
