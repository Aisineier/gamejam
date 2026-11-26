extends RefCounted

const CROPS := {
	"greens": ["青菜", 1, 5, 10, 10, 8],
	"potato": ["土豆", 2, 10, 20, 25, 6],
	"berry": ["草莓", 4, 12, 40, 20, 20],
}
const LIVESTOCK := {
	"pig": ["猪", 3, 20, 100, 1, 400],
	"honey": ["蜂", 6, 15, 150, 20, 25],
	"cow": ["牛", 10, 30, 300, 1, 1200],
}
const PRODUCT_NAMES := {"greens":"青菜", "potato":"土豆", "berry":"草莓", "eggs":"鸡蛋", "bad_egg":"坏蛋", "chicken":"成年鸡", "pig":"成猪", "honey":"蜂蜜", "cow":"成年牛"}
const PROJECTS := {
	"station": ["修葺车站", 500, 0, "班车通车，售卖免劳力"],
	"lamps": ["道路照明", 800, 0, "夜间行动劳力 +1"],
	"road": ["修水泥路", 1500, 2, "售卖单价 +10%，解锁货车"],
	"pond": ["池塘观景台", 1800, 2, "每日游客收入 +100"],
	"camp": ["树林露营区", 2200, 2, "每日游客收入 +150，声望 +2"],
	"square": ["文化广场", 2000, 3, "声望 +15，青年回村 +1"],
	"network": ["网络基站", 2500, 2, "物流进村，解锁自动出货"],
	"machine": ["农机升级", 500, 0, "每级每日劳力上限 +2"],
}
const MACHINE_COSTS := [500, 1200, 2500]
const DAYS := 720
const EVENTS := {
	"eggs": ["鸡舍旁", "老陈", "老周，鸡蛋留三天能孵出小鸡，卖得贵！但要是运气不好，蛋就坏了。"],
	"walk": ["菜地", "老陈", "菜种得不错，但去镇上走路得大半天，菜都蔫了。步行卖货每趟消耗 2 点劳力，只能卖到原价的九成。"],
	"station_goal": ["烂尾车站", "周伯", "要是这车站修好，小满回家就方便了，菜也能卖上价。修葺车站需要 500 金币。"],
	"station_open": ["班车通车", "周伯", "路通了，村子就有救了。以后搭班车卖货，不用再花劳力挑担进镇。"],
	"recognition": ["村口树林", "村民", "车站真修好了！老周有本事。"],
	"homecoming": ["车站", "周小满", "爸，这车站你真修好了……以后周末我能坐班车回来看你了。"],
	"tourism": ["池塘边", "城里游客", "大爷，这池塘能钓鱼吗？要是修个观景台，我们下次带朋友来。"],
	"network": ["村北空地", "小林", "周伯，物流能进村了，我帮你网上卖！仓里备好的货每天都能自动出。"],
	"youth": ["文化广场", "回村青年", "周伯，我想在村里留下来，帮着做游客接待。"],
	"drought": ["干旱", "老陈", "已经连续三天没有下雨了。是靠人工浇水撑过这一季，还是一次修好灌溉？", "人工浇水 · 每日劳力 −3，本季减产 30%", "修建灌溉 · 500 金币，永久免疫干旱", 0, 500],
	"conflict": ["村民内讧", "村民", "最近大伙儿对收益分配有意见，需要给村民一个说法。", "开村民大会 · 200 金币，声望 +8", "让利分红 · 500 金币，声望 +15", 200, 500],
	"daughter": ["小满的来电", "周小满", "爸，要不别干了来城里吧。你要是还想留在村里，我先给你凑点钱。", "继续坚持 · 声望 +5，后续负面概率 +10 个百分点", "接受资助 · 金币 +1000，声望 −5", 0, 0],
	"stream": ["直播翻车", "小林", "直播间的客人收到了不合规格的货。现在得处理订单和口碑。", "停播整顿 · 订单暂停 3 天，声望 −5", "公开道歉换品 · 500 金币，声望 +3", 0, 500],
	"complaint": ["游客投诉", "游客", "我们到了观景台才发现服务跟不上。能退票，或者改善一下吗？", "退款道歉 · 200 金币，声望 −2", "升级服务 · 500 金币，声望 +5，游客收益 +10%", 200, 500],
}

