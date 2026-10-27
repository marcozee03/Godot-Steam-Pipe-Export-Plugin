@tool
extends EditorPlugin

const SteamPipeExportPlugin := preload("res://addons/steam-pipe-export/steam_pipe_export_plugin.gd")
var steam_pipe: SteamPipeExportPlugin


func _enter_tree() -> void:
	steam_pipe = SteamPipeExportPlugin.new()
	add_export_plugin(steam_pipe)
	_register_editor_setting(
		"steam_pipe/export/username",
		"",
		{
			"name": "steam_pipe/export/username",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			# "usage": PROPERTY_USAGE_SECRET | PROPERTY_USAGE_EDITOR_BASIC_SETTING,
		},
	)
	_register_editor_setting(
		"steam_pipe/export/password",
		"",
		{
			"name": "steam_pipe/export/password",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_PASSWORD,
			"hint_string": "",
			# "usage": PROPERTY_USAGE_SECRET | PROPERTY_USAGE_EDITOR_BASIC_SETTING,
		},
	)
	_register_editor_setting(
		"steam_pipe/export/steam_cmd_path",
		"",
		{
			"name": "steam_pipe/export/steam_cmd_path",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_GLOBAL_FILE,
			"hint_string": "",
			# "usage": PROPERTY_USAGE_EDITOR_BASIC_SETTING,
		},
	)
	EditorInterface.get_editor_settings().settings_changed.connect(_on_settings_changed)
	pass


func _exit_tree() -> void:
	remove_export_plugin(steam_pipe)
	var es := EditorInterface.get_editor_settings()
	if es.settings_changed.is_connected(_on_settings_changed):
		es.settings_changed.disconnect(_on_settings_changed)

	pass


const steam_pipe_CMD_PATH := "steam_pipe/export/steam_pipe_cmd_path"
const steam_pipe_USER_NAME := "steam_pipe/export/username"
const steam_pipe_PASSWORD := "steam_pipe/export/password"


func _register_editor_setting(key: String, default: Variant, info: Dictionary) -> void:
	var es := EditorInterface.get_editor_settings()
	if not es.has_setting(key):
		es.set_setting(key, default)
	es.set_initial_value(key, default, false)
	es.add_property_info(info)


func _on_settings_changed() -> void:
	pass
