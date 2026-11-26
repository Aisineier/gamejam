extends Control

const Village := preload("res://scripts/village.gd")
const FarmView := preload("res://scripts/farm_view.gd")
const Profile := preload("res://scripts/profile.gd")
const GameAudio := preload("res://scripts/game_audio.gd")
const InkPaper := preload("res://scripts/ink_paper.gd")
const PrologueArt := preload("res://scripts/prologue_art.gd")
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
const PROLOGUE := [
	["村口的烂尾车站", "周伯望着村口：“小满今年又回不来。路不通，人就不回来。先种点菜！”"],
	["粮仓里的账", "周伯记下本钱，也数了数鸡。菜地和鸡舍是村里眼下能着手打理的两样活儿。"],
	["从菜地开始", "天亮了。周伯把账本带上，先去开一块菜地，再到鸡舍看看老陈。"],
]

var village := Village.new()
var board: Control
var overlay: Control
var font := SystemFont.new()
var brush_font := SystemFont.new()
var paper_texture: ImageTexture

var prologue: Control
var prologue_page := -1
var farm_window_mode := Window.MODE_WINDOWED
var fullscreen_button: Button
var game_audio := GameAudio.new()
var save_status := ""
var in_game := false
var saved_game: Village


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
	show_prologue_page(0)


func show_prologue_page(page: int) -> void:
	clear_prologue_page()
	prologue_page = page
	prologue = Control.new()
	add_child(prologue)
	prologue.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var print_art := PrologueArt.new()
	print_art.chapter = page
	print_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prologue.add_child(print_art)
	print_art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var page_surface := Control.new()
	page_surface.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	page_surface.gui_input.connect(on_prologue_art_input)
	prologue.add_child(page_surface)
	page_surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var skip := button(prologue, Rect2(0, 0, 137, 42), "跳过序章", enter_farm)
	skip.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	skip.offset_left = -165
	skip.offset_right = -28
	skip.offset_top = 26
	skip.offset_bottom = 68
	fullscreen_button = button(prologue, Rect2(28, 26, 128, 42), "", toggle_prologue_fullscreen)
	fullscreen_button.tooltip_text = "也可以按 Esc 切换窗口和全屏。"
	update_fullscreen_label()

	var card_height := 225
	var card_width := 1060
	var reader := panel(prologue, Rect2(0, 0, card_width, card_height), "#f6eddaef", "#665a45")
	reader.mouse_filter = Control.MOUSE_FILTER_STOP
	reader.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	reader.offset_left = -530
	reader.offset_right = -530 + card_width
	reader.offset_top = -card_height - 34
	reader.offset_bottom = -34
	panel(reader, Rect2(8, 8, card_width - 16, card_height - 16), "#ffffff00", "#b6a584", 0)
	panel(reader, Rect2(8, 8, card_width - 16, 3), "#465849", "#465849", 0)
	brush_label(reader, Rect2(32, 20, 378, 28), "序章  %d / %d" % [page + 1, PROLOGUE.size()], 19, RED)
	brush_label(reader, Rect2(30, 49, 955, 53), PROLOGUE[page][0], 42)
	paragraph(reader, Rect2(33, 106, 986, 58), PROLOGUE[page][1], 19, INK)
	label(reader, Rect2(33, 170, 410, 37), "点击画面继续", 14, MUTED)
	var button_text := "进入河湾村  →" if page == PROLOGUE.size() - 1 else "继续剧情  →"
	button(reader, Rect2(839, 166, 187, 45), button_text, advance_prologue, true).grab_focus()


func clear_prologue_page() -> void:
	if is_instance_valid(prologue):
		remove_child(prologue)
		prologue.queue_free()
		prologue = null


func on_prologue_art_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		game_audio.click()
		advance_prologue()


func advance_prologue() -> void:
	if prologue_page < PROLOGUE.size() - 1:
		show_prologue_page(prologue_page + 1)
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
	if is_instance_valid(prologue) and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
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
	fast.tooltip_text = "最多 30 天。遇到收获、孵化、养殖产出、月初或剧情会停下。"
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
	var id: String = village.current_event
	var entry: Array = Village.EVENTS[id]
	var frame := modal(entry[0], entry[1], 342)
	paragraph(frame, Rect2(32, 117, 596, 67), entry[2], 17, INK)
	if entry.size() == 3:
		if id == "station_open":
			bus_animation(frame)
		button(frame, Rect2(443, 267, 185, 43), "继续经营  →", perform.bind(village.resolve_event.bind(0)), true).grab_focus()
	else:
		for choice in 2:
			button(frame, Rect2(32, 188 + choice * 51, 596, 43), entry[3 + choice], perform.bind(village.resolve_event.bind(choice)), choice == 0, village.coins < entry[5 + choice])
		if village.coins < entry[5] and village.coins < entry[6]:
			button(frame, Rect2(443, 291, 185, 32), "暂缓处理 · 声望 −2", perform.bind(village.resolve_event.bind(2))).grab_focus()


func bus_animation(frame: Control) -> void:
	var road := panel(frame, Rect2(32, 181, 596, 69), WASH, BORDER)
	road.clip_contents = true
	panel(road, Rect2(0, 51, 596, 2), BORDER, BORDER, 0)
	var bus := panel(road, Rect2(-117, 16, 109, 32), "#75846b", GREEN)
	for index in 4:
		panel(bus, Rect2(10 + index * 23, 5, 16, 13), PARCHMENT, BORDER, 0)
	panel(bus, Rect2(13, 26, 13, 13), INK, INK, 6)
	panel(bus, Rect2(78, 26, 13, 13), INK, INK, 6)
	bus.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).tween_property(bus, "position:x", 410.0, 2.0)


func show_ending() -> void:
	var endings := {
		"C":["遗憾", "小满接周伯进城。车开远了，周伯回头望着村口的车站，轻轻叹了口气。"],
		"B":["维持", "周伯和老陈继续在菜地里忙。“慢慢来吧，路修好了，总有希望。”"],
		"A":["小康", "小满周末常回家帮忙。村里有游客，路上有订单，周伯终于能把一部分活计交给年轻人。"],
		"S":["圆满", "小满回村了。她和周伯、小林站在村里的新广场上，商量来年把村里的好东西卖到更远的地方。"],
	}
	var ending: Array = endings[village.result]
	var frame := modal("%s · %s" % [village.result, ending[0]], "第 24 月末  /  河湾村", 327)
	paragraph(frame, Rect2(32, 118, 596, 75), ending[1], 18, INK)
	label(frame, Rect2(32, 200, 596, 30), "金币 %d  ·  声望 %d  ·  改造 %d 项  ·  青年 %d 人" % [village.coins, village.reputation, village.built.size(), village.youth], 15, MUTED)
	button(frame, Rect2(283, 255, 152, 45), "返回主菜单", save_and_return)
	button(frame, Rect2(450, 255, 178, 45), "重新经营  →", restart, true).grab_focus()


func restart() -> void:
	start_prologue()