var coins := 200
var reputation := 10
var labor := 5
var day := 1
var youth := 0
var hens := 2
var waiting_chicks := 0
var eggs_in_nest := 0
var fed_chickens := false
var plots: Array[Dictionary] = []
var incubating: Array[int] = []
var pens := {"pig": 0, "honey": 0, "cow": 0}
var stock := {"greens":0, "potato":0, "berry":0, "eggs":0, "bad_egg":0, "pig":0, "honey":0, "cow":0}
var built: Array[String] = []
var machine_level := 0
var auto_orders := true
var tourism_bonus := 0
var irrigation := false
var drought_until := 0
var stream_days := 0
var extra_risk := 0
var dry_run := 0
var monthly_dry_peak := 0
var tutorial := 0
var pond_unlocked := false
var done := {}
var event_queue: Array[String] = []
var current_event := ""
var result := ""
var journal: Array[String] = []
var rng := RandomNumberGenerator.new()


func _init(seed_value: int = -1) -> void:
	if seed_value < 0:
		rng.randomize()
	else:
		rng.seed = seed_value
	for index in 4:
		plots.append({"cleared":false, "crop":"", "ready":0})
	log_entry("周伯开始打理菜地和鸡舍。")


func month() -> int:
	return floori(float(day - 1) / 30.0) + 1


func date_label() -> String:
	return "第%d年 %02d月 %02d日" % [1 + floori(float(month() - 1) / 12.0), 1 + (month() - 1) % 12, 1 + (day - 1) % 30]


func labor_limit() -> int:
	return 5 + machine_level * 2 + int(built.has("lamps"))


func reset_labor() -> void:
	labor = maxi(0, labor_limit() - (3 if drought_until >= day else 0))


func can_act() -> bool:
	return current_event.is_empty() and result.is_empty()


func can_pay(gold: int, effort: int) -> bool:
	return coins >= gold and labor >= effort


func change_rep(amount: int) -> void:
	reputation = clampi(reputation + amount, 0, 100)


func queue_once(id: String) -> void:
	if not done.has(id):
		done[id] = true
		event_queue.append(id)


func check_story() -> void:
	if tutorial >= 2 and coins >= 400:
		queue_once("station_goal")
	if month() == 12 and coins < 2000:
		queue_once("daughter")
	if built.has("station"):
		if coins >= 1000:
			queue_once("recognition")
		if coins >= 3000:
			queue_once("homecoming")
		if month() >= 10:
			queue_once("tourism")
		if month() >= 13 and reputation >= 60 and built.has("square"):
			queue_once("youth")
	if current_event.is_empty() and not event_queue.is_empty():
		current_event = event_queue.pop_front()


func plot_ready(index: int) -> bool:
	return not plots[index]["crop"].is_empty() and day >= plots[index]["ready"]


func clear_plot(index: int) -> void:
	if not can_act() or plots[index]["cleared"] or labor < 1:
		return
	labor -= 1
	plots[index]["cleared"] = true
	log_entry("开垦了第 %d 块菜地。" % (index + 1))
	if tutorial == 0:
		tutorial = 1
		queue_once("eggs")
		check_story()


func plant(index: int, crop: String) -> void:
	var spec: Array = CROPS[crop]
	if not can_act() or not plots[index]["cleared"] or not plots[index]["crop"].is_empty() or month() < spec[1] or not can_pay(spec[3], 1):
		return
	labor -= 1
	coins -= spec[3]
	plots[index]["crop"] = crop
	plots[index]["ready"] = day + spec[2]
	log_entry("播种%s，%d 天后成熟。" % [spec[0], spec[2]])


func harvest(index: int) -> void:
	if not can_act() or labor < 1 or not plot_ready(index):
		return
	var item: String = plots[index]["crop"]
	var amount: int = CROPS[item][4]
	if drought_until >= day:
		amount = floori(0.7 * amount)
	labor -= 1
	stock[item] += amount
	plots[index]["crop"] = ""
	log_entry("收获%s %d 份。" % [CROPS[item][0], amount])


func feed_chickens() -> void:
	if not can_act() or hens == 0 or labor < 1 or fed_chickens:
		return
	labor -= 1
	fed_chickens = true
	eggs_in_nest += hens
	log_entry("喂了鸡群，鸡窝新增 %d 枚蛋。" % hens)


