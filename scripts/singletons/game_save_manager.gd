extends Node

const SAVE_PATH := "user://saves/"
const FORMAT := "json"
const FORMAT_ENC := "dat"
const SAVE_GROUP := "game_save_group"
const ENCRYPT := false

var _loaded_nodes_dictionary: Dictionary
var _prepared_data: Dictionary
var _prepared := false
var _password := "admin123lmao"

signal load_finished()

func register_loaded_node(id:int, node:Node):
	_loaded_nodes_dictionary[id] = node

func get_loaded_node(id:int) -> Node:
	return _loaded_nodes_dictionary[id]

func erase_prepared():
	_prepared = false
	_prepared_data.clear()

func remove_save(path:String):
	erase_prepared()
	DirAccess.remove_absolute(SAVE_PATH+path+"."+FORMAT)
	DirAccess.remove_absolute(SAVE_PATH+path+"."+FORMAT_ENC)
func has_prepared():
	return _prepared

func prepare_from_file(path:String) -> Error:
	var file: FileAccess
	if ENCRYPT:
		file = FileAccess.open_encrypted_with_pass(SAVE_PATH+path+"."+FORMAT_ENC, FileAccess.READ, _password)
	else:
		file = FileAccess.open(SAVE_PATH+path+"."+FORMAT, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()
	var game_data :Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	
	_prepared = true
	_prepared_data = game_data
	return OK


func save_to_file(path:String) -> Error:
	var full_path: String
	var file: FileAccess
	if ENCRYPT:
		full_path = SAVE_PATH+path+"."+FORMAT_ENC
		DirAccess.make_dir_recursive_absolute(full_path.get_base_dir())
		file = FileAccess.open_encrypted_with_pass(full_path, FileAccess.WRITE, _password)
	else:
		full_path = SAVE_PATH+path+"."+FORMAT
		DirAccess.make_dir_recursive_absolute(full_path.get_base_dir())
		file = FileAccess.open(full_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	
	var game_data := {}
	for node in get_tree().get_nodes_in_group(SAVE_GROUP):
		var node_path := node.get_path()
		var node_data := {
			id = node.get_instance_id(),
			custom_data = {},
		}
		if node.has_method("_write_data"):
			node._write_data(node_data.custom_data)
		game_data[str(node_path)] = node_data
	
	file.store_string(JSON.stringify(game_data, "\t"))
	file.close()
	return OK

func load_prepared():
	assert(_prepared, "No save data was prepared")
	_loaded_nodes_dictionary.clear()
	for node_path in _prepared_data:
		var node_data :Dictionary = _prepared_data[node_path]
		var node :Node = get_node_or_null(node_path)
		register_loaded_node(node_data.id, node)
		if node.has_method("_read_data_load"):
			node._read_data_load(node_data.custom_data)

	for node_path in _prepared_data:
		var node_data :Dictionary = _prepared_data[node_path]
		var node := get_loaded_node(node_data.id)
		if node.has_method("_read_data"):
			node._read_data(node_data.custom_data)
	load_finished.emit()
