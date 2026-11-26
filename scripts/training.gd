extends RefCounted
## A disposable village lets players learn by using the real farming rules.

const Village := preload("res://scripts/village.gd")
const FarmView := preload("res://scripts/farm_view.gd")
const STEPS := [
	["开垦土地", "点击第一块菜地，或点「开垦 · 1 劳力」。每块地只需开垦一次，以后可以反复播种。", "开垦 · 1 劳力"],
	["种下青菜", "正式游戏里，点「挑选种子」。青菜种子花 10 金币，播种花 1 劳力，5 天后成熟。", "播种青菜 · 10 金币"],
	["快进到成熟", "点「快进到下一事项」，日历会向前推进，遇到成熟或剧情等重要事项就停下。", "快进到下一事项"],
	["收进仓库", "成熟的田块会出现「收获」。花 1 劳力，把 10 份青菜收进仓库。", "收获 · 1 劳力"],
	["第一次卖菜", "正式游戏里，从右侧打开「查看库存与售卖」。步行卖货花 2 劳力，收入是原价的 90%。", "卖出全部青菜"],
	["照料鸡舍", "正式游戏里，点「进入养殖场」喂鸡。开局有两只鸡，喂一次花 1 劳力，鸡窝马上多两枚蛋。", "喂鸡 · 1 劳力"],
	["摸走鸡蛋", "摸走的蛋会进入仓库，可以卖钱。也可以把蛋留在鸡舍，3 天后尝试孵化。", "摸走鸡蛋"],
]

var main: Control
var practice := Village.new(1)
var from_farm: bool
var step := 0
var feedback := "先操作第一块菜地，留意上方的劳力变化。"


func _init(game: Control, returning_to_farm: bool) -> void:
	main = game
	from_farm = returning_to_farm
	practice.tutorial = 2
	for event in ["first_plot", "first_harvest", "walk", "eggs"]:
		practice.done[event] = true


func show_step() -> void:
	main.replace_board()
	var board: Control = main.board
	var background := TextureRect.new()
	background.texture = main.paper_texture
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main.place(background, board, Rect2(0, 0, 1440, 900))
	main.brush_label(board, Rect2(48, 25, 620, 63), "新手教程", 48)
	main.label(board, Rect2(50, 84, 842, 32), "用一块菜地练习。正式开局时使用初始资源。", 17, main.MUTED)
	main.button(board, Rect2(1215, 49, 178, 43), "返回农场" if from_farm else "跳过教程", main.finish_training.bind(from_farm))
	main.metric(48, "练习日期", practice.date_label(), "快进会停在重要事项", main.INK)
	main.metric(389, "练习金库", str(practice.coins), "播种花金币，卖菜赚金币", main.GOLD)
	main.metric(730, "今日劳力", "%d / %d" % [practice.labor, practice.labor_limit()], "次日恢复", main.GREEN)
	main.metric(1071, "仓库", "%d 菜  ·  %d 蛋" % [practice.stock["greens"], practice.stock["eggs"]], "收获或摸蛋后才能卖", main.INK)

	var field: Panel = main.panel(board, Rect2(48, 235, 936, 433))
	main.section_heading(field, 936, "练习田")
	var scenery := FarmView.new()
	scenery.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scenery.village = practice
	main.place(scenery, field, Rect2(16, 46, 904, 344))
	if step in [0, 1, 3]:
		var plot := Rect2(70, 278, 186, 72)
		var hit := Control.new()
		hit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		hit.gui_input.connect(main.on_plot_input.bind(advance))
		main.place(hit, field, plot)
		main.panel(field, plot, "#ffffff00", main.CINNABAR, 0)
	main.label(field, Rect2(26, 393, 856, 26), "第一块菜地  ·  鸡窝 %d 枚蛋" % practice.eggs_in_nest, 15, main.MUTED)

	var guide: Panel = main.panel(board, Rect2(1004, 235, 388, 433))
	var finished := step == STEPS.size()
	main.section_heading(guide, 388, "练习完成" if finished else "第 %d / %d 步" % [step + 1, STEPS.size()])
	if finished:
		main.brush_label(guide, Rect2(19, 75, 350, 56), "接下来修车站", 33)
		main.paragraph(guide, Rect2(19, 151, 350, 147), "先种菜、养鸡，靠卖货攒到 400 金币触发车站剧情。攒到 500 金币就能修好车站，之后卖货不再消耗劳力。", 18, main.INK)
		main.button(guide, Rect2(18, 337, 353, 57), "返回农场  →" if from_farm else "正式开始游戏  →", main.finish_training.bind(from_farm), true).grab_focus()
	else:
		var instruction: Array = STEPS[step]
		main.brush_label(guide, Rect2(19, 75, 350, 56), instruction[0], 33)
		main.paragraph(guide, Rect2(19, 151, 350, 147), instruction[1], 18, main.INK)
		main.button(guide, Rect2(18, 337, 353, 57), instruction[2], advance, true).grab_focus()

	var result: Panel = main.panel(board, Rect2(48, 687, 1344, 135), "#ecedda", main.BORDER)
	main.section_heading(result, 1344, "操作结果")
	main.label(result, Rect2(27, 54, 1289, 50), feedback, 20, main.GREEN)


func advance() -> void:
	match step:
		0:
			practice.clear_plot(0)
			feedback = "土地已开垦。劳力 −1，现在可以播种。"
		1:
			practice.plant(0, "greens")
			feedback = "已种下青菜。金币 −10，劳力 −1，5 天后可收获。"
		2:
			practice.advance_to_next()
			feedback = "快进结束。青菜已经成熟，今日劳力也恢复了。"
		3:
			practice.harvest(0)
			feedback = "青菜 +10 份，已经放入仓库。劳力 −1，菜地可以再种。"
		4:
			var earned := practice.sale_value("greens", practice.stock["greens"])
			practice.sell("greens", practice.stock["greens"])
			feedback = "卖出了 10 份青菜。金币 +%d，劳力 −2，青菜库存已清空。" % earned
		5:
			practice.feed_chickens()
			feedback = "鸡窝多了 2 枚蛋。劳力 −1，现在可以收蛋或留蛋。"
		6:
			practice.gather_eggs()
			feedback = "鸡蛋 +2 枚，已经放入仓库。收蛋不需要劳力。"
		_:
			return
	step += 1
	show_step()
