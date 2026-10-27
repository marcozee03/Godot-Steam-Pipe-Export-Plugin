extends EditorExportPlugin


func _get_name() -> String:
	return "steam_pipe"


func file_mapping(index: int) -> Array[Dictionary]:
	return [
		{
			"option": {
				"name": "steam_pipe/app_build/depot_build/file_mapping_%d/local_path" % index,
				"type": TYPE_STRING,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_DEFAULT,
			},
			"default_value": "",
		},
		{
			"option": {
				"name": "steam_pipe/app_build/depot_build/file_mapping_%d/depot_path" % index,
				"type": TYPE_STRING,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_DEFAULT,
			},
			"default_value": "",
		},
		{
			"option": {
				"name": "steam_pipe/app_build/depot_build/file_mapping_%d/recursive" % index,
				"type": TYPE_BOOL,
			},
			"default_value": true,
		},
	]


func _supports_platform(platform) -> bool:
	return true


const max_file_mappings := 10


func _get_export_option_visibility(platform: EditorExportPlatform, option: String) -> bool:
	if !option.begins_with("steam_pipe"):
		return true
	if option == "steam_pipe/enabled":
		return true
	if not get_option("steam_pipe/enabled"):
		return false
	if (
		not option.contains("file_mapping")
		or option == "steam_pipe/app_build/depot_build/file_mapping_count"
	):
		return true
	if (option.begins_with("steam_pipe/app_build/depot_build/file_mapping_")):
		var count = get_option("steam_pipe/app_build/depot_build/file_mapping_count")
		for i in range(0, count):
			if option.begins_with("steam_pipe/app_build/depot_build/file_mapping_%d" % i):
				return true
	return false


