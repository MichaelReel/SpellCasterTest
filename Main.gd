extends Node


const MAX_CLIENTS: int = 32
const MAX_CHANNELS: int = 0
const IN_BANDWIDTH: int = 0
const OUT_BANDWIDTH: int = 0

const Player: PackedScene = preload("res://Player.tscn")
const UPNPResult: GDScript = preload("res://utils/UPNPResultMap.gd")

@export var port: int = 9999

var _enet_peer = ENetMultiplayerPeer.new()

@onready var main_menu: PanelContainer = $CanvasLayer/MainMenu
@onready var address_entry: LineEdit = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/JoinRow/AddressEntry
@onready var upnp_result: UPNPResult = UPNPResult.new()
@onready var status_label: Label = $StatusLabel
@onready var join_button: Button = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/JoinRow/JoinButton
@onready var spell_manager: Node = $SpellManager

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _on_host_button_pressed() -> void:
	_on_local_host_button_pressed()
	
	upnp_setup()

func _on_local_host_button_pressed():
	main_menu.hide()
	
	_enet_peer.create_server(port, MAX_CLIENTS, MAX_CHANNELS, IN_BANDWIDTH, OUT_BANDWIDTH)
	multiplayer.multiplayer_peer = _enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())
	
	var success_msg: String = "Success! Join Addresses: %s" % IP.get_local_addresses()
	print(success_msg)
	status_label.set_text(success_msg)

func _on_join_button_pressed() -> void:
	main_menu.hide()
	
	var address: String = address_entry.text
	_enet_peer.create_client(address, port, MAX_CHANNELS, IN_BANDWIDTH, OUT_BANDWIDTH)
	multiplayer.multiplayer_peer = _enet_peer

func _on_address_entry_text_changed(new_text: String):
	join_button.set_disabled(new_text == "" or new_text == null)

func add_player(peer_id: int) -> void:
	var player = Player.instantiate()
	player.name = str(peer_id)
	spell_manager.register_caster(player)
	add_child(player)

func remove_player(peer_id: int) -> void:
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func upnp_setup() -> void:
	var upnp = UPNP.new()
	var discover_result = upnp.discover()
	
	if not (discover_result == UPNP.UPNP_RESULT_SUCCESS):
		var err_msg: String = "UPNP Discover Failed! Error %s" % upnp_result.upnp_result_string[discover_result]
		printerr(err_msg)
		status_label.set_text(err_msg)
	
	if not (upnp.get_gateway() and upnp.get_gateway().is_valid_gateway()):
		var err_msg: String = "UPNP Invalid Gateway!"
		printerr(err_msg)
		status_label.set_text(err_msg)
	
	var map_result = upnp.add_port_mapping(port)
	if not (map_result == UPNP.UPNP_RESULT_SUCCESS):
		var err_msg: String = "UPNP Port Mapping Failed! Error %s" % upnp_result.upnp_result_string[map_result]
		printerr(err_msg)
		status_label.set_text(err_msg)
	
	var success_msg: String = "Success! Join Address: %s" % upnp.query_external_address()
	print(success_msg)
	status_label.set_text(success_msg)