func gather_eggs() -> void:
	if not can_act() or eggs_in_nest == 0:
		return
	stock["eggs"] += eggs_in_nest
	log_entry("摸走 %d 枚鸡蛋。" % eggs_in_nest)
	eggs_in_nest = 0


func can_incubate() -> bool:
	return eggs_in_nest > 0 and hens < 3


func incubate() -> void:
	if not can_act() or not can_incubate():
		return
	eggs_in_nest -= 1
	incubating.append(day + 3)
	log_entry("留下一枚鸡蛋，3 天后判定孵化。")


func start_livestock(id: String) -> void:
	var spec: Array = LIVESTOCK[id]
	if not can_act() or month() < spec[1] or pens[id] != 0 or not can_pay(spec[3], 1):
		return
	coins -= spec[3]
	labor -= 1
	pens[id] = day + spec[2]
	log_entry("开始养%s，%d 天后产出。" % [spec[0], spec[2]])


func yield_ready_stock() -> bool:
	var arrived := false
	while not incubating.is_empty() and incubating[0] <= day:
		incubating.pop_front()
		if rng.randf() < 0.65:
			waiting_chicks += 1
			log_entry("孵出一只小鸡。")
			fill_coop()
		else:
			stock["bad_egg"] += 1
			log_entry("孵化失败，仓库新增一枚坏蛋。")
		arrived = true
	for id in LIVESTOCK:
		if pens[id] > 0 and day >= pens[id]:
			var spec: Array = LIVESTOCK[id]
			stock[id] += spec[4]
			pens[id] = 0
			log_entry("%s的产出已入仓。" % spec[0])
			arrived = true
	return arrived


func fill_coop() -> void:
	var moved := mini(3 - hens, waiting_chicks)
	waiting_chicks -= moved
	hens += moved
	if moved > 0:
		log_entry("%d 只小鸡补入鸡舍。" % moved)


func transport() -> String:
	if built.has("network") and stream_days == 0:
		return "物流进村"
	if built.has("road"):
		return "货车运输"
	if built.has("station"):
		return "班车通车"
	return "步行挑担"


func sale_effort() -> int:
	return 0 if built.has("station") else 2


func base_price(id: String) -> int:
	if CROPS.has(id):
		return CROPS[id][5]
	if LIVESTOCK.has(id):
		return LIVESTOCK[id][5]
	return int({"eggs":6, "bad_egg":2, "chicken":60}[id])


func sale_percent() -> int:
	var transport_rate := 120 if built.has("network") and stream_days == 0 else (100 if built.has("station") else 90)
	return transport_rate * 110 / 100 if built.has("road") else transport_rate


func amount(id: String) -> int:
	return hens if id == "chicken" else stock[id]


func sale_value(id: String, quantity: int) -> int:
	return floori(float(base_price(id) * quantity * sale_percent()) / 100.0)


func sell(id: String, quantity: int) -> void:
	if not can_act() or tutorial < 2 or quantity <= 0 or quantity > amount(id) or labor < sale_effort():
		return
	labor -= sale_effort()
	var earnings := sale_value(id, quantity)
	if id == "chicken":
		hens -= quantity
		fill_coop()
	else:
		stock[id] -= quantity
	coins += earnings
	log_entry("售卖%s %d 份，收入 %d 金币。" % [PRODUCT_NAMES[id], quantity, earnings])
	check_story()


func tourism_income() -> int:
	var income := 100 * int(built.has("pond")) + 150 * int(built.has("camp"))
	return floori(income * (100 + tourism_bonus) / 100.0)


func project_cost(id: String) -> int:
	if id == "machine":
		return MACHINE_COSTS[mini(machine_level, 2)]
	return PROJECTS[id][1]


func project_available(id: String) -> bool:
	if id == "station":
		return done.has("station_goal") and not built.has(id)
	if not built.has("station"):
		return false
	if id == "machine":
		return machine_level < 3
	if id == "pond" and not pond_unlocked:
		return false
	if id == "camp" and not built.has("pond"):
		return false
	return not built.has(id)


func build(id: String) -> void:
	var effort: int = PROJECTS[id][2]
	var cost := project_cost(id)
	if not can_act() or not project_available(id) or not can_pay(cost, effort):
		return
	coins -= cost
	labor -= effort
	if not built.has(id):
		built.append(id)
	match id:
		"station":
			change_rep(10)
			queue_once("station_open")
		"lamps":
			labor += 1
		"square":
			change_rep(15)
			youth += 1
		"network":
			queue_once("network")
		"machine":
			machine_level += 1
			labor += 2
	log_entry("%s已完工。" % PROJECTS[id][0])
	check_story()


