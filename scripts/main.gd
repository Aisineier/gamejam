extends Control

const Village := preload("res://scripts/village.gd")
const FarmView := preload("res://scripts/farm_view.gd")
const Profile := preload("res://scripts/profile.gd")
const GameAudio := preload("res://scripts/game_audio.gd")
const InkPaper := preload("res://scripts/ink_paper.gd")
const PrologueArt := preload("res://scripts/prologue_art.gd")
const Story := preload("res://scripts/story_script.gd")
const Training := preload("res://scripts/training.gd")
const INK := "#273831"
const MUTED := "#554e40"
const GOLD := "#78501d"
const GREEN := "#2f644c"
const RED := "#923f30"
const CINNABAR := "#a03e2d"
const BORDER := "#a79c82"
const PANEL := "#f7f0dfed"
const PARCHMENT := "#fff7e5"
const WASH := "#eee4cb"
const PORTRAITS := {
	"周伯": preload("res://portraits/zhou.png"),
	"周小满": preload("res://portraits/xiaoman.png"),
}

var village := Village.new()
var board: Control
var overlay: Control
var font := SystemFont.new()
var brush_font := SystemFont.new()
var paper_texture: ImageTexture

var prologue: Control
var prologue_page := -1
var dialogue_kind := ""
var dialogue_lines: Array = []
var dialogue_chapter := ""
var dialogue_location := -1
var farm_window_mode := Window.MODE_WINDOWED
var fullscreen_button: Button
var game_audio := GameAudio.new()
var save_status := ""
var in_game := false
var saved_game: Village
var training: Training


func _ready() -> void:
	font.font_names = PackedStringArray(["Microsoft YaHei UI", "Microsoft YaHei", "Noto Sans CJK SC", "PingFang SC", "Arial"])
	brush_font.font_names = PackedStringArray(["KaiTi", "STKaiti", "Kaiti SC", "SimSun", "Noto Serif CJK SC", "Microsoft YaHei UI"])
	paper_texture = InkPaper.make_texture()
	var village_theme := Theme.new()
	village_theme.default_font = font
	village_theme.set_stylebox("normal", "LineEdit", box_style(PARCHMENT, BORDER))
	village_theme.set_stylebox("focus", "LineEdit", box_style("#ffffff00", GREEN))
	village_theme.set_color("font_color", "LineEdit", Color(INK))
	village_theme.set_color("caret_color", "LineEdit", Color(INK))
	village_theme.set_color("font_selected_color", "LineEdit", Color(PARCHMENT))
	village_theme.set_color("selection_color", "LineEdit", Color(GREEN))
	for direction in ["up", "down"]:
		village_theme.set_color(direction + "_icon_modulate", "SpinBox", Color(INK))
		village_theme.set_color(direction + "_hover_icon_modulate", "SpinBox", Color(CINNABAR))
		village_theme.set_color(direction + "_pressed_icon_modulate", "SpinBox", Color(GREEN))
		village_theme.set_color(direction + "_disabled_icon_modulate", "SpinBox", Color("#8d8574"))
	theme = village_theme
	add_child(game_audio)
	get_tree().auto_accept_quit = false
	var game_data := Profile.read_game()
	if not game_data.is_empty():
		var candidate := Village.new()
		if candidate.restore_state(game_data):
			saved_game = candidate
	show_menu()


func box_style(fill: String, border: String, radius: int = 2) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(fill)
	style.border_color = Color(border)
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 5
	style.content_margin_right = 5
	return style


func place(node: Control, parent: Control, bounds: Rect2) -> void:
	node.position = bounds.position
	node.size = bounds.size
	parent.add_child(node)


func panel(parent: Control, bounds: Rect2, fill: String = PANEL, border: String = BORDER, radius: int = 2) -> Panel:
	var node := Panel.new()
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_theme_stylebox_override("panel", box_style(fill, border, radius))
	place(node, parent, bounds)
	return node


