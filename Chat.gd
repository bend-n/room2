extends Control

onready var labels = find_node("labels")
onready var whoami = find_node("whoami")
onready var text = find_node("text")
onready var scroller = find_node("scroller")
onready var tween = find_node("Tween")
onready var scrollbar = scroller.get_v_scrollbar()

const server_says = "[b]server[color=#f0e67e]:[/color][/b] "

var regexes: Array = []


func _connected():
	add_label(
		(
			"%s[b][matrix]w[/matrix]elcome to [rainbow freq=.3 sat=.7][shake rate=20 level=25]room 2!"
			% server_says
		),
		"server"
	)
	yield(get_tree().create_timer(.4), "timeout")
	add_label(
		"%s[b]you can use a custom flavor of [wave amp=20 freq=20]markdown!" % server_says,
		"howto",
		Vector2(1000, 80)
	)


func _ready():
	regexes.append([reg("_([^_]+)_"), "[i]$1[/i]"])
	regexes.append([reg("\\*\\*([^\\*\\*]+)\\*\\*"), "[b]$1[/b]"])
	regexes.append([reg("\\*([^\\*]+)\\*"), "[i]$1[/i]"])
	regexes.append([reg("```([^`]+)```"), "[code]$1[/code]"])
	regexes.append([reg("`([^`]+)`"), "[code]$1[/code]"])
	regexes.append([reg("~~([^~]+)~~"), "[s]$1[/s]"])
	regexes.append([reg("#([^#]+)#"), "[rainbow freq=.3 sat=.7]$1[/rainbow]"])
	regexes.append([reg("@([^@]+)@"), "[wave amp=20 freq=20]$1[/wave]"])
	regexes.append([reg("%([^%]+)%"), "[shake rate=20 level=25]$1[/shake]"])
	regexes.append([reg("\\$([^\\$]+)\\$"), "[matrix]$1[/matrix]"])

# 	if OS.has_feature('JavaScript'):
# 		text.connect("gui_input", self, "_on_text_input")

# func _on_text_input(input : InputEvent):
# 	if input is InputEventMouseButton:
# 		popup_input()

# func popup_input():
# 	text.text = JavaScript.eval("""
# 		window.prompt('Username')
# 	""")


func reg(src: String) -> RegEx:
	var regex := RegEx.new()
	regex.compile(src)
	return regex


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
	t = translate_md(t.strip_edges())
	text.text = ""
	get_parent().send_packet({"who": whoami.text, "text": t, "header": "C"})


func translate_md(input: String) -> String:
	for replacement in regexes:
		input = replacement[0].sub(input, replacement[1])
	return input


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
