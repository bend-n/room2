extends Node

var ws = null

signal recieved(data)


func _ready():
	ws = WebSocketClient.new()
	ws.connect("connection_established", self, "_connection_established")
	ws.connect("connection_closed", self, "_connection_closed")
	ws.connect("connection_error", self, "_connection_error")

	var url = "https://chat-server-gd.herokuapp.com/"
	print("Connecting to " + url)
	ws.connect_to_url(url)


func _connection_established(protocol):
	print("Connection established with protocol: ", protocol)


func _connection_closed(_err):
	print("Connection closed")


func _connection_error():
	print("Connection error")


func _process(_delta):
	if (
		ws.get_connection_status() == ws.CONNECTION_CONNECTING
		|| ws.get_connection_status() == ws.CONNECTION_CONNECTED
	):
		ws.poll()
	if ws.get_peer(1).is_connected_to_host():
		if ws.get_peer(1).get_available_packet_count() > 0:
			var text = ws.get_peer(1).get_var()
			emit_signal("recieved", text.value)
			print("recieved %s" % text.value)


func send_packet(variant: String):
	if ws.get_peer(1).is_connected_to_host():
		ws.get_peer(1).put_var(variant)