func label(parent: Control, bounds: Rect2, value: String, size_px: int = 16, color: String = INK, align: int = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var node := Label.new()
	node.text = value
	node.horizontal_alignment = align as HorizontalAlignment
	node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	node.add_theme_color_override("font_color", Color(color))
	node.add_theme_font_size_override("font_size", size_px)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(node, parent, bounds)
	return node


func brush_label(parent: Control, bounds: Rect2, value: String, size_px: int, tint: String = INK, align: int = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var node := label(parent, bounds, value, size_px, tint, align)
	node.add_theme_font_override("font", brush_font)
	return node


func section_heading(parent: Control, width: int, title: String) -> void:
	panel(parent, Rect2(17, 15, 3, 20), CINNABAR, CINNABAR, 0)
	brush_label(parent, Rect2(28, 6, width - 45, 39), title, 26)


func button(parent: Control, bounds: Rect2, title: String, action: Callable, accent: bool = false, disabled: bool = false) -> Button:
	var node := Button.new()
	node.text = title
	node.disabled = disabled
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	node.add_theme_font_size_override("font_size", 15)
	var text_color := PARCHMENT if accent else INK
	node.add_theme_color_override("font_color", Color(text_color))
	node.add_theme_color_override("font_hover_color", Color(text_color))
	node.add_theme_color_override("font_pressed_color", Color(text_color))
	node.add_theme_color_override("font_focus_color", Color(text_color))
	node.add_theme_color_override("font_disabled_color", Color("#645c4f"))
	node.add_theme_stylebox_override("normal", box_style(CINNABAR if accent else "#f4ecd9", "#7e3024" if accent else "#8c876e"))
	node.add_theme_stylebox_override("hover", box_style("#b04a35" if accent else "#e2e7d1", "#773023" if accent else GREEN))
	node.add_theme_stylebox_override("pressed", box_style("#7b3024" if accent else "#dce1cb", INK))
	node.add_theme_stylebox_override("disabled", box_style("#e7deca", "#b5aa91"))
	var focus := box_style("#ffffff00", "#5d715a")
	focus.set_border_width_all(2)
	focus.set_expand_margin_all(2)
	node.add_theme_stylebox_override("focus", focus)
	node.pressed.connect(game_audio.click)
	node.pressed.connect(action)
	place(node, parent, bounds)
	return node


func show_menu() -> void:
	close_modal()
	clear_prologue_page()
	in_game = false
	game_audio.play_music("title")
	replace_board()
	var artwork := PrologueArt.new()
	artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(artwork, board, Rect2(0, 0, 1440, 900))
	var cover := panel(board, Rect2(93, 159, 516, 582), "#f6eddaeb", "#615744")
	panel(cover, Rect2(9, 9, 498, 564), "#ffffff00", "#b6a584")
	panel(cover, Rect2(9, 9, 498, 4), INK, INK, 0)
	panel(cover, Rect2(42, 48, 48, 49), CINNABAR, RED)
	brush_label(cover, Rect2(42, 48, 48, 49), "穗", 31, PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	brush_label(cover, Rect2(42, 111, 430, 92), "麦穗余晖", 65)
	brush_label(cover, Rect2(45, 207, 426, 34), "河湾村 · 周伯的账本", 24, MUTED)
	panel(cover, Rect2(44, 265, 428, 1), BORDER, BORDER, 0)
	var next := button(cover, Rect2(44, 290, 428, 60), "继续游戏", continue_game, true, saved_game == null)
	var start := button(cover, Rect2(44, 401, 428, 54), "开始游戏", confirm_new_game, saved_game == null)
	var summary := "暂无存档" if saved_game == null else "%s  ·  %d 金币" % [saved_game.date_label(), saved_game.coins]
	label(cover, Rect2(44, 355, 428, 31), summary, 16, MUTED)
	button(cover, Rect2(44, 469, 428, 54), "关闭游戏", quit_game)
	if saved_game != null:
		next.grab_focus()
	else:
		start.grab_focus()


func confirm_new_game() -> void:
	if saved_game == null:
		start_prologue()
		return
	var frame := modal("开始新游戏", "存档", 300)
	paragraph(frame, Rect2(32, 122, 596, 68), "进入农场后，新游戏会替换当前存档。")
	button(frame, Rect2(276, 220, 152, 44), "取消", close_modal).grab_focus()
	button(frame, Rect2(442, 220, 186, 44), "开始新游戏", start_prologue, true)


func continue_game() -> void:
	if saved_game == null:
		return
	village = saved_game
	farm_window_mode = get_window().mode
	enter_farm()


func write_save() -> bool:
	if Profile.write_game(village.save_state()) != OK:
		save_status = "存档写入失败"
		return false
	saved_game = village
	save_status = "进度已保存"
	return true


func save_and_return() -> void:
	if write_save():
		show_menu()
	else:
		refresh()
		show_pending_event()


func quit_game() -> void:
	if in_game and not write_save():
		close_modal()
		refresh()
		show_pending_event()
		return
	get_tree().quit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_game()


func replace_board() -> void:
	if is_instance_valid(board):
		remove_child(board)
		board.queue_free()
	board = Control.new()
	place(board, self, Rect2(0, 0, 1440, 900))


func start_prologue() -> void:
	close_modal()
	village = Village.new()
	in_game = false
	if is_instance_valid(board):
		remove_child(board)
		board.queue_free()
		board = null
	var window := get_window()
	farm_window_mode = window.mode
	window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	if DisplayServer.get_name() != "headless":
		window.mode = Window.MODE_FULLSCREEN
	game_audio.play_music("story")
	dialogue_kind = "opening"
	render_dialogue(0)


func render_dialogue(page: int) -> void:
	clear_prologue_page()
	prologue_page = page
	var opening := dialogue_kind == "opening"
	var ending := dialogue_kind == "ending"
	var total := Story.OPENING.size() if opening else dialogue_lines.size()
	var choice_event: bool = dialogue_kind == "event" and Village.EVENTS[village.current_event].size() > 3
	var choosing := choice_event and page == total
	var speaker: String
	var line: String
	var chapter := dialogue_chapter
	var location := dialogue_location
	if opening:
		var opening_line: Array = Story.OPENING[page]
		chapter = opening_line[0]
		location = opening_line[1]
		speaker = opening_line[2]
		line = opening_line[3]
	elif choosing:
		speaker = "抉择"
		line = "接下来，周伯要怎么做？"
	else:
		speaker = dialogue_lines[page][0]
		line = dialogue_lines[page][1]

	prologue = Control.new()
	add_child(prologue)
	prologue.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var art := PrologueArt.new()
	art.chapter = location
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prologue.add_child(art)
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var surface := Control.new()
	if not choosing:
		surface.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		surface.gui_input.connect(on_prologue_art_input)
	prologue.add_child(surface)
	surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if is_instance_valid(board):
		board.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED

	if PORTRAITS.has(speaker):
		show_portrait(speaker)
	if opening and page in [2, 3]:
		show_ticket()
	if dialogue_kind == "event" and village.current_event == "station_open" and page == 2:
		bus_animation(prologue)
	if opening:
		fullscreen_button = button(prologue, Rect2(28, 26, 128, 42), "", toggle_prologue_fullscreen)
		fullscreen_button.tooltip_text = "也可以按 Esc 切换窗口和全屏。"
		update_fullscreen_label()
	if opening or ending:
		var skip := button(prologue, Rect2(0, 0, 137, 42), "跳过序章" if opening else "跳到结算", start_training if opening else finish_ending)
		skip.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		skip.offset_left = -165
		skip.offset_right = -28
		skip.offset_top = 26
		skip.offset_bottom = 68

	var height := 252 if choosing else 223
	var reader := panel(prologue, Rect2(0, 0, 1060, height), "#f6eddaef", "#665a45")
	reader.mouse_filter = Control.MOUSE_FILTER_STOP
	reader.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	reader.offset_left = -530
	reader.offset_right = 530
	reader.offset_top = -height - 34
	reader.offset_bottom = -34
	panel(reader, Rect2(8, 8, 1044, height - 16), "#ffffff00", "#b6a584", 0)
	panel(reader, Rect2(8, 8, 1044, 3), INK, INK, 0)
	brush_label(reader, Rect2(35, 22, 953, 26), chapter, 20, RED)
	if not choosing:
		label(reader, Rect2(879, 22, 145, 26), "%d / %d" % [page + 1, total], 14, MUTED, HORIZONTAL_ALIGNMENT_RIGHT)
	brush_label(reader, Rect2(32, 50, 975, 45), speaker, 38)
	paragraph(reader, Rect2(36, 103, 985, 70), line, 21, INK)
	if choosing:
		var entry: Array = Village.EVENTS[village.current_event]
		for choice in 2:
			button(reader, Rect2(34 + 502 * choice, 155, 487, 43), entry[3 + choice], resolve_story_choice.bind(choice), choice == 0, village.coins < entry[5 + choice])
		if village.coins < entry[5] and village.coins < entry[6]:
			button(reader, Rect2(784, 203, 239, 32), "暂缓处理 · 声望 −2", resolve_story_choice.bind(2)).grab_focus()
		return

	label(reader, Rect2(36, 167, 425, 37), "点击画面继续", 14, MUTED)
	if page > 0:
		button(reader, Rect2(697, 165, 119, 43), "上一句", turn_dialogue.bind(-1))
	var next_text := "继续剧情  →"
	if page == total - 1:
		if opening:
			next_text = "开始新手教程  →"
		elif ending:
			next_text = "查看结算  →"
		else:
			next_text = "作出选择  →" if choice_event else "继续经营  →"
	button(reader, Rect2(837, 165, 187, 43), next_text, turn_dialogue.bind(1), true).grab_focus()


func show_portrait(speaker: String) -> void:
	var left := speaker == "周伯"
	var portrait := panel(prologue, Rect2(0, 0, 310, 453), "#f3ead7", "#8e8064")
	portrait.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	portrait.offset_left = -530 if left else 220
	portrait.offset_right = portrait.offset_left + 310
	portrait.offset_top = -740
	portrait.offset_bottom = -287
	var picture := TextureRect.new()
	picture.texture = PORTRAITS[speaker]
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var print_material := CanvasItemMaterial.new()
	print_material.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
	picture.material = print_material
	place(picture, portrait, Rect2(8, 8, 294, 437))
	portrait.position.y += 7
	portrait.create_tween().tween_property(portrait, "position:y", portrait.position.y - 7, 0.23)


func show_ticket() -> void:
	var ticket := panel(prologue, Rect2(0, 0, 258, 135), "#f0e0bf", "#8e8064")
	ticket.set_anchors_preset(Control.PRESET_CENTER)
	ticket.offset_left = -129
	ticket.offset_right = 129
	ticket.offset_top = -85
	ticket.offset_bottom = 50
	panel(ticket, Rect2(0, 0, 258, 7), CINNABAR, CINNABAR, 0)
	brush_label(ticket, Rect2(21, 18, 213, 51), "返程车票", 33)
	panel(ticket, Rect2(22, 77, 214, 1), BORDER, BORDER, 0)
	label(ticket, Rect2(22, 89, 214, 28), "小满发来的照片", 15, MUTED)


func clear_prologue_page() -> void:
	if is_instance_valid(prologue):
		remove_child(prologue)
		prologue.queue_free()
		prologue = null
		if is_instance_valid(board):
			board.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_INHERITED


func on_prologue_art_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		game_audio.click()
		turn_dialogue(1)


func turn_dialogue(step: int) -> void:
	var next := prologue_page + step
	var total := Story.OPENING.size() if dialogue_kind == "opening" else dialogue_lines.size()
	if next >= total:
		match dialogue_kind:
			"opening":
				start_training()
				return
			"ending":
				finish_ending()
				return
			"event":
				if Village.EVENTS[village.current_event].size() == 3:
					resolve_story_choice(0)
					return
	if in_game:
		village.story_page = next
		write_save()
	render_dialogue(next)


func resolve_story_choice(choice: int) -> void:
	clear_prologue_page()
	perform(village.resolve_event.bind(choice))

func start_training(from_farm: bool = false) -> void:
	close_modal()
	clear_prologue_page()
	get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	game_audio.play_music("farm")
	training = Training.new(self, from_farm)
	training.show_step()


func finish_training(from_farm: bool) -> void:
	training = null
	if from_farm:
		refresh()
	else:
		enter_farm()


func enter_farm() -> void:
	close_modal()
	clear_prologue_page()
	var window := get_window()
	window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	if DisplayServer.get_name() != "headless":
		window.mode = farm_window_mode
	in_game = true
	game_audio.play_music("farm")
	write_save()
	refresh()
	show_pending_event()


func toggle_prologue_fullscreen() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var window := get_window()
	window.mode = Window.MODE_WINDOWED if window.mode == Window.MODE_FULLSCREEN else Window.MODE_FULLSCREEN
	update_fullscreen_label()


func update_fullscreen_label() -> void:
	fullscreen_button.text = "退出全屏" if get_window().mode == Window.MODE_FULLSCREEN else "全屏展示"


func _unhandled_key_input(event: InputEvent) -> void:
	if dialogue_kind == "opening" and is_instance_valid(prologue) and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		toggle_prologue_fullscreen()


func close_modal() -> void:
	if is_instance_valid(overlay):

		remove_child(overlay)
		overlay.queue_free()
		overlay = null
		board.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_INHERITED


func modal(title: String, tag: String, height: int) -> Panel:
	close_modal()
	board.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
	overlay = Control.new()
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	place(overlay, self, Rect2(0, 0, 1440, 900))
	var shade := ColorRect.new()
	shade.color = Color(0.14, 0.18, 0.14, 0.67)
	place(shade, overlay, Rect2(0, 0, 1440, 900))
	var frame := panel(overlay, Rect2(390, (900 - height) / 2.0, 660, height), "#f8efd9", "#5b5d4b")
	panel(frame, Rect2(8, 8, 644, height - 16), "#ffffff00", "#b9a88c", 0)
	panel(frame, Rect2(8, 8, 644, 4), INK, INK, 0)
	brush_label(frame, Rect2(32, 21, 596, 30), tag, 19, RED)
	brush_label(frame, Rect2(32, 51, 596, 54), title, 43)
	return frame


func paragraph(parent: Control, bounds: Rect2, copy: String, size_px: int = 17, tint: String = MUTED) -> Label:
	var node := label(parent, bounds, copy, size_px, tint)
	node.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.add_theme_constant_override("line_spacing", 7)
	node.size = bounds.size
	return node



func refresh() -> void:
	replace_board()
	var paper := TextureRect.new()
	paper.texture = paper_texture
	paper.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(paper, board, Rect2(0, 0, 1440, 900))
	panel(board, Rect2(0, 0, 1440, 6), INK, INK, 0)
	panel(board, Rect2(48, 31, 50, 52), CINNABAR, RED)
	brush_label(board, Rect2(48, 30, 50, 52), "穗", 33, PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	brush_label(board, Rect2(113, 16, 510, 60), "麦穗余晖", 50)
	brush_label(board, Rect2(119, 76, 410, 22), "河湾村 · 周伯的账本", 18, MUTED)
	label(board, Rect2(619, 41, 214, 37), save_status, 14, RED if save_status == "存档写入失败" else MUTED, HORIZONTAL_ALIGNMENT_RIGHT)
	button(board, Rect2(847, 41, 108, 37), "存档", manual_save)
	button(board, Rect2(966, 41, 128, 37), "村庄日志", show_journal)
	button(board, Rect2(1105, 41, 128, 37), "如何经营", show_guide)
	button(board, Rect2(1244, 41, 148, 37), "返回主菜单", save_and_return)
	metric(48, "村庄金库", str(village.coins), "建设、买种和饲养的资金", GOLD)
	metric(389, "村民声望", "%d / 100" % village.reputation, "青年回村 %d 人" % village.youth, GREEN)
	metric(730, "今日劳力", "%d / %d" % [village.labor, village.labor_limit()], "干旱：每日劳力 −3" if village.drought_until >= village.day else "次日恢复", RED if village.labor == 0 else INK)
	var phase := "引导 · 修葺车站" if not village.built.has("station") else ("扩张 · 通车与增产" if village.month() < 13 else "冲刺 · 第 24 月结局评定")
	metric(1071, "第 %d / 24 月" % village.month(), village.date_label(), phase, INK)
	farm_panel()
	operations_panel()
	tutorial_panel()
	panel(board, Rect2(48, 818, 1344, 1), BORDER, BORDER, 0)
	label(board, Rect2(49, 837, 870, 36), village.journal[0], 14, MUTED)
	var fast := button(board, Rect2(966, 834, 224, 43), "快进到下一事项  »", perform.bind(village.advance_to_next))
	fast.tooltip_text = "最多快进 30 天。逐日结算作物、养殖、游客、电商和事件。遇到下一项重要事项时停止。"
	button(board, Rect2(1203, 834, 189, 43), "结束今天  →", perform.bind(village.advance_day), true)


func metric(x: int, title: String, value: String, subtitle: String, tint: String) -> void:
	var tile := panel(board, Rect2(x, 111, 321, 105))
	label(tile, Rect2(16, 9, 287, 22), title, 14, MUTED)
	brush_label(tile, Rect2(16, 31, 289, 38), value, 32, tint)
	label(tile, Rect2(16, 71, 289, 23), subtitle, 14, MUTED)


func farm_panel() -> void:
	var frame := panel(board, Rect2(48, 235, 936, 430))
	section_heading(frame, 936, "河湾田野")
	label(frame, Rect2(470, 9, 450, 32), "本季作物减产 30%" if village.drought_until >= village.day else "点击田块，开垦、播种或收获", 14, MUTED, HORIZONTAL_ALIGNMENT_RIGHT)
	var scenery := FarmView.new()
	scenery.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scenery.village = village
	place(scenery, frame, Rect2(16, 47, 904, 344))
	for index in village.plots.size():
		var plot: Dictionary = village.plots[index]
		var title := "开垦 · 1 劳力"
		var disabled := village.labor == 0
		var action := perform.bind(village.clear_plot.bind(index))
		var ready := village.plot_ready(index)
		var detail := "第 %d 块菜地" % (index + 1)
		if plot["cleared"] and plot["crop"].is_empty():
			title = "挑选种子"
			action = show_seeds.bind(index)
		elif not plot["crop"].is_empty():
			detail = Village.CROPS[plot["crop"]][0]
			if ready:
				title = "收获 · 1 劳力"
				action = perform.bind(village.harvest.bind(index))
			else:
				title = "余 %d 天" % (plot["ready"] - village.day)
				disabled = true
		var x := 77 + index * 204
		var plot_button := button(frame, Rect2(x, 352, 170, 33), title, action, ready, disabled)
		plot_button.tooltip_text = detail
		label(frame, Rect2(x, 394, 170, 26), detail, 14, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
		if not disabled:
			var hit := Control.new()
			hit.mouse_filter = Control.MOUSE_FILTER_STOP
			hit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			hit.gui_input.connect(on_plot_input.bind(action))
			place(hit, frame, Rect2(x - 8, 278, 186, 70))
	button(frame, Rect2(779, 66, 123, 34), "车站已通车" if village.built.has("station") else "村口车站", show_projects)


func on_plot_input(event: InputEvent, action: Callable) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		game_audio.click()
		action.call()


func operations_panel() -> void:
	var frame := panel(board, Rect2(1004, 235, 388, 563))
	section_heading(frame, 388, "仓库与经营")
	panel(frame, Rect2(17, 54, 354, 77), WASH, BORDER)
	brush_label(frame, Rect2(30, 59, 328, 28), village.transport(), 24)
	label(frame, Rect2(30, 91, 328, 25), "时价 %d%%  ·  每趟 %d 劳力" % [village.sale_percent(), village.sale_effort()], 15, MUTED)
	button(frame, Rect2(17, 143, 354, 46), "查看库存与售卖  →", show_sales, true, village.tutorial < 2)
	panel(frame, Rect2(17, 208, 354, 1), BORDER, BORDER, 0)
	brush_label(frame, Rect2(17, 223, 201, 36), "鸡舍与养殖", 25)
	label(frame, Rect2(17, 260, 352, 23), "成年鸡 %d / 3  ·  鸡窝 %d 枚  ·  孵化 %d 枚" % [village.hens, village.eggs_in_nest, village.incubating.size()], 14, MUTED)
	button(frame, Rect2(17, 294, 354, 44), "进入养殖场", show_animals)
	panel(frame, Rect2(17, 357, 354, 1), BORDER, BORDER, 0)
	brush_label(frame, Rect2(17, 372, 201, 36), "村落改造", 25)
	label(frame, Rect2(17, 415, 352, 22), "已完成 %d 项  ·  游客收入 %d / 天" % [village.built.size(), village.tourism_income()], 14, MUTED)
	button(frame, Rect2(17, 448, 354, 44), "查看改造项目", show_projects)
	var order_note := "物流暂停 %d 天" % village.stream_days if village.stream_days > 0 else ("自动出货已开启" if village.auto_orders else "自动出货已暂停")
	if village.built.has("network"):
		button(frame, Rect2(17, 505, 354, 37), order_note, toggle_auto_orders, false, village.stream_days > 0)
	else:
		label(frame, Rect2(17, 505, 355, 37), "第 24 月末按金币、声望和建设评定结局。", 14, MUTED)


func tutorial_panel() -> void:
	var frame := panel(board, Rect2(48, 681, 936, 117))
	section_heading(frame, 936, "经营目标")
	var goal := "先开垦菜地，再到鸡舍喂鸡。" if village.tutorial == 0 else "收获并售卖作物，攒够 400 金币查看车站。"
	if village.done.has("station_goal"):
		goal = "攒够 500 金币修好车站，班车售卖免劳力。"
	if village.built.has("station"):
		goal = "第 24 月末评定结局。第 10 月起可解锁池塘观景台。" if not village.pond_unlocked else "提升声望和金库，经营旅游或电商，迎接青年回村。"
	label(frame, Rect2(17, 52, 850, 34), goal, 17)
	button(frame, Rect2(743, 51, 176, 38), "结局达成条件", show_endings_guide)


func show_seeds(index: int) -> void:
	var frame := modal("选择种子", "菜地", 400)
	var row := 0
	for id in Village.CROPS:
		var spec: Array = Village.CROPS[id]
		var y := 112 + row * 69
		label(frame, Rect2(33, y, 420, 26), "%s  ·  %d 金币  ·  %d 天" % [spec[0], spec[3], spec[2]], 17)
		label(frame, Rect2(33, y + 28, 430, 19), "第 %d 月解锁  ·  产 %d 份  ·  基础售价 %d / 份" % [spec[1], spec[4], spec[5]], 13, MUTED)
		button(frame, Rect2(492, y + 7, 136, 38), "播种", perform.bind(village.plant.bind(index, id)), true, village.month() < spec[1] or not village.can_pay(spec[3], 1))
		row += 1
	button(frame, Rect2(491, 337, 137, 39), "返回田野", close_modal).grab_focus()


func show_sales() -> void:
	var frame := modal("查看库存与售卖", village.transport(), 723)
	label(frame, Rect2(32, 105, 596, 28), "时价 %d%%  ·  每笔消耗 %d 劳力" % [village.sale_percent(), village.sale_effort()], 15, MUTED)
	var row := 0
	for id in Village.PRODUCT_NAMES:
		var y := 145 + row * 54
		panel(frame, Rect2(32, y + 49, 596, 1), BORDER, BORDER, 0)
		label(frame, Rect2(32, y, 197, 46), "%s × %d" % [Village.PRODUCT_NAMES[id], village.amount(id)], 17)
		label(frame, Rect2(235, y, 218, 46), "基准单价 %d 金币" % village.base_price(id), 14, MUTED)
		var quantity: int = village.amount(id)
		var disabled := quantity == 0 or village.labor < village.sale_effort()
		if village.built.has("station"):
			button(frame, Rect2(436, y + 6, 92, 35), "选数量", show_sell_quantity.bind(id), false, disabled)
			var quick_sale := button(frame, Rect2(538, y + 6, 90, 35), "全卖", quick_sell.bind(id, quantity), true, disabled)
			quick_sale.tooltip_text = "卖出全部%s，收入 %d 金币。" % [Village.PRODUCT_NAMES[id], village.sale_value(id, quantity)]
		else:
			button(frame, Rect2(487, y + 6, 141, 35), "选择数量", show_sell_quantity.bind(id), false, disabled)
		row += 1
	button(frame, Rect2(481, 657, 147, 41), "返回村庄", close_modal).grab_focus()


func show_sell_quantity(id: String) -> void:
	var frame := modal("出售%s" % Village.PRODUCT_NAMES[id], village.transport(), 331)
	var quantity := SpinBox.new()
	quantity.min_value = 1
	quantity.max_value = village.amount(id)
	quantity.value = 1
	quantity.rounded = true
	quantity.update_on_text_changed = true
	place(quantity, frame, Rect2(32, 122, 138, 41))
	button(frame, Rect2(183, 122, 99, 41), "全部", func() -> void: quantity.value = quantity.max_value)
	var summary := label(frame, Rect2(32, 184, 596, 34), "", 17, GREEN)
	quantity.value_changed.connect(update_sale_summary.bind(id, summary))
	update_sale_summary(1, id, summary)
	button(frame, Rect2(326, 254, 125, 43), "返回库存", show_sales)
	button(frame, Rect2(465, 254, 163, 43), "确认卖出", func() -> void:
		quantity.apply()
		perform(village.sell.bind(id, int(quantity.value)))
	).grab_focus()


func update_sale_summary(value: float, id: String, summary: Label) -> void:
	summary.text = "预计进账 %d 金币  ·  消耗 %d 劳力" % [village.sale_value(id, int(value)), village.sale_effort()]


func quick_sell(id: String, quantity: int) -> void:
	perform(village.sell.bind(id, quantity))
	if village.can_act():
		show_sales()


func show_animals() -> void:
	var frame := modal("鸡舍与养殖", "河湾村", 571)
	label(frame, Rect2(32, 106, 596, 32), "成年鸡 %d / 3  ·  鸡窝 %d 枚  ·  孵化中 %d 枚" % [village.hens, village.eggs_in_nest, village.incubating.size()], 17)
	label(frame, Rect2(32, 140, 596, 24), "每天喂一次。摸蛋入仓，或留蛋 3 天，有 65% 几率孵出小鸡。", 15, MUTED)
	var chick_note := "满栏时，新孵出的小鸡等有空位再补入。"
	if not village.incubating.is_empty():
		chick_note = "下一枚蛋还需 %d 天。" % (village.incubating[0] - village.day)
	if village.waiting_chicks > 0:
		chick_note += " 待入栏小鸡 %d 只。" % village.waiting_chicks
	label(frame, Rect2(32, 169, 596, 24), chick_note, 14, MUTED)
	button(frame, Rect2(32, 204, 172, 40), "喂鸡 · 1 劳力", animal_action.bind(village.feed_chickens), false, village.fed_chickens or village.labor == 0 or village.hens == 0)
	button(frame, Rect2(220, 204, 163, 40), "摸走鸡蛋", animal_action.bind(village.gather_eggs), true, village.eggs_in_nest == 0)
	button(frame, Rect2(398, 204, 230, 40), "留一枚蛋孵化", animal_action.bind(village.incubate), false, not village.can_incubate())
	var row := 0
	for id in Village.LIVESTOCK:
		var spec: Array = Village.LIVESTOCK[id]
		var y := 264 + row * 73
		panel(frame, Rect2(32, y, 596, 1), BORDER, BORDER, 0)
		label(frame, Rect2(32, y + 5, 395, 25), "养%s  ·  %d 金币  ·  %d 天" % [spec[0], spec[3], spec[2]], 16)
		label(frame, Rect2(32, y + 33, 420, 22), "%d 月解锁  ·  产量 %d  ·  基础售价 %d" % [spec[1], spec[4], spec[5]], 13, MUTED)
		var text := "余 %d 天" % (village.pens[id] - village.day) if village.pens[id] != 0 else "开始饲养"
		button(frame, Rect2(478, y + 12, 150, 37), text, animal_action.bind(village.start_livestock.bind(id)), false, village.month() < spec[1] or village.pens[id] != 0 or not village.can_pay(spec[3], 1))
		row += 1
	button(frame, Rect2(481, 505, 147, 41), "返回村庄", close_modal).grab_focus()


func animal_action(action: Callable) -> void:
	perform(action)
	if village.can_act():
		show_animals()


func show_projects() -> void:
	var frame := modal("村落改造", "河湾村", 710)
	var row := 0
	for id in Village.PROJECTS:
		var spec: Array = Village.PROJECTS[id]
		var y := 110 + row * 65
		panel(frame, Rect2(32, y + 59, 596, 1), BORDER, BORDER, 0)
		label(frame, Rect2(32, y, 410, 27), "%s  %d / 3" % [spec[0], village.machine_level] if id == "machine" else spec[0], 17)
		label(frame, Rect2(32, y + 30, 411, 20), spec[3], 14, MUTED)
		var text := "%d 金币" % village.project_cost(id)
		if int(spec[2]) > 0:
			text += " · %d 劳力" % spec[2]
		if id != "machine" and village.built.has(id):
			text = "已完成"
		elif id == "machine" and village.machine_level == 3:
			text = "已升满"
		elif not village.project_available(id):
			text = "第 10 月解锁" if id == "pond" and village.built.has("station") else "待解锁"
		button(frame, Rect2(440, y + 10, 188, 39), text, project_action.bind(id), false, not village.project_available(id) or not village.can_pay(village.project_cost(id), spec[2]))
		row += 1
	button(frame, Rect2(481, 644, 147, 41), "返回村庄", close_modal).grab_focus()


func project_action(id: String) -> void:
	perform(village.build.bind(id))
	if village.can_act():
		show_projects()


func toggle_auto_orders() -> void:
	village.auto_orders = not village.auto_orders
	write_save()
	refresh()


func manual_save() -> void:
	write_save()
	refresh()
	show_pending_event()


func show_guide() -> void:
	var frame := modal("如何经营河湾村", "村庄账本", 382)
	paragraph(frame, Rect2(32, 119, 596, 181), "开垦、播种、收获各花 1 劳力。开局步行卖货每次花 2 劳力，修好车站即可免去这笔消耗。\n\n鸡蛋可以摸走卖钱，也可留在鸡舍孵化。其它养殖随月份解锁。\n\n第 24 月末评定结局。快进会在成熟、孵化、养殖产出、月初或剧情发生时停下。", 16, INK)
	button(frame, Rect2(481, 315, 147, 41), "返回村庄", close_modal).grab_focus()
	button(frame, Rect2(272, 315, 190, 41), "重玩新手教程", start_training.bind(true))


func show_endings_guide() -> void:
	var frame := modal("四种结局", "第 24 月末评定", 430)
	paragraph(frame, Rect2(32, 120, 596, 220), "S 圆满 · 15,000 金币、60 声望、3 项改造，且开通电商或有 2 名青年回村。\n\nA 小康 · 8,000 金币、40 声望、2 项改造，且班车通车并开启旅游或电商。\n\nB 维持 · 3,000 金币、20 声望。\n\nC 遗憾 · 未达到以上结局条件。", 16, INK)
	button(frame, Rect2(481, 366, 147, 41), "返回村庄", close_modal).grab_focus()


func show_journal() -> void:
	var frame := modal("村庄日志", "河湾村", 491)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	place(scroll, frame, Rect2(32, 122, 596, 280))
	var entries := VBoxContainer.new()
	entries.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	entries.add_theme_constant_override("separation", 11)
	scroll.add_child(entries)
	for entry in village.journal:
		var row := Label.new()
		row.text = entry
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_theme_color_override("font_color", Color(INK))
		entries.add_child(row)
	button(frame, Rect2(481, 420, 147, 44), "返回村庄", close_modal, true).grab_focus()


func perform(action: Callable) -> void:
	close_modal()
	action.call()
	write_save()
	refresh()
	show_pending_event()


func show_pending_event() -> void:
	if not village.result.is_empty():
		show_ending()
	elif not village.current_event.is_empty():
		show_event()


func show_event() -> void:
	var id := village.current_event
	var entry: Array = Village.EVENTS[id]
	var chapter: Array = Story.CHAPTERS.get(id, [entry[0], -1, [[entry[1], entry[2]]]])
	dialogue_kind = "event"
	dialogue_chapter = chapter[0]
	dialogue_location = chapter[1]
	dialogue_lines = chapter[2].duplicate()
	if id == "month18":
		dialogue_lines.append(Story.MONTH18_HIGH if village.reputation >= 60 else Story.MONTH18_LOW)
	var last_page := dialogue_lines.size() if entry.size() > 3 else dialogue_lines.size() - 1
	render_dialogue(clampi(village.story_page, 0, last_page))

func bus_animation(frame: Control) -> void:
	var road := panel(frame, Rect2(412, 447, 616, 77), "#e3d6b593", BORDER)
	road.clip_contents = true
	panel(road, Rect2(0, 51, 596, 2), BORDER, BORDER, 0)
	var bus := panel(road, Rect2(-117, 16, 109, 32), "#75846b", GREEN)
	for index in 4:
		panel(bus, Rect2(10 + index * 23, 5, 16, 13), PARCHMENT, BORDER, 0)
	panel(bus, Rect2(13, 26, 13, 13), INK, INK, 6)
	panel(bus, Rect2(78, 26, 13, 13), INK, INK, 6)
	bus.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).tween_property(bus, "position:x", 410.0, 2.0)


func show_ending() -> void:
	if village.ending_seen:
		show_ending_summary()
		return
	var chapter: Array = Story.ENDINGS[village.result]
	dialogue_kind = "ending"
	dialogue_chapter = "%s结局 · %s" % [village.result, chapter[0]]
	dialogue_location = chapter[1]
	dialogue_lines = Story.FINAL_MARKET.duplicate() if village.built.has("station") else [["旁白", "第二十四月最后一天，河湾村迎来了两年的结算。"]]
	dialogue_lines.append_array(chapter[2])
	render_dialogue(clampi(village.story_page, 0, dialogue_lines.size() - 1))


func finish_ending() -> void:
	clear_prologue_page()
	village.ending_seen = true
	village.story_page = 0
	write_save()
	show_ending_summary()


func show_ending_summary() -> void:
	var chapter: Array = Story.ENDINGS[village.result]
	var frame := modal("%s · %s" % [village.result, chapter[0]], "第 24 月末  /  河湾村", 347)
	label(frame, Rect2(32, 120, 596, 35), "金币 %d  ·  声望 %d  ·  改造 %d 项  ·  青年 %d 人" % [village.coins, village.reputation, village.built.size(), village.youth], 17)
	var stations := "已通车" if village.built.has("station") else "待通车"
	var tourism := "旅游已开启" if village.built.has("pond") else "旅游未开启"
	var network := "电商已开启" if village.built.has("network") else "电商未开启"
	label(frame, Rect2(32, 173, 596, 35), "%s  ·  %s  ·  %s" % [stations, tourism, network], 16, MUTED)
	button(frame, Rect2(283, 269, 152, 45), "返回主菜单", save_and_return)
	button(frame, Rect2(450, 269, 178, 45), "重新经营  →", restart, true).grab_focus()


func restart() -> void:
	start_prologue()