func settle_orders() -> int:
	if not built.has("network") or not auto_orders or stream_days > 0:
		return 0
	var earnings := 0
	for id in stock:
		earnings += sale_value(id, stock[id])
		stock[id] = 0
	return earnings


func monthly_events() -> void:
	var rate := (40 if reputation <= 5 else 20) + extra_risk
	if rng.randi_range(1, 100) <= rate:
		var candidates: Array[String] = []
		if monthly_dry_peak >= 3 and not irrigation and drought_until < day + 1:
			candidates.append("drought")
		if reputation <= 5:
			candidates.append("conflict")
		if built.has("network"):
			candidates.append("stream")
		if built.has("pond"):
			candidates.append("complaint")
		if not candidates.is_empty():
			event_queue.append(candidates[rng.randi_range(0, candidates.size() - 1)])
	monthly_dry_peak = 0


func advance_day() -> bool:
	if not can_act():
		return false
	var collected := tourism_income() + settle_orders()
	coins += collected
	if built.has("camp"):
		change_rep(2)
	if collected > 0:
		log_entry("游客与订单结算 %d 金币。" % collected)
	stream_days = maxi(0, stream_days - 1)
	dry_run = dry_run + 1 if rng.randf() < 0.62 else 0
	monthly_dry_peak = maxi(monthly_dry_peak, dry_run)
	if day == DAYS:
		result = ending_tier()
		return true
	if day % 30 == 0:
		monthly_events()
	day += 1
	reset_labor()
	fed_chickens = false
	var arrived := yield_ready_stock()
	check_story()
	return arrived or plots.any(func(plot: Dictionary) -> bool: return plot["ready"] == day and not plot["crop"].is_empty())


func advance_to_next() -> void:
	for step in 30:
		var arrived := advance_day()
		if arrived or not can_act() or (day - 1) % 30 == 0:
			break
	log_entry("进度推进至 %s。" % date_label())


func resolve_event(choice: int) -> void:
	if current_event.is_empty():
		return
	var entry: Array = EVENTS[current_event]
	if entry.size() > 3:
		if choice < 2:
			var cost: int = entry[5 + choice]
			if coins < cost:
				return
			coins -= cost
		elif coins >= entry[5] or coins >= entry[6]:
			return
		if choice == 2:
			change_rep(-2)
			log_entry("资金不足，暂缓处理「%s」。声望 −2。" % entry[0])
		else:
			resolve_branch(current_event, choice)
	else:
		match current_event:
			"eggs":
				tutorial = 2
				queue_once("walk")
			"station_open":
				tutorial = 3
			"recognition":
				change_rep(5)
			"tourism":
				pond_unlocked = true
			"youth":
				youth += 1
		log_entry("剧情 · %s。" % entry[0])
	current_event = ""
	check_story()


func resolve_branch(id: String, choice: int) -> void:
	var first := choice == 0
	match id:
		"drought":
			if first:
				drought_until = ceili(month() / 3.0) * 90
				labor = maxi(0, labor - 3)
			else:
				irrigation = true
				drought_until = 0
		"conflict":
			change_rep(8 if first else 15)
		"daughter":
			change_rep(5 if first else -5)
			if first:
				extra_risk += 10
			else:
				coins += 1000
		"stream":
			change_rep(-5 if first else 3)
			if first:
				stream_days = 3
		"complaint":
			change_rep(-2 if first else 5)
			if not first:
				tourism_bonus += 10
	log_entry("已处理「%s」· %s。" % [EVENTS[id][0], EVENTS[id][3 + choice].get_slice(" · ", 0)])


func ending_tier() -> String:
	var ecommerce := built.has("network")
	if coins >= 15000 and reputation >= 60 and built.size() >= 3 and (ecommerce or youth >= 2):
		return "S"
	if coins >= 8000 and reputation >= 40 and built.size() >= 2 and built.has("station") and (built.has("pond") or ecommerce):
		return "A"
	if coins >= 3000 and reputation >= 20:
		return "B"
	return "C"


func log_entry(message: String) -> void:
	journal.push_front("%s  %s" % [date_label(), message])
	if journal.size() > 80:
		journal.pop_back()