func _get_export_options(platform: EditorExportPlatform) -> Array[Dictionary]:
	var user_config = {
		"option": {
			"name": "steam_pipe/app_build/depot_build/file_properties/user_configs",
			"type": TYPE_PACKED_STRING_ARRAY,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		"default_value": PackedStringArray(),
	}
	var versioned_config = {
		"option": {
			"name": "steam_pipe/app_build/depot_build/file_properties/versioned_configs",
			"type": TYPE_PACKED_STRING_ARRAY,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		"default_value": PackedStringArray(),
	}

	var d: Array[Dictionary] = [
		{
			"option": {
				"name": "steam_pipe/enabled",
				"type": TYPE_BOOL,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_DEFAULT,
			},
			"default_value": false,
			"update_visibility": true,
		},
		{
			"option": {
				"name": "steam_pipe/app_build/app_id",
				"type": TYPE_STRING,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_DEFAULT,
			},
			"default_value": "",
		},
		{
			"option": {
				"name": "steam_pipe/app_build/description",
				"type": TYPE_STRING,
				"hint": PROPERTY_HINT_MULTILINE_TEXT,
				"hint_string": "",
				"usage": PROPERTY_USAGE_DEFAULT,
			},
			"default_value": "",
		},
		{
			"option": {
				"name": "steam_pipe/app_build/preview",
				"type": TYPE_BOOL,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_DEFAULT,
			},
			"default_value": false,
		},
		{
			"option": {
				"name": "steam_pipe/app_build/local",
				"type": TYPE_STRING,
				"hint": PROPERTY_HINT_GLOBAL_DIR,
				"hint_string": "",
				"usage": PROPERTY_USAGE_DEFAULT,
			},
			"default_value": "",
		},
		{
			"option": {
				"name": "steam_pipe/app_build/set_live",
				"type": TYPE_STRING,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_DEFAULT,
			},
			"default_value": "",
		},
		{
			"option": {
				"name": "steam_pipe/app_build/depot_build/depot_id",
				"type": TYPE_STRING,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_DEFAULT,
			},
			"default_value": "",
		},
		{
			"option": {
				"name": "steam_pipe/app_build/depot_build/file_mapping_count",
				"type": TYPE_INT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "0,%d,1" % max_file_mappings,
				"usage": PROPERTY_USAGE_DEFAULT,
			},
			"default_value": 0,
			"update_visibility": true,
		},
	]
	for i in range(0, max_file_mappings):
		d.append_array(file_mapping(i))

	d.append_array(
		[
			{
				"option": {
					"name": "steam_pipe/app_build/depot_build/file_exclusion",
					"type": TYPE_PACKED_STRING_ARRAY,
					"hint": PROPERTY_HINT_NONE,
					"hint_string": "",
					"usage": PROPERTY_USAGE_DEFAULT,
				},
				"default_value": PackedStringArray(),
			},
			{
				"option": {
					"name": "steam_pipe/app_build/depot_build/install_scripts",
					"type": TYPE_PACKED_STRING_ARRAY,
					"hint": PROPERTY_HINT_NONE,
					"hint_string": "",
					"usage": PROPERTY_USAGE_DEFAULT,
				},
				"default_value": PackedStringArray(),
			},
		]
	)
	d.append(versioned_config)
	d.append(user_config)
	return d


func _export_end() -> void:
	if not get_option("steam_pipe/enabled"):
		return
	var file = _build_vdf()
	var es := EditorInterface.get_editor_settings()
	var cmd: String = es.get_setting("steam_pipe/export/steam_cmd_path")
	var username: String = es.get_setting("steam_pipe/export/username")
	var password: String = es.get_setting("steam_pipe/export/password")
	var output: Array
	await EditorInterface \
			.get_base_control() \
			.get_tree() \
			.create_timer(10.0, true, false, true) \
			.timeout
	var args: PackedStringArray = [
		"+@ShutdownOnFailedCommand",
		"1",
		"+@NoPromptForPassword",
		"1",
		"+login",
		username,
		"+run_app_build",
		file.get_path_absolute(),
		"+quit",
	]
	if not password.is_empty():
		args.insert(6, password)

	var exit_code = OS.execute(cmd, args, output)
	print(output)
	if (exit_code != 0):
		push_error("steam_pipeCMD exited with %s" % exit_code)
	file.close()
	pass


func _build_vdf() -> FileAccess:
	var file = FileAccess.create_temp(FileAccess.WRITE_READ)
	file.store_line("AppBuild")
	file.store_line("{")

	var preview: bool = get_option("steam_pipe/app_build/preview")
	var store: Callable = func(indent: int, key: String, value):
		for i in range(0, indent):
			file.store_string("\t")
		file.store_line('''"%s"\t"%s"''' % [key, value])
	store.call(1, "AppID", get_option("steam_pipe/app_build/app_id"))
	store.call(1, "Desc", get_option("steam_pipe/app_build/description"))
	store.call(
		1,
		"ContentRoot",
		ProjectSettings.globalize_path(
			"res://" + get_export_preset().get_export_path().get_base_dir()
		),
	)

	store.call(1, "BuildOutput", ProjectSettings.globalize_path("user://logs/"))
	if (preview):
		store.call(1, "Preview", "1")
	if not str(get_option("steam_pipe/app_build/set_live")).is_empty():
		store.call(1, "SetLive", get_option("steam_pipe/app_build/set_live"))

	if not str(get_option("steam_pipe/app_build/local")).is_empty():
		store.call(1, "Local", get_option("steam_pipe/app_build/local"))

	file.store_line("\t\"Depots\"")
	file.store_line("\t{")
	file.store_line("\t\t\"%s\"" % get_option("steam_pipe/app_build/depot_build/depot_id"))
	file.store_line("\t\t{")
	for exclusion in get_option("steam_pipe/app_build/depot_build/file_exclusion"):
		store.call(3, "FileExclusion", exclusion)
	for exclusion in get_option("steam_pipe/app_build/depot_build/install_scripts"):
		store.call(3, "InstallScript", exclusion)
	for i in range(0, get_option("steam_pipe/app_build/depot_build/file_mapping_count")):
		file.store_line("\t\t\t\"FileMapping\"")
		file.store_line("\t\t\t{")
		store.call(
			4,
			"LocalPath",
			get_option("steam_pipe/app_build/depot_build/file_mapping_%d/local_path" % i),
		)
		store.call(
			4,
			"DepotPath",
			get_option("steam_pipe/app_build/depot_build/file_mapping_%d/depot_path" % i),
		)
		var recursive: bool = get_option(
			"steam_pipe/app_build/depot_build/file_mapping_%d/recursive" % i
		)
		if (recursive):
			store.call(4, "Rescursive", 1)
		file.store_line("\t\t\t}")
	for user_config in get_option("steam_pipe/app_build/depot_build/file_properties/user_configs"):
		file.store_line("\t\t\t\"FileProperties\"")
		file.store_line("\t\t\t{")
		store.call(4, "LocalPath", user_config)
		store.call(4, "Attributes", "userconfig")
		file.store_line("\t\t\t}")
	for versioned_config in get_option(
		"steam_pipe/app_build/depot_build/file_properties/versioned_configs"
	):
		file.store_line("\t\t\t\"FileProperties\"")
		file.store_line("\t\t\t{")
		store.call(4, "LocalPath", versioned_config)
		store.call(4, "Attributes", "versionedconfig")
		file.store_line("\t\t\t}")

	file.store_line("\t\t}")
	file.store_line("\t}")
	file.store_line("}")
	file.flush()
	push_warning(file.get_as_text())
	return file
