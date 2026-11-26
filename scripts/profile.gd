extends RefCounted

const SAVE_PATH := "user://village.save"
const SAVE_VERSION := 1


static func write_game(state: Dictionary) -> Error:
	var temporary_path := SAVE_PATH + ".%d.tmp" % OS.get_process_id()
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_var({"version": SAVE_VERSION, "village": state})
	file.flush()
	var error := file.get_error()
	file.close()
	if error != OK:
		return error
	return DirAccess.rename_absolute(temporary_path, SAVE_PATH)


static func read_game() -> Dictionary:
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null or file.get_length() < 8 or file.get_length() > 4 * 1024 * 1024:
		return {}
	var payload: Variant = file.get_var(false)
	if not payload is Dictionary or payload.get("version") != SAVE_VERSION:
		return {}
	var state: Variant = payload.get("village")
	return state if state is Dictionary else {}
