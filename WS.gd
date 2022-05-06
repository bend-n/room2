extends Node
class_name Network

var ws = WebSocketClient.new()
var timer = Timer.new()

signal recieved(data)
signal connected
signal err(err)

const HEADERS = {"chat": "C", "ping": "P"}


func _ready():
	add_child(timer)
	timer.start(5)
	timer.connect("timeout", self, "ping")
	ws.connect("connection_established", self, "_connection_established")
	ws.connect("connection_closed", self, "_connection_closed")
	ws.connect("connection_error", self, "_connection_error")
	ws.connect("data_received", self, "_data_recieved")
	ws.connect("connection_failed", self, "connectwebsocket")
	connectwebsocket()


func connectwebsocket():
	var url = "https://chat-server-gd.herokuapp.com/"
	print("Connecting to " + url)
	ws.connect_to_url(url)


func ping():
	send_packet({"header": "P"})


func _connection_established(protocol):
	print("Connection established ", protocol)
	emit_signal("connected")


func _connection_closed(_err):
	emit_signal("err", "Connection closed")


func _connection_error():
	emit_signal("err", "Connection error")


func _data_recieved():
	var text = ws.get_peer(1).get_var()
	if text.header == HEADERS.chat:
		emit_signal("recieved", text)
		print("recieved %s" % text.text)


func _process(_delta):
	if (
		ws.get_connection_status() == ws.CONNECTION_CONNECTING
		|| ws.get_connection_status() == ws.CONNECTION_CONNECTED
	):
		ws.poll()


func send_packet(variant):
	if ws.get_peer(1).is_connected_to_host() and variant.header:
		ws.get_peer(1).put_var(variant)
