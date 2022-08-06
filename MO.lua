script_name('MoD-Helper')
script_authors('Xavier Adamson', 'Frapsy', 'Sergey Parhutik', 'DIPIRIDAMOLE')
script_description('Ministry of Defence Helper.')
script_version_number(39)
script_version("0.3.9")
script_properties("work-in-pause")

--memory.fill(sampGetBase() + 0x9D31A, 0x90, 12, true)
--memory.fill(sampGetBase() + 0x9D329, 0x90, 12, true)
-- блок худа сампу


local res = pcall(require, "lib.moonloader")
assert(res, 'Library lib.moonloader not found')
---------------------------------------------------------------
local res, ffi = pcall(require, 'ffi')
assert(res, 'Library ffi not found')
---------------------------------------------------------------
local dlstatus = require('moonloader').download_status
---------------------------------------------------------------
local res = pcall(require, 'lib.sampfuncs')
assert(res, 'Library lib.sampfuncs not found')
---------------------------------------------------------------
local res, sampev = pcall(require, 'lib.samp.events')
assert(res, 'Library SAMP Events not found')
---------------------------------------------------------------
local res, bass = pcall(require, "lib.bass")
assert(res, 'Library BASS not found.')
---------------------------------------------------------------
local res, key = pcall(require, "vkeys")
assert(res, 'Library vkeys not found')
---------------------------------------------------------------
local res, aes = pcall(require, "aeslua")
assert(res, 'Library aeslua not found')
---------------------------------------------------------------
local res, imgui = pcall(require, "imgui")
assert(res, 'Library imgui not found')
---------------------------------------------------------------
local res, encoding = pcall(require, "encoding")
assert(res, 'Library encoding not found')
---------------------------------------------------------------
local res, inicfg = pcall(require, "inicfg")
assert(res, 'Library inicfg not found')
---------------------------------------------------------------
local res, memory = pcall(require, "memory")
assert(res, 'Library memory not found')
---------------------------------------------------------------
local res, rkeys = pcall(require, "rkeys")
assert(res, 'Library rkeys not found')
---------------------------------------------------------------
local res, hk = pcall(require, 'lib.imcustom.hotkey')
assert(res, 'Library imcustom not found')
---------------------------------------------------------------
local res, https = pcall(require, 'ssl.https')
assert(res, 'Library ssl.https not found')
---------------------------------------------------------------
local lanes = require('lanes').configure()
---------------------------------------------------------------
local res, sha1 = pcall(require, 'sha1')
assert(res, 'Library sha1 not found')
---------------------------------------------------------------
local res, basexx = pcall(require, 'basexx')
assert(res, 'Library basexx not found')
---------------------------------------------------------------
local res, fa = pcall(require, 'faIcons')
assert(res, 'Library faIcons not found')

-- ---------------------------------------------------------------
-- local res, effil = pcall(require, 'effil')
-- assert(res, 'Library effil not found')


encoding.default = 'CP1251'
u8 = encoding.UTF8

ffi.cdef[[
	short GetKeyState(int nVirtKey);
	bool GetKeyboardLayoutNameA(char* pwszKLID);
	int GetLocaleInfoA(int Locale, int LCType, char* lpLCData, int cchData);
	
	void* __stdcall ShellExecuteA(void* hwnd, const char* op, const char* file, const char* params, const char* dir, int show_cmd);
	uint32_t __stdcall CoInitializeEx(void*, uint32_t);

	int __stdcall GetVolumeInformationA(
    const char* lpRootPathName,
    char* lpVolumeNameBuffer,
    uint32_t nVolumeNameSize,
    uint32_t* lpVolumeSerialNumber,
    uint32_t* lpMaximumComponentLength,
    uint32_t* lpFileSystemFlags,
    char* lpFileSystemNameBuffer,
    uint32_t nFileSystemNameSize
);
]]
local LocalSerial = ffi.new("unsigned long[1]", 0)
ffi.C.GetVolumeInformationA(nil, nil, 0, LocalSerial, nil, nil, nil, 0)
LocalSerial = LocalSerial[0]

local BuffSize = 32
local KeyboardLayoutName = ffi.new("char[?]", BuffSize)
local LocalInfo = ffi.new("char[?]", BuffSize)
local shell32 = ffi.load 'Shell32'
local ole32 = ffi.load 'Ole32'
ole32.CoInitializeEx(nil, 2 + 4)


-- свалка переменных
mlogo, errorPic, classifiedPic, pentagonPic, accessDeniedPic, gameServer, nasosal_rang = nil, nil, nil, nil, nil, nil -- картинки
srv, arm = nil, nil -- номера сервера и армии
whitelist, superID, vigcout, narcout, order = 0, 0, 0, 0, 0 -- значения по дефолту для "информация"
regDialogOpen, regAcc, UpdateNahuy, checking, getLeader, checkupd = false, false, false, false, false -- bool переменные для работы с диалогами
ScriptUse = 3 -- для цикла
armourStatus = 0 -- статус броника(снят/надет)
offscript = 0 -- переменная для подсчета количества нажатий на кнопку "выключить скрипта"
pentcout, pentsrv, pentinv, pentuv = 0,0,0,0 -- дефолт значения /base
regStatus = false -- проверяет пройденность получения инфы 
gmsg = false -- проверка на разрешение чекать на ВК
gosButton, AccessBe = true -- проверка на отправку госки 
dostupLvl = nil -- уровень доступа
activated = nil -- ограничение функционала, если скрипт не соединился с БД
isLocalPlayerSoldier = false -- проверка на состояние в МО по диалогу статы
getMOLeader = "Not Registred" -- МО
getSVLeader = "Not Registred" -- СВ
getVVSLeader = "Not Registred" -- ВВС
getVMFLeader = "Not Registred" -- ВМФ
pidr = false -- для черного спика
errorSearch = nil -- если не смогли найти в пентагоне
vkinf = "Disabled by developer"
developMode = "Local Edition"
--assTakeDamage = 0 -- количество раз, сколько игрок получил дамага
flymode = 0 -- камхак
isPlayerSoldier = false -- проверка на состояние в МО по данным из БД
speed = 0.2 -- скорость камхака
bstatus = 0 -- для чекера на ЧС, 1 если в ЧСе найден
offMask = true -- таймер маски
enableStrobes = false -- стробоскопы
skill = false -- кач скиллов
fizra = false -- переменная для физры
state = false -- автострой если не ошибаюсь
--assDmg = false -- для отправки репорта на дмщика от координатора
--dmInfo = false -- вывод инфы о дме в окно имгуи
keystatus = false -- проверка на воспроизведение бинда
workpause = false -- проверка на включенность костыля для работы скрипта при свернутой игре для vkint
mouseCoord = false -- проверка на статус перемещения окна информера
token = 1 -- токен
mouseCoord2 = false -- перемещение автостроя
mouseCoord3 = false -- перемещение координатора
phpchat = true
getServerColored = '' -- переменная в которой храним все ники пользователей по серверу для покраса в чате


--Secondcolor = 'A7A7A7'



blackbase = {} -- для черного списка
names = {} -- для автростроя
SecNames = {}
SecNames2 = {}

mass_niki = { '', '' }

-- переменные для шпоры, если не ошибаюсь, то есть лишние
files							= {}
window_file						= {}
menu_spur						= imgui.ImBool(false)
name_add_spur					= imgui.ImBuffer(256)
name_edit_spur					= imgui.ImBuffer(256)
find_name_spur					= imgui.ImBuffer(256)
find_text_spur					= imgui.ImBuffer(256)
edit_text_spur					= imgui.ImBuffer(65536)
edit_size_x						= imgui.ImInt(-1)
edit_size_y						= imgui.ImInt(-1)
russian_characters				= { [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я' }
magicChar						= { '\\', '/', ':', '*', '?', '"', '>', '<', '|' }
	
-- настройки игрока
local SET = {
 	settings = {
		autologin = false,
		autogoogle = false,
		autopass = '',
		googlekey = '',
		smssound = true,
		rpFind = false,
		rpinv = true,
		rpuninv = true,
		rpuninvoff = true,
		rpskin = true,
		rprang = true,
		rptime = false,
		timerp = 'Best Man',
		timecout = false,
		rpblack = false,
		gangzones = false,
		zones = false,
		Zdravia = false,
		FPSunlock = false,
		MeNuNaX = false,
		ColorFama = false,
		assistant = false,
		rtag = '',
		ftag = '',
		enable_tag = false,
		gos1 = '',
		gos2 = '',
		gos3 = '',
		gos4 = '',
		gos5 = '',
		lady = false,
		gateOn = false,
		lockCar = false,
		strobes = false,
		armOn = false,
		ads = false,
		chatInfo = false,
		timeToZp = false,
		timeBrand = '',
		casinoBlock = false,
		keyT = false,
		screenSave = false,
		phoneModel = '',
		inComingSMS = false,
		specUd = false,
		infoX = 0,
		infoY = 0,
		infoX2 = 0,
		infoY2 = 0,
		R = 1,
		G = 1,
		B = 1,
		Theme = 1;
		SCRIPTCOLOR = 0x046D63;
		Secondcolor = '00C2BB';
		spOtr = '',
		marker = true,
		gnewstag = 'МО',
		colornikifama = '',
		nikifama1 = '',
		nikifama2 = '',
		nikifama3 = '',
		nikifama4 = '',
		nikifama5 = '',
		nikifama6 = '',
		nikifama7 = '',
		nikifama8 = '',
		nikifama9 = '',
		nikifama10 = '',
		textprivet = 'Здравия желаю, товарищ',
		textpriv = 'Здравия желаю',
		timefix = 3,
		enableskin = false,
		skin = 1,
		blackcheckerpath = 'https://forum.advance-rp.ru/threads/.1542759/'
	},
	vkint = {
		zp = false,
		nickdetect = false,
		pushv = false,
		smsinfo = false,
		remotev = false,
		getradio = false,
		familychat = false
	},
	assistant = {
		asX = 1,
		asY = 1
	},
	informer = {
		zone = true,
		hp = true,
		armour = true,
		city = true,
		kv = true,
		time = true,
		rajon = true,
		mask = true
	}
}


local SeleList = {"Досье", "Сведения", "Пентагон"} -- список менюшек для блока "информация"

-- это делалось если не ошибаюсь для выделения выбранного пункта
local SeleListBool = {}
for i = 1, #SeleList do
	SeleListBool[i] = imgui.ImBool(false)
end

-- массив для окон
local win_state = {}
win_state['main'] = imgui.ImBool(false)
win_state['info'] = imgui.ImBool(false)
win_state['settings'] = imgui.ImBool(false)
win_state['hotkeys'] = imgui.ImBool(false)
win_state['leaders'] = imgui.ImBool(false)
win_state['help'] = imgui.ImBool(false)
win_state['about'] = imgui.ImBool(false)
win_state['update'] = imgui.ImBool(false)
win_state['player'] = imgui.ImBool(false)
win_state['base'] = imgui.ImBool(false)
win_state['informer'] = imgui.ImBool(false)
win_state['regst'] = imgui.ImBool(false)
win_state['renew'] = imgui.ImBool(false)
win_state['find'] = imgui.ImBool(false)
win_state['ass'] = imgui.ImBool(false)
win_state['leave'] = imgui.ImBool(false)

-- временные переменные, которым не требуется сохранение
pozivnoy = imgui.ImBuffer(256) -- позывной в меню взаимодействия
cmd_name = imgui.ImBuffer(256) -- название команды
cmd_text = imgui.ImBuffer(65536) -- текст бинда
searchn = imgui.ImBuffer(256) -- поиск ника в пентагоне
specOtr = imgui.ImBuffer(256) -- спец.отряд для нашивки(вроде)
weather = imgui.ImInt(-1) -- установка погоды
gametime = imgui.ImInt(-1) -- установка времени 
vkid = imgui.ImInt(1) -- назначаем vkid при регистрации
binddelay = imgui.ImInt(3) -- задержка биндера

-- удаление файла клавиш, делаю только тогда, когда добавляю новые клавиши. P.S. удаляет как когда
if doesFileExist(getWorkingDirectory() .. "\\config\\MoD-Helper\\keys.bind") then 
	os.remove(getWorkingDirectory() .. "\\config\\MoD-Helper\\keys.bind")
end

-- Собственно тут ебошим клавиши для биндера и обычные, ничего необычного, а исток всего этого - PerfectBinder хомяка, ибо только там было показано, как более менее юзать imcustom/rkeys.
hk._SETTINGS.noKeysMessage = u8("Пусто")
local bfile = getWorkingDirectory() .. "\\config\\MoD-Helper\\key.bind" -- путь к файлу для хранения клавиш
local tBindList = {}
if doesFileExist(bfile) then
	local fkey = io.open(bfile, "r")
	if fkey then
		tBindList = decodeJson(fkey:read("a*"))
		fkey:close()
	end
else
	tBindList = { 
		[1] = { text = "Тайм", v = {} },
		[2] = { text = "/gate", v = {} },
		[3] = { text = "Сотрудники", v = {} },
		[4] = { text = "Carlock", v = {} },
		[5] = { text = "In SMS", v = {} },
		[6] = { text = "Out SMS", v = {} },
		[7] = { text = "Реконнект", v = {} },
		[8] = { text = "АвтоСтрой", v = {} },
		[9] = { text = "P.E.S. Help", v = {} },
		[10] = { text = "Принять P.E.S.", v = {} },
		[11] = { text = "Fuck Pe4enka.", v = {} },
		[12] = { text = "Снять маркер", v = {} },
		[13] = { text = "Меню скрипта", v = {} },
		[14] = { text = "/r", v = {} },
		[15] = { text = "/f", v = {} },
		[16] = { text = "/g", v = {} }
	}
end
--sampSetChatInputEnabled(true)

local bindfile = getWorkingDirectory() .. '\\config\\MoD-Helper\\binder.bind'
local mass_bind = {}
if doesFileExist(bindfile) then
	local fbind = io.open(bindfile, "r")
	if fbind then
		mass_bind = decodeJson(fbind:read("a*"))
		fbind:close()
	end
else
	mass_bind = {
		[1] = { cmd = "-", v = {}, text = "Any text", delay = 3 },
		[2] = { cmd = "-", v = {}, text = "Any text", delay = 3 },
		[3] = { cmd = "-", v = {}, text = "Any text", delay = 3 },
		[4] = { cmd = "-", v = {}, text = "Any text", delay = 3 },
		[5] = { cmd = "-", v = {}, text = "Any text", delay = 3 }
	}
end


-----------------------------------------------------------------------------------
------------------------------- ФИКСЫ И ПОДОБНАЯ ХУЙНЯ ----------------------------
-----------------------------------------------------------------------------------

-- Фикс зеркального бага alt+tab(черный экран или же какая то хуйня в виде зеркал на экране после разворота в инте)
writeMemory(0x555854, 4, -1869574000, true)
writeMemory(0x555858, 1, 144, true)

-- функция быстрого прогруза игры, кепчик чтоль автор.. Не помню
function patch()
	if memory.getuint8(0x748C2B) == 0xE8 then
		memory.fill(0x748C2B, 0x90, 5, true)
	elseif memory.getuint8(0x748C7B) == 0xE8 then
		memory.fill(0x748C7B, 0x90, 5, true)
	end
	if memory.getuint8(0x5909AA) == 0xBE then
		memory.write(0x5909AB, 1, 1, true)
	end
	if memory.getuint8(0x590A1D) == 0xBE then
		memory.write(0x590A1D, 0xE9, 1, true)
		memory.write(0x590A1E, 0x8D, 4, true)
	end
	if memory.getuint8(0x748C6B) == 0xC6 then
		memory.fill(0x748C6B, 0x90, 7, true)
	elseif memory.getuint8(0x748CBB) == 0xC6 then
		memory.fill(0x748CBB, 0x90, 7, true)
	end
	if memory.getuint8(0x590AF0) == 0xA1 then
		memory.write(0x590AF0, 0xE9, 1, true)
		memory.write(0x590AF1, 0x140, 4, true)
	end
end
patch()

-----------------------------------------------------------------------------------
-------------------------- ФУНКЦИИ СКРИПТА И ВСЕ ЧТО ПО НИМ -----------------------
-----------------------------------------------------------------------------------


function apply_custom_style() -- дизайн imgui, цветовая схема уникальная в том плане, что ее нет в сети и сделана руками

	imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2

    style.WindowPadding = ImVec2(15, 15)
    style.WindowRounding = 5.0
    style.FramePadding = ImVec2(5, 5)
    style.FrameRounding = 4.0
    style.ItemSpacing = ImVec2(12, 8)
    style.ItemInnerSpacing = ImVec2(8, 6)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 15.0
    style.ScrollbarRounding = 9.0
    style.GrabMinSize = 5.0
	style.GrabRounding = 3.0
	style.WindowTitleAlign = ImVec2(0.5, 0.5)

	if Theme == 1 then
		SCRIPTCOLOR = 0x046D63
		Secondcolor.v = '00C2BB'
		colors[clr.Text] = ImVec4(0.71, 0.94, 0.93, 1.00) 
		colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00) 
		colors[clr.WindowBg] = ImVec4(0.00, 0.06, 0.08, 0.91) 
		colors[clr.ChildWindowBg] = ImVec4(0.00, 0.07, 0.07, 0.91) 
		colors[clr.PopupBg] = ImVec4(0.02, 0.08, 0.09, 0.94) 
		colors[clr.Border] = ImVec4(0.04, 0.60, 0.55, 0.88) 
		colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00) 
		colors[clr.FrameBg] = ImVec4(0.02, 0.60, 0.56, 0.49) 
		colors[clr.FrameBgHovered] = ImVec4(0.10, 0.63, 0.69, 0.72) 
		colors[clr.FrameBgActive] = ImVec4(0.04, 0.54, 0.60, 1.00) 
		colors[clr.TitleBg] = ImVec4(0.00, 0.26, 0.30, 0.94) 
		colors[clr.TitleBgActive] = ImVec4(0.00, 0.26, 0.29, 0.94) 
		colors[clr.TitleBgCollapsed] = ImVec4(0.01, 0.28, 0.40, 0.66) 
		colors[clr.MenuBarBg] = ImVec4(0.00, 0.22, 0.22, 0.73) 
		colors[clr.ScrollbarBg] = ImVec4(0.01, 0.44, 0.43, 0.60) 
		colors[clr.ScrollbarGrab] = ImVec4(0.00, 0.93, 1.00, 0.31) 
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.17, 0.64, 0.79, 1.00) 
		colors[clr.ScrollbarGrabActive] = ImVec4(0.01, 0.48, 0.57, 1.00) 
		colors[clr.ComboBg] = ImVec4(0.01, 0.51, 0.50, 0.74) 
		colors[clr.CheckMark] = ImVec4(0.17, 0.87, 0.85, 0.62) 
		colors[clr.SliderGrab] = ImVec4(0.10, 0.84, 0.87, 0.31) 
		colors[clr.SliderGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00) 
		colors[clr.Button] = ImVec4(0.09, 0.70, 0.75, 0.48) 
		colors[clr.ButtonHovered] = ImVec4(0.15, 0.72, 0.75, 0.69) 
		colors[clr.ButtonActive] = ImVec4(0.13, 0.92, 0.98, 0.47) 
		colors[clr.Header] = ImVec4(0.09, 0.65, 0.69, 0.47) 
		colors[clr.HeaderHovered] = ImVec4(0.07, 0.54, 0.58, 0.47) 
		colors[clr.HeaderActive] = ImVec4(0.06, 0.50, 0.53, 0.47) 
		colors[clr.Separator] = ImVec4(0.00, 0.20, 0.23, 1.00) 
		colors[clr.SeparatorHovered] = ImVec4(0.00, 0.20, 0.23, 1.00) 
		colors[clr.SeparatorActive] = ImVec4(0.00, 0.20, 0.23, 1.00) 
		colors[clr.ResizeGrip] = ImVec4(0.06, 0.90, 0.78, 0.16) 
		colors[clr.ResizeGripHovered] = ImVec4(0.04, 0.54, 0.48, 1.00) 
		colors[clr.ResizeGripActive] = ImVec4(0.01, 0.28, 0.41, 1.00) 
		colors[clr.CloseButton] = ImVec4(0.00, 0.94, 0.96, 0.25) 
		colors[clr.CloseButtonHovered] = ImVec4(0.15, 0.63, 0.61, 0.39) 
		colors[clr.CloseButtonActive] = ImVec4(0.15, 0.63, 0.61, 0.39) 
		colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63) 
		colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00) 
		colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63) 
		colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00) 
		colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43) 
		colors[clr.ModalWindowDarkening] = ImVec4(0.00, 0.00, 0.00, 0.80)
	elseif Theme == 2 then
		SCRIPTCOLOR = 0x4F4F4F
		Secondcolor.v = 'A7A7A7'
		colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
		colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 0.50)
		colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 0.80)
		colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
		colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
		--colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.TitleBgCollapsed] = ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.TitleBgActive] = ImVec4(0.07, 0.07, 0.09, 1.00)
		colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 0.50) 	
		colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 0.50)
		colors[clr.CheckMark] = ImVec4(0.80, 0.80, 0.83, 0.31)
		colors[clr.SliderGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
		colors[clr.SliderGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
		--colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.HeaderHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
		colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
		colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
		colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
		colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
		colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
		colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
		colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
		--colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.70)
		colors[clr.ModalWindowDarkening] = ImVec4(0.00, 0.00, 0.00, 0.80)

		colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 0.98)
		--colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.FrameBg] = ImVec4(0.13, 0.12, 0.15, 1.00)
		colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.TitleBg] = ImVec4(0.10, 0.09, 0.12, 0.50)
	elseif Theme == 3 then
		SCRIPTCOLOR = 0xcc5400
		Secondcolor.v = 'E69C67'
		colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
		colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
		colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
		colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
		colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
		colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.TitleBg] = ImVec4(0.76, 0.31, 0.00, 1.00)
		colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
		colors[clr.TitleBgActive] = ImVec4(0.80, 0.33, 0.00, 1.00)
		colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
		colors[clr.CheckMark] = ImVec4(1.00, 0.42, 0.00, 0.53)
		colors[clr.SliderGrab] = ImVec4(1.00, 0.42, 0.00, 0.53)
		colors[clr.SliderGrabActive] = ImVec4(1.00, 0.42, 0.00, 1.00)
		colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
		colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
		colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
		colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
		colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
		colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
		colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
		colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
		colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
	elseif Theme == 4 then
		SCRIPTCOLOR = 0x5b3680
		Secondcolor.v = 'A183C0'
		colors[clr.WindowBg]              = ImVec4(0.14, 0.12, 0.16, 1.00)
		colors[clr.ChildWindowBg]         = ImVec4(0.30, 0.20, 0.39, 0.00)
		colors[clr.PopupBg]               = ImVec4(0.05, 0.05, 0.10, 0.90)
		colors[clr.Border]                = ImVec4(0.89, 0.85, 0.92, 0.30)
		colors[clr.BorderShadow]          = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]               = ImVec4(0.30, 0.20, 0.39, 1.00)
		colors[clr.FrameBgHovered]        = ImVec4(0.41, 0.19, 0.63, 0.68)
		colors[clr.FrameBgActive]         = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.TitleBg]               = ImVec4(0.41, 0.19, 0.63, 0.45)
		colors[clr.TitleBgCollapsed]      = ImVec4(0.41, 0.19, 0.63, 0.35)
		colors[clr.TitleBgActive]         = ImVec4(0.41, 0.19, 0.63, 0.78)
		colors[clr.MenuBarBg]             = ImVec4(0.30, 0.20, 0.39, 0.57)
		colors[clr.ScrollbarBg]           = ImVec4(0.30, 0.20, 0.39, 1.00)
		colors[clr.ScrollbarGrab]         = ImVec4(0.41, 0.19, 0.63, 0.31)
		colors[clr.ScrollbarGrabHovered]  = ImVec4(0.41, 0.19, 0.63, 0.78)
		colors[clr.ScrollbarGrabActive]   = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.ComboBg]               = ImVec4(0.30, 0.20, 0.39, 1.00)
		colors[clr.CheckMark]             = ImVec4(0.56, 0.61, 1.00, 1.00)
		colors[clr.SliderGrab]            = ImVec4(0.41, 0.19, 0.63, 0.24)
		colors[clr.SliderGrabActive]      = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.Button]                = ImVec4(0.41, 0.19, 0.63, 0.44)
		colors[clr.ButtonHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86)
		colors[clr.ButtonActive]          = ImVec4(0.64, 0.33, 0.94, 1.00)
		colors[clr.Header]                = ImVec4(0.41, 0.19, 0.63, 0.76)
		colors[clr.HeaderHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86)
		colors[clr.HeaderActive]          = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.ResizeGrip]            = ImVec4(0.41, 0.19, 0.63, 0.20)
		colors[clr.ResizeGripHovered]     = ImVec4(0.41, 0.19, 0.63, 0.78)
		colors[clr.ResizeGripActive]      = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.CloseButton]           = ImVec4(1.00, 1.00, 1.00, 0.75)
		colors[clr.CloseButtonHovered]    = ImVec4(0.88, 0.74, 1.00, 0.59)
		colors[clr.CloseButtonActive]     = ImVec4(0.88, 0.85, 0.92, 1.00)
		colors[clr.PlotLines]             = ImVec4(0.89, 0.85, 0.92, 0.63)
		colors[clr.PlotLinesHovered]      = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.PlotHistogram]         = ImVec4(0.89, 0.85, 0.92, 0.63)
		colors[clr.PlotHistogramHovered]  = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.TextSelectedBg]        = ImVec4(0.41, 0.19, 0.63, 0.43)
		colors[clr.ModalWindowDarkening]  = ImVec4(0.20, 0.20, 0.20, 0.35)
	elseif Theme == 5 then
		SCRIPTCOLOR = 0x4e4e4e
		Secondcolor.v = 'A7A7A7'
	    colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
		colors[clr.TextDisabled]           = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.WindowBg]               = ImVec4(0.00, 0.00, 0.00, 1.00)
		colors[clr.ChildWindowBg]          = ImVec4(0.00, 0.00, 0.00, 1.00)
		colors[clr.PopupBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
		colors[clr.Border]                 = ImVec4(0.82, 0.77, 0.78, 1.00)
		colors[clr.BorderShadow]           = ImVec4(0.35, 0.35, 0.35, 0.66)
		colors[clr.FrameBg]                = ImVec4(1.00, 1.00, 1.00, 0.28)
		colors[clr.FrameBgHovered]         = ImVec4(0.68, 0.68, 0.68, 0.67)
		colors[clr.FrameBgActive]          = ImVec4(0.79, 0.73, 0.73, 0.62)
		colors[clr.TitleBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
		colors[clr.TitleBgActive]          = ImVec4(0.46, 0.46, 0.46, 1.00)
		colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 1.00)
		colors[clr.MenuBarBg]              = ImVec4(0.00, 0.00, 0.00, 0.80)
		colors[clr.ScrollbarBg]            = ImVec4(0.00, 0.00, 0.00, 0.60)
		colors[clr.ScrollbarGrab]          = ImVec4(1.00, 1.00, 1.00, 0.87)
		colors[clr.ScrollbarGrabHovered]   = ImVec4(1.00, 1.00, 1.00, 0.79)
		colors[clr.ScrollbarGrabActive]    = ImVec4(0.80, 0.50, 0.50, 0.40)
		colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 0.99)
		colors[clr.CheckMark]              = ImVec4(0.99, 0.99, 0.99, 0.52)
		colors[clr.SliderGrab]             = ImVec4(1.00, 1.00, 1.00, 0.42)
		colors[clr.SliderGrabActive]       = ImVec4(0.76, 0.76, 0.76, 1.00)
		colors[clr.Button]                 = ImVec4(0.51, 0.51, 0.51, 0.60)
		colors[clr.ButtonHovered]          = ImVec4(0.68, 0.68, 0.68, 1.00)
		colors[clr.ButtonActive]           = ImVec4(0.67, 0.67, 0.67, 1.00)
		colors[clr.Header]                 = ImVec4(0.72, 0.72, 0.72, 0.54)
		colors[clr.HeaderHovered]          = ImVec4(0.92, 0.92, 0.95, 0.77)
		colors[clr.HeaderActive]           = ImVec4(0.82, 0.82, 0.82, 0.80)
		colors[clr.Separator]              = ImVec4(0.73, 0.73, 0.73, 1.00)
		colors[clr.SeparatorHovered]       = ImVec4(0.81, 0.81, 0.81, 1.00)
		colors[clr.SeparatorActive]        = ImVec4(0.74, 0.74, 0.74, 1.00)
		colors[clr.ResizeGrip]             = ImVec4(0.80, 0.80, 0.80, 0.30)
		colors[clr.ResizeGripHovered]      = ImVec4(0.95, 0.95, 0.95, 0.60)
		colors[clr.ResizeGripActive]       = ImVec4(1.00, 1.00, 1.00, 0.90)
		colors[clr.CloseButton]            = ImVec4(0.45, 0.45, 0.45, 0.50)
		colors[clr.CloseButtonHovered]     = ImVec4(0.70, 0.70, 0.90, 0.60)
		colors[clr.CloseButtonActive]      = ImVec4(0.70, 0.70, 0.70, 1.00)
		colors[clr.PlotLines]              = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.PlotLinesHovered]       = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.PlotHistogram]          = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.TextSelectedBg]         = ImVec4(1.00, 1.00, 1.00, 0.35)
		colors[clr.ModalWindowDarkening]   = ImVec4(0.88, 0.88, 0.88, 0.35)
	elseif Theme == 6 then
		SCRIPTCOLOR = 0x005ec7
		Secondcolor.v = '66A1E3'
		colors[clr.Text]   = ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.TextDisabled]   = ImVec4(0.24, 0.24, 0.24, 1.00)
		colors[clr.WindowBg]              = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.ChildWindowBg]         = ImVec4(0.96, 0.96, 0.96, 1.00)
		colors[clr.PopupBg]               = ImVec4(0.92, 0.92, 0.92, 1.00)
		colors[clr.Border]                = ImVec4(0.86, 0.86, 0.86, 1.00)
		colors[clr.BorderShadow]          = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]               = ImVec4(0.88, 0.88, 0.88, 1.00)
		colors[clr.FrameBgHovered]        = ImVec4(0.82, 0.82, 0.82, 1.00)
		colors[clr.FrameBgActive]         = ImVec4(0.76, 0.76, 0.76, 1.00)
		colors[clr.TitleBg]               = ImVec4(0.00, 0.45, 1.00, 0.82)
		colors[clr.TitleBgCollapsed]      = ImVec4(0.00, 0.45, 1.00, 0.82)
		colors[clr.TitleBgActive]         = ImVec4(0.00, 0.45, 1.00, 0.82)
		colors[clr.MenuBarBg]             = ImVec4(0.00, 0.37, 0.78, 1.00)
		colors[clr.ScrollbarBg]           = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.ScrollbarGrab]         = ImVec4(0.00, 0.35, 1.00, 0.78)
		colors[clr.ScrollbarGrabHovered]  = ImVec4(0.00, 0.33, 1.00, 0.84)
		colors[clr.ScrollbarGrabActive]   = ImVec4(0.00, 0.31, 1.00, 0.88)
		colors[clr.ComboBg]               = ImVec4(0.92, 0.92, 0.92, 1.00)
		colors[clr.CheckMark]             = ImVec4(0.00, 0.49, 1.00, 0.59)
		colors[clr.SliderGrab]            = ImVec4(0.00, 0.49, 1.00, 0.59)
		colors[clr.SliderGrabActive]      = ImVec4(0.00, 0.39, 1.00, 0.71)
		colors[clr.Button]                = ImVec4(0.00, 0.49, 1.00, 0.59)
		colors[clr.ButtonHovered]         = ImVec4(0.00, 0.49, 1.00, 0.71)
		colors[clr.ButtonActive]          = ImVec4(0.00, 0.49, 1.00, 0.78)
		colors[clr.Header]                = ImVec4(0.00, 0.49, 1.00, 0.78)
		colors[clr.HeaderHovered]         = ImVec4(0.00, 0.49, 1.00, 0.71)
		colors[clr.HeaderActive]          = ImVec4(0.00, 0.49, 1.00, 0.78)
		colors[clr.ResizeGrip]            = ImVec4(0.00, 0.39, 1.00, 0.59)
		colors[clr.ResizeGripHovered]     = ImVec4(0.00, 0.27, 1.00, 0.59)
		colors[clr.ResizeGripActive]      = ImVec4(0.00, 0.25, 1.00, 0.63)
		colors[clr.CloseButton]           = ImVec4(0.00, 0.35, 0.96, 0.71)
		colors[clr.CloseButtonHovered]    = ImVec4(0.00, 0.31, 0.88, 0.69)
		colors[clr.CloseButtonActive]     = ImVec4(0.00, 0.25, 0.88, 0.67)
		colors[clr.PlotLines]             = ImVec4(0.00, 0.39, 1.00, 0.75)
		colors[clr.PlotLinesHovered]      = ImVec4(0.00, 0.39, 1.00, 0.75)
		colors[clr.PlotHistogram]         = ImVec4(0.00, 0.39, 1.00, 0.75)
		colors[clr.PlotHistogramHovered]  = ImVec4(0.00, 0.35, 0.92, 0.78)
		colors[clr.TextSelectedBg]        = ImVec4(0.00, 0.47, 1.00, 0.59)
		colors[clr.ModalWindowDarkening]  = ImVec4(0.20, 0.20, 0.20, 0.35)
	elseif Theme == 7 then
		SCRIPTCOLOR = 0x33404a
		Secondcolor.v = '8898A4'
		colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
		colors[clr.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
		colors[clr.WindowBg] = ImVec4(0.11, 0.15, 0.17, 1.00)
		colors[clr.ChildWindowBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
		colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
		colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
		colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
		colors[clr.TitleBg] = ImVec4(0.09, 0.12, 0.14, 0.65)
		colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
		colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
		colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
		colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
		colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
		colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
		colors[clr.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
		colors[clr.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
		colors[clr.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.ButtonHovered] = ImVec4(0.28, 0.56, 1.00, 1.00)
		colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
		colors[clr.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
		colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
		colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
		colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
		colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
		colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
		colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
		colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
		colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
		colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
		colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
		colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
		colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
		colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
	elseif Theme == 8 then
		
		SCRIPTCOLOR = 0x572D2D
		Secondcolor.v = 'AB7E7E'
		colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.TextDisabled]         = ImVec4(0.73, 0.75, 0.74, 1.00)
		colors[clr.WindowBg]             = ImVec4(0.09, 0.09, 0.09, 0.94)
		colors[clr.ChildWindowBg]        = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border]               = ImVec4(0.20, 0.20, 0.20, 0.50)
		colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]              = ImVec4(0.71, 0.39, 0.39, 0.54)
		colors[clr.FrameBgHovered]       = ImVec4(0.84, 0.66, 0.66, 0.40)
		colors[clr.FrameBgActive]        = ImVec4(0.84, 0.66, 0.66, 0.67)
		colors[clr.TitleBg]              = ImVec4(0.47, 0.22, 0.22, 0.67)
		colors[clr.TitleBgActive]        = ImVec4(0.47, 0.22, 0.22, 1.00)
		colors[clr.TitleBgCollapsed]     = ImVec4(0.47, 0.22, 0.22, 0.67)
		colors[clr.MenuBarBg]            = ImVec4(0.34, 0.16, 0.16, 1.00)
		colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.53)
		colors[clr.ScrollbarGrab]        = ImVec4(0.31, 0.31, 0.31, 1.00)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
		colors[clr.ScrollbarGrabActive]  = ImVec4(0.51, 0.51, 0.51, 1.00)
		colors[clr.CheckMark]            = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.SliderGrab]           = ImVec4(0.71, 0.39, 0.39, 1.00)
		colors[clr.SliderGrabActive]     = ImVec4(0.84, 0.66, 0.66, 1.00)
		colors[clr.Button]               = ImVec4(0.47, 0.22, 0.22, 0.65)
		colors[clr.ButtonHovered]        = ImVec4(0.71, 0.39, 0.39, 0.65)
		colors[clr.ButtonActive]         = ImVec4(0.20, 0.20, 0.20, 0.50)
		colors[clr.Header]               = ImVec4(0.71, 0.39, 0.39, 0.54)
		colors[clr.HeaderHovered]        = ImVec4(0.84, 0.66, 0.66, 0.65)
		colors[clr.HeaderActive]         = ImVec4(0.84, 0.66, 0.66, 0.00)
		colors[clr.Separator]            = ImVec4(0.43, 0.43, 0.50, 0.50)
		colors[clr.SeparatorHovered]     = ImVec4(0.71, 0.39, 0.39, 0.54)
		colors[clr.SeparatorActive]      = ImVec4(0.71, 0.39, 0.39, 0.54)
		colors[clr.ResizeGrip]           = ImVec4(0.71, 0.39, 0.39, 0.54)
		colors[clr.ResizeGripHovered]    = ImVec4(0.84, 0.66, 0.66, 0.66)
		colors[clr.ResizeGripActive]     = ImVec4(0.84, 0.66, 0.66, 0.66)
		colors[clr.CloseButton]          = ImVec4(0.41, 0.41, 0.41, 1.00)
		colors[clr.CloseButtonHovered]   = ImVec4(0.98, 0.39, 0.36, 1.00)
		colors[clr.CloseButtonActive]    = ImVec4(0.98, 0.39, 0.36, 1.00)
		colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
		colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
		colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
		colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
		colors[clr.TextSelectedBg]       = ImVec4(0.26, 0.59, 0.98, 0.35)
		colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
	elseif Theme == 9 then
		SCRIPTCOLOR = 0x801341
		Secondcolor.v = 'C0668C'
		colors[clr.Text] = ImVec4(0.860, 0.930, 0.890, 0.78)
		colors[clr.TextDisabled] = ImVec4(0.860, 0.930, 0.890, 0.28)
		colors[clr.WindowBg] = ImVec4(0.13, 0.14, 0.17, 1.00)
		colors[clr.ChildWindowBg] = ImVec4(0.200, 0.220, 0.270, 0.58)
		colors[clr.PopupBg] = ImVec4(0.200, 0.220, 0.270, 0.9)
		colors[clr.Border] = ImVec4(0.31, 0.31, 1.00, 0.00)
		colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg] = ImVec4(0.200, 0.220, 0.270, 1.00)
		colors[clr.FrameBgHovered] = ImVec4(0.455, 0.198, 0.301, 0.78)
		colors[clr.FrameBgActive] = ImVec4(0.455, 0.198, 0.301, 1.00)
		colors[clr.TitleBg] = ImVec4(0.232, 0.201, 0.271, 1.00)
		colors[clr.TitleBgActive] = ImVec4(0.502, 0.075, 0.256, 1.00)
		colors[clr.TitleBgCollapsed] = ImVec4(0.200, 0.220, 0.270, 0.75)
		colors[clr.MenuBarBg] = ImVec4(0.200, 0.220, 0.270, 0.47)
		colors[clr.ScrollbarBg] = ImVec4(0.200, 0.220, 0.270, 1.00)
		colors[clr.ScrollbarGrab] = ImVec4(0.09, 0.15, 0.1, 1.00)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.455, 0.198, 0.301, 0.78)
		colors[clr.ScrollbarGrabActive] = ImVec4(0.455, 0.198, 0.301, 1.00)
		colors[clr.CheckMark] = ImVec4(0.71, 0.22, 0.27, 1.00)
		colors[clr.SliderGrab] = ImVec4(0.47, 0.77, 0.83, 0.14)
		colors[clr.SliderGrabActive] = ImVec4(0.71, 0.22, 0.27, 1.00)
		colors[clr.Button] = ImVec4(0.455, 0.198, 0.301, 1.00)
		colors[clr.ButtonHovered] = ImVec4(0.455, 0.198, 0.301, 0.86)
		colors[clr.ButtonActive] = ImVec4(0.455, 0.198, 0.301, 1.00)
		colors[clr.Header] = ImVec4(0.455, 0.198, 0.301, 0.76)
		colors[clr.HeaderHovered] = ImVec4(0.455, 0.198, 0.301, 0.86)
		colors[clr.HeaderActive] = ImVec4(0.502, 0.075, 0.256, 1.00)
		colors[clr.ResizeGrip] = ImVec4(0.47, 0.77, 0.83, 0.04)
		colors[clr.ResizeGripHovered] = ImVec4(0.455, 0.198, 0.301, 0.78)
		colors[clr.ResizeGripActive] = ImVec4(0.455, 0.198, 0.301, 1.00)
		colors[clr.PlotLines] = ImVec4(0.860, 0.930, 0.890, 0.63)
		colors[clr.PlotLinesHovered] = ImVec4(0.455, 0.198, 0.301, 1.00)
		colors[clr.PlotHistogram] = ImVec4(0.860, 0.930, 0.890, 0.63)
		colors[clr.PlotHistogramHovered] = ImVec4(0.455, 0.198, 0.301, 1.00)
		colors[clr.TextSelectedBg] = ImVec4(0.455, 0.198, 0.301, 0.43)
		colors[clr.ModalWindowDarkening] = ImVec4(0.200, 0.220, 0.270, 0.73)
	end

end
--apply_custom_style()

function files_add() -- функция подгрузки медиа файлов
	print("Проверка целостности файлов")
	if not doesDirectoryExist("moonloader\\MoD-Helper") then print("Создаю MoD-Helper/") createDirectory("moonloader\\MoD-Helper") end
	if not doesDirectoryExist("moonloader\\MoD-Helper\\shpora") then print("Создаю MoD-Helper/shpora") createDirectory('moonloader\\MoD-Helper\\shpora') end
	if not doesDirectoryExist("moonloader\\MoD-Helper\\audio") then print("Создаю MoD-Helper/audio") createDirectory('moonloader\\MoD-Helper\\audio') end
	if not doesDirectoryExist("moonloader\\MoD-Helper\\images") then print("Создаю MoD-Helper/images") createDirectory('moonloader\\MoD-Helper\\images') end
	if not doesDirectoryExist("moonloader\\MoD-Helper\\files") then print("Создаю MoD-Helper/files") createDirectory("moonloader\\MoD-Helper\\files") end

	if not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\audio\\ad.wav') or not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\audio\\avik.mp3') or not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\audio\\base.mp3') or not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\audio\\sms.mp3') or not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\audio\\crash.mp3') then
		async_http_request('GET', 'https://frank09.000webhostapp.com/files/ad.wav', nil, 
		function(response)
			local f = assert(io.open(getWorkingDirectory() .. '/MoD-Helper/audio/ad.wav', 'wb'))
			f:write(response.text)
			f:close()
			print("Audio download[ad.wav]: Success")
		end,
		function(err)
			print("Audio download[ad.wav]: "..err)
		end)

		async_http_request('GET', 'https://frank09.000webhostapp.com/files/base.mp3', nil,
		function(response)
			local f = assert(io.open(getWorkingDirectory() .. '/MoD-Helper/audio/base.mp3', 'wb'))
			f:write(response.text)
			f:close()
			print("Audio download[base.mp3]: Success")
		end,
		function(err)
			print("Audio download[base.mp3]: "..err)
		end)
		
		async_http_request('GET', 'https://frank09.000webhostapp.com/files/avik.mp3', nil,
		function(response)
			local f = assert(io.open(getWorkingDirectory() .. '/MoD-Helper/audio/avik.mp3', 'wb'))
			f:write(response.text)
			f:close()
			print("Audio download[avik.mp3]: Success")
		end,
		function(err)
			print("Audio download[avik.mp3]: "..err)
		end)

		async_http_request('GET', 'https://frank09.000webhostapp.com/files/crash.mp3', nil,
		function(response)
			local f = assert(io.open(getWorkingDirectory() .. '/MoD-Helper/audio/crash.mp3', 'wb'))
			f:write(response.text)
			f:close()
			print("Audio download[avik.mp3]: Success")
		end,
		function(err)
			print("Audio download[avik.mp3]: "..err)
		end)

		async_http_request('GET', 'https://frank09.000webhostapp.com/files/sms.mp3', nil,
		function(response)
			local f = assert(io.open(getWorkingDirectory() .. '/MoD-Helper/audio/sms.mp3', 'wb'))
			f:write(response.text)
			f:close()
			print("Audio download[avik.mp3]: Success")
		end,
		function(err)
			print("Audio download[avik.mp3]: "..err)
		end)
	end

	if not doesDirectoryExist("moonloader\\MoD-Helper\\images\\skins") then
		print("Создаю MoD-Helper/images/skins")
		createDirectory("moonloader\\MoD-Helper\\images\\skins")
	end
		
	lua_thread.create(function()
		for i = 1, 311 do
			if not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\skins\\'..i..'.png') then
				if i ~= 53 and i ~= 74 then
					downloadUrlToFile('https://files.advance-rp.ru/media/skins/'..i..'.png', getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\skins\\'..i..'.png')
					print('Skinload: Skin: '..i..'/311 loaded')
					repeat 
						wait(0)
					until doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\skins\\'..i..'.png')
				end
			end
		end
	end)

	if not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\img.png') or not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\errorPic.png') or not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\classified.png') or not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\pentagon.png') or not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\access_denied.png') then
		print("Загружаю системные картинки")
		downloadUrlToFile('https://i.imgur.com/KkOXJJs.png', getWorkingDirectory() .. '/MoD-Helper/images/img.png')
		downloadUrlToFile('https://i.imgur.com/X99DKIb.png', getWorkingDirectory() .. '/MoD-Helper/images/errorPic.png')
		downloadUrlToFile('https://i.imgur.com/fnHuVN3.png', getWorkingDirectory() .. '/MoD-Helper/images/classified.png')
		downloadUrlToFile('https://i.imgur.com/Obl47RD.png', getWorkingDirectory() .. '/MoD-Helper/images/pentagon.png')
		downloadUrlToFile('https://i.imgur.com/jrJVpOS.png', getWorkingDirectory() .. '/MoD-Helper/images/access_denied.png')			
	end
	if not doesDirectoryExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\helpers') then
		print("Создаю MoD-Helper/images/helpers")
		createDirectory('moonloader\\MoD-Helper\\images\\helpers')
	end

	if not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\helpers\\stefani.png') then
		print("Загружаю Стефани(майор Фиорентино).")
		downloadUrlToFile('https://i.imgur.com/oHDkTvI.png', getWorkingDirectory() .. '/MoD-Helper/images/helpers/stefani.png')	
	end
	if not doesFileExist(getGameDirectory()..'\\moonloader\\config\\MoD-Helper\\settings.ini') then 
		inicfg.save(SET, 'config\\MoD-Helper\\settings.ini')
	end
end

function rkeys.onHotKey(id, keys) -- эту штучку я не использую, но она помогла запретить юзание клавиш в определенных ситах
	if sampIsChatInputActive() or sampIsDialogActive() or isSampfuncsConsoleActive() or win_state['base'].v or win_state['update'].v or win_state['player'].v or droneActive or keystatus then
		return false
	end
end

function onHotKey(id, keys) -- функция обработки всех клавиш, которые ток существуют в скрипте благодаря imcustom, rkeys и хомяку
	local sKeys = tostring(table.concat(keys, " "))
	for k, v in pairs(tBindList) do
		if sKeys == tostring(table.concat(v.v, " ")) then
			if k == 1 then -- вбиваем тайм
				sampSendChat("/c 60")
				return
			elseif k == 2 then -- открываем врата
				if interior ~= 0 and isPlayerSoldier then
					sampAddChatMessage("[MoD-Helper]{FFFFFF} Вы находитесь в интерьере, команда недоступна.", SCRIPTCOLOR) 
				elseif interior == 0 and isPlayerSoldier then
					if gateOn.v then
						sampSendChat("/do Камеры наблюдения автоматически распознали лицо "..(lady.v and 'девушки' or 'мужчины')..".") 
						wait(1000)
						sampSendChat("/do После распознания сработали автоматические ворота.")
						wait(150)
					end
					sampSendChat("/gate")
				end
				return
			elseif k == 3 then -- открываем финд
				ex_find()
				return
			elseif k == 4 then -- клавиша локкара
				if interior ~= 0 then
					sampAddChatMessage("[MoD-Helper]{FFFFFF} Вы находитесь в интерьере, команда недоступна.", SCRIPTCOLOR)
				else
					if lockCar.v then
						sampSendChat("/me достав ключ из кармана, "..(lady.v and 'нажала' or 'нажал').." кнопку [Открыть/Закрыть]") 
						wait(150)
					end
					sampSendChat("/lock 1")
				end
				return
			elseif k == 5 then -- вставляем в чат "/sms " и номер человека, который нам последний писал
				if lastnumberon ~= nil then
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/sms "..lastnumberon.." ")
				else
					sampAddChatMessage("[MoD-Helper]{FFFFFF} Вы ранее не получали входящих сообщений.", SCRIPTCOLOR)
				end
				return
			elseif k == 6 then -- вставляем в чат "/sms " и номер человека, которому последний раз писали
				if lastnumberfor ~= nil then
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/sms "..lastnumberfor.." ")
				else
					sampAddChatMessage("[MoD-Helper]{FFFFFF} Вы ранее не отправляли СМС сообщений.", SCRIPTCOLOR)
				end
				return
			elseif k == 7 then -- делаем реконнект
				reconnect()
				return
			elseif k == 8 then -- включаем/выключаем автрострой 
				--[[if isPlayerSoldier then
					state = not state
					names = {}
					SecNames = {}
					SecNames2 = {}
					namID = {}
					secID = {}
					sec2ID = {}
				end]]--
				return
			elseif k == 9 then -- отправляем коорды
				if isPlayerSoldier then
					if cX ~= nil and cY ~= nil and cZ ~= nil then
						locationPos()
						bcX = math.ceil(cX + 3000)
						bcY = math.ceil(cY + 3000)
						bcZ = math.ceil(cZ)
						while bcZ < 1 do bcZ = bcZ + 1 end
						sampSendChat('/f [P.E.S.]: Передаю координаты: '..BOL..'! N'..bcX..'E'..bcY..'Z'..bcZ..'!') 
					end
				end
				return
			elseif k == 10 then -- принимаем коорды
				if isPlayerSoldier then
					sampAddChatMessage("+", -1)
					if x1 ~= nil and y1 ~= nil then
						if doesPickupExist(pickup1) or doesPickupExist(pickup1a) or doesBlipExist(marker1) then removePickup(pickup1) removePickup(pickup1a) removeBlip(marker1) end
						sampProcessChatInput('/f Координаты принял. Расстояние до вас: '..math.ceil(getDistanceBetweenCoords2d(x1, y1, cX, cY))..' м.')
						result, pickup1 = createPickup(19605, 19, x1, y1, z1)
						result, pickup1a = createPickup(19605, 14, x1, y1, z1)
						marker1 = addSpriteBlipForCoord(x1, y1, z1, 56)
						x1 = nil
						y1 = nil
						z1 = nil
						lastcall = nil
					end
				end
				return
			elseif k == 11 then -- включаем/выключаем vkint
				workpause = not workpause
				if workpause then
					WorkInBackground(true)
					sampTextdrawCreate(102, "FuckPe4enka", 550, 435)
				else 
					WorkInBackground(false)
					sampTextdrawDelete(102)
				end
				return
			elseif k == 12 then -- удаляем маркер/таргет
				ClearBlip()
				return
			elseif k == 13 then -- открываем меню
				if not sampIsChatInputActive() and not sampIsDialogActive() then
					mainmenu()
				end
				return
			elseif k == 14 then -- открываем чат с /r
				if not sampIsChatInputActive() and not sampIsDialogActive() then
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/r ")
				end
				return
			elseif k == 15 then -- открываем чат с /f
				if not sampIsChatInputActive() and not sampIsDialogActive() then
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/f ")
				end
				return
			elseif k == 16 then -- открываем чат с /g
				if not sampIsChatInputActive() and not sampIsDialogActive() then
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/g ")
				end
				return
			end
		end
	end

	for i, p in pairs(mass_bind) do -- тут регистрируем биндер на клавиши.
		if sKeys == tostring(table.concat(p.v, " ")) then
			rcmd(nil, p.text, p.delay)		
		end
	end
end

function calc(m) -- "калькулятор", который так и не нашел применения в скрипте, но функция все же тут есть
    local func = load('return '..tostring(m))
    local a = select(2, pcall(func))
    return type(a) == 'number' and a or nil
end

function WorkInBackground(work) -- работа в свернутом imringa'a
    local memory = require 'memory'
	if work then -- on
        memory.setuint8(7634870, 1) 
        memory.setuint8(7635034, 1)
        memory.fill(7623723, 144, 8)
        memory.fill(5499528, 144, 6)
	else -- off
        memory.setuint8(7634870, 0)
        memory.setuint8(7635034, 0)
        memory.hex2bin('5051FF1500838500', 7623723, 8)
        memory.hex2bin('0F847B010000', 5499528, 6)
    end 
end

function WriteLog(text, path, file) -- функция записи текст в файл, используется для чатлога
	if not doesDirectoryExist(getWorkingDirectory()..'\\'..path..'\\') then
		createDirectory(getWorkingDirectory()..'\\'..path..'\\')
	end
	local file = io.open(getWorkingDirectory()..'\\'..path..'\\'..file..'.txt', 'a+')
	file:write(text..'\n')
	file:flush()
	file:close()
end

-- Шифровалка Base64
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' -- You will need this for encoding/decoding
function en(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end
function dc(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
    end))
end

function tags(args) -- функция с тэгами скрипта

	args = args:gsub("{params}", tostring(cmdparams))
	args = args:gsub("{par1}", tostring(cmdparams1))
	args = args:gsub("{par2}", tostring(cmdparams2))
	args = args:gsub("{paramNickByID}", tostring(sampGetPlayerNickname(cmdparams)))
	args = args:gsub("{paramFullNameByID}", tostring(sampGetPlayerNickname(cmdparams):gsub("_", " ")))
	args = args:gsub("{paramNameByID}", tostring(sampGetPlayerNickname(cmdparams):gsub("_.*", "")))
	args = args:gsub("{paramSurnameByID}", tostring(sampGetPlayerNickname(cmdparams):gsub(".*_", "")))

	args = args:gsub("{NickByIDpar1}", tostring(sampGetPlayerNickname(cmdparams1)))
	args = args:gsub("{FullNameByIDpar1}", tostring(sampGetPlayerNickname(cmdparams1):gsub("_", " ")))
	args = args:gsub("{NameByIDpar1}", tostring(sampGetPlayerNickname(cmdparams1):gsub("_.*", "")))
	args = args:gsub("{SurnameByIDpar1}", tostring(sampGetPlayerNickname(cmdparams1):gsub(".*_", "")))

	args = args:gsub("{NickByIDpar2}", tostring(sampGetPlayerNickname(cmdparams2)))
	args = args:gsub("{FullNameByIDpar2}", tostring(sampGetPlayerNickname(cmdparams2):gsub("_", " ")))
	args = args:gsub("{NameByIDpar2}", tostring(sampGetPlayerNickname(cmdparams2):gsub("_.*", "")))
	args = args:gsub("{SurnameByIDpar2}", tostring(sampGetPlayerNickname(cmdparams2):gsub(".*_", "")))

	args = args:gsub("{mynick}", tostring(userNick))
	args = args:gsub("{myid}", tostring(myID))
	args = args:gsub("{myhp}", tostring(healNew))
	args = args:gsub("{myrang}", tostring(rang))
	args = args:gsub("{myarm}", tostring(armourNew))
	args = args:gsub("{base}", tostring(ZoneText))
	args = args:gsub("{arm}", tostring(fraction))
	args = args:gsub("{city}", tostring(playerCity))
	args = args:gsub("{org}", tostring(org))
	args = args:gsub("{mtag}", tostring(mtag))
	args = args:gsub("{rtag}", tostring(u8:decode(rtag.v)))
	args = args:gsub("{ftag}", tostring(u8:decode(rtag.v)))
	args = args:gsub("{kvadrat}", tostring(locationPos()))
	args = args:gsub("{steam}", tostring(u8:decode(spOtr.v)))

	args = args:gsub("{time}", string.format(os.date('%H:%M:%S', moscow_time)))
	args = args:gsub("{myfname}", tostring(nickName))
	args = args:gsub("{myname}", tostring(userNick:gsub("_.*", "")))
	args = args:gsub("{mysurname}", tostring(userNick:gsub(".*_", "")))
	args = args:gsub("{zone}", tostring(ZoneInGame))
	args = args:gsub("{fid}", tostring(lastfradioID))
	args = args:gsub("{rid}", tostring(lastrradioID))
	args = args:gsub("{ridrang}", tostring(lastrradiozv))
	args = args:gsub("{fidrang}", tostring(lastfradiozv))
	args = args:gsub("{ridnick}", tostring(sampGetPlayerNickname(lastrradioID)))
	args = args:gsub("{fidnick}", tostring(sampGetPlayerNickname(lastfradioID)))
	args = args:gsub("{ridfname}", tostring(sampGetPlayerNickname(lastrradioID):gsub("_", " ")))
	args = args:gsub("{fidfname}", tostring(sampGetPlayerNickname(lastfradioID):gsub("_", " ")))
	args = args:gsub("{ridname}", tostring(sampGetPlayerNickname(lastrradioID):gsub("_.*", " ")))
	args = args:gsub("{fidname}", tostring(sampGetPlayerNickname(lastfradioID):gsub("_.*", " ")))
	args = args:gsub("{ridsurname}", tostring(sampGetPlayerNickname(lastrradioID):gsub(".*_", " ")))
	args = args:gsub("{fidsurname}", tostring(sampGetPlayerNickname(lastfradioID):gsub(".*_", " ")))

	if newmark ~= nil then
		args = args:gsub("{targetfname}", tostring(sampGetPlayerNickname(blipID):gsub("_", " ")))
		args = args:gsub("{targetname}", tostring(sampGetPlayerNickname(blipID):gsub("_.*", "")))
		args = args:gsub("{targetsurname}", tostring(sampGetPlayerNickname(blipID):gsub(".*_", "")))
		args = args:gsub("{targetnick}", tostring(sampGetPlayerNickname(blipID)))
		args = args:gsub("{tID}", tostring(blipID))
	end
	return args
end

function mainmenu() -- функция открытия основного меню скрипта
	if not win_state['player'].v and not win_state['update'].v and not win_state['base'].v and not win_state['regst'].v then
		if win_state['settings'].v then
			win_state['settings'].v = not win_state['settings'].v
		elseif win_state['leaders'].v then
			win_state['leaders'].v = not win_state['leaders'].v
		elseif win_state['about'].v then
			win_state['about'].v = not win_state['about'].v
		elseif win_state['help'].v then
			win_state['help'].v = not win_state['help'].v
		elseif win_state['info'].v then
			win_state['info'].v = not win_state['info'].v
		elseif menu_spur.v then
			menu_spur.v = not menu_spur.v
		end
		win_state['main'].v = not win_state['main'].v

		offscript = 0
		selected = 1
		selected2 = 1
		showSet = 1
		leadSet = 1
	end
end


function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end

	print("Начинаем подгрузку скрипта и его составляющих")
	

	-- if doesFileExist(getWorkingDirectory().."\\MoD-Helper\\files\\regst.data") then secure_vk() end
	files_add() -- загрузка файлов и подгрузка текстур
	
	mlogo = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\img.png')
	errorPic = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\errorPic.png')
	classifiedPic = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\classified.png')
	pentagonPic = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\pentagon.png')
	accessDeniedPic = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\access_denied.png')
	helper_stefani = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\helpers\\stefani.png')
	
	

	print("Создаем файл черного списка")
	if not doesFileExist(getWorkingDirectory().."\\MoD-Helper\\blacklist.txt") then 
		local blk = assert(io.open(getWorkingDirectory().."\\MoD-Helper\\blacklist.txt", 'a'))
		blk:write()
		blk:close()
	end
	load_settings() -- загрузка настроек
	apply_custom_style()
	print("Подгружаем настройки скрипта")
	update() -- запуск обновлений
	while not UpdateNahuy do wait(0) end -- пока не проверит обновления тормозим работу

	sampAddChatMessage("[MoD-Helper] {FFFFFF}Скрипт подгружен в игру, версия: {"..u8:decode(Secondcolor.v).."}"..thisScript().version.."{ffffff}, начинаем инициализацию.", SCRIPTCOLOR)
	colorf = imgui.ImFloat3(R, G, B)
	
	repeat wait(10) until sampIsLocalPlayerSpawned()
	print("Проверяем подключаемый сервер")
	print(sampGetCurrentServerName())
	if sampGetCurrentServerName():find("Red") then
		gameServer = "Red"
		srv = 1
	elseif sampGetCurrentServerName():find("Green")  then -- проверяем подключенный сервер
		gameServer = "Green"
		srv = 2
	elseif sampGetCurrentServerName():find("Blue")  then -- проверяем подключенный сервер
		gameServer = "Blue"
		srv = 3
	elseif sampGetCurrentServerName():find("Lime")  then -- проверяем подключенный сервер
		gameServer = "Lime"
		srv = 4

	else
		print("Сервер не допущен, работа скрипта завершена")
		sampAddChatMessage("[MoD-Helper]{FFFFFF} К сожалению, данный скрипт недоступен для работы на данном сервере.", SCRIPTCOLOR)
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Свяжитесь с разработчиками, если хотите уточнить возможность решения данной проблемы.", SCRIPTCOLOR)
		thisScript():unload()
		return
	end
	print("Проверка пройдена, сервер: "..tostring(gameServer))
	
	
	-- ожидаем спавн игрока
	
	print("Форматируем чекер ЧСа")
	format_file()
	
	-- определяем ник и ID локального игрока 
	print("Определяем ID и ник локального игрока")
	_, myID = sampGetPlayerIdByCharHandle(PLAYER_PED)
	userNick = sampGetPlayerNickname(myID)
	nickName = userNick:gsub('_', ' ')


	print("Начинаем получение данных")
	-- регистрация данных статистики в скрипте
	regDialogOpen = true
	if srv <= 9 then sampSendChat("/mn") else sampSendChat("/stats") end
	while ScriptUse == 3 do wait(0) end -- ожидаем окончания регистрации
	if ScriptUse == 0 then
		print("/mn -> 1: Игрок определен как гражданский")
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Вы определены как {"..u8:decode(Secondcolor.v).."}гражданский{FFFFFF}, функционал откорректирован.", SCRIPTCOLOR)
		isPlayerSoldier = false
	else
		print("/mn -> 1: Игрок определен как военный")
		isPlayerSoldier = true
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Вы определены как {"..u8:decode(Secondcolor.v).."}военный{FFFFFF}, функционал откорректирован.", SCRIPTCOLOR)
	end
	sampAddChatMessage("[MoD-Helper]{FFFFFF} Внимание, активна {"..u8:decode(Secondcolor.v).."}локальная{FFFFFF} версия, активация {"..u8:decode(Secondcolor.v).."}/mod{FFFFFF}, разработчик: {"..u8:decode(Secondcolor.v).."}Xavier Adamson.", SCRIPTCOLOR)
	--sampAddChatMessage("[MoD-Helper]{FFFFFF} Технический модератор в отставке и просто хороший человек - {"..u8:decode(Secondcolor.v).."}Arina Borisova.", SCRIPTCOLOR)
	sampAddChatMessage("[MoD-Helper]{FFFFFF} Введите {FFCC00}/whatsup{FFFFFF}, чтобы подробнее узнать о нововведениях в {"..u8:decode(Secondcolor.v).."}"..thisScript().version..".", SCRIPTCOLOR)
	sampAddChatMessage("[MoD-Helper]{FFFFFF} Действующий разработчик скрипта: {"..u8:decode(Secondcolor.v).."}DIPIRIDAMOLE", SCRIPTCOLOR)
	

	print("Начинаем инициализацию биндера")
	if mass_bind ~= nil then
		print("Регистрируем команды бинда.")
		for k, p in ipairs(mass_bind) do
			if p.cmd ~= "-" then
				rcmd(p.cmd, p.text, p.delay)
				print("Зарегистрирована команда биндера: /"..p.cmd)
			end
		end
	else
		print("Критическая ошибка, выполняем откат binder.bind")
		mass_bind = {
			[1] = { cmd = "-", v = {}, text = "Any text", delay = 3 },
			[2] = { cmd = "-", v = {}, text = "Any text", delay = 3 },
			[3] = { cmd = "-", v = {}, text = "Any text", delay = 3 },
			[4] = { cmd = "-", v = {}, text = "Any text", delay = 3 },
			[5] = { cmd = "-", v = {}, text = "Any text", delay = 3 }
		}
		print("Откат выполнен.")

	end
	print("Регистрация клавиш бинда")
	for i, g in pairs(mass_bind) do
		rkeys.registerHotKey(g.v, true, onHotKey)
	end
	print("Инициализация биндера завершена")

	print("Начинаем инициализацию клавиш")
	if tBindList ~= nil then
		print("Регистрируем клавиши")
		for k, v in pairs(tBindList) do
			rkeys.registerHotKey(v.v, true, onHotKey)
		end
	else
		print("Критическая ошибка, выполняем откат клавиш")
		tBindList = { 
			[1] = { text = "Тайм", v = {} },
			[2] = { text = "/gate", v = {} },
			[3] = { text = "Сотрудники", v = {} },
			[4] = { text = "Carlock", v = {} },
			[5] = { text = "In SMS", v = {} },
			[6] = { text = "Out SMS", v = {} },
			[7] = { text = "Реконнект", v = {} },
			[8] = { text = "АвтоСтрой", v = {} },
			[9] = { text = "P.E.S. Help", v = {} },
			[10] = { text = "Принять P.E.S.", v = {} },
			[11] = { text = "Fuck Pe4enka.", v = {} },
			[12] = { text = "Снять маркер", v = {} },
			[13] = { text = "Меню скрипта", v = {} },
			[14] = { text = "/r", v = {} },
			[15] = { text = "/f", v = {} },
			[16] = { text = "/g", v = {} }
		}
		print("Откат выполнен.")
	end
	print("Инициализация клавиш завершена")


	
	while nasosal_rang == nil do wait(0) end
	
	async_http_request('GET', 'http://dipimod.000webhostapp.com/?text=['..tostring(gameServer)..']%20'..tostring(userNick), nil,
	function(response)
    
	end,
	function(err)
    
	end)



	inputHelpText = renderCreateFont("Arial", 10, FCR_BORDER + FCR_BOLD) -- шрифт для chatinfo
	lua_thread.create(showInputHelp)
	files, window_file = getFilesSpur() -- подгружаем шпоры
	
	print("Определяем скин персонажа")
	local playerSkin = getCharModel(PLAYER_PED)
	skinPic = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\skins\\'..playerSkin..'.png')
	
	print("Регистрация скриптовых команд началась")
	-- регистрация локальных команд/команды
	sampRegisterChatCommand("cc", ClearChat) -- очистка чата
	sampRegisterChatCommand("test", test) -- очистка чата
	sampRegisterChatCommand("rm", ClearBlip) -- удаление блипа
	sampRegisterChatCommand("drone", drone) -- дроны
	sampRegisterChatCommand("leave", function() if not win_state['player'].v and not win_state['update'].v and not win_state['main'].v then win_state['leave'].v = not win_state['leave'].v end end) -- дроны
	sampRegisterChatCommand("reload", rel) -- перезагрузка скрипта
	sampRegisterChatCommand("ud", cmd_ud) -- удостоверение
	sampRegisterChatCommand("black", black_checker) -- чек на ЧС по ID
	sampRegisterChatCommand("bhist", black_history) -- чек на ЧС по истории
	sampRegisterChatCommand("bb", upd_blacklist) -- обновить ЧС
	sampRegisterChatCommand("find", ex_find) -- отыгровка финда
	sampRegisterChatCommand("hist", cmd_histid) -- история ников по ID
	sampRegisterChatCommand("where", cmd_where) -- команда чтобы запросить местоположение по ID
	sampRegisterChatCommand("rn", cmd_rn) -- OOC чат /r
	sampRegisterChatCommand("fn", cmd_fn) -- OOC чат /f
	sampRegisterChatCommand("r", rradio) -- Обработка /r с тегами
	sampRegisterChatCommand("f", fradio) -- Обработка /f с тегами
	sampRegisterChatCommand("rd", cmd_rd) -- доклады в /r чат
	sampRegisterChatCommand("fd", cmd_fd) -- доклады в /f чат
	sampRegisterChatCommand("livr", cmd_livrby) -- запросить увольнение(офикам)
	sampRegisterChatCommand("livf", cmd_livfby) -- запросить увольнение(офикам)
	sampRegisterChatCommand("raport", livraport) -- рапорт отстранения(офикам)
	sampRegisterChatCommand("uninv", cmd_uninvby) -- уволить по просьбе
	sampRegisterChatCommand("ok", cmd_ok) -- уволить по просьбе
	sampRegisterChatCommand("uninvite", ex_uninvite)
	sampRegisterChatCommand("uninviteoff", ex_uninviteoff)
	sampRegisterChatCommand("rang", ex_rang)
	sampRegisterChatCommand("changeskin", ex_skin)
	sampRegisterChatCommand("invite", ex_invite)
	sampRegisterChatCommand("dice", ex_dice)
	sampRegisterChatCommand("mod", mainmenu)
	sampRegisterChatCommand("colorstring", cmd_color)
	sampRegisterChatCommand("tir", Skill_Up)
	sampRegisterChatCommand("whatsup", pokaz_obnov)
	sampRegisterChatCommand("vig", vigovor)
	sampRegisterChatCommand("nr", naryad)
	sampRegisterChatCommand("lua", chatlua)
	sampRegisterChatCommand("fpsunlock", function(param) local stat = tonumber(param) ~= 0 fpsUnlock(stat) sampAddChatMessage(stat and "включен" or "выключен", -1) end)
	
	--sampRegisterChatCommand("base", function() if isPlayerSoldier then if not win_state['player'].v and not win_state['update'].v and not win_state['main'].v then selected3 = 1  win_state['base'].v = not win_state['base'].v end end end)
	sampRegisterChatCommand("upd", function() if not win_state['player'].v and not win_state['update'].v and not win_state['main'].v then win_state['renew'].v = not win_state['renew'].v end end)
	print("Регистрация скриптовых команд завершена")
	
	if isLocalPlayerSoldier then -- если по стате игрок вояка, то включаем рандом сообщения в чат + инфу о людях из бд грузим
		random_messages()
	end
	
	-- используем bass.lua
	aaudio = bass.BASS_StreamCreateFile(false, "moonloader/MoD-Helper/audio/ad.wav", 0, 0, 0) -- уведомление при включении скрипта
	bass.BASS_ChannelSetAttribute(aaudio, BASS_ATTRIB_VOL, 0.1)
	bass.BASS_ChannelPlay(aaudio, false)

	asms = bass.BASS_StreamCreateFile(false, "moonloader/MoD-Helper/audio/sms.mp3", 0, 0, 0) -- sms звук
	bass.BASS_ChannelSetAttribute(asms, BASS_ATTRIB_VOL, 1.0)
	
	aerr = bass.BASS_StreamCreateFile(false, "moonloader/MoD-Helper/audio/crash.mp3", 0, 0, 0) -- краш звук
	bass.BASS_ChannelSetAttribute(aerr, BASS_ATTRIB_VOL, 3.0)
	

	while token == 0 do wait(0) end
	if enableskin.v then changeSkin(-1, localskin.v) end -- установка визуал скина, если включено
	while true do
		wait(0)
		colornikifama = tostring(('%06X'):format((join_argb(0, colorf.v[1] * 255, colorf.v[2] * 255, colorf.v[3] * 255))))
		local parra
		if FPSunlock.v then parra = nil end
		if not FPSunlock.v then parra = 0 end
		local stat = tonumber(parra) ~= 0 
		fpsUnlock(stat)
		mass_niki[#mass_niki] = imgui.ImBuffer(256)
		-- получаем время
		unix_time = os.time(os.date('!*t'))
		moscow_time = unix_time + timefix.v * 60 * 60

		if gametime.v ~= -1 then writeMemory(0xB70153, 1, gametime.v, true) end -- установка игрового времени
		if weather.v ~= -1 then writeMemory(0xC81320, 1, weather.v, true) end -- установка игровой погоды
		
		-- if zp.v and workpause then -- отправляем оповещение в ВК о зарплате в определенные минуты
		-- 	if os.date('%M:%S') == "50:00" then
		-- 		wait(995)
		-- 		vkmessage(tonumber(vkid2), "--------------------------------Зарплата--------------------------------%0A"..userNick..", до получения зарплаты осталось примерно 10 минут.")
		-- 	elseif os.date('%M:%S') == "55:00" then
		-- 		wait(995)
		-- 		vkmessage(tonumber(vkid2), "--------------------------------Зарплата--------------------------------%0A"..userNick..", до получения зарплаты осталось примерно 5 минут.")
		-- 	elseif os.date('%M:%S') == "59:00" then
		-- 		wait(995)
		-- 		vkmessage(tonumber(vkid2), "--------------------------------Зарплата--------------------------------%0A"..userNick..", до получения зарплаты осталось примерно 1 минута.")
		-- 	elseif os.date('%M:%S') == "59:30" then
		-- 		wait(995)
		-- 		vkmessage(tonumber(vkid2), "--------------------------------Зарплата--------------------------------%0A"..userNick..", до получения зарплаты осталось примерно 30 секунд.")
		-- 	end
		-- end
		--addGangZone(1001, -2080.2, 2200.1, -2380.9, 2540.3, 0x11011414) менее светлый цвет
		armourNew = getCharArmour(PLAYER_PED) -- получаем броню
		healNew = getCharHealth(PLAYER_PED) -- получаем ХП
		interior = getActiveInterior() -- получаем инту
		

		-- if healNew <= 3 then assDmg = false assTakeDamage = 0 end -- обнуляем 
		if not offmask and healNew == 0 then
			offMask = true
			offMaskTime = nil
		end

		-- получение названия района на инглише(работает только при включенном английском в настройках игры, иначе иероглифы)
		local zX, zY, zZ = getCharCoordinates(playerPed)
		ZoneInGame = getGxtText(getNameOfZone(zX, zY, zZ))
			
		-- определение города
		local citiesList = {'Los-Santos', 'San-Fierro', 'Las-Venturas'}
		local city = getCityPlayerIsIn(PLAYER_HANDLE)
		if city > 0 then playerCity = citiesList[city] else playerCity = "Нет сигнала" end


		-- назначаем переменным зоны по коордам и проверяем на нахождение персонажа в них
		vmfZone = isCharInArea2d(PLAYER_PED, -2072.8, 2206.0, -2333.6, 2559.6, false)
		vvsZone = isCharInArea2d(PLAYER_PED, 489.8, 2369.5, -122.3, 2594.6, false)
		svZone = isCharInArea2d(PLAYER_PED, 404.6, 1761.0, 69.8, 2129.2, false)
		avikZone = isCharInArea2d(PLAYER_PED, -1732.1, 247.0, -1161.7, 582.3, false)

		if gangzones.v then -- рисуем гангзоны военных объектов
			addGangZone(1001, -2072.8, 2559.6, -2333.6, 2206.0, 0x50511913) -- вмф зона
			addGangZone(1002, 489.8, 2594.6, -122.3, 2369.5, 0x50511913) -- ввс зона
			addGangZone(1003,  404.6, 2129.2, 69.8, 1761.0, 0x50511913) -- св зона
			addGangZone(1004, -1732.1, 247.0, -1161.7, 582.3, 0x50511913) -- авик
		else
			removeGangZone(1001)
			removeGangZone(1002)
			removeGangZone(1003)
			removeGangZone(1004)
		end
		

		-- задаем названия зонам по координатам
		if vmfZone then ZoneText = "Navy Base"
		elseif vvsZone then ZoneText = "Air Forces Base"
		elseif avikZone then ZoneText = "AirCraft Carrier"
		elseif svZone then ZoneText = "Ground Forces"
		else ZoneText = "-" end

		if zones.v and not workpause then -- показываем информер и его перемещение
			if not win_state['regst'].v then win_state['informer'].v = true end

			if mouseCoord then
				showCursor(true, true)
				infoX, infoY = getCursorPos()
				if isKeyDown(VK_RETURN) then
					infoX = math.floor(infoX)
					infoY = math.floor(infoY)
					mouseCoord = false
					showCursor(false, false)
					win_state['main'].v = not win_state['main'].v
					win_state['settings'].v = not win_state['settings'].v
				end
			end
		else
			win_state['informer'].v = false
		end

		if assistant.v and developMode == 1 and isPlayerSoldier then -- координатор и его перемещение
			if not win_state['regst'].v then win_state['ass'].v = true end

			if mouseCoord3 then
				showCursor(true, true)
				asX, asY = getCursorPos()
				if isKeyDown(VK_RETURN) then
					asX = math.floor(asX)
					asY = math.floor(asY)
					mouseCoord3 = false
					showCursor(false, false)
				end
			end
		else
			win_state['ass'].v = false
		end

		if state then -- показываем автострой и его перемещение
			win_state['find'].v = true
			if mouseCoord2 then
				showCursor(true, true)
				infoX2, infoY2 = getCursorPos()
				if isKeyDown(VK_RETURN) then
					infoX2 = math.floor(infoX2)
					infoY2 = math.floor(infoY2)
					mouseCoord2 = false
					showCursor(false, false)
					win_state['main'].v = not win_state['main'].v
					win_state['settings'].v = not win_state['settings'].v
				end
			end
		else
			win_state['find'].v = false
		end
		
		if hasPickupBeenCollected(pickup1) or hasPickupBeenCollected(pickup1a) then -- если подобрали пикап скрипта, то удаляем его
			removeBlip(marker1)
			removePickup(pickup1)
			removePickup(pickup1a)
		end
		
		if files[1] then
			for i, k in pairs(files) do
				if k and not imgui.Process then imgui.Process = menu_spur.v or window_file[i].v end
			end
		else imgui.Process = menu_spur.v end
		
		imgui.Process = win_state['regst'].v or win_state['main'].v or win_state['update'].v or win_state['player'].v or win_state['base'].v or win_state['informer'].v or win_state['renew'].v or win_state['find'].v or win_state['ass'].v or win_state['leave'].v
		
		-- тут мы шаманим с блокировкой управления персонажа
		if menu_spur.v or win_state['settings'].v or win_state['leaders'].v or win_state['player'].v or win_state['base'].v or win_state['regst'].v or win_state['renew'].v or win_state['leave'].v then
			if not isCharInAnyCar(PLAYER_PED) then
				lockPlayerControl(true)
			end
		elseif droneActive then
			lockPlayerControl(true)
		elseif workpause then
			if userNick ~= "Xavier_Adamson" then
				sampSetChatInputEnabled(false)
			end
			lockPlayerControl(true)
		else
			lockPlayerControl(false)
		end
		

		if armOn.v then -- отыгровка броника, при релоге скрипта, если броник был надет - отыграет, если подойдет по условиям.
			if (armourNew == 100 and armourStatus == 0) then
				sampSendChat("/me "..(lady.v and 'открыла' or 'открыл').." склад с новыми бронежилетами IOTV") 
				wait(250)
				sampSendChat("/me "..(lady.v and 'взяла' or 'взял').." новый бронежилет со склада и "..(lady.v and 'надела' or 'надел').." его на себя")
				armourStatus = 1
			end
			
			if armourNew <= 50 and armourStatus == 1 then	
				sampSendChat("/do Бронежилет получил повреждения, требуется замена.")
				armourStatus = 0
			end

		else
			if armourNew == 100 and armourStatus == 0 then
				armourStatus = 1
			elseif armourNew <= 50 and armourStatus == 1 then
				armourStatus = 0
			end
		end

		if wasKeyPressed(key.VK_H) and not sampIsChatInputActive() and not sampIsDialogActive() and strobesOn.v and isCharInAnyCar(PLAYER_PED) then strobes() end -- стробоскопы на H, не делал на гудок ибо не хочу

		if wasKeyPressed(key.VK_R) and not win_state['main'].v and not win_state['update'].v and not win_state['base'].v and not win_state['regst'].v and isPlayerSoldier then -- меню взаимодействия на ПКМ + R
			local result, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
			if result then
				local tdd, id = sampGetPlayerIdByCharHandle(ped)
				if tdd then
					MenuName = sampGetPlayerNickname(id)
					MenuID = id
					win_state['player'].v = not win_state['player'].v
				end
			end
		end

		if wasKeyPressed(key.VK_X) and MeNuNaX.v and not sampIsChatInputActive() and not sampIsDialogActive() then --открытие менюшки на Х, как в старые добрые
			mainmenu()
		end

		if wasKeyPressed(VK_CONTROL) and skill then
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Вы закончили прокачивание скиллов.", SCRIPTCOLOR)
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Для начала используйте {"..u8:decode(Secondcolor.v).."}/tir [мс]", SCRIPTCOLOR)
			skill = false
		end
			

		-- тут у нас идет приветствие на ПКМ + 1
		if wasKeyPressed(key.VK_1) and not win_state['main'].v and not win_state['player'].v and not win_state['update'].v and not win_state['base'].v and not win_state['regst'].v and isPlayerSoldier then
			local result, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
			if result then
				local tdd, id = sampGetPlayerIdByCharHandle(ped)
				if tdd then
					local pSkin = getCharModel(ped)
					local name = string.gsub(sampGetPlayerNickname(id), ".*_", "")
					sampSendChat("/anim 58")
					wait(150)
					if pSkin == 191 or pSkin == 73 or pSkin == 179 or pSkin == 253 or pSkin == 255 or pSkin == 287 or pSkin == 61 then
						sampSendChat("/todo Выполнив воинское приветствие*"..u8:decode(textprivet.v).." "..name.."!")
					else -- бомжей как обычно
						sampSendChat("/todo Поприветствовав человека напротив*"..u8:decode(textpriv.v).."!")
					end
				end
			end
		end

		local result, ped = getCharPlayerIsTargeting(PLAYER_HANDLE) -- это мы получаем маркер/таргет последнего игрока
		if result then
			local tdd, id = sampGetPlayerIdByCharHandle(ped)
			if tdd then
				if marker.v then
					blipID = id
					if newmark ~= nil then removeBlip(newmark) end
					newmark = addBlipForChar(ped)
					changeBlipColour(newmark, 4)
				else
					if id ~= blipID then
						blipID = id
						newmark = true
					end
				end
			end
		end

		if keyT.v then -- чат на русскую Т
			if(isKeyDown(key.VK_T) and wasKeyPressed(key.VK_T))then
				if(not sampIsChatInputActive() and not sampIsDialogActive()) then
					sampSetChatInputEnabled(true)
				end
			end
		end


		for i = 0, sampGetMaxPlayerId(true) do -- отключаем "вх" камхака для игроков, оставляем для разрабов.
			if sampIsPlayerConnected(i) then
				local result, ped = sampGetCharHandleBySampPlayerId(i)
				if result then
					local positionX, positionY, positionZ = getCharCoordinates(ped)
					local localX, localY, localZ = getCharCoordinates(PLAYER_PED)
					local distance = getDistanceBetweenCoords3d(positionX, positionY, positionZ, localX, localY, localZ)
					if distance >= 30 and droneActive and developMode ~= 1 then
						EmulShowNameTag(i, false)
					elseif droneActive and developMode == 1 then
						EmulShowNameTag(i, true)
					else
						EmulShowNameTag(i, true)
					end
				end
			end
		end
	end
end



function genCode(skey) -- генерация гугл ключа для автогугла
	skey = basexx.from_base32(skey)
	value = math.floor(os.time() / 30)
	value = string.char(
		0, 0, 0, 0,
		bit.band(value, 0xFF000000) / 0x1000000,
		bit.band(value, 0xFF0000) / 0x10000,
		bit.band(value, 0xFF00) / 0x100,
		bit.band(value, 0xFF)
	)
	local hash = sha1.hmac_binary(skey, value)
	local offset = bit.band(hash:sub(-1):byte(1, 1), 0xF)
	local function bytesToInt(a,b,c,d)
		return a*0x1000000 + b*0x10000 + c*0x100 + d
	end
	hash = bytesToInt(hash:byte(offset + 1, offset + 4))
	hash = bit.band(hash, 0x7FFFFFFF) % 1000000
	return ("%06d"):format(hash)
end

function EmulShowNameTag(id, value) -- эмуляция показа неймтэгов над бошкой
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt16(bs, id)
    raknetBitStreamWriteBool(bs, value)
    raknetEmulRpcReceiveBitStream(80, bs)
    raknetDeleteBitStream(bs)
end

function sampGetPlayerIdByNickname(nick) -- получаем id игрока по нику
    if type(nick) == "string" then
        for id = 0, 1000 do
            local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
            if sampIsPlayerConnected(id) or id == myid then
                local name = sampGetPlayerNickname(id)
                if nick == name then
                    return id
                end
            end
        end
    end
end

function onQuitGame()
	saveSettings(2) -- сохраняем игру при выходе
end

function onScriptTerminate(script, quitGame) -- действия при отключении скрипта
	if script == thisScript() then
		showCursor(false)
		saveSettings(1)
		
		if marker.v then removeBlip(newmark) end -- удаляем маркер
		if quitGame == false then
			bass.BASS_ChannelPlay(aerr, false) -- воспроизводим звук краша
			lockPlayerControl(false) -- снимаем блок персонажа на всякий
			sampTextdrawDelete(102) -- удаляем текстдрав от VK Int на всякий.

			if not reloadScript then -- выводим текст
				sampAddChatMessage("[MoD-Helper]{FFFFFF} Произошла ошибка, скрипт завершил свою работу принудительно.", SCRIPTCOLOR)
				--sampAddChatMessage("[MoD-Helper]{FFFFFF} Свяжитесь с разработчиком для уточнения деталей проблемы.", SCRIPTCOLOR)
				sampAddChatMessage("[MoD-Helper]{FFFFFF} Для перезапуска скрипта используйте {"..u8:decode(Secondcolor.v).."}CTRL + R.", SCRIPTCOLOR)
			end
			if workpause then -- если был активен VK-Int, то вырубаем его
				memory.setuint8(7634870, 0)
        		memory.setuint8(7635034, 0)
        		memory.hex2bin('5051FF1500838500', 7623723, 8)
				memory.hex2bin('0F847B010000', 5499528, 6)
			end

			if droneActive then -- выходим из дрона и отрубаем все от него возможное
				setInfraredVision(false)
				setNightVision(false)
				restoreCameraJumpcut()
				setCameraBehindPlayer()
				flymode = 0
				droneActive = false
			end
		end
	end
end

function saveSettings(args, key) -- функция сохранения настроек, args 1 = при отключении скрипта, 2 = при выходе из игры, 3 = сохранение клавиш + текст key, 4 = обычное сохранение.

	if aaudio ~= nil then
		bass.BASS_StreamFree(aaudio)
	end
	if doesFileExist(bfile) then
		os.remove(bfile)
	end
	local f = io.open(bfile, "w")
	if f then
		f:write(encodeJson(tBindList))
		f:close()
	end

	if doesFileExist(bindfile) then
		os.remove(bindfile)
	end
	local f2 = io.open(bindfile, "w")
	if f2 then
		f2:write(encodeJson(mass_bind))
		f2:close()
	end

	ini.vkint.nickdetect = nickdetect.v
	ini.vkint.pushv = pushv.v
	ini.vkint.smsinfo = smsinfo.v
	ini.vkint.remotev = remotev.v
	ini.vkint.getradio = getradio.v
	ini.vkint.familychat = familychat.v

	ini.informer.zone = infZone.v
	ini.informer.hp = infHP.v
	ini.informer.armour = infArmour.v
	ini.informer.city = infCity.v
	ini.informer.kv = infKv.v
	ini.informer.time = infTime.v
	ini.informer.rajon = infRajon.v
	ini.informer.mask = infMask.v

	ini.settings.rpinv = rpinv.v
	ini.settings.rpuninv = rpuninv.v
	ini.settings.rpuninvoff = rpuninvoff.v
	ini.settings.rpskin = rpskin.v
	ini.settings.rprang = rprang.v

	ini.settings.rpFind = rpFind.v
	ini.settings.rpblack = rpblack.v
	ini.settings.smssound = smssound.v
	ini.settings.rptime = rptime.v
	ini.settings.assistant = assistant.v
	ini.settings.screenSave = screenSave.v
	ini.settings.casinoBlock = casinoBlock.v
	ini.settings.keyT = keyT.v
	ini.settings.marker = marker.v
	ini.settings.timefix = timefix.v
	ini.settings.enableskin = enableskin.v
	ini.settings.skin = localskin.v
	ini.settings.gnewstag = u8:decode(gnewstag.v)
	ini.settings.colornikifama = colornikifama
	ini.settings.nikifama1 = u8:decode(nikifama1.v)
	ini.settings.nikifama2 = u8:decode(nikifama2.v)
	ini.settings.nikifama3 = u8:decode(nikifama3.v)
	ini.settings.nikifama4 = u8:decode(nikifama4.v)
	ini.settings.nikifama5 = u8:decode(nikifama5.v)
	ini.settings.nikifama6 = u8:decode(nikifama6.v)
	ini.settings.nikifama7 = u8:decode(nikifama7.v)
	ini.settings.nikifama8 = u8:decode(nikifama8.v)
	ini.settings.nikifama9 = u8:decode(nikifama9.v)
	ini.settings.nikifama10 = u8:decode(nikifama10.v)
	ini.settings.textprivet = u8:decode(textprivet.v)
	ini.settings.Secondcolor = u8:decode(Secondcolor.v)
	ini.settings.textpriv = u8:decode(textpriv.v)
	ini.settings.blackcheckerpath = u8:decode(blackcheckerpath.v)
	ini.settings.inComingSMS = inComingSMS.v
	ini.settings.specUd = specUd.v
	ini.settings.timecout = timecout.v
	ini.settings.gangzones = gangzones.v
	ini.settings.zones = zones.v
	ini.settings.Zdravia = Zdravia.v
	ini.settings.Fixtune = Fixtune.v
	ini.settings.MeNuNaX = MeNuNaX.v
	ini.settings.ColorFama = ColorFama.v
	ini.settings.ads = ads.v
	ini.settings.chatInfo = chatInfo.v
	ini.settings.infoX = infoX
	ini.settings.infoY = infoY
	ini.settings.infoX2 = infoX2
	ini.settings.infoY2 = infoY2
	ini.settings.findX = findX
	ini.settings.findY = findY
	ini.settings.R = R
	ini.settings.G = G
	ini.settings.B = B
	ini.settings.Theme = Theme
	ini.settings.SCRIPTCOLOR = SCRIPTCOLOR
	ini.settings.rtag = u8:decode(rtag.v)
	ini.settings.ftag = u8:decode(ftag.v)

	ini.settings.autopass = u8:decode(autopass.v)
	ini.settings.googlekey = u8:decode(googlekey.v)
	ini.settings.autologin = autologin.v
	ini.settings.autogoogle = autogoogle.v

	ini.assistant.asX = asX
	ini.assistant.asY = asY

	ini.settings.enable_tag = enable_tag.v
	ini.settings.gos1 = u8:decode(gos1.v)
	ini.settings.gos2 = u8:decode(gos2.v)
	ini.settings.gos3 = u8:decode(gos3.v)
	ini.settings.gos4 = u8:decode(gos4.v)
	ini.settings.gos5 = u8:decode(gos5.v)
	ini.settings.phoneModel = u8:decode(phoneModel.v)
	ini.settings.timerp = u8:decode(timerp.v)
	ini.settings.timeBrand = u8:decode(timeBrand.v)
	ini.settings.spOtr = u8:decode(spOtr.v)
	ini.settings.lady = lady.v
	ini.settings.timeToZp = timeToZp.v
	ini.settings.gateOn = gateOn.v
	ini.settings.lockCar = lockCar.v
	ini.settings.strobes = strobesOn.v
	ini.settings.FPSunlock = FPSunlock.v
	ini.settings.armOn = armOn.v
	inicfg.save(SET, "/MoD-Helper/settings.ini")
	if args == 1 then
		print("============== SCRIPT WAS TERMINATED ==============")
		print("Настройки и клавиши сохранены в связи.")
		print("MoD-Helper by X.Adamson, version: "..thisScript().version)
		print("Script mode: "..tostring(developMode)..", VK: "..tostring(vkinf))

		if doesFileExist(getWorkingDirectory() .. '\\MoD-Helper\\files\\regst.data') then
			print("File regst.data is finded")
		else
			print("File regst.data not finded")
		end
		print("==================================================")
	elseif args == 2 then
		print("============== GAME WAS TERMINATED ===============")
		print("==================================================")
	elseif args == 3 and key ~= nil then
		print("============== "..key.." SAVED ==============")
	elseif args == 4 then
		print("============== SAVED ==============")
	end
end

function sampev.onPlayerChatBubble(id, color, distance, dur, text)
	if droneActive and developMode == 1 then -- тут мы меняем дальность действия текста над бошкой и для разрабов при камхаке(дроне) расширяем
		return {id, color, 1488, dur, text}
	end
end


-- обработка диалогов
function sampev.onShowDialog(dialogId, style, title, button1, button2, text)

	if title:find("Код с приложения") and text:find("Система безопасности") and autogoogle.v then -- автогугл
		sampSendDialogResponse(dialogId, 1, 0, genCode(u8:decode(googlekey.v)))
		sampAddChatMessage("[MoD-Auth] {FFFFFF}Google Authenticator пройден по коду: "..genCode(u8:decode(googlekey.v)), SCRIPTCOLOR)
		return false
	end

	if title:find("Авторизация") and text:find("Добро пожаловать") and autologin.v then -- автологин
		sampSendDialogResponse(dialogId, 1, 0, u8:decode(autopass.v))
			if text:find("Неверный пароль!") then
				sampAddChatMessage("[MoD-Auth] {FFFFFF}Установленный вами пароль неверен. Автологин был отключен.", SCRIPTCOLOR)
				autologin.v = false
			else
				sampAddChatMessage("[MoD-Auth] {FFFFFF}Установленный вами пароль был автоматически введен.", SCRIPTCOLOR)
			end
		return false
	end


	if title:find('В подразделении%s+.+%sчел.') then
		findCout = title:match('онлайн%s+(.+)%p')
		Vpodrazdelenii = title:match('В подразделении%s+(.+)%sчел.')
		if ColorFama.v then
			if tostring(u8:decode(nikifama1.v)):match('%a') then text = text:gsub(u8:decode(nikifama1.v), '{'..colornikifama..'}'..u8:decode(nikifama1.v)) end
			if tostring(u8:decode(nikifama2.v)):match('%a') then text = text:gsub(u8:decode(nikifama2.v), '{'..colornikifama..'}'..u8:decode(nikifama2.v)) end
			if tostring(u8:decode(nikifama3.v)):match('%a') then text = text:gsub(u8:decode(nikifama3.v), '{'..colornikifama..'}'..u8:decode(nikifama3.v)) end
			if tostring(u8:decode(nikifama4.v)):match('%a') then text = text:gsub(u8:decode(nikifama4.v), '{'..colornikifama..'}'..u8:decode(nikifama4.v)) end
			if tostring(u8:decode(nikifama5.v)):match('%a') then text = text:gsub(u8:decode(nikifama5.v), '{'..colornikifama..'}'..u8:decode(nikifama5.v)) end
			if tostring(u8:decode(nikifama6.v)):match('%a') then text = text:gsub(u8:decode(nikifama6.v), '{'..colornikifama..'}'..u8:decode(nikifama6.v)) end
			if tostring(u8:decode(nikifama7.v)):match('%a') then text = text:gsub(u8:decode(nikifama7.v), '{'..colornikifama..'}'..u8:decode(nikifama7.v)) end
			if tostring(u8:decode(nikifama8.v)):match('%a') then text = text:gsub(u8:decode(nikifama8.v), '{'..colornikifama..'}'..u8:decode(nikifama8.v)) end
			if tostring(u8:decode(nikifama9.v)):match('%a') then text = text:gsub(u8:decode(nikifama9.v), '{'..colornikifama..'}'..u8:decode(nikifama9.v)) end
			if tostring(u8:decode(nikifama10.v)):match('%a') then text = text:gsub(u8:decode(nikifama10.v), '{'..colornikifama..'}'..u8:decode(nikifama10.v)) end
		end
		return { dialogId, style, title, button1, button2, text }
	end

	if title:find('Лидеры') or title:find('Всего игроков в организации: ') or title:find('Последние гос. новости') or title:find('Лицензеры онлайн') or title:find('Адвокаты онлайн') or title:find('Телефонная книга') or title:find('Отчёт организации за сегодня') then
		if ColorFama.v then
			if tostring(u8:decode(nikifama1.v)):match('%a') then text = text:gsub(u8:decode(nikifama1.v), '{'..colornikifama..'}'..u8:decode(nikifama1.v)..'{FFFFFF}') end
			if tostring(u8:decode(nikifama2.v)):match('%a') then text = text:gsub(u8:decode(nikifama2.v), '{'..colornikifama..'}'..u8:decode(nikifama2.v)..'{FFFFFF}') end
			if tostring(u8:decode(nikifama3.v)):match('%a') then text = text:gsub(u8:decode(nikifama3.v), '{'..colornikifama..'}'..u8:decode(nikifama3.v)..'{FFFFFF}') end
			if tostring(u8:decode(nikifama4.v)):match('%a') then text = text:gsub(u8:decode(nikifama4.v), '{'..colornikifama..'}'..u8:decode(nikifama4.v)..'{FFFFFF}') end
			if tostring(u8:decode(nikifama5.v)):match('%a') then text = text:gsub(u8:decode(nikifama5.v), '{'..colornikifama..'}'..u8:decode(nikifama5.v)..'{FFFFFF}') end
			if tostring(u8:decode(nikifama6.v)):match('%a') then text = text:gsub(u8:decode(nikifama6.v), '{'..colornikifama..'}'..u8:decode(nikifama6.v)..'{FFFFFF}') end
			if tostring(u8:decode(nikifama7.v)):match('%a') then text = text:gsub(u8:decode(nikifama7.v), '{'..colornikifama..'}'..u8:decode(nikifama7.v)..'{FFFFFF}') end
			if tostring(u8:decode(nikifama8.v)):match('%a') then text = text:gsub(u8:decode(nikifama8.v), '{'..colornikifama..'}'..u8:decode(nikifama8.v)..'{FFFFFF}') end
			if tostring(u8:decode(nikifama9.v)):match('%a') then text = text:gsub(u8:decode(nikifama9.v), '{'..colornikifama..'}'..u8:decode(nikifama9.v)..'{FFFFFF}') end
			if tostring(u8:decode(nikifama10.v)):match('%a') then text = text:gsub(u8:decode(nikifama10.v), '{'..colornikifama..'}'..u8:decode(nikifama10.v)..'{FFFFFF}') end
		end
		return { dialogId, style, title, button1, button2, text }
	end



	if dialogId == 176 and title:match("Точное время") then -- обработка диалога /c 60
			if timecout.v then -- счетчик чистого онлайна в чат
				local houtyet, minyet = text:match("Время в игре сегодня:		{ffcc00}(%d+) ч (%d+) мин")
				local houtyet1, minyet1 = text:match("AFK за сегодня:		{FF7000}(%d+) ч (%d+) мин")
				local outhour =  houtyet - houtyet1
				local outmin = minyet - minyet1
				if string.find(outmin, "-") then
					outmin = outmin + 60
					outhour = outhour - 1
				end
				sampAddChatMessage("[MoD-Helper]{FFFFFF} Чистый онлайн: "..outhour.." ч "..outmin.." мин.", SCRIPTCOLOR)
			end
			
			if timeToZp.v then 
				sampAddChatMessage("[MoD-Helper]{FFFFFF} До выплаты почасовой зарплаты - "..60-os.date('%M').." минут.", SCRIPTCOLOR)
			end

			if rptime.v then -- Рп часы
				if timerp.v == '' then
					if timeBrand.v == '' then
						sampSendChat("/me вытянув руку, "..(lady.v and 'посмотрела' or 'посмотрел').." на армейские часы")
						
					else
						sampSendChat("/me "..(lady.v and 'посмотрела' or 'посмотрел').." на часы бренда «"..u8:decode(timeBrand.v).."»")
					end
				else
					if timeBrand.v == '' then
						sampSendChat("/me "..(lady.v and 'посмотрела' or 'посмотрел').." на часы c гравировкой «"..u8:decode(timerp.v).."»")
					else
						sampSendChat("/me "..(lady.v and 'посмотрела' or 'посмотрел').." на часы бренда «"..u8:decode(timeBrand.v).."» c гравировкой «"..u8:decode(timerp.v).."»")
					end
				end
				sampShowDialog(176,title,text,button1,button2,style)
			end
			return
	end
		
	if dialogId == 436 and checking then -- работа с диалогом истории ников для чекера на ЧСников
			title = title:match("Прошлые имена (.*)")
			text = text:gsub('{.-}', '')
			text = text:gsub('До %d+.%d+.%d+', '')
			for nicknames in text:gmatch('\t(.*)\n') do
				nicknames = nicknames:gsub("\t", "")
				nicknames = nicknames:gsub("\n", " ")
				for k, v in ipairs(blackbase) do
					if v[1]~= nil then
						if nicknames:find(v[1]) then
							sampShowDialog(1488, '{FFD700}ЧС МО | MoD-Helper', "{DC143C}Игрок "..v[1].." найден в черном списке.\nПричина занесения: "..u8:decode(v[2]), "Закрыть", "", 0)
							bstatus = 1
							checking = false
							break
						end
					end
				end

				if button2 ~= '' and checking then
					sampSendDialogResponse(436, 1, -1, '')
				end
				if button2 == '' and not checking then
					checking = false
					sampSendDialogResponse(436, 1, -1, '')
					sampShowDialog(1488, '{FFD700}ЧС МО | MoD-Helper', "{32CD32}Игрок не находится в ЧС МО.", "Закрыть", "", 0) 
					bstatus = 2
				end
				if button2 == '' and checking then
					checking = false
					sampSendDialogResponse(436, 1, -1, '')
					sampShowDialog(1488, '{FFD700}ЧС МО | MoD-Helper', "{32CD32}Игрок не находится в ЧС МО.", "Закрыть", "", 0) 
					bstatus = 2
				end
			end
			return false
	end
	if text:find('История изменения имён персонажа пуста') and checking and not pidr then 
			sampShowDialog(1488, '{FFD700}ЧС МО | MoD-Helper', "{32CD32}Игрок не находится в ЧС МО.", "Закрыть", "", 0) 
			bstatus = 2
			checking = false
			return false
	end

		-- считывание статистики игрока после спавна на сервере, с последующей обработкой
	if regDialogOpen and title:find("Меню игрока") then -- получение данных статистики
			sampSendDialogResponse(dialogId, 1, 0, -1)
			return false
	elseif regDialogOpen and title:find("Статистика игрока") then
		
			org = text:match("Организация:%s*{66c2ff}(.*)Подр")
			preorg = text:match("Подразделение:%s*{66c2ff}(.*)Долж")
			rang = text:match("Должность:%s*{66c2ff}(.*)Ранг")

			-- если организация не nil или любая, но не Мин.Обороны - ScriptUse = 0, иначе - переименование подфракций.
			if org ~= nil then
				nasosal_rang = tonumber(text:match("Ранг:%s*{66c2ff}(.*)\n{FFFFFF}Работа"))
				if org:find("Министерство обороны") then
					org = "Ministry of Defence"
					if preorg:find("Сухопутные войска") then
						fraction = "Сухопутные Войска"
						arm = 1
						mtag = "G.F."
					elseif preorg:find("Военно%-воздушные силы") then
						fraction = "Военно-Воздушные Силы"
						arm = 2
						mtag = "A.F."
					elseif preorg:find("Военно%-морской флот") then
						fraction = "Военно-Морской Флот"
						arm = 3
						mtag = "Navy"
					elseif preorg:find("Мин. обороны") then
						fraction = "Minister of Defence"
						arm = 4
						mtag = "M"
					end

					if rang ~= "—" then
						rang = all_trim(tostring(rang))
					end
					isLocalPlayerSoldier = true
					ScriptUse = 1
				else
					if preorg:find("ЛС") or preorg:find("LS") then mtag = "LS"
					elseif preorg:find("СФ") or preorg:find("SF") then mtag = "SF"
					elseif preorg:find("ЛВ") or preorg:find("LV") then mtag = "LV"
					else mtag = "-" end
					arm = 5	
					if rang ~= "—" then
						rang = all_trim(tostring(rang))
					end
					nasosal_rang = 1
					ScriptUse = 0
				end
			else
				nasosal_rang = 1
				arm = 5
				preorg = "Гражданский"
				mtag = "SA"
				rang = 0
				ScriptUse = 0
			end
			regDialogOpen = false
			return false
	end
end

function strobes() -- стробоскопы, не мои, автора не могу точно сказать, ибо эти стробоскопы то один делал, то второй, то третий, я лишь чутка их поправил
	if not isCharOnAnyBike(PLAYER_PED) and not isCharInAnyBoat(PLAYER_PED) and not isCharInAnyHeli(PLAYER_PED) and not isCharInAnyPlane(PLAYER_PED) then
		if not enableStrobes then
			enableStrobes = true
			lua_thread.create(function()
				vehptr = getCarPointer(storeCarCharIsInNoSave(PLAYER_PED)) + 1440
				while enableStrobes and isCharInAnyCar(PLAYER_PED) do
					-- 0 левая, 1 правая фары, 3 задние
					callMethod(7086336, vehptr, 2, 0, 0, 0)
					callMethod(7086336, vehptr, 2, 0, 1, 1)
					wait(150)
					callMethod(7086336, vehptr, 2, 0, 0, 1)
					callMethod(7086336, vehptr, 2, 0, 1, 0)
					wait(150)
					if not isCharInAnyCar(PLAYER_PED) then
						enableStrobes = false
						break
					end
				end
				callMethod(7086336, vehptr, 2, 0, 0, 0)
				callMethod(7086336, vehptr, 2, 0, 1, 0)
			end)
		else
			enableStrobes = false
		end
	end
end

function Skill_Up(arg) -- кач скиллов
	if #arg == 0 then
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Вы закончили прокачивание скиллов.", SCRIPTCOLOR)
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Для начала используйте {"..u8:decode(Secondcolor.v).."}/tir [мс]", SCRIPTCOLOR)
		skill = false
	else
		if not skill then
			skill = true
			lua_thread.create(function()
				sampAddChatMessage("[MoD-Helper]{FFFFFF} Вы установили задержку {"..u8:decode(Secondcolor.v).."}"..arg.." мс {FFFFFF}между выстрелами.", SCRIPTCOLOR)
				sampAddChatMessage("[MoD-Helper]{FFFFFF} Начинаем прокачку скиллов.", SCRIPTCOLOR)
				sampAddChatMessage("[MoD-Helper]{FFFFFF} Для завершения введите {"..u8:decode(Secondcolor.v).."}/tir {FFFFFF}или нажмите {"..u8:decode(Secondcolor.v).."}LCTRL", SCRIPTCOLOR)
				while skill do				
					if isCurrentCharWeapon(PLAYER_PED, 0) then
						sampAddChatMessage("[MoD-Helper]{FFFFFF} У вас нет оружия в руках.", SCRIPTCOLOR)
						sampAddChatMessage("[MoD-Helper]{FFFFFF} Вы закончили прокачивание скиллов.", SCRIPTCOLOR)
						sampAddChatMessage("[MoD-Helper]{FFFFFF} Для начала используйте {"..u8:decode(Secondcolor.v).."}/tir [мс]", SCRIPTCOLOR)
						skill = false
					else
						setGameKeyState(17, 255)
						wait(arg)
					end
				end
			end)
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Вы ввели команду второй раз.", SCRIPTCOLOR)
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Вы закончили прокачивание скиллов.", SCRIPTCOLOR)
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Для начала используйте {"..u8:decode(Secondcolor.v).."}/tir [мс]", SCRIPTCOLOR)
			skill = false
		end
	end
end

function pokaz_obnov()
	 sampShowDialog(10, "{FFCC00}Что было добавлено в этой версии?", 
	 '{'..u8:decode(Secondcolor.v)..'}{FFFFFF}Фикс определения статистики персонажа', "{FFFFFF}Закрыть", "", 0)
end

function vigovor(params)
	if isPlayerSoldier then
		if nasosal_rang <= 4 then 
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Данная команда доступна с 5 ранга.", SCRIPTCOLOR) 
			return 
		end
		if params:match("^%d+%s.*") then
			local uid, ureason = params:match("^(%d+)%s(.*)")
			if sampIsPlayerConnected(uid) then
				local uname = sampGetPlayerNickname(uid):gsub('_', ' ')
				if rtag.v == '' then
					sampSendChat(string.format("/r %s получает выговор. Причина: %s", uname, ureason))
				else
					sampSendChat(string.format("/r [%s]: %s получает выговор. Причина: %s", u8:decode(rtag.v), uname, ureason))
				end
			else
				sampAddChatMessage("[MoD-Helper]{FFFFFF} Игрок с данным ID не подключен к серверу или указан ваш ID.", SCRIPTCOLOR)
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /vig [ID] [Причина].", SCRIPTCOLOR)
		end
	end
end


function naryad(params)
	if isPlayerSoldier then
		if nasosal_rang <= 4 then 
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Данная команда доступна с 5 ранга.", SCRIPTCOLOR) 
			return 
		end
		if params:match("^%d+%s.*") then
			local uid, ureason = params:match("^(%d+)%s(.*)")
			if sampIsPlayerConnected(uid) then
				local uname = sampGetPlayerNickname(uid):gsub('_', ' ')
				if rtag.v == '' then
					sampSendChat(string.format("/r %s получает наряд. Причина: %s", uname, ureason))
				else
					sampSendChat(string.format("/r [%s]: %s получает наряд. Причина: %s", u8:decode(rtag.v), uname, ureason))
				end
			else
				sampAddChatMessage("[MoD-Helper]{FFFFFF} Игрок с данным ID не подключен к серверу или указан ваш ID.", SCRIPTCOLOR)
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /nr [ID] [Причина].", SCRIPTCOLOR)
		end
	end
end


-- подключение шрифта для работы иконок
local fa_font = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
function imgui.BeforeDrawFrame()
	if fa_font == nil then
		local font_config = imgui.ImFontConfig() -- to use 'imgui.ImFontConfig.new()' on error
		font_config.MergeMode = true
	
		fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/MoD-Helper/files/fontawesome-webfont.ttf', 14.0, font_config, fa_glyph_ranges)
	end
end

function imgui.ToggleButton(str_id, bool) -- функция хомяка

	local rBool = false
 
	if LastActiveTime == nil then
	   LastActiveTime = {}
	end
	if LastActive == nil then
	   LastActive = {}
	end
 
	local function ImSaturate(f)
	   return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
	end
  
	local p = imgui.GetCursorScreenPos()
	local draw_list = imgui.GetWindowDrawList()
 
	local height = imgui.GetTextLineHeightWithSpacing() + (imgui.GetStyle().FramePadding.y / 2)
	local width = height * 1.55
	local radius = height * 0.50
	local ANIM_SPEED = 0.15
 
	if imgui.InvisibleButton(str_id, imgui.ImVec2(width, height)) then
	   bool.v = not bool.v
	   rBool = true
	   LastActiveTime[tostring(str_id)] = os.clock()
	   LastActive[str_id] = true
	end
 
	local t = bool.v and 1.0 or 0.0
 
	if LastActive[str_id] then
	   local time = os.clock() - LastActiveTime[tostring(str_id)]
	   if time <= ANIM_SPEED then
		  local t_anim = ImSaturate(time / ANIM_SPEED)
		  t = bool.v and t_anim or 1.0 - t_anim
	   else
		  LastActive[str_id] = false
	   end
	end
 
	local col_bg
	if imgui.IsItemHovered() then
	   col_bg = imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.FrameBgHovered])
	else
	   col_bg = imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.FrameBg])
	end
 
	draw_list:AddRectFilled(p, imgui.ImVec2(p.x + width, p.y + height), col_bg, height * 0.5)
	draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius + t * (width - radius * 2.0), p.y + radius), radius - 1.5, imgui.GetColorU32(bool.v and imgui.GetStyle().Colors[imgui.Col.ButtonActive] or imgui.GetStyle().Colors[imgui.Col.Button]))
 
	return rBool
end

function join_argb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end


function imgui.OnDrawFrame()
	local tLastKeys = {} -- это у нас для клавиш
	local sw, sh = getScreenResolution() -- получаем разрешение экрана
	local btn_size = imgui.ImVec2(-0.1, 0) -- а это "шаблоны" размеров кнопок
	local btn_size2 = imgui.ImVec2(160, 0)
	local btn_size3 = imgui.ImVec2(140, 0)

	-- тут мы подстраиваем курсор под адекватность
	imgui.ShowCursor = not win_state['informer'].v and not win_state['ass'].v and not win_state['find'].v or win_state['main'].v or win_state['base'].v or win_state['update'].v or win_state['player'].v or win_state['regst'].v or win_state['renew'].v or win_state['leave'].v

	if win_state['main'].v then -- основное окошко
		
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(280, 230), imgui.Cond.FirstUseEver)
		imgui.Begin(u8' MoD-Helper by Adamson', win_state['main'], imgui.WindowFlags.NoResize)

		-- кнопка информации, визуально реализовано частично
		-- if isPlayerSoldier then if imgui.Button(fa.ICON_STAR..u8' Информация', btn_size) then print("Переход в раздел информации") win_state['info'].v = not win_state['info'].v end end
		-- кнопка настроек, готово
		
		if imgui.Button(fa.ICON_COGS..u8' Настройки', btn_size) then print("Переход в раздел настроек") win_state['settings'].v = not win_state['settings'].v end
		-- кнопка шпоры, готово
		if imgui.Button(fa.ICON_YELP..u8' Шпаргалки', btn_size) then print("Переход в раздел шпор") menu_spur.v = not menu_spur.v end
		-- лидерский раздел(госки), готово
		if imgui.Button(fa.ICON_CHILD..u8' Лидерам', btn_size) then print("Переход в раздел лидерам") win_state['leaders'].v = not win_state['leaders'].v end
		-- информация по скрипту, готово
		if imgui.Button(fa.ICON_EYE..u8' Помощь', btn_size) then print("Переход в раздел помощи") win_state['help'].v = not win_state['help'].v end
		-- о скрипте, установка обновлений, готово
		if imgui.Button(fa.ICON_COPYRIGHT..u8' О скрипте', btn_size) then print("Переход в раздел о скрипте") win_state['about'].v = not win_state['about'].v end
	
		imgui.End()
	end

	if win_state['player'].v then -- окно меню взаимодействия
		
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(380, 260), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Взаимодействие с '..MenuName..'['..MenuID..']', win_state['player'], imgui.WindowFlags.NoResize)
		
		local mname = sampGetPlayerNickname(MenuID):gsub("_", " ")
		local pcolor = sampGetPlayerColor(MenuID)
		
		if pcolor ~= 4288243251 then -- если клист не военный
			if nasosal_rang >= 9 then
				if imgui.Button(fa.ICON_PAW..u8' Принять', btn_size) then
					sampProcessChatInput("/invite "..MenuID)
					win_state['player'].v = not win_state['player'].v
				end
			end
		else
			if nasosal_rang >= 9 then
				if imgui.CollapsingHeader(fa.ICON_JSFIDDLE..u8' Действия с рангами') then
					if imgui.Button(fa.ICON_PAW..u8' Повысить игрока', btn_size) then
						sampProcessChatInput("/rang "..MenuID.." 1 +")
					end
					if imgui.Button(fa.ICON_PAW..u8' Понизить игрока', btn_size) then
						sampProcessChatInput("/rang "..MenuID.." 1 -")
					end
				end
			end
			if nasosal_rang >= 5 then
				if imgui.CollapsingHeader(fa.ICON_LINUX..u8' Выдать нашивку') then
					imgui.InputText(u8'Спец.отряд', specOtr)
					imgui.InputText(u8'Позывной', pozivnoy)
					if imgui.Button(fa.ICON_PAW..u8' Выдать', btn_size) then
						if #specOtr.v <= 3 or #pozivnoy.v <= 3 then 
							sampAddChatMessage("[MoD-Helper]{FFFFFF} Слишком короткое название спец.отряда или позывного.", SCRIPTCOLOR)
						else
							sampSendChat(string.format("/me "..(lady.v and 'достала' or 'достал').." и "..(lady.v and 'выдала' or 'выдал').." заготовленную нашивку бойца %s", mname))
							sampSendChat(string.format("/do Выдана нашивка: %s | %s | %s.", mtag,  u8:decode(specOtr.v), u8:decode(pozivnoy.v)))
							specOtr.v = ''
							pozivnoy.v = ''
						end
					end
				end

				if imgui.CollapsingHeader(fa.ICON_HEART..u8' Общий мед.осмотр') then
					if imgui.Button(fa.ICON_PAW..u8' Представиться', btn_size) then
						lua_thread.create(function()
							sampSendChat("Здравия желаю, сейчас мы проведем вам мед.осмотр.") 
							wait(2500)
							sampSendChat("Назовите ваше имя, фамилию, рост, а так же вес.") 
						end)
					end
					if imgui.Button(fa.ICON_PAW..u8' Уточнить жалобы на здоровье', btn_size) then
						lua_thread.create(function()
							sampSendChat("/todo Заполнив данные в мед.документе*Хорошо, имеются жалобы на здоровье?") 
							wait(2500)
							sampSendChat("Быть может вас что-то беспокоит, тревожит? Нам надо знать все.") 
						end)
					end
					if imgui.Button(fa.ICON_PAW..u8' Проверить глаза', btn_size) then
						lua_thread.create(function()
							sampSendChat("/todo Записав информацию*Ладно, так, нужно проверить ваши глаза.") 
							wait(2500)
							sampSendChat("Мы проверим реакцию ваших зрачков на свет, если все хорошо - продолжим осмотр.") 
							wait(2500)
							sampSendChat("В ином случае, нам придется направить вас к окулисту для дальнейшей консультации.")
							wait(4000)
							sampSendChat("/me достав фанарик из кармана, включив его и подойдя к человеку - начали проверку глаз")
							wait(1250)
							sampSendChat("/n Напиши в чат, /do Зрачки расширялись или /do Зрачки не расширялись.")
						end)
					end
					if imgui.Button(fa.ICON_PAW..u8' Зрачки реагируют', btn_size2) then
						lua_thread.create(function()
							sampSendChat("/todo Посветив фонариком в каждый глаз*Ну что же..")
							wait(2500)
							sampSendChat("Ваши зрачки реагируют на свет, это уже хорошо.") 
						end)
					end
					imgui.SameLine()
					if imgui.Button(fa.ICON_PAW..u8' Зрачки не реагируют', btn_size2) then
						lua_thread.create(function()
							sampSendChat("/todo Посветив фонариком в каждый глаз*Ну что же..")
							wait(2500)
							sampSendChat("Наблюдаю отсутствие реакции зрачков на свет, это плохо.")
							wait(2500)
							sampSendChat("Направляю вас к окулисту в городскую больницу, а пока что мед.осмотр не пройден.")
						end)
					end
					if imgui.Button(fa.ICON_PAW..u8' Попросить раздеться', btn_size) then
						lua_thread.create(function()
							sampSendChat("Так, сейчас мне необходимо проверить ваше тело на внешние признаки.") 
							wait(2500)
							sampSendChat("Пожалуйтса, разденьтесь по пояс.") 
							wait(2500)
							sampSendChat("/n Через /do отыграй, есть ли шрамы, раны и в этом духе.") 
							wait(2500)
							sampSendChat("/n Например, /do Никаких внешних признаков нет или же /do Имеются шрамы.")
							wait(2500)
							sampSendChat("/n Включи фантазию, а там видно будет") 
						end)
					end
					if imgui.Button(fa.ICON_PAW..u8' Удачный осмотр', btn_size2) then
						lua_thread.create(function()
							sampSendChat("/todo Осмотрев человека*Одевайтесь обратно.") 
							wait(2500)
							sampSendChat("В целом никаких нарушений не выявлено, осмотр пройден успешно.") 
							wait(2500)
							sampSendChat("Если все же возникнут какие то проблемы со здоровьем - обращайтесь!") 
						end)
					end
					imgui.SameLine()
					if imgui.Button(fa.ICON_PAW..u8' Неудачный осмотр', btn_size2) then
						lua_thread.create(function()
							sampSendChat("/todo Осмотрев человека*Одевайтесь обратно.") 
							wait(2500)
							sampSendChat("Ваши показания свидетельствуют о ваших проблемах с организмом.") 
							wait(2500)
							sampSendChat("Мед.комиссию вы не прошли, обратитесь к врачу и возвращайтесь после выздоравления!") 
						end)
					end
				end
				
				if imgui.CollapsingHeader(fa.ICON_QQ..u8' Благодарности') then
					if nasosal_rang >= 9 then
						if imgui.Button(fa.ICON_PAW..u8' За помощь на призыве', btn_size) then
							sampSendChat(mname.. ", благодарю вас за помощь на призыве.")				
						end
						if imgui.Button(fa.ICON_PAW..u8' За помощь на всеобщем', btn_size) then
							sampSendChat(mname.. ", благодарю вас за помощь на всеобщем повышении.")				
						end
					end
					if imgui.Button(fa.ICON_PAW..u8' За участие в тренировке', btn_size) then
						sampSendChat(mname.. ", благодарю вас за участие в тренировке.")				
					end
				end
			end
			imgui.NewLine()
			if nasosal_rang >= 8 then
				if imgui.Button(fa.ICON_RANDOM..u8' Сменить скин', btn_size) then
					sampProcessChatInput("/changeskin "..MenuID)
					win_state['player'].v = not win_state['player'].v
				end
			end
		end
		if imgui.Button(fa.ICON_REPEAT..u8' Проверить на ЧС МО', btn_size) then
			lua_thread.create(function()
				win_state['player'].v = not win_state['player'].v
				sampSendChat(mname..", сейчас мы проверим ваше наличие в черном списке Мин.Обороны.")
				wait(1500)
				sampProcessChatInput("/black "..MenuID)
			end)
		end
		if imgui.Button(fa.ICON_USER..u8' Показать автоотчет', btn_size) then
			win_state['player'].v = not win_state['player'].v
			sampSendChat("/team "..MenuID)
		end	
		imgui.End()
	end

	if win_state['info'].v then -- окно с информацией
		
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(930, 450), imgui.Cond.FirstUseEver)
        imgui.Begin(u8('Информация'), win_state['info'], imgui.WindowFlags.NoResize)
        imgui.BeginChild('left pane', imgui.ImVec2(200, 0), true)
		
		-- создание пунктов путем цикла, который берет пункты из массива(так мне говорил Igor Novikov, разраб MM Editor)
		for i = 1, #SeleList do
			if imgui.Selectable(u8(SeleList[i]),SeleListBool[i]) then selected = i end
			imgui.Separator()
		end
		
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginGroup()
		
		-- все меню каждого блока
        if selected == 1 then -- вывод статистики с базы			
			
			imgui.Text(fa.ICON_INFO..u8" Информация о вас в базе данных Ministry of Defence:\n")
			imgui.SameLine()
			showHelp(u8'Информация берется из онлайн базы данных. Любая попытка модифицировать/изменить/подделать несанкционированным путем может быть присечена ограничением доступа, вплоть до пожизненного ограничения доступа к пользованию.')
			imgui.Separator()
			
			if activated then
				imgui.Text(fa.ICON_ID_CARD..u8' Идентификатор бойца: ')
				imgui.SameLine()
				imgui.TextColored(imgui.ImVec4(0.81, 0.92 , 0.4, 1.0), superID)
			end
			
			imgui.Text(fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' Ваше имя и фамилия: ')
			imgui.SameLine()
			imgui.TextColored(imgui.ImVec4(0.81, 0.92 , 0.4, 1.0), nickName)
			
			imgui.Text(fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' Подразделение, в котором служите: ')
			imgui.SameLine()			
			imgui.TextColored(imgui.ImVec4(0.81, 0.92 , 0.4, 1.0), u8""..tostring(org).." | ".. u8""..tostring(fraction).. "[ID: "..tostring(arm).."]")
			
			imgui.Text(fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' Занимаемая должность: ')
			imgui.SameLine()
			imgui.TextColored(imgui.ImVec4(0.81, 0.92 , 0.4, 1.0), u8(tostring(rang)))
			
			imgui.Text(fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' Уровень доступа: ')
			imgui.SameLine()
			imgui.TextColored(imgui.ImVec4(0.71, 0.40 , 0.04, 1.0), accessD)
			
			imgui.Text(fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' Количество выговоров: ')
			imgui.SameLine()
			if activated then
				imgui.TextColored(imgui.ImVec4(0.81, 0.92 , 0.4, 1.0), vigcout.."".. u8"/3 выговоров")
			else
				imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), u8"Данные не получены")
			end
			
			imgui.Text(fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' Количество нарядов: ')
			imgui.SameLine()
			if activated then
				imgui.TextColored(imgui.ImVec4(0.81, 0.92 , 0.4, 1.0), narcout.."".. u8" активных нарядов")
			else
				imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), u8"Данные не получены")
			end
			
			imgui.Text(fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' Наград за воинские заслуги: ')
			imgui.SameLine()
			if activated then	
				imgui.TextColored(imgui.ImVec4(0.81, 0.92 , 0.4, 1.0), order.."".. u8" наград(-ы)")
			else
				imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), u8"Данные не получены")
			end
			
			imgui.Text(fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' Наличие в белом списке: ')
			imgui.SameLine()
			if whitelist == 0 then imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), u8"Не состоит в белом списке")
			elseif whitelist == 1 then imgui.TextColored(imgui.ImVec4(0.12, 0.70 , 0.38, 1.0), u8"Подтверждено")
			else imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), u8"Данные не получены") end
			
			imgui.TextColored(imgui.ImVec4(0.18, 0.91 , 0.87, 1.0), fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' Комментарий руководства о вас: ')
			imgui.SameLine()
			if activated then	
				imgui.TextWrapped(rAbout)
			else
				imgui.TextWrapped(u8'Боец, который всегда выполняет поставленные задачи независимо от сложности. Имеет склонность к игнорированию приказов, что ведет к неоправданным рискам при выполнении военных операций.')
			end
			
			imgui.Separator()
			if not activated then imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), fa.ICON_WARNING..u8"[ВНИМАНИЕ] Активен ограниченный режим. Часть данных недоступна, функционал скрипта ограничен.") end
			imgui.SetCursorPos(imgui.ImVec2(420, 325))
			imgui.Image(classifiedPic, imgui.ImVec2(220, 120))
		
		elseif selected == 2 then -- вывод списка МОшных лидеров	
			imgui.SetCursorPos(imgui.ImVec2(915/2, 30))
			imgui.Image(mlogo, imgui.ImVec2(180, 180))
			imgui.NewLine()
			imgui.SetCursorPos(imgui.ImVec2(490, 220))
			imgui.TextColored(imgui.ImVec4(0.18, 0.91 , 0.87, 1.0), u8'Ministry of Defence')
			--imgui.Separator()
			imgui.SetCursorPos(imgui.ImVec2(270, 242))
			imgui.Text(u8'Является исполнительной властью отдела федерального правительства Соединенных Штатов')
			imgui.SetCursorPos(imgui.ImVec2(385, 254))
			imgui.Text(u8' и поручено координировать, а так же контролировать все')
			imgui.SetCursorPos(imgui.ImVec2(340, 266))
			imgui.Text(u8' органы и функции соответствующего правительства непосредственно')
			imgui.SetCursorPos(imgui.ImVec2(400, 278))
			imgui.Text(u8' национальной безопасности Соединенных Штатов.')

			imgui.NewLine()
			imgui.SetCursorPos(imgui.ImVec2(445, 305))
			imgui.Text(u8"Министр Обороны - ")
			imgui.SameLine()
			imgui.TextColored(imgui.ImVec4(0.78, 0.18 , 0.28, 1.0), u8(getMOLeader))
			imgui.SetCursorPos(imgui.ImVec2(340, 320))
			imgui.Text(u8"Генерал US Ground Force штата "..gameServer.." - ")
			imgui.SameLine()
			imgui.TextColored(imgui.ImVec4(0.78, 0.18 , 0.28, 1.0), u8(getSVLeader))
			imgui.SetCursorPos(imgui.ImVec2(355, 335))
			imgui.Text(u8"Генерал US Air Force штата "..gameServer.." - ")
			imgui.SameLine()
			imgui.TextColored(imgui.ImVec4(0.78, 0.18 , 0.28, 1.0), u8(getVVSLeader))
			imgui.SetCursorPos(imgui.ImVec2(385, 350))
			imgui.Text(u8"Адмирал US Navy штата "..gameServer.." - ")
			imgui.SameLine()
			imgui.TextColored(imgui.ImVec4(0.78, 0.18 , 0.28, 1.0), u8(getVMFLeader))

		elseif selected == 3 then
			if dostupLvl ~= nil or developMode == 1 then
				imgui.SetCursorPos(imgui.ImVec2(915/2, 30))
				imgui.Image(pentagonPic, imgui.ImVec2(180, 180))
				imgui.TextColored(imgui.ImVec4(0.78, 0.18 , 0.28, 1.0), u8'База данных Пентагона | '..accessD..'.')
				imgui.TextColored(imgui.ImVec4(0.12, 0.70 , 0.38, 1.0), u8('Вы идентифицированы как '..nickName..', '..u8:decode(accessD)..' подтвержден.'))
				imgui.Separator()
				imgui.Text(u8'• Ввиду наличия допуска к материалам пентагона, вы можете просматривать базу данных используя свой КПК.')
				imgui.Text(u8'• Любая попытка подделки или же подача ложных данных пресекается техниками Пентагона.')
				imgui.Text(u8'• Распространение полученной информации запрещается без согласования с начальством.')
				imgui.TextWrapped(u8'• Если вы фиксируете наличие заведомо ложной информации или же расцениваете ее некорректной - сообщите техникам, дабы исправить недочеты.')
				imgui.TextColored(imgui.ImVec4(0.81, 0.92 , 0.4, 1.0), u8("КПК доступен по /base."))
			else
				imgui.SetCursorPos(imgui.ImVec2(915/2, 30))
				imgui.Image(accessDeniedPic, imgui.ImVec2(180, 180))
				imgui.TextColored(imgui.ImVec4(0.78, 0.18 , 0.28, 1.0), u8'Доступ запрещен.')
				imgui.TextWrapped(u8'Нами зафиксирована и пресечена попытка получить несанционированный доступ к пользовательской информации закрытых баз данных Пентагона. Санкционируйте доступ у уполномоченных лиц.')
			end
		end
		
		if selected ~= 0 then
			clearSeleListBool(selected) 
		end
        imgui.EndGroup()
        imgui.End()
	end

	if win_state['settings'].v then -- окно с настройками
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(850, 400), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Настройки', win_state['settings'], imgui.WindowFlags.NoResize + imgui.WindowFlags.MenuBar)
		if imgui.BeginMenuBar() then -- меню бар, используется в виде выпадающего списка, ибо горизонтальный с ума сходит и мерцает при клике по одному из пунктов
			if imgui.BeginMenu(fa.ICON_PAW..u8(" Навигация по настройкам")) then
				if developMode == 1 then
					if imgui.MenuItem(fa.ICON_CONNECTDEVELOP..u8" Меню разработчика") then
						showSet = 1
					end
				end
				if imgui.MenuItem(fa.ICON_BARS..u8(" Основное")) then
					showSet = 2
					print("Настройки: Основное")
				elseif imgui.MenuItem(fa.ICON_KEYBOARD_O..u8(" Клавиши")) then
					showSet = 3
					print("Настройки: Клавиши")
				--[[elseif imgui.MenuItem(fa.ICON_VK..u8(" int.")) then
					showSet = 4
					print("Настройки: VK Int")]]--
				elseif imgui.MenuItem(fa.ICON_INDENT..u8(" Биндер")) then
					showSet = 5
					print("Настройки: Биндер")
				elseif imgui.MenuItem(fa.ICON_USERS..u8(" Семья")) then
					showSet = 7
					print("Настройки: Семья")
				elseif imgui.MenuItem(fa.ICON_THUMBS_O_UP..u8("  Стили")) then
					showSet = 8
					print("Настройки: Стили")
				end
				-- if assistant.v and developMode == 1 and isPlayerSoldier then
				-- 	if imgui.MenuItem(fa.ICON_ANCHOR..u8(" Координатор")) then
				-- 		showSet = 6
				-- 		print("Настройки: Координатор")
				-- 	end
				-- end
				imgui.EndMenu()
			end
			imgui.EndMenuBar()
		end
		if showSet == 1 then -- что-то типо закрытого меню с красивым названием, но ничего кроме смены стилей тут нет.
			if developMode == 1 then
				if imgui.CollapsingHeader(u8("Редактор стилей")) then
					imgui.ShowStyleEditor()
				end
				if imgui.Button(u8("Стиль #1(default new)"), btn_size) then apply_custom_style() end
				if imgui.Button(u8("Стиль #2(old dark)"), btn_size) then new_style() end
			else
				showSet = 2
			end
		elseif showSet == 2 then -- общие настройки
			if imgui.CollapsingHeader(fa.ICON_COMMENTING..u8' Рация') then
				imgui.InputText(u8'Тэг в рацию подразделения (/r)', rtag)
				imgui.InputText(u8'Тэг в общую рацию (/f)', ftag)
				--[[if isPlayerSoldier then 
					imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_TUMBLR_SQUARE..u8(" Автотэг")); imgui.SameLine(); imgui.ToggleButton(u8"Автотэг", enable_tag)
					imgui.SameLine()
					showHelp(u8'При отправке сообщений в /f чат - сработает подстановка тэга, который укажет организацию и указанный вами тэг.\nОпределение организаций:\nGF(Ground Force) - Сухопутные Войска\nAF(AirForce) - Военно-Воздушные Силы\nN(Navy) - Военно-Морской Флот\nДля Министра Обороны системный тэг не устанавливается.')
				end]]--
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_FIRE..u8(" Таймскрин при докладе")); imgui.SameLine(); imgui.ToggleButton(u8"Таймскрин при докладе", screenSave)
				imgui.SameLine()
				showHelp(u8'При отправке доклада в /rd и /fd будет пробиваться время + автоматически сделается скриншот.')
			end

			if imgui.CollapsingHeader(fa.ICON_HAND_PEACE_O..u8' Приветствие') then
				imgui.PushItemWidth(300)
				imgui.InputText(u8'Фраза приветствия военнослужащего при ПКМ + 1', textprivet)
				imgui.Text(u8'Вы будете произносить: Выполнив воинское приветствие, '..userNick..u8' сказал: '..textprivet.v..u8' Фамилия!')
				imgui.Separator()
				imgui.PushItemWidth(300)
				imgui.InputText(u8'Фраза приветствия остальных при ПКМ + 1', textpriv)
				imgui.Text(u8'Вы будете произносить: Поприветствовав человека напротив, '..userNick..u8' сказал: '..textpriv.v..'!')
			end
		
			if imgui.CollapsingHeader(fa.ICON_ENVIRA..u8' Часы(/c 60)') then
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_CLOCK_O..u8(" Отыгровка часов")); imgui.SameLine(); imgui.ToggleButton(u8'Отыгровка часов', rptime)
				if rptime.v then
					imgui.SameLine()
					showHelp(u8"Если включена отыгровка часов, но гравировка пустая - отыгровка будет стандартной.\nЕсли поле гравировки заполнено, будет отыгровка в виде:\n/me посмотрел на часы с гравировкой «Текст»")
					imgui.InputText(u8'Гравировка', timerp)
					imgui.InputText(u8'Бренд', timeBrand)
				else
					imgui.SameLine()
					showHelp(u8"Если включена отыгровка часов, но гравировка пустая - отыгровка будет стандартной.\nЕсли поле гравировки заполнено, будет отыгровка в виде:\n/me посмотрел на часы с гравировкой «Текст»")
				end
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_FLAG..u8(" Чистый онлайн")); imgui.SameLine(); imgui.ToggleButton(u8'Чистый онлайн', timecout)
				imgui.SameLine()
				showHelp(u8'Будет подсчитывать чистый онлайн за сегодняшний день и выводить информацию в чат.')
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_CROP..u8(" Показывать время до ЗП")); imgui.SameLine(); imgui.ToggleButton(u8'Показывать время до ЗП', timeToZp)
			end	
			if imgui.CollapsingHeader(fa.ICON_HEADER..u8' Разные отыгровки') then
				imgui.BeginChild('##asdasasdf', imgui.ImVec2(750, 150), false)
				imgui.Columns(2, _, false)
				if isPlayerSoldier then
					imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Спец.отряд в /ud")); imgui.SameLine(); imgui.ToggleButton(u8'Спец.отряд в /ud', specUd)
					if specUd.v then
						imgui.InputText(u8'Спец.отряд', spOtr)
					end
					imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отыгровка /find")); imgui.SameLine(); imgui.ToggleButton(u8'Отыгровка /find', rpFind)
					imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отыгровка /gate")); imgui.SameLine(); imgui.ToggleButton(u8'Отыгровка /gate', gateOn)
					imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отыгровка чекера на ЧС")); imgui.SameLine(); imgui.ToggleButton(u8'Отыгровка чекера ЧС', rpblack)
				end
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отыгровка /lock 1")); imgui.SameLine(); imgui.ToggleButton(u8'Отыгровка /lock 1', lockCar)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отыгровка входящего СМС")); imgui.SameLine(); imgui.ToggleButton(u8'Отыгровка входящего СМС', inComingSMS)
				if inComingSMS.v then
					imgui.InputText(u8'Модель телефона', phoneModel)
				end
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отыгровка броника")); imgui.SameLine(); imgui.ToggleButton(u8'Отыгровка броника', armOn)
				imgui.NextColumn()
					if isPlayerSoldier then
						imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отыгровка /uninvite")); imgui.SameLine(); imgui.ToggleButton(u8'Отыгровка /uninvite', rpuninv)
						imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отыгровка смены скина")); imgui.SameLine(); imgui.ToggleButton(u8'Отыгровка смены скина', rpskin)
						imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отыгровка /invite")); imgui.SameLine(); imgui.ToggleButton(u8'Отыгровка /invite', rpinv)
						imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отыгровка выдачи ранга")); imgui.SameLine(); imgui.ToggleButton(u8'Отыгровка выдачи ранга', rprang)				
						imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отыгровка /uninviteoff")); imgui.SameLine(); imgui.ToggleButton(u8'Отыгровка /uninviteoff', rpuninvoff)
					end
				imgui.EndChild()
			end
			if imgui.CollapsingHeader(fa.ICON_GIFT..u8' Модификации') then
				imgui.BeginChild('##as2dasasdf', imgui.ImVec2(750, 130), false)
				imgui.Columns(2, _, false)
				
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ChatInfo")); imgui.SameLine(); imgui.ToggleButton(u8'ChatInfo', chatInfo)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Гангзоны МО")); imgui.SameLine(); imgui.ToggleButton(u8'Гангзоны МО', gangzones)
				imgui.SameLine()
				showHelp(u8'Отображение территорий Мин.Обороны по типу гангзон. Все гангзоны кроме авика багаются на миникарте, причина неизвестна.')
				
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Женский пол")); imgui.SameLine(); imgui.ToggleButton(u8'Женский пол', lady)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Анти-казино")); imgui.SameLine(); imgui.ToggleButton(u8'Анти-казино', casinoBlock)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Маркер игрока")); imgui.SameLine(); imgui.ToggleButton(u8'Маркер игрока', marker)
				--imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(' Открытие меню на Х')); imgui.SameLine(); imgui.ToggleButton(u8'Открытие меню на Х', MeNuNaX)
				imgui.NextColumn()
				-- if isPlayerSoldier then
				-- 	imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Координатор")); imgui.SameLine(); imgui.ToggleButton(u8'Координатор', assistant)
				-- end
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Чат на клавишу Т")); imgui.SameLine(); imgui.ToggleButton(u8'Чат на клавишу T', keyT)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отключение объявлений")); imgui.SameLine(); imgui.ToggleButton(u8'Отключение объявлений', ads)
				imgui.SameLine()
				showHelp(u8'Все объявления /ad из чата будут переходить в консоль SF, которая открывается на клавишу ~.')
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Звук входяшего СМС")); imgui.SameLine(); imgui.ToggleButton(u8'Звук входящего СМС', smssound)
				imgui.SameLine()
				showHelp(u8'При каждом входящем СМС будет проигрывать звук, который расположен в MoD-Helper/audio/sms.mp3. Вы можете выбрать любой другой звук, для этого скачайте его и замените и переименуйте в "sms", формат обязательно должен быть mp3.')
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Стробоскопы")); imgui.SameLine(); imgui.ToggleButton(u8'Стробоскопы', strobesOn)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" FPSunlock")); imgui.SameLine(); imgui.ToggleButton(u8'FPSunlock', FPSunlock)
				--imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(' Ответ в рацию на "Здравия желаю"')); imgui.SameLine(); imgui.ToggleButton(u8'Ответ в рацию на "Здравия желаю"', Zdravia)
				--imgui.SameLine()
				--showHelp(u8'Если в рации подразделения кто-либо скажет "Здравия желаю", то Вы автоматически ответите: "Здравия желаю, товарищ Фамилия!"')
				--imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(' FPS unlock')); imgui.SameLine(); imgui.ToggleButton(u8'FPS unlock', Fixtune)
				--imgui.SameLine()
				--showHelp(u8'Если вы хоть раз катались на ФТ автомобиле, вы могли заметить, что ускорение авто очень неприятно работает. Включив этот пункт, тюнинг станет немного адекватней. Спасибо Михаилу Трефилову за открытый код данного фикса.')
				imgui.EndChild()
			end
			if imgui.CollapsingHeader(fa.ICON_GAMEPAD..u8' Информер MoD-Helper') then
				imgui.BeginChild('##25252', imgui.ImVec2(750, 130), false)
				imgui.Columns(2, _, false)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Включить информер")); imgui.SameLine(); imgui.ToggleButton(u8'Включить информер', zones)
				if zones.v then
					imgui.SameLine()
					if imgui.Button(u8'Переместить') then 
						sampAddChatMessage("[MoD-Helper]{FFFFFF} Выберите позицию и нажмите {"..u8:decode(Secondcolor.v).."}Enter{FFFFFF} чтобы сохранить ее.", SCRIPTCOLOR)
						win_state['settings'].v = not win_state['settings'].v 
						win_state['main'].v = not win_state['main'].v 
						mouseCoord = true 
					end
				end
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Таймер маски")); imgui.SameLine(); imgui.ToggleButton(u8'Таймер маски', infMask)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отображение военной зоны")); imgui.SameLine(); imgui.ToggleButton(u8'Отображение военной зоны', infZone)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отображение брони")); imgui.SameLine(); imgui.ToggleButton(u8'Отображение брони', infArmour)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отображение здоровья")); imgui.SameLine(); imgui.ToggleButton(u8'Отображение здоровья', infHP)
				imgui.NextColumn()
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отображение города")); imgui.SameLine(); imgui.ToggleButton(u8'Отображение города', infCity)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отображение района")); imgui.SameLine(); imgui.ToggleButton(u8'Отображение района', infRajon)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отображение квадрата")); imgui.SameLine(); imgui.ToggleButton(u8'Отображение квадрата', infKv)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Отображение времени")); imgui.SameLine(); imgui.ToggleButton(u8'Отображение времени', infTime)
				imgui.EndChild()
			end
			if imgui.CollapsingHeader(fa.ICON_UNIVERSAL_ACCESS..u8' Авторизация') then
				imgui.BeginChild('##asdasasddf', imgui.ImVec2(750, 60), false)
				imgui.Columns(2, _, false)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Автологин")); imgui.SameLine(); imgui.ToggleButton(u8("Автологин"), autologin)
				if autologin.v then
					imgui.InputText(u8'Пароль', autopass)
				end
				imgui.NextColumn()
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Автогугл")); imgui.SameLine(); imgui.ToggleButton(u8("Автогугл"), autogoogle)
				imgui.SameLine()
				showHelp(u8"При привязки гугл-защиты система вам выдавала ключ, который необходимо сохранить. Введите данный ключ без пробелов и лишних знаков, после чего авторизация будет проходить автоматически.")
				if autogoogle.v then
					imgui.InputText(u8'Секретный код', googlekey)
				end
				imgui.EndChild()
			end
			if imgui.CollapsingHeader(fa.ICON_DRUPAL..u8' Таймцикл') then
				if weather.v == -1 then weather.v = readMemory(0xC81320, 1, true) end
				if gametime.v == -1 then gametime.v = readMemory(0xB70153, 1, true) end
				imgui.SliderInt(u8"ID погоды", weather, 0, 50)
				imgui.SliderInt(u8"Игровой час", gametime, 0, 23)
			end
			if imgui.CollapsingHeader(fa.ICON_PAW..u8' Прочие настройки') then
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" Визуальный скин")); imgui.SameLine(); imgui.ToggleButton(u8("Визуальный скин"), enableskin)
				if enableskin.v then
					imgui.InputInt("##229", localskin, 0, 0)
					imgui.SameLine()
					if imgui.Button(u8("Применить")) then
						if localskin.v <= 0 or localskin.v == 74 or localskin.v == 53 then
							localskin.v = 1
						end
						changeSkin(-1, localskin.v)
					end
				end
				imgui.InputText(fa.ICON_PAW..u8' Ссылка для чекера', blackcheckerpath)
				imgui.SliderInt(fa.ICON_PAW..u8" Коррекция времени", timefix, 0, 5)
			end
			

			if state and isPlayerSoldier then
				if imgui.Button(fa.ICON_ELLIPSIS_H..u8' Переместить АвтоСтрой', btn_size) then 
					sampAddChatMessage("[MoD-Helper]{FFFFFF} Выберите позицию и нажмите {"..u8:decode(Secondcolor.v).."}Enter{FFFFFF} чтобы сохранить ее.", SCRIPTCOLOR)
					win_state['settings'].v = not win_state['settings'].v 
					win_state['main'].v = not win_state['main'].v 
					mouseCoord2 = true 
				end
			end
		elseif showSet == 3 then -- настройки клавиш
			imgui.Columns(2, _, false)
			for k, v in ipairs(tBindList) do
				--[[if isPlayerSoldier then -- выводим клавиши для военного
					if hk.HotKey("##HK" .. k, v, tLastKeys, 100) then
						if not rkeys.isHotKeyDefined(v.v) then
							if rkeys.isHotKeyDefined(tLastKeys.v) then
								rkeys.unRegisterHotKey(tLastKeys.v)
							end
						end
						rkeys.registerHotKey(v.v, true, onHotKey)
						saveSettings(3, "KEY")
					end
					imgui.SameLine()
					imgui.Text(u8(v.text))
				else]]-- -- выводим клавиши для обычной печеньки
					if k ~= 2 and k ~= 8 and k ~= 9 and k ~= 10 then
						if hk.HotKey("##HK" .. k, v, tLastKeys, 100) then
							if not rkeys.isHotKeyDefined(v.v) then
								if rkeys.isHotKeyDefined(tLastKeys.v) then
									rkeys.unRegisterHotKey(tLastKeys.v)
								end
							end
							rkeys.registerHotKey(v.v, true, onHotKey)
							saveSettings(3, "KEY")
						end
						imgui.SameLine()
						imgui.Text(u8(v.text))
					end
				--end
				if k >= 10 and imgui.GetColumnIndex() ~= 1 then imgui.NextColumn() end
			end
		elseif showSet == 4 then -- настройки VK Int.
			if token ~= 1 and vkid2 ~= nil then
				imgui.Columns(2, _, false)
				imgui.Text(u8("Ваш ID ВК: "..tostring((vkid2 == nil and 'N/A' or vkid2))))
				imgui.Text(u8("Статус АФК: "))
				imgui.SameLine()
				if workpause then
					imgui.TextColored(imgui.ImVec4(0.12, 0.70 , 0.38, 1.0), u8"Активно")
				else
					imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), u8"Отключено.")
				end
				imgui.SameLine()
				showHelp(u8("Перед тем, как сворачивать игру, если вы хотите, чтобы скрипт работал корректно - вам необходимо активировать статус АФК клавишей VK int, которую вы назначите в настройках. Если вы уйдете в АФК, но не активируете модуль - скрипт выполнит все действия только после выхода из АФК, связано это с тем, что скрипт не могут работать в АФК режиме без включения данного 'рычага'. В момент, пока активен данный режим - чат из игры заблокирован."))
				imgui.Text(u8("Функции не будут работать, если VK Int в статусе - 'Отключено'."))	
				imgui.NewLine()
				imgui.TextWrapped(u8("На некоторых серверах могут возникнуть споры касательно определенных функций, тем не менее, VK Int не дает никакого преимущества игрокам, ибо:"))
				imgui.Text(u8("- Оповещение о ЗП равносильно будильнику."))
				imgui.TextWrapped(u8("- Детект ника всего лишь информирует в основном о выданных наказаниях."))
				imgui.TextWrapped(u8("- Удаленный режим позволяет читать чат, что по факту запретить невозможно."))
					
				imgui.NextColumn()
				imgui.AlignTextToFramePadding(); imgui.Text(u8("Оповещать перед ЗП")); imgui.SameLine(); imgui.ToggleButton(u8'Оповещать перед ЗП', zp)
				imgui.SameLine()
				showHelp(u8("Оповестит сообщением в ВК перед ЗП за 10, 5, 1 минуту, 30 секунд до зарплаты."))
				imgui.AlignTextToFramePadding(); imgui.Text(u8("Детект вашего ника")); imgui.SameLine(); imgui.ToggleButton(u8'Детект вашего ника', nickdetect)
				imgui.SameLine()
				showHelp(u8("Если в чате появится ваш ник в формате Nick_Name - придет оповещение и строка, в которой вас определило."))
				imgui.AlignTextToFramePadding(); imgui.Text(u8("Получать информацию об SMS")); imgui.SameLine(); imgui.ToggleButton(u8'Получать информацию об SMS', smsinfo)
				imgui.SameLine()
				showHelp(u8("Если вам придет СМС или вы его отправите - вам напишет об этом в ВК. Полезно, если отправляете СМС из диалога."))
				imgui.AlignTextToFramePadding(); imgui.Text(u8("Получать сообщения из /r, /f")); imgui.SameLine(); imgui.ToggleButton(u8'Получать сообщения из /r, /f', getradio)
				imgui.SameLine()
				showHelp(u8("Отправляет все сообщения из раций, если включена данная опция."))
				imgui.AlignTextToFramePadding(); imgui.Text(u8("Получать сообщения из /g")); imgui.SameLine(); imgui.ToggleButton(u8'Получать сообщения из /g', familychat)
				imgui.SameLine()
				showHelp(u8("Отправляет все сообщения из чата семьи/группы."))
				imgui.AlignTextToFramePadding(); imgui.Text(u8("Удаленный режим")); imgui.SameLine(); imgui.ToggleButton(u8'Удаленный режим', remotev)
				imgui.SameLine()
				showHelp(u8("Позволяет отправлять команды /f(n), /r(n), /sms из личного диалога с сообществом в ВК, который привязан к аккаунту."))
			else
				imgui.Text(u8("К сожалению, функция VK Int. временно недоступна. Попробуйте перезагрузить скрипт или попробовать позже."))
			end
		elseif showSet == 5 then -- меню биндера
			imgui.Columns(4, _, false)
			imgui.NextColumn()
			imgui.NextColumn()
			imgui.NextColumn()
			for k, v in ipairs(mass_bind) do -- выводим все бинды
				imgui.NextColumn()
				if hk.HotKey("##ID" .. k, v, tLastKeys, 100) then -- выводим окошко, куда будем тыкать, чтобы назначить клавишу
					if not rkeys.isHotKeyDefined(v.v) then
						if rkeys.isHotKeyDefined(tLastKeys.v) then
							rkeys.unRegisterHotKey(tLastKeys.v)
						end
					end
					rkeys.registerHotKey(v.v, true, onHotKey)
					saveSettings(3, "KEY") -- сохраняем настройки
				end
				imgui.NextColumn()
				if v.cmd ~= "-" then -- условие вывода текста
					imgui.Text(u8("Команда: /"..v.cmd))
				else
					imgui.Text(u8("Команда не назначена"))
				end
				imgui.NextColumn()
				if imgui.Button(fa.ICON_CC..u8(" Редактировать бинд ##"..k)) then imgui.OpenPopup(u8"Установка клавиши ##modal"..k) end
				if k ~= 0 then
					imgui.NextColumn()
					if imgui.Button(fa.ICON_SLIDESHARE..u8(" Удалить бинд ##"..k)) then
						if v.cmd ~= "-" then sampUnregisterChatCommand(v.cmd) print("Разрегистрирована команда /"..v.cmd) end
						if rkeys.isHotKeyDefined(tLastKeys.v) then rkeys.unRegisterHotKey(tLastKeys.v) end
						table.remove(mass_bind, k)
						saveSettings(3, "DROP BIND")
					end
				end
				
				if imgui.BeginPopupModal(u8"Установка клавиши ##modal"..k, _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
					if imgui.Button(fa.ICON_ODNOKLASSNIKI..u8(' Сменить/Назначить команду'), imgui.ImVec2(200, 0)) then
						imgui.OpenPopup(u8"Команда - /"..v.cmd)
					end
					if imgui.Button(fa.ICON_REBEL..u8(' Редактировать содержимое'), imgui.ImVec2(200, 0)) then
						cmd_text.v = u8(v.text):gsub("~", "\n")
						binddelay.v = v.delay
						imgui.OpenPopup(u8'Редактор текста ##second'..k)
					end

					if imgui.BeginPopupModal(u8"Команда - /"..v.cmd, _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize) then
						imgui.Text(u8"Введите название команды, которую хотите применить к бинду, указывайте без '/':")						
						imgui.Text(u8"Чтобы удалить комманду, введите прочерк и сохраните.")						
						imgui.InputText("##FUCKITTIKCUF_1", cmd_name)

						if imgui.Button(fa.ICON_SIGN_LANGUAGE..u8" Сохранить", imgui.ImVec2(100, 0)) then
							v.cmd = u8:decode(cmd_name.v)

							if u8:decode(cmd_name.v) ~= "-" then
								rcmd(v.cmd, v.text, v.delay)
								print("Зарегистрирована команда /"..v.cmd)
								cmd_name.v = ""
							end
							saveSettings(3, "CMD "..v.cmd)
							imgui.CloseCurrentPopup()
						end
						imgui.SameLine()
						if imgui.Button(fa.ICON_SLACK..u8" Закрыть") then
							cmd_name.v = ""
							imgui.CloseCurrentPopup()
						end
						imgui.EndPopup()
					end

					if imgui.BeginPopupModal(u8'Редактор текста ##second'..k, _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize) then
						imgui.BeginChild('##sdaadasdd', imgui.ImVec2(1100, 600), true)
						imgui.Columns(2, _, false)
						--[[imgui.InputInt(u8("Задержка строк(сек.)"), binddelay)
						if binddelay.v <= 0 then
							binddelay.v = 1
						elseif binddelay.v >= 1801 then
							binddelay.v = 1800
						end
						imgui.SameLine()
						showHelp(u8("600 секунд - 10 минут\n1200 секунд - 20 минут\n1800 секунд - 30 минут"))]]--
						imgui.TextWrapped(u8("Параметр {bwait:time} обязателен после каждой строки. Задержка автоматически не выставляется."))
						imgui.TextWrapped(u8"Редактор текста биндера(локальные команды не работают при вызове биндером):")
						imgui.InputTextMultiline('##FUCKITTIKCUF_2', cmd_text, imgui.ImVec2(550, 300))
						
						imgui.Text(u8("Результат:"))
						local example = tags(u8:decode(cmd_text.v))
						imgui.Text(u8(example))
						imgui.NextColumn()
						imgui.BeginChild('##sdaadddasdd', imgui.ImVec2(525, 480), true)
						imgui.TextColoredRGB('• {bwait:1500} {21BDBF}- задержка между строк - {fff555}ОБЯЗАТЕЛЬНЫЙ ПАРАМЕТР')
						imgui.Separator()
						
						imgui.TextColoredRGB('• {params} {21BDBF}- параметр команды - {fff555}/'..v.cmd..' [параметр]')
						imgui.TextColoredRGB('• {paramNickByID} {21BDBF}- цифровой параметр, получаем ник по ID.')
						imgui.TextColoredRGB('• {paramFullNameByID} {21BDBF}- цифровой параметр, получаем РП ник по ID.')
						imgui.TextColoredRGB('• {paramNameByID} {21BDBF}- цифровой параметр, получаем имя по ID.')
						imgui.TextColoredRGB('• {paramSurnameByID} {21BDBF}- цифровой параметр, получаем фамилию по ID.')

						if imgui.CollapsingHeader(u8'Для двух параметров') then
							imgui.TextColoredRGB('• {fff555}/'..v.cmd..' [параметр 1 | параметр 2] ("|" - обязательно)')
							imgui.Separator()
							imgui.TextColoredRGB('• {par1} {21BDBF}- первый параметр команды.')
							imgui.TextColoredRGB('• {NickByIDpar1} {21BDBF}- первый цифровой параметр, получаем ник по ID.')
							imgui.TextColoredRGB('• {FullNameByIDpar1} {21BDBF}- первый цифровой параметр, получаем РП ник по ID.')
							imgui.TextColoredRGB('• {NameByIDpar1} {21BDBF}- первый цифровой параметр, получаем имя по ID.')
							imgui.TextColoredRGB('• {SurnameByIDpar1} {21BDBF}- первый цифровой параметр, получаем фамилию по ID.')
							imgui.Separator()
							imgui.TextColoredRGB('• {par2} {21BDBF}- второй параметр команды.')
							imgui.TextColoredRGB('• {NickByIDpar2} {21BDBF}- второй цифровой параметр, получаем ник по ID.')
							imgui.TextColoredRGB('• {FullNameByIDpar2} {21BDBF}- второй цифровой параметр, получаем РП ник по ID.')
							imgui.TextColoredRGB('• {NameByIDpar2} {21BDBF}- второй цифровой параметр, получаем имя по ID.')
							imgui.TextColoredRGB('• {SurnameByIDpar2} {21BDBF}- второй цифровой параметр, получаем фамилию по ID.')
						end

						imgui.Separator()
						imgui.TextColoredRGB('• {mynick} {21BDBF}- ваш полный ник - {fff555}'..tostring(userNick))
						imgui.TextColoredRGB('• {myfname} {21BDBF}- ваш РП ник - {fff555}'..tostring(nickName))
						imgui.TextColoredRGB('• {myname} {21BDBF}- ваше имя - {fff555}'..tostring(userNick:gsub("_.*", "")))
						imgui.TextColoredRGB('• {mysurname} {21BDBF}- ваша фамилия - {fff555}'..tostring(userNick:gsub(".*_", "")))
						imgui.TextColoredRGB('• {myid} {21BDBF}- ваш ID - {fff555}'..tostring(myID))
						imgui.TextColoredRGB('• {myhp} {21BDBF}- ваш уровень HP - {fff555}'..tostring(healNew))
						imgui.TextColoredRGB('• {myarm} {21BDBF}- ваш уровень брони - {fff555}'..tostring(armourNew))
						imgui.Separator()
						imgui.TextColoredRGB('• {arm} {21BDBF}- ваша армия - {fff555}'..tostring(fraction))
						imgui.TextColoredRGB('• {org} {21BDBF}- ваша организация - {fff555}'..tostring(org))
						imgui.TextColoredRGB('• {mtag} {21BDBF}- тэг организации - {fff555}'..tostring(mtag))
						imgui.TextColoredRGB('• {rtag} {21BDBF}- ваш тэг в /r - {fff555}'..tostring(u8:decode(rtag.v)))
						imgui.TextColoredRGB('• {ftag} {21BDBF}- ваш тэг в /f - {fff555}'..tostring(u8:decode(ftag.v)))
						imgui.TextColoredRGB('• {myrang} {21BDBF}- ваша должность - {fff555}'..tostring(rang))
						imgui.TextColoredRGB('• {steam} {21BDBF}- ваш спец.отряд(должно быть включено в настройках) - {fff555}'..tostring(u8:decode(spOtr.v)))
						imgui.Separator()
						imgui.TextColoredRGB('• {city} {21BDBF}- город, в котором находитесь - {fff555}'..tostring(playerCity))
						imgui.TextColoredRGB('• {base} {21BDBF}- определение военной зоны - {fff555}'..tostring(ZoneText))
						imgui.TextColoredRGB('• {kvadrat} {21BDBF}- определение квадрата - {fff555}'..tostring(locationPos()))
						imgui.TextColoredRGB('• {zone} {21BDBF}- определение района - {fff555}'..tostring(ZoneInGame))
						imgui.TextColoredRGB('• {time} {21BDBF}- МСК время - {fff555}'..string.format(os.date('%H:%M:%S', moscow_time)))
						imgui.Separator()
						if newmark ~= nil then
							imgui.TextColoredRGB('• {targetnick} {21BDBF}- полный ник игрока по таргету - {fff555}'..tostring(sampGetPlayerNickname(blipID)))
							imgui.TextColoredRGB('• {targetfname} {21BDBF}- РП ник игрока по таргету - {fff555}'..tostring(sampGetPlayerNickname(blipID):gsub("_", " ")))
							imgui.TextColoredRGB('• {tID} {21BDBF}- ID игрока по таргету - {fff555}'..tostring(blipID))
							imgui.TextColoredRGB('• {targetname} {21BDBF}- имя игрока по таргету - {fff555}'..tostring(sampGetPlayerNickname(blipID):gsub("_.*", "")))
							imgui.TextColoredRGB('• {targetsurname} {21BDBF}- фамилия игрока по таргету - {fff555}'..tostring(sampGetPlayerNickname(blipID):gsub(".*_", "")))
						else
							imgui.TextColoredRGB('• {targetnick} {21BDBF}- полный ник игрока по таргету')
							imgui.TextColoredRGB('• {targetfname} {21BDBF}- РП ник игрока по таргету')
							imgui.TextColoredRGB('• {tID} {21BDBF}- ID игрока по таргету')
							imgui.TextColoredRGB('• {targetname} {21BDBF}- имя игрока по таргету')
							imgui.TextColoredRGB('• {targetsurname} {21BDBF}- фамилия игрока по таргету')
						end
						imgui.Separator()
						imgui.TextColoredRGB('• {fid} {21BDBF}- последний ID из /f чата  - {fff555}'..tostring(lastfradioID))
						imgui.TextColoredRGB('• {fidrang} {21BDBF}- звание последнего в /f - {fff555}'..tostring(lastfradiozv))
						imgui.TextColoredRGB('• {fidnick} {21BDBF}- ник последнего в /f - {fff555}'..tostring(sampGetPlayerNickname(lastfradioID)))
						imgui.TextColoredRGB('• {finfname} {21BDBF}- РП имя последнего в /f - {fff555}'..tostring(sampGetPlayerNickname(lastfradioID):gsub("_", " ")))
						imgui.TextColoredRGB('• {fidname} {21BDBF}- имя последнего в /f - {fff555}'..tostring(sampGetPlayerNickname(lastfradioID):gsub("_.*", " ")))
						imgui.TextColoredRGB('• {fidsurname} {21BDBF}- фамилия последнего в /f - {fff555}'..tostring(sampGetPlayerNickname(lastfradioID):gsub(".*_", " ")))
						imgui.Separator()
						imgui.TextColoredRGB('• {rid} {21BDBF}- последний ID из /r чата - {fff555}'..tostring(lastrradioID))
						imgui.TextColoredRGB('• {ridrang} {21BDBF}- звание последнего в /r - {fff555}'..tostring(lastrradiozv))
						imgui.TextColoredRGB('• {ridnick} {21BDBF}- ник последнего в /r - {fff555}'..tostring(sampGetPlayerNickname(lastrradioID)))
						imgui.TextColoredRGB('• {ridfname} {21BDBF}- РП имя последнего в /r - {fff555}'..tostring(sampGetPlayerNickname(lastrradioID):gsub("_", " ")))
						imgui.TextColoredRGB('• {ridname} {21BDBF}- имя последнего в /r - {fff555}'..tostring(sampGetPlayerNickname(lastrradioID):gsub("_.*", " ")))
						imgui.TextColoredRGB('• {ridsurname} {21BDBF}- фамилия последнего в /r - {fff555}'..tostring(sampGetPlayerNickname(lastrradioID):gsub(".*_", " ")))

						
						imgui.EndChild()
						imgui.NewLine()
						if imgui.Button(fa.ICON_SIGN_LANGUAGE..u8" Сохранить", btn_size) then

							v.text = u8:decode(cmd_text.v):gsub("\n", '~')
							v.delay = binddelay.v
							if v.cmd ~= nil then
								rcmd(v.cmd, v.text, v.delay)
							else
								rcmd(nil, v.text, v.delay)
							end
							saveSettings(3, "BIND TEXT")
							imgui.CloseCurrentPopup()
						end

						if imgui.Button(fa.ICON_SLACK..u8" Закрыть не сохраняя", btn_size) then
							imgui.CloseCurrentPopup()
						end
						imgui.EndChild()
						imgui.EndPopup()
					end

					if imgui.Button(fa.ICON_SLACK..u8" Закрыть", imgui.ImVec2(200, 0)) then
						imgui.CloseCurrentPopup()
					end
					imgui.EndPopup()
				end
			end
			
			imgui.NextColumn()
			imgui.NewLine()
			if imgui.Button(fa.ICON_WHEELCHAIR..u8(" Добавить бинд")) then mass_bind[#mass_bind + 1] = {delay = "3", v = {}, text = "n/a", cmd = "-"} end	
		elseif showSet == 7 then			
				imgui.SetCursorPosX(300)
				imgui.Text(u8"Настройки для семьи (by DIPIRIDAMOLE).")
				imgui.Separator()
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_APPLE..u8(" Смена цвета ников в чате")); imgui.SameLine(); imgui.ToggleButton(u8("Смена цвета ников в чате"), ColorFama)
				imgui.PushItemWidth(200)	
				if imgui.ColorEdit3("", colorf) then
					colornikifama = tostring(('%06X'):format((join_argb(0, colorf.v[1] * 255, colorf.v[2] * 255, colorf.v[3] * 255))))
					R = colorf.v[1]
					G = colorf.v[2]
					B = colorf.v[3]
				end
				imgui.SameLine()
				imgui.Text(u8"Нажмите на иконку и выберите цвет.")
				imgui.Separator()
				imgui.SetCursorPosX(260)
				imgui.Text(u8"Введите ники, которые хотите выделять в чате.")
				imgui.Separator()
				imgui.Columns(2, _, false)
				imgui.PushItemWidth(200)
				imgui.InputText(fa.ICON_USER_CIRCLE..u8' Ник 1', nikifama1)
				imgui.InputText(fa.ICON_USER_CIRCLE..u8' Ник 2', nikifama2)
				imgui.InputText(fa.ICON_USER_CIRCLE..u8' Ник 3', nikifama3)
				imgui.InputText(fa.ICON_USER_CIRCLE..u8' Ник 4', nikifama4)
				imgui.InputText(fa.ICON_USER_CIRCLE..u8' Ник 5', nikifama5)
				imgui.NextColumn()
				imgui.PushItemWidth(200)
				imgui.InputText(fa.ICON_USER_CIRCLE..u8' Ник 6', nikifama6)
				imgui.InputText(fa.ICON_USER_CIRCLE..u8' Ник 7', nikifama7)
				imgui.InputText(fa.ICON_USER_CIRCLE..u8' Ник 8', nikifama8)
				imgui.InputText(fa.ICON_USER_CIRCLE..u8' Ник 9', nikifama9)
				imgui.InputText(fa.ICON_USER_CIRCLE..u8' Ник 10', nikifama10)
				
				--[[for i, v in ipairs(mass_niki) do
					--mass_niki[#mass_niki] = imgui.ImBuffer(256)				
					imgui.PushItemWidth(400)
					imgui.InputText(fa.ICON_USER_CIRCLE..u8' Ник '..i, mass_niki[i])
					imgui.SameLine()
					if imgui.Button(fa.ICON_SLIDESHARE..u8(" Удалить ник ##"..i)) then
						table.remove(mass_niki, i)
						saveSettings(3, "DROP NICK")
					end

				end
				imgui.Columns(1, _, false)
				if imgui.Button(fa.ICON_WHEELCHAIR..u8(" Добавить ник")) then 
					mass_niki[#mass_niki + 1] = { '' } 
				end]]
		elseif showSet == 8 then
			if imgui.Button(u8("Стандартная"), btn_size) then 
				Theme = 1
				apply_custom_style()
			end
			if imgui.Button(u8("Андровира"), btn_size) then 
				Theme = 2
				apply_custom_style()
			end
			if imgui.Button(u8("Черно-оранжевая"), btn_size) then 
				Theme = 3
				apply_custom_style()
			end	
			if imgui.Button(u8("Фиолетовая"), btn_size) then 
				Theme = 4
				apply_custom_style()
			end	
			if imgui.Button(u8("Серая"), btn_size) then 
				Theme = 5
				apply_custom_style()
			end	
			if imgui.Button(u8("Бело-голубая"), btn_size) then 
				Theme = 6
				apply_custom_style()
			end
			if imgui.Button(u8("Темно-серая"), btn_size) then 
				Theme = 7
				apply_custom_style()
			end
			if imgui.Button(u8("Темно-красная"), btn_size) then 
				Theme = 8
				apply_custom_style()
			end
			if imgui.Button(u8("Вишневая"), btn_size) then 
				Theme = 9
				apply_custom_style()
			end

		end

		imgui.End()
	end

	if win_state['leaders'].v then -- окно для лидеров
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(900, 430), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Лидерам', win_state['leaders'], imgui.WindowFlags.NoResize)

			imgui.Columns(2, _, false)
			imgui.SetColumnWidth(-1, 640)
			imgui.Text(u8'Общая госка:')
			imgui.PushItemWidth(530)
			imgui.InputText(u8'##gsk1', gos1)
			imgui.InputText(u8'##gsk2', gos2)
			imgui.InputText(u8'##gsk3', gos3)
			imgui.SameLine()
			if imgui.Button(u8'Отправить') then
				if #gos1.v == 0 or #gos2.v == 0 or #gos3.v == 0 then
					sampAddChatMessage("[MoD-Helper]{FFFFFF} Минимум одно поле пустое, заполните все поля.", SCRIPTCOLOR)
				else
					if gosButton then
						gosButton = false
						lua_thread.create(function()
							sampSendChat("/gnews "..u8:decode(gnewstag.v).." "..u8:decode(gos1.v))
							wait(1000)
							sampSendChat("/gnews "..u8:decode(gnewstag.v).." "..u8:decode(gos2.v))
							wait(1000)
							sampSendChat("/gnews "..u8:decode(gnewstag.v).." "..u8:decode(gos3.v))
							wait(5000)
							gosButton = true
						end)
					else
						sampAddChatMessage("[MoD-Helper]{FFFFFF} Пожалуйста подождите окончания подачи гос.новости.", SCRIPTCOLOR)
					end
				end
			end
			imgui.Text(u8'Одиночная госка:')
			imgui.InputText(u8'##gsk4', gos4)
			imgui.SameLine()
			if imgui.Button(u8'Отпpавить') then
				if #gos4.v == 00 then 
					sampAddChatMessage("[MoD-Helper]{FFFFFF} Поле пустое, подача пустой строки невозможна.", SCRIPTCOLOR)
				else
					if gosButton then
						gosButton = false
						lua_thread.create(function()
							sampSendChat("/gnews "..u8:decode(gnewstag.v).." "..u8:decode(gos4.v))
							wait(5000)
							gosButton = true
						end)
					else
						sampAddChatMessage("[MoD-Helper]{FFFFFF} Пожалуйста подождите окончания подачи гос.новости.", SCRIPTCOLOR)
					end
				end
			end
			imgui.Text(u8'Окончание:')
			imgui.InputText(u8'##gsk5', gos5)
			imgui.SameLine()
			if imgui.Button(u8'Завершить') then
				if #gos5.v == 0 then
					sampAddChatMessage("[MoD-Helper]{FFFFFF} Поле пустое, подача пустой строки невозможна.", SCRIPTCOLOR)
				else
					if gosButton then
						gosButton = false
						lua_thread.create(function()
							sampSendChat("/gnews "..u8:decode(gnewstag.v).." "..u8:decode(gos5.v))
							wait(5000)
							gosButton = true
						end)
					else
						sampAddChatMessage("[MoD-Helper]{FFFFFF} Пожалуйста подождите окончания подачи гос.новости.", SCRIPTCOLOR)
					end
				end
			end
			imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"Время по МСК: ")
			imgui.SameLine()
			imgui.Text(u8(string.format(os.date('%H:%M:%S', moscow_time))))
			imgui.NextColumn()
			if imgui.CollapsingHeader(u8'Правительство') then
				if imgui.Button(u8"АП") then
					gos1.v = u8("Сейчас пройдет собеседование в Администрацию Президента.")
					gos2.v = u8("Собеседование будет проходит в здании Администрации.")
					gos3.v = u8("Критерии: 5 лет в штате, пакет лицензий, быть законопослушным.")
					gos4.v = u8("Напоминаю, проходит собеседование в Администрацию Президента.")
					gos5.v = u8("Собеседование в Администрацию Президента окончено.")
				end
				imgui.SameLine()
				if imgui.Button(u8"Мэрия ЛС") then
					gos1.v = u8("Уважаемые жители штата, минуточку внимания.")
					gos2.v = u8("Сейчас пройдёт собеседование в Мэрию г.Лос-Сантос.")
					gos3.v = u8("Требования: 5 лет в штате, лицензии и владения Desert Eagle.")
					gos4.v = u8("Собеседование в мэрию г.Лос-Сантос продолжается.")
					gos5.v = u8("Собеседование в мэрию г.Лос-Сантос окончено.")
				end
				imgui.SameLine()
				if imgui.Button(u8"Мэрия СФ") then
					gos1.v = u8("Уважаемые жители штата, минуточку внимания.")
					gos2.v = u8("Сейчас пройдёт собеседование в Мэрию г.Сан-Фиерро.")
					gos3.v = u8("Требования: 5 лет в штате, лицензии и владения Desert Eagle.")
					gos4.v = u8("Собеседование в мэрию г.Сан-Фиерро продолжается.")
					gos5.v = u8("Собеседование в мэрию г.Сан-Фиерро окончено.")
				end
				imgui.SameLine()
				if imgui.Button(u8"Мэрия ЛВ") then
					gos1.v = u8("Уважаемые жители штата, минуточку внимания.")
					gos2.v = u8("Сейчас пройдёт собеседование в Мэрию г.Лас-Вентурас.")
					gos3.v = u8("Требования: 5 лет в штате, лицензии и владения Desert Eagle.")
					gos4.v = u8("Собеседование в мэрию г.Лас-Вентурас продолжается.")
					gos5.v = u8("Собеседование в мэрию г.Лас-Вентурас окончено.")
				end
			end
			if imgui.CollapsingHeader(u8'Министерство Внутренних Дел') then
				if imgui.Button(u8"ЛСПД") then
					gos1.v = u8("Сейчас пройдет собеседование в полицию г.Лос-Сантос.")
					gos2.v = u8("Собеседование пройдет в гараже департамента.")
					gos3.v = u8("Критерии: 4 года в штате, пакет лицензий, быть законопослушным.")
					gos4.v = u8("Напоминаю, проходит собеседование в полицию г.Лос-Сантос.")
					gos5.v = u8("Собеседование в полицию г.Лос-Сантос окончено.")
				end
				imgui.SameLine()
				if imgui.Button(u8"СФПД") then
					gos1.v = u8("Сейчас пройдет собеседование в полицию г.Сан-Фиерро.")
					gos2.v = u8("Собеседование пройдет в гараже департамента.")
					gos3.v = u8("Критерии: 4 года в штате, пакет лицензий, быть законопослушным.")
					gos4.v = u8("Напоминаю, проходит собеседование в полицию г.Сан-Фиерро.")
					gos5.v = u8("Собеседование в полицию г.Сан-Фиерро окончено.")
				end
				imgui.SameLine()
				if imgui.Button(u8"ЛВПД") then
					gos1.v = u8("Сейчас пройдет собеседование в полицию г.Лас-Вентурас.")
					gos2.v = u8("Собеседование пройдет в гараже департамента.")
					gos3.v = u8("Критерии: 4 года в штате, пакет лицензий, быть законопослушным.")
					gos4.v = u8("Напоминаю, проходит собеседование в полицию г.Лас-Вентурас.")
					gos5.v = u8("Собеседование в полицию г.Лас-Вентурас окончено.")
				end
			end		
			if imgui.CollapsingHeader(u8'Министерство Обороны') then
				if imgui.Button(u8"СВ") then
					gos1.v = u8("Сейчас пройдет призыв в Сухопутные Войска.")
					gos2.v = u8("Призыв будет проходить в военкомате г.Лас-Вентурас.")
					gos3.v = u8("Критерии: 3 года в штате, пакет лицензий, быть законопослушным.")
					gos4.v = u8("Напоминаю, проходит призыв в Сухопутные Войска.")
					gos5.v = u8("Призыв военкомата в армию Сухопутных Войск завершен.")
				end
				imgui.SameLine()
				if imgui.Button(u8"ВВС") then
					gos1.v = u8("Сейчас пройдет призыв в Военно-Воздушные Силы.")
					gos2.v = u8("Призыв будет проходить в военкомате г.Лас-Вентурас.")
					gos3.v = u8("Критерии: 3 года в штате, пакет лицензий, быть законопослушным.")
					gos4.v = u8("Напоминаю, проходит призыв в Военно-Воздушные Силы.")
					gos5.v = u8("Призыв военкомата в армию Военно-Воздушных Сил завершен.")
				end
				imgui.SameLine()
				if imgui.Button(u8"ВМФ") then
					gos1.v = u8("Сейчас пройдет призыв в Военно-Морской Флот.")
					gos2.v = u8("Призыв будет проходить в военкомате г.Лас-Вентурас.")
					gos3.v = u8("Критерии: 3 года в штате, пакет лицензий, быть законопослушным.")
					gos4.v = u8("Напоминаю, проходит призыв в Военно-Морской Флот.")
					gos5.v = u8("Призыв военкомата в армию Военно-Морского Флота завершен.")
				end
				imgui.SameLine()
				if imgui.Button(u8"Ком.Час") then
					gos1.v = u8("Уважаемые жители штата, прошу уделить нам минуточку внимания!")
					gos2.v = u8("С 21:00 до 09:00 на всех военных территориях введен Комендантский час.")
					gos3.v = u8("Военные имеют право открыть огонь на поражение в случае проникновения.")
					gos4.v = ''
					gos5.v = ''
				end
			end		
			if imgui.CollapsingHeader(u8'Министерство Здравоохранения') then
				if imgui.Button(u8"Болька ЛС") then
					gos1.v = u8("Уважаемые жители штата, минуточку внимания.")
					gos2.v = u8("Сейчас пройдет собеседование в Больницу г.Лос-Сантос.")
					gos3.v = u8("Требования: 3 года в штате, законопослушность. Ждём вас.")
					gos4.v = u8("Напоминаю, проходит собеседование в больницу г.Лос-Сантос.")
					gos5.v = u8("Собеседование в больницу г.Лос-Сантос завершено.")
				end
				imgui.SameLine()
				if imgui.Button(u8"Болька СФ") then
					gos1.v = u8("Уважаемые жители штата, минуточку внимания.")
					gos2.v = u8("Сейчас пройдет собеседование в Больницу г.Сан-Фиерро.")
					gos3.v = u8("Требования: 3 года в штате, законопослушность. Ждём вас.")
					gos4.v = u8("Напоминаю, проходит собеседование в больницу г.Сан-Фиерро.")
					gos5.v = u8("Собеседование в больницу г.Сан-Фиерро завершено.")
				end
				imgui.SameLine()			
				if imgui.Button(u8"Болька ЛВ") then
					gos1.v = u8("Уважаемые жители штата, минуточку внимания.")
					gos2.v = u8("Сейчас пройдет собеседование в Больницу г.Лас-Вентурас.")
					gos3.v = u8("Требования: 3 года в штате, законопослушность. Ждём вас.")
					gos4.v = u8("Напоминаю, проходит собеседование в больницу г.Лас-Вентурас.")
					gos5.v = u8("Собеседование в больницу г.Лас-Вентурас завершено.")
				end
			end
			if imgui.CollapsingHeader(u8'Средства Массовой Информации') then
				if imgui.Button(u8"РЦЛС") then
					gos1.v = u8("Уважаемые жители штата, минуту внимания.")
					gos2.v = u8("В радиоцентре г.Лос-Сантос проходит собеседование!")
					gos3.v = u8("Требования: 4 года в штате, законопослушность.")
					gos4.v = u8("Напоминаю, проходит собеседование в радиоцентр г.Лос-Сантос.")
					gos5.v = u8("Собеседование в радиоцентр г.Лос-Сантос завершено.")
				end
				imgui.SameLine()
				if imgui.Button(u8"РЦСФ") then
					gos1.v = u8("Уважаемые жители штата, минуту внимания.")
					gos2.v = u8("В радиоцентре г.Сан-Фиерро проходит собеседование!")
					gos3.v = u8("Требования: 4 года в штате, законопослушность.")
					gos4.v = u8("Напоминаю, проходит собеседование в радиоцентр г.Сан-Фиерро.")
					gos5.v = u8("Собеседование в радиоцентр г.Сан-Фиерро завершено.")
				end
				imgui.SameLine()
				if imgui.Button(u8"РЦЛВ") then
					gos1.v = u8("Уважаемые жители штата, минуту внимания.")
					gos2.v = u8("В радиоцентре г.Лас-Вентурас проходит собеседование!")
					gos3.v = u8("Требования: 4 года в штате, законопослушность.")
					gos4.v = u8("Напоминаю, проходит собеседование в радиоцентр г.Лас-Вентурас.")
					gos5.v = u8("Собеседование в радиоцентр г.Лас-Вентурас завершено.")
				end
				imgui.SameLine()
				if imgui.Button(u8"ТВ-Ц") then
					gos1.v = u8("Уважаемые жители штата, минуту внимания.")
					gos2.v = u8("Сейчас в Телецентр штата пройдет собеседование!")
					gos3.v = u8("Требования: 4 года в штате, быть законопослушным.")
					gos4.v = u8("Напоминаю, что сейчас проходит собеседование в Телецентр.")
					gos5.v = u8("Собеседование в Телецентр штата окончено.")
				end
			end
			--imgui.NewLine()
			if imgui.Button(u8'Очистить строки') then
				gos1.v = ''
				gos2.v = ''
				gos3.v = ''
				gos4.v = ''
				gos5.v = ''
			end
			--imgui.NewLine()
			imgui.PushItemWidth(60.0)
			imgui.InputText(u8'Тэг /gnews', gnewstag)
			imgui.PopItemWidth()
			imgui.SameLine()
			if imgui.Button(u8("Применить##228")) then saveSettings(4) end
			--imgui.NewLine()

		
			imgui.Columns(1, _, false)
			imgui.Separator()
			imgui.Text(u8'/gnews '..gnewstag.v..' '..gos1.v)
			imgui.Text(u8'/gnews '..gnewstag.v..' '..gos2.v)
			imgui.Text(u8'/gnews '..gnewstag.v..' '..gos3.v)
			imgui.NewLine()
			imgui.Text(u8'/gnews '..gnewstag.v..' '..gos4.v)
			imgui.Text(u8'/gnews '..gnewstag.v..' '..gos5.v)
			
		--end
		imgui.End()
	end

	if win_state['help'].v then -- окно "помощь"
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(970, 400), imgui.Cond.FirstUseEver)
		imgui.Begin(u8('Помощь'), win_state['help'], imgui.WindowFlags.NoResize)
		imgui.BeginGroup()
		imgui.BeginChild('left pane', imgui.ImVec2(180, 350), true)
		
		if imgui.Selectable(u8"Команды скрипта") then selected2 = 1 end
		imgui.Separator()
		if imgui.Selectable(u8"Чекер ЧС") then selected2 = 2 end
		imgui.Separator()
		if imgui.Selectable(u8"Шпаргалки") then selected2 = 3 end
		imgui.Separator()
		if imgui.Selectable(u8"Биндер") then selected2 = 4 end
		imgui.Separator()		
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild('##ddddd', imgui.ImVec2(745, 350), true)
		if selected2 == 0 then
			selected2 = 1
		elseif selected2 == 1 then
			imgui.Text(u8"Команды скрипта")
			imgui.Separator()
			imgui.Columns(2, _,false)
			imgui.SetColumnWidth(-1, 300)
				if isPlayerSoldier then
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/black [ID]")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/bhist [nickname]")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/bb")
				end
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/rn [text]")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/fn [text]")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/rd [Пост] [Состояние]")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/fd [Пост] [Состояние]")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/reload")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/where [ID]")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/hist [ID]")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/сс")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/drone")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/ok [ID]")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/rm")
				if isPlayerSoldier then
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/ud [ID]")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/uninv [ID] [ID офицера] [Причина]")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/livr [ID] [Причина]")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/livf [ID] [Причина]")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/raport [ID] [Причина]")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/upd")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/tir [мс]")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/vig [id] [Причина]")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/nr [id] [Причина]")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/ffind")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"ПКМ + 1")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"ПКМ + R")
				end
			imgui.NextColumn()
				if isPlayerSoldier then
					imgui.Text(u8"Полная проверка игрока на ЧС МО(по нику + история ников).")
					imgui.Text(u8"Проверка игрока на ЧС МО по его никнейму через историю ников (Не работает на Red сервере).")
					imgui.Text(u8"Обновление черного списка с форума.")
				end
				imgui.Text(u8"Отправка ООС сообщения в рацию подфракции.")
				imgui.Text(u8"Отправка ООС сообщения в общую рацию фракции.")
				imgui.Text(u8"Сделать доклад с поста в рацию фракции.")
				imgui.Text(u8"Сделать доклад с поста в общую рацию.")
				imgui.Text(u8"Перезагрузка скрипта.")
				imgui.Text(u8"Запросить местоположение игрока в рацию по его ID.")
				imgui.Text(u8"Проверить историю ников по ID.")
				imgui.Text(u8"Очистка чата.")
				imgui.Text(u8"Получить картинку с дрона на территории.")
				imgui.Text(u8"Принять доклад игрока.")
				imgui.Text(u8"Удалить метку с игрока.")
				if isPlayerSoldier then
					imgui.Text(u8"Показать удостоверение человеку.")
					imgui.Text(u8"Уволить бойца по просьбе офицера.")
					imgui.Text(u8"Запросить увольнение бойца в /r.")
					imgui.Text(u8"Запросить увольнение бойца в /f.")
					imgui.Text(u8"Рапорт отстранения special for Red.")
					imgui.Text(u8"Обновить данные в системе MoD-Helper(ник, фракция).")
					imgui.Text(u8"Прокачивание скиллов. Задержка в милисекундах.")
					imgui.Text(u8"Выдача выговора в /r. Доступна с 5 ранга.")
					imgui.Text(u8"Выдача наряда в /r. Доступна с 5 ранга.")
					imgui.Text(u8"Бесполезная секретная команда.")
					imgui.Text(u8"Отдать честь игроку.")
					imgui.Text(u8"Меню взаимодействия.")
				end
		elseif selected2 == 2 then
			imgui.Text(u8"Чекер ЧС by Adamson(огромное спасибо deddosouru)")
			imgui.Separator()
			imgui.Text(u8"Сейчас мы рассмотрим работу чекера на ЧС данного скрипта.")
			imgui.Text(u8"Прежде всего затронем команды, к которым он относится: ")
			imgui.SameLine()
			imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/bb, /bhist, /black.")
			imgui.TextWrapped(u8"Описания данных команд дано в общем списке, но сейчас это не столь важно. При активации команды обновления черного списка, скрипт напрямую получает информацию с форума сервера, где специальными метками выделены зоны с никами, которые переходят в обработку скрипту. После того как вы загрузили/обновили список - в папке скрипта появится файл blacklist.txt, который содержит в себе полный список ЧСников и их причины занесения.")
			imgui.TextWrapped(u8"Далее, после того как у нас появился список ЧСников, мы можем работать над проверкой игрока. По своему универсальной командой является /black, так как она проверяет сразу игрока по его ID вместе с его историей ников, что преимущественно на проведении призыва.")
			imgui.TextWrapped(u8"Если же у вас появились сомнения касательно того, находится ли в ЧС МО, например, ваш офицер, но в игре его нет - приходит на помощь команда /bhist, которая поможет проверить игрока на нахождение в ЧС по нику.")
			imgui.TextWrapped(u8"Наш чекер указывает информации о том, по какой причине игрок занесен в ЧС, но не указывает, с какого ника занесен, так как мы считаем, что это не столь обязательная и интересная информация, если игрок пожелает - он сам сможет проверить себя на наличие в ЧС. Тем не менее, если игрок твердо настаивает на том, что его нет в черном списке - вы можете проверить вручную осуществив поиск по файлу, указанному выше, быть может произойдет ложная выдача результата(редкий случай), вероятность которого крайне низка.")
			imgui.TextWrapped(u8"Теперь касательно самого процесса проверки игрока. Когда вы запускаете проверку игрока на ЧС тем или иным видом - вам выдаст итоговый результат, есть игрок в ЧС или нет. Если вы видите, что причина выглядит как-то некорректно, то есть в нее попадает часть фамилии игрока - вероятней всего, игрок занесен в ЧС МО на форуме без нижнего подчеркивания, тем не менее, это никак не влияет на результат(по итогам проверки). Если игрок находится в ЧС МО под несколькими никами, вам выдаст результат только по первому из них. Думаю я смог донести до вас суть работы чекера, приятного пользования.")

		elseif selected2 == 3 then
			imgui.Text(u8"Шпаргалки")
			imgui.Separator()
			imgui.Text(u8"Сейчас мы рассмотрим работу и возможности шпор, которые интегрированы в скрипт.")
			imgui.TextWrapped(u8"В целом, суть скрипта лежит в названии - это обычные шпаргалки. Вы можете создавать множество шпаргалок с любыми названиями, заполнять их как вашей душе угодно, удалять их в случае ненадобности. Это конечно круто, но этого нам недостаточно, да?")
			imgui.TextWrapped(u8"Шпоры имеют скромный дополнительный функционал, который будет полезен при оформлении ваших вспомогательных текстов. О чем идет речь? Речь идет о поддержке тэгов, а именно:")
			imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"[center], [left], [right].")
			imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"{HTML цвета}.")
			imgui.TextWrapped(u8"Согласитесь, вашему глазу будет приятней с красивым оформлением, нежели монотонным текстом, который словно вот вот задохнется от грусти и печали :D Надеемся, что данная мелочь будет удобна вам в использовании, ну а мы продолжаем перечислять возможности.")
			imgui.TextWrapped(u8"Раньше шпоры можно было использовать для создания собственных лекций в рацию или же при строе, но с приходом внутрескриптового биндера - в этом больше нет необходимости и теперь шпоры выполняют исключительно свою функцию в полной мере, а мы способствуем ее развитию, по этому у нас имеется удобный поиск ключевых фраз по всем созданным шпорам с последующим выводом строчки, где фигурирует ключевая фраза, просто и удобно.")
			imgui.TextWrapped(u8"Собственно на этом и закончилось перечисление особенностей интегрированных шпаргалок, надеемся, они пригодятся вам в использовании и вы будете довольны, приятного пользования.")
		elseif selected2 == 4 then
			imgui.Text(u8"Внутриигровой биндер by X.Adamson")
			imgui.Separator()
			imgui.Text(u8"Сейчас мы рассмотрим работу и возможности внутриигрового биндера, который может быть вам полезен.")
			imgui.TextWrapped(u8"Прежде всего, главное отличие нашего биндера от прочих известных - количество биндов неограничено, количество строк неограничено, назначение бинда возможно как на клавиши, так и на команды, на каждую отыгровку можно назначить единцую задержку между строками. Имеется набор простеньких тэгов, но ими никого не удивишь :)")
			imgui.TextWrapped(u8"Перед тем как создать команду, вам необходимо принять во внимание один важный факт:")
			imgui.Text(u8("- Данная команда не используется в скриптах или же на сервере"))
			imgui.TextWrapped(u8"Если вы создадите команду, которая используется в каком либо скрипте - вы не заблокируете ее, бинд не будет работать, но, при смене/удалении этого бинда вы отключите команду независимо от того, работал у вас на ней бинд или нет. Чтобы восстановить работу прежней команды, скрипт необходимо будет перезагрузить. Так же нельзя использовать в тексте бинда вызов команды, которая используется для вызова бинда. Будьте аккуратны с этим :)")
			imgui.TextWrapped(u8"Бесконечные бинды, строки.. Это все скучно, по этому мы разнообразили их системными тэгами, которые работают только в биндере. Если вам недостаточно имеющихся - напишите нам в тех.поддержку идею тэга и мы наверника его введем :)")
		end
		imgui.EndChild()
        imgui.EndGroup()
        imgui.End()
	end

	if win_state['about'].v then -- окно "о скрипте"
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(330, 270), imgui.Cond.FirstUseEver)
		imgui.Begin(u8('О скрипте'), win_state['about'], imgui.WindowFlags.NoResize)

		if developMode == 1 then imgui.Text(u8'MoD-Helper | Developer Mode')
		elseif developMode == 2 then imgui.Text(u8'MoD-Helper | Correction Mode')
		else imgui.Text(u8'MoD-Helper') end
		imgui.Text(u8'Разработчик: Xavier Adamson')
		imgui.Text(u8'Модератор: Arina Borisova')
		imgui.Text(u8'Дополнял: DIPIRIDAMOLE')
		imgui.Text(u8'Версия скрипта: '..thisScript().version)
		imgui.Text(u8'Версия Moonloader: 026')
		imgui.Text(u8'Спасибо blast.hk и нескольким людям за помощь')
		imgui.Separator()
		--[[if imgui.Button(u8'VK') then
			print("Открываю: Настройки - О скрипте - ВК")
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Сейчас откроется ссылка на официальный паблик ВК.", SCRIPTCOLOR)
			print(shell32.ShellExecuteA(nil, 'open', 'https://vk.com/public168899283', nil, nil, 1))
		end
		imgui.SameLine()
		if imgui.Button(u8'Поддержка') then
			print("Открываю: Настройки - О скрипте - Поддержка")
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Сейчас откроется ссылка на официальную тему поддержки.", SCRIPTCOLOR)
			print(shell32.ShellExecuteA(nil, 'open', 'https://forum.advance-rp.ru/threads/ministerstvo-oborony-mod-helper-dlja-voennosluzhaschix.1649378/', nil, nil, 1))
		end
		imgui.SameLine()]]
		if imgui.Button(u8'Обновиться до последней версии', btn_size) then
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Начинаем проверку обновлений.", SCRIPTCOLOR)
			checkupd = true
			update()
		end
		if imgui.Button(u8'Отключить скрипт', btn_size) then 
			offscript = offscript + 1
			if offscript ~= 2 then
				sampAddChatMessage("[MoD-Helper]{FFFFFF} Вы собираетесь отключить скрипт, обратная загрузка невозможна без сторонних скриптов или перезахода.", SCRIPTCOLOR)
				sampAddChatMessage("[MoD-Helper]{FFFFFF} Подтвердите отключение скрипта, если уверены в необходимости его отключения.", SCRIPTCOLOR)
			else
				print("Отключаем скрипт из настроек")
				reloadScript = true
				thisScript():unload()
			end
		end
		imgui.End()
	end

	if win_state['leave'].v then -- окно, которое срабатывает при /leave и просит подтверждения
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(360, 225), imgui.Cond.FirstUseEver)

		imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.0, 0.0, 0.0, 0.3))
		if imgui.Begin(u8('Подтверждение самостоятельного увольнения'), win_state['leave'], imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoSavedSettings) then
			imgui.OpenPopup(u8"Подтверждение /leave")
			if imgui.BeginPopupModal(u8"Подтверждение /leave", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
				imgui.Text(u8("Вы ввели команду для самостоятельного увольнения из фракции, иногда это магическим образом у вас может произойти случайно, на такие случаи создано данное уведомление.\nКоманда была заблокирована в целях безопасности, если вы хотите продолжить - нажмите на кнопку, в ином случае - на другую."))
				if imgui.Button(u8('Я уверен'), btn_size) then
					print("Подвтерждаю скриптовый /leave")
					win_state['leave'].v = not win_state['leave'].v
					imgui.CloseCurrentPopup()
					sampSendChat("/leave")
				end
				if imgui.Button(u8('Я передумал'), btn_size) then
					win_state['leave'].v = not win_state['leave'].v
					imgui.CloseCurrentPopup()
				end
				imgui.EndPopup()
			end
			imgui.End()
		end
		imgui.PopStyleColor()
	end

	if win_state['update'].v then -- окно обновления скрипта
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(450, 200), imgui.Cond.FirstUseEver)
        imgui.Begin(u8('Обновление'), nil, imgui.WindowFlags.NoResize)
		imgui.Text(u8'Обнаружено обновление до версии: '..updatever)
		imgui.Separator()
		imgui.TextWrapped(u8("Для установки обновления необходимо подтверждение пользователя, разработчик настоятельно рекомендует принимать обновления ввиду того, что прошлые версии через определенное время отключаются и более не работают."))
		if imgui.Button(u8'Скачать и установить обновление', btn_size) then
			async_http_request('GET', 'https://raw.githubusercontent.com/DiPiDi/install/master/MO.luac', nil, 
				function(response) -- вызовется при успешном выполнении и получении ответа
				local f = assert(io.open(getWorkingDirectory() .. '/MO.luac', 'wb'))
				f:write(response.text)
				f:close()
				sampAddChatMessage("[MoD-Helper]{FFFFFF} Обновление успешно, перезагружаем скрипт.", SCRIPTCOLOR)
				thisScript():reload()
			end,
			function(err) -- вызовется при ошибке, err - текст ошибки. эту функцию можно не указывать
				print(err)
				sampAddChatMessage("[MoD-Helper]{FFFFFF} Произошла ошибка при обновлении, попробуйте позже.", SCRIPTCOLOR)
				win_state['update'].v = not win_state['update'].v
				return
			end)
		end
		if imgui.Button(u8'Закрыть', btn_size) then win_state['update'].v = not win_state['update'].v end
		imgui.End()
	end


	if win_state['informer'].v then -- окно информера

		imgui.SetNextWindowPos(imgui.ImVec2(infoX, infoY), imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(200, 200), imgui.Cond.FirstUseEver)

		imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.0, 0.0, 0.0, 0.3))
		if imgui.Begin("MoD-Service", win_state['informer'], imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoSavedSettings) then
			imgui.Text("MoD-Helper Services")
			imgui.Separator()
			if not offMask and infMask.v then 
				maskRemainingTime = math.floor((offMaskTime - os.clock() * 1000 ) / 1000)
				maskSeconds = maskRemainingTime % 60
				maskMinutes = math.floor(maskRemainingTime / 60)

				imgui.Text(u8("• Время маски: "..tostring(maskMinutes)..":"..(maskSeconds >= 10 and '' or '0')..""..tostring(maskSeconds)))
				if maskSeconds <= 0 and maskMinutes <= 0 then offMask = true end
			end
			if infZone.v then imgui.Text(u8("• Зона: "..ZoneText)) end
			if infArmour.v then imgui.Text(u8("• Броня: "..armourNew)) end
			if infHP.v then imgui.Text(u8("• Здоровье: "..healNew)) end
			if infCity.v then imgui.Text(u8("• Город: "..playerCity)) end
			if infRajon.v then imgui.Text(u8("• Район: "..ZoneInGame)) end
			
			if infKv.v then imgui.Text(u8("• Квадрат: "..tostring(locationPos()))) end
			if infTime.v then imgui.Text(u8("• Время: "..os.date("%H:%M:%S"))) end
			imgui.End()
		end
		imgui.PopStyleColor()
	end

	if win_state['find'].v then -- автострой, который сделан максимально говнокодно, но работает ;D

		imgui.SetNextWindowPos(imgui.ImVec2(infoX2, infoY2), imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(500, 170), imgui.Cond.FirstUseEver)

		imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.0, 0.0, 0.0, 0.3))
		if imgui.Begin(u8"Автострой", win_state['find'], imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoSavedSettings) then
			imgui.Columns(3, _, false)
			imgui.SetColumnWidth(-1, 150)
			imgui.Text(u8("В строю:"))
			for i = 1, #names do
				imgui.Text(u8(names[i]))
			end

			imgui.NextColumn(2)
			imgui.SetColumnWidth(-1, 150)
			imgui.Text(u8("Рядом:"))
			for i = 1, #SecNames do
				imgui.TextColored(imgui.ImVec4(0.12, 0.70 , 0.38, 1.0), u8(SecNames[i].."["..secID[i].."]"))
			end
	
			imgui.NextColumn(3)
			imgui.SetColumnWidth(-1, 160)
			imgui.Text(u8("Не в строю:"))
			for i = 1, #SecNames2 do 
				imgui.TextColored(imgui.ImVec4(0.12, 0.70 , 0.38, 1.0), u8(SecNames2[i].."["..sec2ID[i].."]"))
			end
			imgui.End()
		end
		imgui.PopStyleColor()
	end

	if menu_spur.v then -- окно для шпор
		local t_find_text = {}
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(1110, 720), imgui.Cond.FirstUseEver)
		imgui.Begin(u8("Шпаргалки | MoD-Helper"), menu_spur)
		imgui.BeginChild(1, imgui.ImVec2(imgui.GetWindowWidth()/3.8, 0), true)
		if imgui.Selectable(u8("Новая шпаргалка")) then add_spur = true end
		imgui.Separator()
		imgui.InputText(u8("Искать"), find_text_spur)
		imgui.Separator()
		
		for i, k in pairs(files) do
			find_name_spur.v = find_name_spur.v:gsub('%[', '')
			find_name_spur.v = find_name_spur.v:gsub('%(', '')
			find_text_spur.v = find_text_spur.v:gsub('%[', '')
			find_text_spur.v = find_text_spur.v:gsub('%(', '')
			if k then
				local nameFileOpen = k:match('(.*).txt')
				if find_text_spur.v:find('%S') then
					local file = io.open('moonloader/MoD-Helper/shpora/'..k, 'r')
					while not file do file = io.open('moonloader/MoD-Helper/shpora/'..k, 'r') end
					local fileText = file:read('*a')
					fileText = fileText:gsub('{......}', '')
					if string.rlower(fileText):find(string.rlower(u8:decode(find_text_spur.v))) then
						t_find_text[#t_find_text+1] = k
						if imgui.Selectable(u8(nameFileOpen)) then
							find_text_spur.v = ''
							text_spur = true
							id_spur = i
						end
					else
						text_spur = false
					end
					file:close()
				elseif string.rlower(nameFileOpen):find(string.rlower(u8:decode(find_name_spur.v))) and imgui.Selectable(u8(nameFileOpen)) then
					text_spur = true
					id_spur = i
				end
			end
		end
		
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild(2, imgui.ImVec2(0, 0), false)
		if add_spur then
			imgui.InputText(u8("Название"), name_add_spur)
			imgui.SameLine()
			imgui.Text("Sym: "..tostring(#name_add_spur.v)..", finded: "..(tostring(name_add_spur.v):match("%s") and "yes" or "no"))
			if imgui.Button(u8("Создать")) then
				math.randomseed(os.time())
				local randf = math.random(1, 999999)

				if #u8:decode(name_add_spur.v) == 0 or tostring(name_add_spur.v):match("%s") then name_add_spur.v = "Unnamed #"..randf end
				name_add_spur.v = u8(removeMagicChar(u8:decode(name_add_spur.v)))
				local namedublicate = false
				-- for i, k in pairs(files) do
				-- 	-- if k == u8:decode(name_add_spur.v) or not u8:decode(name_add_spur.v):find('%S') then namedublicate = true end
				-- 	if k == tostring(u8:decode(name_add_spur.v)) then namedublicate = true end
				-- end
				if doesFileExist("moonloader/MoD-Helper/shpora/"..tostring(u8:decode(name_add_spur.v))..".txt") then
					print("duplicated name in Shpora: "..u8:decode(name_add_spur.v))
					namedublicate = true
					anyvaribleoftext = tostring(u8:decode(name_add_spur.v)..'#'..randf)
				end
					local index, boolindex = 0, false
					while not boolindex do
						index = index + 1
						send = true
						if not files[index] then boolindex = true end
					end

					local file = io.open('moonloader/MoD-Helper/shpora/'..(namedublicate and anyvaribleoftext or u8:decode(name_add_spur.v))..'.txt', 'a')
					file:write('')
					file:flush()
					file:close()
					window_file[#window_file+1] = imgui.ImBool(false)
					files[#files+1] = (namedublicate and anyvaribleoftext or u8:decode(name_add_spur.v))..'.txt'
					add_spur = false
					name_add_spur.v = ''
				-- end
			end
			imgui.SameLine()
			if imgui.Button(u8("Отмена")) then add_spur = false end
		elseif t_find_text[1] then
			for i = 1, #t_find_text do
				local nameFileOpen = t_find_text[i]:match('(.*).txt')
				imgui.BeginChild(i+50, imgui.ImVec2(0, 150), true)
				imgui.AlignTextToFramePadding()
				imgui.Text(u8(nameFileOpen))
				imgui.SameLine()
				if imgui.Button(u8('Открыть шпору ##'..i)) then
					find_text_spur.v = ''
					text_spur = true
					id_spur = i
				end
				imgui.Separator()
				for line in io.lines('moonloader/MoD-Helper/shpora/'..t_find_text[i]) do
					if string.rlower(line):find(string.rlower(u8:decode(find_text_spur.v))) then
						imgui.TextColoredRGB(line, imgui.GetMaxWidthByText(line))
					end
				end
				imgui.EndChild()
			end
		elseif edit_nspur then
			imgui.InputText(u8("Название"), name_edit_spur)
			imgui.SameLine()
			if imgui.Button(u8("Сохранить")) then
				math.randomseed(os.time())
				local randf = math.random(1, 99999)

				if #u8:decode(name_edit_spur.v) == 0 then name_edit_spur.v = "Unnamed #"..randf end
				name_edit_spur.v = u8(removeMagicChar(u8:decode(name_edit_spur.v)))
				local namedublicate = false
				for i, k in pairs(files) do
					if k == u8:decode(name_edit_spur.v) or not u8:decode(name_edit_spur.v):find('%S') then namedublicate = true end
				end
				if not namedublicate then
					local file = io.open('moonloader/moonloader/MoD-Helper/shpora/'..files[id_spur], 'r')
					while not file do file = io.open('moonloader/MoD-Helper/shpora/'..files[id_spur], 'r') end
					local fileText = file:read('*a')
					file:close()
					os.remove('moonloader/MoD-Helper/shpora/'..files[id_spur])
					local file = io.open('moonloader/MoD-Helper/shpora/'..u8:decode(name_edit_spur.v)..'.txt', 'w')
					file:write(fileText)
					file:flush()
					file:close()
					files[id_spur] = u8:decode(name_edit_spur.v)..'.txt'
					edit_nspur = false
				end
			end
			imgui.SameLine()
			if imgui.Button(u8("Отмена")) then edit_nspur = false end
			imgui.Separator()
			local file = io.open('moonloader/MoD-Helper/shpora/'..files[id_spur], 'r')
			while not file do file = io.open('moonloader/MoD-Helper/shpora/'..files[id_spur], 'r') end
			local fileText = file:read('*a')
			fileText = fileText:gsub('\n\n', '\n \n')
			imgui.TextColoredRGB(fileText, imgui.GetMaxWidthByText(fileText))
			file:close()
		elseif id_spur then
			if not window_file[id_spur].v then
				if not text_spur then
					if edit_spur then
						imgui.Text(u8(files[id_spur]:match('(.*).txt')))
						imgui.SameLine()
						if imgui.Button(u8("Сохранить")) then
							edit_text_spur.v = edit_text_spur.v:gsub('\n\n', '\n \n')
							local file = io.open('moonloader/MoD-Helper/shpora/'..files[id_spur], 'w')
							file:write(u8:decode(edit_text_spur.v))
							file:flush()
							file:close()
							text_spur = true
							edit_spur = false
						end
						imgui.SameLine()
						if imgui.Button(u8("Отмена")) then
							text_spur = true
							edit_spur = false
						end
						imgui.Separator()
						imgui.InputTextMultiline('', edit_text_spur, imgui.ImVec2(-0.1, -0.1))
					end
				else
					local file = io.open('moonloader/MoD-Helper/shpora/'..files[id_spur], 'r')
					while not file do file = io.open('moonloader/MoD-Helper/shpora/'..files[id_spur], 'r') end
					local fileText = file:read('*a')
					fileText = fileText:gsub('\n\n', '\n \n')
					edit_spur = false
					copy_spur = false
					imgui.Text(u8(files[id_spur]:match('(.*).txt')))
					file:close()
					imgui.SameLine()
					if imgui.Button(u8("Изменить")) then
						text_spur = false
						edit_spur = true
						edit_text_spur.v = u8(fileText)
					end
					imgui.SameLine()
					if imgui.Button(u8("Переименовать")) then
						edit_nspur = true
						name_edit_spur.v = u8(files[id_spur]:match('(.*).txt'))
					end
					imgui.SameLine()
					if imgui.Button(u8("Удалить")) then
						os.remove('moonloader/MoD-Helper/shpora/'..files[id_spur])
						while doesFileExist('moonloader/MoD-Helper/shpora/'..files[id_spur]) do os.remove('moonloader/MoD-Helper/shpora/'..files[id_spur]) end
						window_file[id_spur] = nil
						files[id_spur] = nil
						id_spur = nil
						text_spur = false
					end
					imgui.Separator()
					imgui.TextColoredRGB(fileText, imgui.GetMaxWidthByText(fileText))
				end
			end
		end
		imgui.EndChild()
		imgui.End()
	end

	for i, k in pairs(files) do
		if k then
			if window_file[i].v then
				local flags = (not imgui.ShowCursor) and imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize or 0
				imgui.SetNextWindowPos(imgui.ImVec2(x/2-100, y/2-100), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
				imgui.SetNextWindowSize(imgui.ImVec2(500, 500), imgui.Cond.FirstUseEver)
				imgui.Begin(u8(k:match('(.*).txt')), window_file[i], flags)
				local file = io.open('moonloader/MoD-Helper/shpora/'..k, 'r')
				while not file do file = io.open('moonloader/MoD-Helper/shpora/'..k, 'r') end
				local fileText = file:read('*a')

				imgui.TextColoredRGB(fileText, imgui.GetMaxWidthByText(fileText) - 15)
			
				file:close()
				imgui.End()
			end
		end
	end
end

function rcmd(cmd, text, delay) -- функция для биндера, без которой не будет ни команд, ни клавиш.
	if cmd ~= nil then -- обрабатываем биндер, который работает по команде
		if cmd ~= '-' then sampUnregisterChatCommand(cmd) end -- делаем это для перерегистрации команд
		sampRegisterChatCommand(cmd, function(params) -- регистрируем команду + задаем функцию
			globalcmd = lua_thread.create(function() -- поток гасим в переменную, чтобы потом я мог стопить бинды, но что-то пошло не так и они обратно не запускались ;D
				if not keystatus then -- проверяем, не активен ли сейчас иной бинд
					cmdparams = params -- задаем параметры тэгам
					if text:find("{par1") or text:find("{par2") or text:find("IDpar1}") or text:find("IDpar2}") then
						cmdparams1 = cmdparams:match("(.+) | .+")
						cmdparams2 = cmdparams:match(".+ | (.+)")
					end  -- (text:find("{par") or text:find("IDpar")) and (cmdparams == '' or cmdparams1 == nil or cmdparams2 == nil)
					
					
					if (((text:find("{par1}") or text:find("{par2}") or text:find("IDpar")) and (cmdparams1 == nil or cmdparams2 == nil)) or ((text:find("{params}") or text:find("ByID}")) and cmdparams == '')) then -- если в тексте бинда есть намек на тэг параметра и параметр пуст, говорим заполнить его
						--sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /"..cmd.." ["..(text:find("byID}") and 'ID' or 'Параметр').."].", 0x046D63)
						local partype = '' -- объявим локальную переменную
						if text:find("ByID}") then 
							partype = "ID"
							sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: {"..u8:decode(Secondcolor.v).."}/"..cmd.." ["..partype.."].", SCRIPTCOLOR)
						elseif text:find("{par1}") and text:find("{par2}") then 
							partype = "Параметр 1 | Параметр 2"
							sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: {"..u8:decode(Secondcolor.v).."}/"..cmd.." ["..partype.."].", SCRIPTCOLOR)
						elseif text:find("IDpar1}") and text:find("{par2") then
							partype = "ID | Параметр 2"
							sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: {"..u8:decode(Secondcolor.v).."}/"..cmd.." ["..partype.."].", SCRIPTCOLOR)
						elseif text:find("IDpar2}") and text:find("{par1") then 
							partype = "Параметр 1 | ID"
							sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: {"..u8:decode(Secondcolor.v).."}/"..cmd.." ["..partype.."].", SCRIPTCOLOR)
						elseif text:find("IDpar1}") and text:find("IDpar2}") then 
							partype = "ID | ID"
							sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: {"..u8:decode(Secondcolor.v).."}/"..cmd.." ["..partype.."].", SCRIPTCOLOR)
						elseif text:find("{params}") then
							partype = "Параметр"
							sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: {"..u8:decode(Secondcolor.v).."}/"..cmd.." ["..partype.."].", SCRIPTCOLOR)
						else
							sampAddChatMessage("[MoD-Helper]{FFFFFF} В тексте бинда нехватает параметров либо есть лишние.", SCRIPTCOLOR)
						end -- зададим ей значение из условия
					else
						keystatus = true
						local strings = split(text, '~', false) -- обрабатываем текст бинда
						for i, g in ipairs(strings) do -- начинаем непосредественный вывод текста по строкам
							if not g:find("{bwait:") then sampSendChat(tags(tostring(g))) end
							wait(g:match("%{bwait:(%d+)%}"))
						end
						keystatus = false
						cmdparams = nil -- обнуляем параметры после использования
						cmdparams1 = nil
						cmdparams2 = nil
					end
				end
			end)
		end)
	else
		-- тут все аналогично, как и с командами, только чуток проще.
		globalkey = lua_thread.create(function()
			if text:find("{par") or text:find("par1}") or text:find("par2}") then
				sampAddChatMessage("[MoD-Helper]{FFFFFF} В данном бинде имеется один или более параметров, использование клавишами невозможно.", SCRIPTCOLOR)
			else

				local strings = split(text, '~', false)
				keystatus = true
				for i, g in ipairs(strings) do
					if not g:find("{bwait:") then sampSendChat(tags(tostring(g))) end
					wait(g:match("%{bwait:(%d+)%}"))
				end
				keystatus = false
			end
		end)
	end
end

function split(str, delim, plain) -- функция фипа, которая сделала биндер рабочим
    local tokens, pos, plain = {}, 1, not (plain == false) 
    repeat
        local npos, epos = string.find(str, delim, pos, plain)
        table.insert(tokens, string.sub(str, pos, npos and npos - 1))
        pos = epos and epos + 1
    until not pos
    return tokens
end

function showHelp(param) -- "вопросик" для скрипта
    imgui.TextDisabled('(?)')
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(imgui.GetFontSize() * 35.0)
        imgui.TextUnformatted(param)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function all_trim(s) -- удаление пробелов из строки ес не ошибаюсь
   return s:match( "^%s*(.-)%s*$" )
end

function ClearChat() -- очистка чата
    memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200)
    memory.write(sampGetChatInfoPtr() + 306, 25562, 4, 0x0)
    memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1)
end

function ClearBlip() -- удаление маркера/таргета
	if newmark ~= nil then
		if marker.v then
			removeBlip(newmark)	
			print("Снимаем таргет маркер с игрока "..sampGetPlayerNickname(blipID))
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Маркер с игрока "..sampGetPlayerNickname(blipID).." был успешно удален.", SCRIPTCOLOR)
		else
			print("Снимаем таргет с игрока "..sampGetPlayerNickname(blipID))
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Таргет с игрока "..sampGetPlayerNickname(blipID).." был успешно снят.", SCRIPTCOLOR)
		end
		blipID = nil
		newmark = nil
	end
end

function locationPos() -- получение квадрата игрока
	if not workpause then
		if interior == 0 then
			local KV = {
				[1] = "А",
				[2] = "Б",
				[3] = "В",
				[4] = "Г",
				[5] = "Д",
				[6] = "Ж",
				[7] = "З",
				[8] = "И",
				[9] = "К",
				[10] = "Л",
				[11] = "М",
				[12] = "Н",
				[13] = "О",
				[14] = "П",
				[15] = "Р",
				[16] = "С",
				[17] = "Т",
				[18] = "У",
				[19] = "Ф",
				[20] = "Х",
				[21] = "Ц",
				[22] = "Ч",
				[23] = "Ш",
				[24] = "Я",
			}
			local X, Y, Z = getCharCoordinates(PLAYER_PED)
			X = math.ceil((X + 3000) / 250)
			Y = math.ceil((Y * - 1 + 3000) / 250)
			Y = KV[Y]
			if Y ~= nil then
				KVX = (Y.."-"..X)
				if getActiveInterior() == 0 then BOL = KVX end
				if getActiveInterior() == 0 then cX, cY, cZ = getCharCoordinates(PLAYER_PED) cX = math.ceil(cX) cY = math.ceil(cY) cZ = math.ceil(cZ) end
				return KVX
			else
				KVX = ("ZERO -"..X)
				if getActiveInterior() == 0 then BOL = KVX end
				if getActiveInterior() == 0 then cX, cY, cZ = getCharCoordinates(PLAYER_PED) cX = math.ceil(cX) cY = math.ceil(cY) cZ = math.ceil(cZ) end
				return KVX
			end
		else
			return "N/A"
		end
	end
end

function ARGBtoRGB(color) return bit32 or require'bit'.band(color, 0xFFFFFF) end -- конверт цветов

function rel() -- перезагрузка скрипта
	sampAddChatMessage("[MoD-Helper]{FFFFFF} Скрипт перезагружается.", SCRIPTCOLOR)
	reloadScript = true
	thisScript():reload()
end

function clearSeleListBool(var) -- не ебу что-это ахахах ;D
	for i = 1, #SeleList do
		SeleListBool[i].v = false
	end
	SeleListBool[var].v = true
end


function update() -- проверка обновлений
	local zapros = https.request("https://raw.githubusercontent.com/DiPiDi/install/master/update.json")

	if zapros ~= nil then
		local info2 = decodeJson(zapros)

		if info2.latest_number ~= nil and info2.latest ~= nil and info2.drop ~= nil then
			updatever = info2.latest
			version = tonumber(info2.latest_number)
			dropver = tonumber(info2.drop)
			
			print("[Update] Начинаем контроль версий")
			
			if tonumber(thisScript().version_num) <= dropver then
				print("[Update] Used non supported version: "..thisScript().version_num..", actual: "..version)
				sampAddChatMessage("[MoD-Helper]{FFFFFF} Ваша версия более не поддерживается разработчиком, работа скрипта невозможна.", SCRIPTCOLOR)
				reloadScript = true
				thisScript():unload()
			elseif version > tonumber(thisScript().version_num) then
				print("[Update] Обнаружено обновление")
				sampAddChatMessage("[MoD-Helper]{FFFFFF} Обнаружено обновление до версии {"..u8:decode(Secondcolor.v).."}"..updatever..".", SCRIPTCOLOR)
				win_state['update'].v = true
				UpdateNahuy = true
			else
				print("[Update] Новых обновлений нет, контроль версий пройден")
				if checkupd then
					sampAddChatMessage("[MoD-Helper]{FFFFFF} У вас стоит актуальная версия скрипта: {"..u8:decode(Secondcolor.v).."}"..thisScript().version..".", SCRIPTCOLOR)
					sampAddChatMessage("[MoD-Helper]{FFFFFF} Необходимости обновлять скрипт - нет, приятного пользования.", SCRIPTCOLOR)
					checkupd = false
				end
				UpdateNahuy = true
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Ошибка при получении информации об обновлении.", SCRIPTCOLOR)
			print("[Update] JSON file read error")
			UpdateNahuy = true
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Не удалось проверить наличие обновлений, попробуйте позже.", SCRIPTCOLOR)
		UpdateNahuy = true
	end
end

function cmd_color() -- функция получения цвета строки, хз зачем она мне, но когда то юзал
	local text, prefix, color, pcolor = sampGetChatString(99)
	sampAddChatMessage(string.format("Цвет последней строки чата - {934054}[%d] (скопирован в буфер обмена)",color),-1)
	setClipboardText(color)
end

function async_http_request(method, url, args, resolve, reject) -- асинхронные запросы, опасная штука местами, ибо при определенном использовании игра может улететь в аут ;D
	local request_lane = lanes.gen('*', {package = {path = package.path, cpath = package.cpath}}, function()
		local requests = require 'requests'
        local ok, result = pcall(requests.request, method, url, args)
        if ok then
            result.json, result.xml = nil, nil -- cannot be passed through a lane
            return true, result
        else
            return false, result -- return error
        end
    end)
    if not reject then reject = function() end end
    lua_thread.create(function()
        local lh = request_lane()
        while true do
            local status = lh.status
            if status == 'done' then
                local ok, result = lh[1], lh[2]
                if ok then resolve(result) else reject(result) end
                return
            elseif status == 'error' then
                return reject(lh[1])
            elseif status == 'killed' or status == 'cancelled' then
                return reject(status)
            end
            wait(0)
        end
    end)
end

function black_checker(params) -- чекер ЧСа по ID
	if params:match("^%d+") then
		local blackid  = params:match("^(%d+)")
		blackid = tonumber(blackid)
		if sampIsPlayerConnected(blackid) or blackid == myID then
			local blacknick = sampGetPlayerNickname(blackid)
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Если никаких уведомлений после этого сообщения нет - игрока нет в ЧС.", SCRIPTCOLOR)
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Проверяем игрока "..blacknick.." на наличие в черном списке Мин.Обороны.", SCRIPTCOLOR)
			
			if rpblack.v then
				lua_thread.create(function() 
					sampSendChat("/me достав КПК из кармана, "..(lady.v and 'ввела' or 'ввел').." данные человека и сделала запрос в Пентагон")
					wait(2000)
					sampSendChat("/todo После успешного ввода данных*"..(lady.v and 'Сделала' or 'Сделал').." запрос, ожидаем.")
					wait(2000)
					if bstatus == 1 then
						bstatus = 0
						sampSendChat("/do КПК: "..blacknick:gsub("_", " ").." занесен в черный список Министерства Обороны.")
						wait(2000)
						sampSendChat(blacknick:gsub("_.*", "")..", сожалению, но вы состоите в черном списке Министерства Обороны.")
					elseif bstatus == 2 then
						bstatus = 0
						sampSendChat("/do КПК: Записей по "..blacknick:gsub("_", " ").." в черном списке не обнаружено.")
						wait(2000)
						sampSendChat(blacknick:gsub("_.*", "")..", отлично, вас нет в черном списке Министерства Обороны.")
					end
				end)
			end
		
			for k, v in ipairs(blackbase) do
				if v[1]~= nil then
					if blacknick:find(v[1]) then
						sampShowDialog(1488, '{FFD700}ЧС МО | MoD-Helper', "{DC143C}Игрок "..blacknick.." найден в черном списке.\nПричина занесения: "..u8:decode(v[2]), "Закрыть", "", 0)
						bstatus = 1
						checking = false
						break
					end
				end
			end
			black_history(blacknick) -- чек по истории сразу
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Игрок с данным ID не подключен к серверу или указан ваш ID.", SCRIPTCOLOR)
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /black [ID].", SCRIPTCOLOR)
		return
	end
end

function black_history(params) -- чекер ЧСа по нику
	if params:match("^.*") then
		blackn = params:match("^(.*)")
		pidr = false
		for k, v in ipairs(blackbase) do
			if v[1]~= nil then
				if blackn:find(v[1]) then
					sampShowDialog(1488, '{FFD700}ЧС МО | MoD-Helper', "{DC143C}Игрок "..blackn.." найден в черном списке.\nПричина занесения: "..u8:decode(v[2]), "Закрыть", "", 0)
					bstatus = 1
					pidr = true
					break
				end
			end
		end
		if not pidr then
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Проверяем историю ников "..params..".", SCRIPTCOLOR)
			checking = true
			sampSendChat("/history "..blackn.."")
		end
	else 
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /bhist [nick].", SCRIPTCOLOR)
		return
	end
end


function changeSkin(id, skinId) -- визуальная смена скина(imring вроде бы скидывал ее)
    bs = raknetNewBitStream()
    if id == -1 then _, id = sampGetPlayerIdByCharHandle(PLAYER_PED) end
    raknetBitStreamWriteInt32(bs, id)
    raknetBitStreamWriteInt32(bs, skinId)
    raknetEmulRpcReceiveBitStream(153, bs)
    raknetDeleteBitStream(bs)
end

function upd_blacklist() -- обновить список ЧСников
	sampAddChatMessage("[MoD-Helper]{FFFFFF} Начинаем обновление списка ЧС.", SCRIPTCOLOR)
	local path = getGameDirectory() .. '\\moonloader\\MoD-Helper\\blacklist.txt'
	downloadUrlToFile(blackcheckerpath.v, path, function(id, status, p1, p2)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			print('[Blacklist]: Downloaded, preparing..')
			printStringNow("~r~STATUS: ~g~UPDATE", 5000)
			lua_thread.create(function()
				wait(3000)
				local f = io.open(path, 'r')
				local blackF = f:read('*a')
				f:close()
			
				if f then 
					print('[Blacklist]: First preparing completed')
					blackF = blackF:gsub('<.->', '')
					blackList = io.open(path, 'w')
					for w in blackF:gmatch('~ZZ~(.-)~ZZEND~') do 
						blackList:write(w)
					end
					blackList:close()
							
					format_file()
					print('[Blacklist]: Second preparing completed')
					print('[Blacklist]: Update completed')
					printStringNow("~r~STATUS: ~g~UPDATE COMPLETED", 3000)
				else 
					print('[Blacklist]: Preparing error, please, /try again later.')
					sampAddChatMessage("[MoD-Helper]{FFFFFF} Произошла ошибка при обновлении списка ЧС.", SCRIPTCOLOR)
				end
			end)
		end
	end)
end

function ex_find() -- Отыгровка финда
	sampSendChat("/find")
	lua_thread.create(function()
		if rpFind.v then
			sampSendChat("/me "..(lady.v and 'достала' or 'достал').." КПК из кармана и "..(lady.v and 'открыла' or 'открыл').." список бойцов "..(arm == 3 and 'флота' or 'армии'))
			wait(800)
			sampSendChat("/do КПК "..(findCout ~= nil and 'показал информацию, количество бойцов '..(arm == 3 and 'флота' or 'армии')..': '..findCout or 'скрыл информацию о количестве бойцов '..(arm == 3 and 'флота' or 'армии')..'')..".")
			wait(800)
			sampSendChat("/me после ознакомления со списком "..(lady.v and 'закрыла' or 'закрыл').." и "..(lady.v and 'положила' or 'положил').." КПК обратно")				
		end
	end)
end

function sampev.onSendPlayerSync(data)
	if workpause then -- костыль для работы скрипта при свернутой игре
		return false
	end
end

function sampev.onServerMessage(color, text)

	WriteLog(os.date('[%H:%M:%S | %d.%m.%Y]')..' '..text:gsub("{.-}", ""),  'MoD-Helper', 'chatlog') -- запись всех сообщений в лог, тут я подрезал функцию у Вани Мытарева хД

	if ads.v then -- отключаем объявки и переносим их в консольку
		if color == 13369599 and text:find("Отправил") then print("{14ccbd}[ADS]{279c40}".. text) return false end
		if color == 10027263 and text:find("сотрудник") then print("{14ccbd}[ADS]{0f6922}"..text) return false end
	end

	if text == "Вы сняли маску" or text == "Вы надели новую маску и выбросили старую" then -- таймер маски АРП, автора не помню, имеются неточности с подсчетом +- 30 секунд(но это не точно).
		offMask = true
	elseif color == 865730559 and text:find("Ваше месторасположение на GPS скрыто") then
		offMaskTime = os.clock() * 1000 + 600000
		offMask = false
	end


	if color == 1721355519 and text:match("%[F%] .*") then -- получение ранга и ID игрока, который последним написал в /f чат, для тэгов биндера
		lastfradiozv, lastfradioID = text:match('%[F%]%s(.+)%s%a+_%a+%[(%d+)%]: .+')
	elseif color == 869033727 and text:match("%[R%] .*") then -- получение ранга и ID игрока, который последним написал в /r чат, для тэгов биндера
		lastrradiozv, lastrradioID = text:match('%[R%]%s(.+)%s%a+_%a+%[(%d+)%]: .+')
	end

	if color == -577699841 and text:find("взял%(а%)") then -- автоматическая хавка в военной столовке
		if text:find("паёк") or text:find("добавкой") or text:find("десерт") then
			lua_thread.create(function()
				wait(500)
				sampSendChat("/eat")
			end)
		end
		return {color, text}
	end

	if text:match("SMS: .* | Отправитель: .* %[т%.%d+%]") then -- сохраняем входящий номер + отыгровки мобилки + звук
		local tsms, tname, SMS = text:match("SMS: (.*) | Отправитель: (.*) %[т%.(%d+)%]") 
		-- if smsinfo.v and workpause then vkmessage(tonumber(vkid2), text) end
		if inComingSMS.v then
			if phoneModel.v == '' then
				sampSendChat(string.format("/do На телефон пришло сообщение с номера %d.", SMS))
			else
				sampSendChat(string.format("/do На телефон модели %s пришло сообщение с номера %d.", u8:decode(phoneModel.v), SMS))
			end
			sampAddChatMessage(text, 0xFFFF00)
		end
		if smssound.v then bass.BASS_ChannelPlay(asms, false) end
		lastnumberon = SMS 
	end
		
	if text:match("SMS: .* | Получатель: .* %[т%.%d+%]") then -- сохраняем исходящий номер
		local SMSfor = text:match("SMS: .* | Получатель: .* %[т%.(%d+)%]") 
		-- if smsinfo.v and workpause then vkmessage(tonumber(vkid2), text) end
		lastnumberfor = SMSfor 
	end

	if color == 1721355519 and text:find("%[P.E.S.%]: Передаю координаты:") then -- принимаем коорды из пса, если видим в /f чате
		if text:find("%d+E%d+Z%d+") then
			tempx, tempy, tempz = text:match("(%d+)E(%d+)Z(%d+)")
			if tonumber(tempx) < 10000 and tonumber(tempy) < 10000 and tonumber(tempz) < 200 then
				sampAddChatMessage("1", -1)
				tempx = tempx - 3000
				tempy = tempy - 3000
				tempz = tempz - 1
			else
				tempx = nil
				tempy = nil
				tempz = nil
			end
			if tempx ~= nil and tempy ~= nil and tempz ~= nil then
				x1 = tempx
				y1 = tempy
				z1 = tempz
				lastcall = 1
			end  
		end
	end

	-----------------------------------------------------------------------------
	----------------- ПОКРАСКА НИКОВ И ВСЕ ЧТО С ЭТИМ СВЯЗАНО -------------------
	-----------------------------------------------------------------------------

	if ColorFama.v then
		local masss = {}
		table.insert(masss, 1, nikifama1.v)
		table.insert(masss, 2, nikifama2.v)
		table.insert(masss, 3, nikifama3.v)
		table.insert(masss, 4, nikifama4.v)
		table.insert(masss, 5, nikifama5.v)
		table.insert(masss, 6, nikifama6.v)
		table.insert(masss, 7, nikifama7.v)
		table.insert(masss, 8, nikifama8.v)
		table.insert(masss, 9, nikifama9.v)
		table.insert(masss, 10, nikifama10.v)
		for i = 1, 10 do
			if text:find('%('..u8:decode(masss[i])..'%)%[.+%]') then
				local idc = text:match('%[(%d+)%]')
				if tostring(u8:decode(masss[i])):match('%a') then	
					text = text:gsub('%('..u8:decode(masss[i])..'%)%['..idc..'%]', '{'..colornikifama..'}('..u8:decode(masss[i])..')['..idc..']{'..string.format('%X', bit.rshift(color, 8))..'}')
				end
			elseif text:find(''..u8:decode(masss[i])..'%[.+%]:') then
				local idc = text:match('%[(%d+)%]')
				if tostring(u8:decode(masss[i])):match('%a') then	
					text = text:gsub(u8:decode(masss[i])..'%['..idc..'%]:', '{'..colornikifama..'}'..u8:decode(masss[i])..'['..idc..']:{'..string.format('%X', bit.rshift(color, 8))..'}')
				end
			elseif text:find(''..u8:decode(masss[i])..'%[.+%]') and not text:find('| Отправил') then
				local idc = text:match('%[(%d+)%]')
				if tostring(u8:decode(masss[i])):match('%a') then	
					text = text:gsub(u8:decode(masss[i])..'%['..idc..'%]', '{'..colornikifama..'}'..u8:decode(masss[i])..'['..idc..']{'..string.format('%X', bit.rshift(color, 8))..'}')
				end
			elseif text:find(''..u8:decode(masss[i])..'%[.+%]') and text:find('| Отправил') then
				local idc = text:match('%[(%d+)%]')
				if tostring(u8:decode(masss[i])):match('%a') then	
					text = text:gsub(u8:decode(masss[i])..'%['..idc..'%]', '{'..colornikifama..'}'..u8:decode(masss[i])..'['..idc..']{00'..string.format('%X', bit.rshift(color, 8))..'}')
				end
			elseif text:find('%('..u8:decode(masss[i])..'%)') then
				if tostring(u8:decode(masss[i])):match('%a') then	
					text = text:gsub('%('..u8:decode(masss[i])..'%)', '{'..colornikifama..'}('..u8:decode(masss[i])..'){'..string.format('%X', bit.rshift(color, 8))..'}')
				end
			elseif text:find(u8:decode(masss[i])..':') then
				if tostring(u8:decode(masss[i])):match('%a') then	
					text = text:gsub(''..u8:decode(nikifama1.v)..':', '{'..colornikifama..'}'..u8:decode(masss[i])..':{'..string.format('%X', bit.rshift(color, 8))..'}')
				end
			elseif text:find(u8:decode(masss[i])) and not text:find('Объявление проверил сотрудник СМИ') then
				if tostring(u8:decode(masss[i])):match('%a') then	
					text = text:gsub(u8:decode(masss[i]), '{'..colornikifama..'}'..u8:decode(masss[i])..'{'..string.format('%X', bit.rshift(color, 8))..'}')
				end
			elseif text:find(u8:decode(masss[i])) and text:find('Объявление проверил сотрудник СМИ') then
				if tostring(u8:decode(masss[i])):match('%a') then	
					text = text:gsub(u8:decode(masss[i]), '{'..colornikifama..'}'..u8:decode(masss[i])..'{00'..string.format('%X', bit.rshift(color, 8))..'}')
				end
			end
		end
		return { color, text }
	end
end


function load_settings() -- загрузка настроек
	-- CONFIG CREATE/LOAD
	ini = inicfg.load(SET, getGameDirectory()..'\\moonloader\\config\\MoD-Helper\\settings.ini')
	
	-- LOAD CONFIG INFO
	
	gangzones = imgui.ImBool(ini.settings.gangzones)
	zones = imgui.ImBool(ini.settings.zones)
	Zdravia = imgui.ImBool(ini.settings.Zdravia)
	Fixtune = imgui.ImBool(ini.settings.Fixtune)
	MeNuNaX = imgui.ImBool(ini.settings.MeNuNaX)
	ColorFama = imgui.ImBool(ini.settings.ColorFama)
	rpFind = imgui.ImBool(ini.settings.rpFind)
	rptime = imgui.ImBool(ini.settings.rptime)
	assistant = imgui.ImBool(ini.settings.assistant)
	
	autologin = imgui.ImBool(ini.settings.autologin)
	autogoogle = imgui.ImBool(ini.settings.autogoogle)
	googlekey = imgui.ImBuffer(u8(ini.settings.googlekey), 256)
	autopass = imgui.ImBuffer(u8(ini.settings.autopass), 256)
	gnewstag = imgui.ImBuffer(u8(ini.settings.gnewstag), 20)
	colornikifama = imgui.ImBuffer(u8(ini.settings.colornikifama), 7)
	nikifama1 = imgui.ImBuffer(u8(ini.settings.nikifama1), 40)
	nikifama2 = imgui.ImBuffer(u8(ini.settings.nikifama2), 40)
	nikifama3 = imgui.ImBuffer(u8(ini.settings.nikifama3), 40)
	nikifama4 = imgui.ImBuffer(u8(ini.settings.nikifama4), 40)
	nikifama5 = imgui.ImBuffer(u8(ini.settings.nikifama5), 40)
	nikifama6 = imgui.ImBuffer(u8(ini.settings.nikifama6), 40)
	nikifama7 = imgui.ImBuffer(u8(ini.settings.nikifama7), 40)
	nikifama8 = imgui.ImBuffer(u8(ini.settings.nikifama8), 40)
	nikifama9 = imgui.ImBuffer(u8(ini.settings.nikifama9), 40)
	nikifama10 = imgui.ImBuffer(u8(ini.settings.nikifama10), 40)
	textprivet = imgui.ImBuffer(u8(ini.settings.textprivet), 256)
	Secondcolor = imgui.ImBuffer(u8(ini.settings.Secondcolor), 20)
	textpriv = imgui.ImBuffer(u8(ini.settings.textpriv), 256)
	blackcheckerpath = imgui.ImBuffer(u8(ini.settings.blackcheckerpath), 256)
	
	timefix = imgui.ImInt(ini.settings.timefix)
	localskin = imgui.ImInt(ini.settings.skin)
	enableskin = imgui.ImBool(ini.settings.enableskin)


	rpinv = imgui.ImBool(ini.settings.rpinv)
	rprang = imgui.ImBool(ini.settings.rprang)
	rpuninvoff = imgui.ImBool(ini.settings.rpuninvoff)
	rpskin = imgui.ImBool(ini.settings.rpskin)
	rpuninv = imgui.ImBool(ini.settings.rpuninv)

	infZone = imgui.ImBool(ini.informer.zone)
	infHP = imgui.ImBool(ini.informer.hp)
	infArmour = imgui.ImBool(ini.informer.armour)
	infCity = imgui.ImBool(ini.informer.city)
	infKv = imgui.ImBool(ini.informer.kv)
	infTime = imgui.ImBool(ini.informer.time)
	infRajon = imgui.ImBool(ini.informer.rajon)
	infMask = imgui.ImBool(ini.informer.mask)

	screenSave = imgui.ImBool(ini.settings.screenSave)
	rpblack = imgui.ImBool(ini.settings.rpblack)
	smssound = imgui.ImBool(ini.settings.smssound)
	casinoBlock = imgui.ImBool(ini.settings.casinoBlock)
	keyT = imgui.ImBool(ini.settings.keyT)
	marker = imgui.ImBool(ini.settings.marker)
	ads = imgui.ImBool(ini.settings.ads)
	inComingSMS = imgui.ImBool(ini.settings.inComingSMS)
	specUd = imgui.ImBool(ini.settings.specUd)
	chatInfo = imgui.ImBool(ini.settings.chatInfo)
	armOn = imgui.ImBool(ini.settings.armOn)
	timecout = imgui.ImBool(ini.settings.timecout)
	rtag = imgui.ImBuffer(u8(ini.settings.rtag), 256)
	ftag = imgui.ImBuffer(u8(ini.settings.ftag), 256)
	nickdetect = imgui.ImBool(ini.vkint.nickdetect)
	pushv = imgui.ImBool(ini.vkint.pushv)
	smsinfo = imgui.ImBool(ini.vkint.smsinfo)
	remotev = imgui.ImBool(ini.vkint.remotev)
	getradio = imgui.ImBool(ini.vkint.getradio)
	familychat = imgui.ImBool(ini.vkint.familychat)
	enable_tag = imgui.ImBool(ini.settings.enable_tag)
	FPSunlock = imgui.ImBool(ini.settings.FPSunlock)
	gos1 = imgui.ImBuffer(u8(ini.settings.gos1), 256)
	gos2 = imgui.ImBuffer(u8(ini.settings.gos2), 256)
	gos3 = imgui.ImBuffer(u8(ini.settings.gos3), 256)
	gos4 = imgui.ImBuffer(u8(ini.settings.gos4), 256)
	gos5 = imgui.ImBuffer(u8(ini.settings.gos5), 256)
	
	timerp = imgui.ImBuffer(u8(ini.settings.timerp), 256)
	timeBrand = imgui.ImBuffer(u8(ini.settings.timeBrand), 256)
	phoneModel = imgui.ImBuffer(u8(ini.settings.phoneModel), 256)
	spOtr = imgui.ImBuffer(u8(ini.settings.spOtr), 256)
	lady = imgui.ImBool(ini.settings.lady)
	timeToZp = imgui.ImBool(ini.settings.timeToZp)
	gateOn = imgui.ImBool(ini.settings.gateOn)
	lockCar = imgui.ImBool(ini.settings.lockCar)
	strobesOn = imgui.ImBool(ini.settings.strobes)
	infoX = ini.settings.infoX
	infoY = ini.settings.infoY
	infoX2 = ini.settings.infoX2
	infoY2 = ini.settings.infoY2
	findX = ini.settings.findX
	findY = ini.settings.findY
	R = ini.settings.R
	G = ini.settings.G
	B = ini.settings.B
	Theme = ini.settings.Theme
	SCRIPTCOLOR = ini.settings.SCRIPTCOLOR
	asX = ini.assistant.asX
	asY = ini.assistant.asY
	-- END CONFIG WORKING
end


function cmd_histid(params) -- история ников по ID
	if params:match("^%d+") then
		params = tonumber(params:match("^(%d+)"))
		if sampIsPlayerConnected(params) or myID == tonumber(params) then
			local histnick = sampGetPlayerNickname(params)
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Проверяем историю ников игрока "..histnick..".", SCRIPTCOLOR)
			sampSendChat("/history "..histnick)
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Игрок с данным ID не подключен к серверу.", SCRIPTCOLOR)
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /hist [ID].", SCRIPTCOLOR)
	end
end

function rradio(params) -- обработка /r
	if mtag ~= "M" then -- запрещаем министру обороны /r чат
		if #params:match("^.*") > 0 then
			local params = params:match("^(.*)")
			if params:find("%(%(") or params:find("%)%)") or params:find("%)") or params:find("%(") then
				params = params:gsub("%(", "")
				params = params:gsub("%)", "")
				sampAddChatMessage("[MoD-Helper]{FFFFFF} Сообщение определено как OOC и автоматически обработано. Запрещенные символы: %( и %).", SCRIPTCOLOR)
				sampSendChat(string.format("/r (( %s ))", params))
			else
				if rtag.v == '' then
					sampSendChat(string.format("/r %s", params))
				else
					sampSendChat(string.format("/r [%s]: %s", u8:decode(rtag.v), params))
				end
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /r [text].", SCRIPTCOLOR)	
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Вам недоступна данная рация.", SCRIPTCOLOR)
	end
end

function fradio(params) -- обработка /f
	if #params:match("^.*") > 0 then
		local params = tostring(params:match("^(.*)"))
		if params:find("%(%(") or params:find("%)%)") or params:find("%)") or params:find("%(") then
			params = params:gsub("%(", "")
			params = params:gsub("%)", "")
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Сообщение определено как OOC и автоматически обработано. Запрещенные символы: %( и %).", SCRIPTCOLOR)
			sampSendChat(string.format("/f (( %s ))", params))
		else 
			if mtag == "M" then
				sampSendChat(string.format("/f %s", params))
			else
				if ftag.v == '' then
					sampSendChat(string.format("/f %s", params))
				else
					sampSendChat(string.format("/f [%s]: %s", u8:decode(ftag.v), params))
				end
			end
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /f [text].", SCRIPTCOLOR)
	end
end

function cmd_livrby(params) -- просьба увала
	if isPlayerSoldier then
		if nasosal_rang <= 4 and nasosal_rang ~= 10 and nasosal_rang ~= 8 and nasosal_rang ~= 8 then sampAddChatMessage("[MoD-Helper]{FFFFFF} Данная команда доступна с 5 по 7 ранг.", SCRIPTCOLOR) return end
		if params:match("^%d+%s.*") then
			local livid, rsn = params:match("^(%d+)%s(.*)")
			if sampIsPlayerConnected(livid) then
				local livname = string.gsub(sampGetPlayerNickname(livid), '_', ' ')
				if rtag.v == '' then
					sampSendChat(string.format("/r Запрашиваю отставку бойца %s#%d.", livname, livid))
					sampSendChat(string.format("/r Причина: %s", rsn))
				else
					sampSendChat(string.format("/r [%s]: Запрашиваю отставку бойца %s#%d.", u8:decode(rtag.v), livname, livid))
					sampSendChat(string.format("/r [%s]: Причина: %s", u8:decode(rtag.v), rsn))
				end
			else
				sampAddChatMessage("[MoD-Helper]{FFFFFF} Игрок с данным ID не подключен к серверу или указан ваш ID.", SCRIPTCOLOR)
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /livr [ID] [Причина].", SCRIPTCOLOR)
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Недоступно на данном сервере или вы не военнослужащий.", SCRIPTCOLOR)
	end
end

function cmd_livfby(params) -- просьба увала
	if isPlayerSoldier then
		if nasosal_rang <= 4 and nasosal_rang ~= 10 and nasosal_rang ~= 8 and nasosal_rang ~= 8 then sampAddChatMessage("[MoD-Helper]{FFFFFF} Данная команда доступна с 5 по 7 ранг.", SCRIPTCOLOR) return end
		if params:match("^%d+%s.*") then
			local livid, rsn = params:match("^(%d+)%s(.*)")
			if sampIsPlayerConnected(livid) then
				local livname = string.gsub(sampGetPlayerNickname(livid), '_', ' ')
				if ftag.v == '' then
					sampSendChat(string.format("/f Запрашиваю отставку бойца %s#%d.", livname, livid))
					sampSendChat(string.format("/f Причина: %s", rsn))
				else
					sampSendChat(string.format("/f [%s]: Запрашиваю отставку бойца %s#%d.", u8:decode(ftag.v), livname, livid))
					sampSendChat(string.format("/f [%s]: Причина: %s", u8:decode(ftag.v), rsn))
				end
			else
				sampAddChatMessage("[MoD-Helper]{FFFFFF} Игрок с данным ID не подключен к серверу или указан ваш ID.", SCRIPTCOLOR)
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /livf [ID] [Причина].", SCRIPTCOLOR)
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Недоступно на данном сервере или вы не военнослужащий.", SCRIPTCOLOR)
	end
end

function livraport(params) -- просьба увала [Рапорт отстранения]: Ник отстранен. Причина: Сон в неположенном месте.               [Рапорт отстранения]: Жетон id отстранен. Причина: причина
	if isPlayerSoldier then
		if nasosal_rang <= 4 then 
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Данная команда доступна с 5 по 7 ранг.", SCRIPTCOLOR) 
			return 
		end
		if params:match("^%d+%s.*") then
			local livid, rsn = params:match("^(%d+)%s(.*)")
			if sampIsPlayerConnected(livid) then
				local livname = string.gsub(sampGetPlayerNickname(livid), '_', ' ')	
				sampSendChat(string.format("/do [Рапорт отстранения]: Жетон %d отстранен. Причина: %s", livid, rsn))
				if nasosal_rang > 7 then
					lua_thread.create(function()
						if rpuninvoff.v then
							sampSendChat("/me "..(lady.v and 'достала' or 'достал').." КПК, после чего "..(lady.v and 'вошла' or 'зашел').." в базу данных военнослужащих")
							wait(1000)
							sampSendChat(string.format("/me "..(lady.v and 'отметила' or 'пометил').." личное дело %d как «Уволен»", livid))
							wait(250)
						end
						sampSendChat(string.format("/uninviteoff %d %s", livid, rsn))
					end)
				end
			else
				sampAddChatMessage("[MoD-Helper]{FFFFFF} Игрок с данным ID не подключен к серверу или указан ваш ID.", SCRIPTCOLOR)
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /raport [ID] [Причина].", SCRIPTCOLOR)
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Недоступно на данном сервере или вы не военнослужащий.", SCRIPTCOLOR)
	end
end

function ex_uninvite(params) -- увал из организации
	if isPlayerSoldier then
		if nasosal_rang <= 7 and developMode ~= 1 then sampAddChatMessage("[MoD-Helper]{FFFFFF} Данная команда доступна с 8 ранга.", SCRIPTCOLOR) return end
		if params:match("^%d+%s.*") then
			local uid, ureason = params:match("^(%d+)%s(.*)")
			if sampIsPlayerConnected(uid) then
				local uname = sampGetPlayerNickname(uid):gsub('_', ' ')
				lua_thread.create(function()
					if rpuninv.v then
						sampSendChat("/me "..(lady.v and 'достала' or 'достал').." КПК, после чего "..(lady.v and 'зашла' or 'зашел').." в базу данных военнослужащих")
						wait(1000)
						sampSendChat(string.format("/me "..(lady.v and 'отметила' or 'отметил').." личное дело %s как «Уволен»", uname))
						wait(250)

						if ftag.v == '' then
							sampSendChat(string.format("/f Боец %s был отправлен в отставку.", mtag, uname))
							wait(500)
							sampSendChat(string.format("/f Причина отставки: %s", ureason))
						else
							sampSendChat(string.format("/f [%s]: Боец %s был отправлен в отставку.", u8:decode(ftag.v), uname))
							wait(500)
							sampSendChat(string.format("/f [%s]: Причина отставки: %s", u8:decode(ftag.v), ureason))
						end
					end
					wait(250)
					sampSendChat(string.format("/uninvite %d %s", uid, ureason))
				end)
			else
				sampAddChatMessage("[MoD-Helper]{FFFFFF} Игрок с данным ID не подключен к серверу или указан ваш ID.", SCRIPTCOLOR)
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /uninvite [ID] [Причина].", SCRIPTCOLOR)
		end
	else
		sampSendChat("/uninvite "..params)
	end
end

function ex_uninviteoff(params) -- увал в оффе
	if isPlayerSoldier then
		if nasosal_rang ~= 10 and developMode ~= 1 then sampAddChatMessage("[MoD-Helper]{FFFFFF} Данная команда доступна только лидеру.", SCRIPTCOLOR) return end
		if params:match("^%S+%s.*") then
			local uid, ureason = params:match("^(%S+)%s(.*)")	
			local uname = uid:gsub('_', ' ')
			lua_thread.create(function()
				if rpuninvoff.v then
					sampSendChat("/me "..(lady.v and 'достала' or 'достал').." КПК, после чего "..(lady.v and 'вошла' or 'зашел').." в базу данных военнослужащих")
					wait(1000)
					sampSendChat(string.format("/me "..(lady.v and 'отметила' or 'пометил').." личное дело %s как «Уволен»", uname))
					wait(250)

					if ftag.v == '' then
						sampSendChat(string.format("/f Боец %s был отправлен в отставку.", uname))
						wait(500)
						sampSendChat(string.format("/f Причина отставки: %s", ureason))
					else
						sampSendChat(string.format("/f [%s]: Боец %s был отправлен в отставку.", u8:decode(ftag.v), uname))
						wait(500)
						sampSendChat(string.format("/f [%s]: Причина отставки: %s", u8:decode(ftag.v), ureason))
					end
				end
				sampSendChat(string.format("/uninviteoff %s %s", uid, ureason))
			end)
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /uninviteoff [Ник] [Причина].", SCRIPTCOLOR)
		end
	else
		sampSendChat("/uninviteoff "..params)
	end
end

function ex_skin(params) -- смена скина
	if isPlayerSoldier then
		if (nasosal_rang <= 7) and (developMode ~= 1) then sampAddChatMessage("[MoD-Helper]{FFFFFF} Данная команда доступна с 8 ранга.", SCRIPTCOLOR) return end
		if params:match("^%d+") then
			local uid = params:match("^(%d+)")
			if sampIsPlayerConnected(uid) or myID == tonumber(params) then
				local uname = sampGetPlayerNickname(uid):gsub('_', ' ')
				lua_thread.create(function()
					if rpskin.v then
						sampSendChat("/do В руках заранее подготовленный комплект с формой.")
						wait(1000)						
						sampSendChat(string.format("/me "..(lady.v and 'передала' or 'выдал').." пакет с формой для %s", uname))
						wait(500)
					end
					sampSendChat(string.format("/changeskin %d", uid))
				end)
			else
				sampAddChatMessage("[MoD-Helper]{FFFFFF} Игрок с данным ID не подключен к серверу.", SCRIPTCOLOR)
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /changeskin [ID].", SCRIPTCOLOR)
		end
	else
		sampSendChat("/changeskin "..params)
	end
end

function ex_rang(params) -- повышение ранга
	if isPlayerSoldier then
		if nasosal_rang <= 8 and developMode ~= 1 then sampAddChatMessage("[MoD-Helper]{FFFFFF} Данная команда доступна с 9 ранга.", SCRIPTCOLOR) return end
		if params:match("^%d+%s%d+%s.*") then
			local uid, rcout, utype = params:match("^(%d+)%s(%d+)%s(.*)")
			rcout = tonumber(rcout)
			if sampIsPlayerConnected(uid) then
				lua_thread.create(function()
					if rcout <= 0 or rcout >= 5 then sampAddChatMessage("[MoD-Helper]{FFFFFF} Ограничение на количество повышения от 1 до 4.", SCRIPTCOLOR) return end
					if rprang.v then
						local uname = sampGetPlayerNickname(uid):gsub('_', ' ')
						sampSendChat("/do Сумка с новыми погонами в руке.")
						wait(1500)
						sampSendChat(string.format("/me "..(lady.v and 'открыла' or 'открыл').." сумку с погонами и "..(lady.v and 'достала' or 'достал').." нужные для %s", uname))
						wait(1500)
						sampSendChat(string.format("/me "..(lady.v and 'передала' or 'выдал').." новые погоны %s", uname))
						wait(500)
						sampSendChat("/anim 21")
					end
					
					if utype == "+" then
						for i = 1, rcout do
							sampSendChat(string.format("/rang %s +", uid))
							wait(700)
						end
					elseif utype == "-" then
						for i = 1, rcout do
							sampSendChat(string.format("/rang %s -", uid))
							wait(700)
						end
					else
						if rprang.v then
							sampSendChat("/me понял, что что-то пошло не так")
							wait(1500)
							sampSendChat("Дико извиняюсь, я малость заработался..")
						else
							sampAddChatMessage("[MoD-Helper]{FFFFFF} Вы ввели неверный тип [+/-].", SCRIPTCOLOR) return
						end
					end
				end)
			else
				sampAddChatMessage("[MoD-Helper]{FFFFFF} Игрок с данным ID не подключен к серверу или указан ваш ID.", SCRIPTCOLOR)
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /rang [ID] [Количество] [+/-].", SCRIPTCOLOR)
		end
	else
		sampSendChat("/rang "..params)
	end
end

function ex_invite(params) -- инвайты игроков
	if isPlayerSoldier then
		if nasosal_rang <= 8 and developMode ~= 1 then sampAddChatMessage("[MoD-Helper]{FFFFFF} Данная команда доступна с 9 ранга.", SCRIPTCOLOR) return end
		if params:match("^%d+") then
			local uid, utype = params:match("^(%d+)")
			if sampIsPlayerConnected(uid) then
				local uname = sampGetPlayerNickname(uid):gsub('_', ' ')
				lua_thread.create(function()
					if rpinv.v then
						if arm == 3 then
							sampSendChat("/do В руках пакет с новой военной формой и рацией U.S. Navy.")
						elseif arm == 1 then
							sampSendChat("/do В руках пакет с новой военной формой и рацией U.S. Ground Force.")
						elseif arm == 2 then
							sampSendChat("/do В руках пакет с новой военной формой и рацией U.S. Air Force.")
						end
						wait(1000)

						sampSendChat(string.format("/me "..(lady.v and 'передала' or 'выдал').." пакет новобранцу по имени %s", uname))
						wait(1000)

						sampSendChat(string.format("%s, переодевайтесь, рацию на пояс.", uname))
						wait(1500)
						sampSendChat("На портале штата Вы обязаны ознакомиться с уставом и реформами.")
						wait(100)
					end
					sampSendChat(string.format("/invite %d", uid))
				end)
			else
				sampAddChatMessage("[MoD-Helper]{FFFFFF} Игрок с данным ID не подключен к серверу или указан ваш ID.", SCRIPTCOLOR)
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /invite [ID].", SCRIPTCOLOR)
		end
	else
		sampSendChat("/invite "..params)
	end
end

function cmd_uninvby(params) -- увал по просьбе
	if isPlayerSoldier then
		if nasosal_rang <= 7 and developMode ~= 1 and mtag ~= "M" then sampAddChatMessage("[MoD-Helper]{FFFFFF} Данная команда доступна с 8 ранга и лидеру организации.", SCRIPTCOLOR) return end
		if params:match("^%d+%s%d+%s.*") then
			local livid, fromid, rsn = params:match("^(%d+)%s(%d+)%s(.*)")
			if sampIsPlayerConnected(livid) then 
				local fromid = string.gsub(sampGetPlayerNickname(fromid), '_', ' ')
				local uname = string.gsub(sampGetPlayerNickname(livid), '_', ' ')

				lua_thread.create(function()
					if rpuninv.v then
						sampSendChat("/me "..(lady.v and 'достала' or 'достал').." КПК, после чего "..(lady.v and 'вошла' or 'зашел').." в базу данных военнослужащих")
						wait(1000)
						sampSendChat(string.format("/me "..(lady.v and 'пометила' or 'отметил').." личное дело %s как «Уволен»", uname))
						wait(250)

						if ftag.v == '' then
							sampSendChat(string.format("/f Боец %s был отправлен в отставку по жалобе офицера.", uname))
							sampSendChat(string.format("/f Причина отставки: %s | Офицер: %s", rsn, fromid))
						else
							sampSendChat(string.format("/f [%s]: Боец %s был отправлен в отставку по жалобе офицера.", u8:decode(ftag.v), uname))
							sampSendChat(string.format("/f [%s]: Причина отставки: %s | Офицер: %s", u8:decode(ftag.v), rsn, fromid))
						end
					end
					sampSendChat(string.format("/uninvite %d %s | %s ", livid, rsn, fromid))
				end)
			else
				sampAddChatMessage("[MoD-Helper]{FFFFFF} Игрок с данным ID не подключен к серверу или указан ваш ID.", SCRIPTCOLOR)
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /uninv [ID] [ID офицера] [Причина].", SCRIPTCOLOR)
		end
	end
end

function cmd_where(params) -- запрос местоположения
	if params:match("^%d+") then
		params = tonumber(params:match("^(%d+)"))
		if sampIsPlayerConnected(params) then
			local name = string.gsub(sampGetPlayerNickname(params), "_", " ")
			if rtag.v == '' then
				sampSendChat(string.format("/r %s, доложите свое местоположение. На ответ 20 секунд.", name))
			else
				sampSendChat(string.format("/r [%s]: %s, доложите свое местоположение. На ответ 20 секунд.", u8:decode(rtag.v), name))
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Игрок с данным ID не подключен к серверу или указан ваш ID.", SCRIPTCOLOR)
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /where [ID].", SCRIPTCOLOR)
	end
end

function cmd_ok(params) -- прием докладов
	if params:match("^%d+") then
		params = tonumber(params:match("^(%d+)"))
		if sampIsPlayerConnected(params) then
			local name = string.gsub(sampGetPlayerNickname(params), "_", " ")
			if rtag.v == '' then
				sampSendChat(string.format("/r %s, ваш доклад принят!", name))
			else
				sampSendChat(string.format("/r [%s]: %s, ваш доклад принят!", u8:decode(rtag.v), name))
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Игрок с данным ID не подключен к серверу или указан ваш ID.", SCRIPTCOLOR)
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /ok [ID].", SCRIPTCOLOR)
	end
end

function ex_dice(params) -- еще одна часть антиказино, если включено - /dice отрубаем
	if not casinoBlock.v then
		if params:match("^%d+%s%d+") then
			local casinoID, cmoney = params:match("^(%d+)%s(%d+)")
			sampSendChat(string.format("/dice %d %d", casinoID, cmoney))
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /dice [ID] [Ставка].", SCRIPTCOLOR)
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Мы сохраним ваши средства! Лучше отправь их на 89799(Red) или 1655(Lime).", SCRIPTCOLOR)
	end
end

function cmd_ud(params) -- удостоверение только для вояк
	lua_thread.create(function()
		if isPlayerSoldier then
			if params:match("^%d+") then
				local udID = params:match("^(%d+)")	
				if myID == tonumber(udID) or sampIsPlayerConnected(udID) then
					local name = sampGetPlayerNickname(udID):gsub("_", " ")
					if arm == 1 then
						sampSendChat("/do Удостоверение U.S. Ground Force в левом кармане.")
					elseif arm == 2 then
						sampSendChat("/do Удостоверение U.S. Air Force в левом кармане.")
					elseif arm == 3 then
						sampSendChat("/do Удостоверение U.S. Navy в левом кармане.")
					end
					wait(800)
					sampSendChat(string.format("/me достав удостоверение, "..(lady.v and 'предъявила' or 'предъявил').." его %s", name))
					wait(800)
					if specUd.v and spOtr.v ~= '' then
						sampSendChat(string.format("/do %s | %s | %s | Военнослужащий Мин.Обороны США.", mtag, nickName, u8:decode(spOtr.v)))
					else
						sampSendChat(string.format("/do %s | %s | Военнослужащий Мин.Обороны США.", mtag, nickName))
					end
					wait(800)
					sampSendChat("/me "..(lady.v and 'убрала' or 'убрал').." удостоверение обратно")
				else
					sampAddChatMessage("[MoD-Helper]{FFFFFF} Игрок с данным ID не подключен к серверу.", SCRIPTCOLOR)
				end
			else
				sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /ud [ID].", SCRIPTCOLOR)
			end
		end
	end)
end

function cmd_rn(params) -- OOC чат /r
	if #params:match("^.*") > 0 then
		params = tostring(params:match("^(.*)"))
		sampSendChat("/r (( "..params.. " ))")
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /rn [text].", SCRIPTCOLOR)
	end
end

function cmd_fn(params) -- OOC чат /f
	if #params:match("^.*") > 0 then
		params = tostring(params:match("^(.*)"))
		sampSendChat("/f (( "..params.. " ))")
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /fn [text].", SCRIPTCOLOR)
	end
end

function addGangZone(id, left, up, right, down, color) -- создание гангзоны
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt16(bs, id)
    raknetBitStreamWriteFloat(bs, left)
    raknetBitStreamWriteFloat(bs, up)
    raknetBitStreamWriteFloat(bs, right)
    raknetBitStreamWriteFloat(bs, down)
    raknetBitStreamWriteInt32(bs, color)
    raknetEmulRpcReceiveBitStream(108, bs)
    raknetDeleteBitStream(bs)
end

function removeGangZone(id) -- удаление гангзоны
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt16(bs, id)
    raknetEmulRpcReceiveBitStream(120, bs)
    raknetDeleteBitStream(bs)
end

function showInputHelp() -- chatinfo(для меня) и showinputhelp от хомяка ес не ошибаюсь
	while true do
		local chat = sampIsChatInputActive()
		if chat == true then
			local in1 = getStructElement(sampGetInputInfoPtr(), 0x8, 4)
			local in2 = getStructElement(in1, 0x8, 4)
			local in3 = getStructElement(in1, 0xC, 4)
			fib = in3 + 48
			fib2 = in2 + 10
			local _, mmyID = sampGetPlayerIdByCharHandle(PLAYER_PED)
			local nname = sampGetPlayerNickname(mmyID)
			local score = sampGetPlayerScore(mmyID)
			local color = sampGetPlayerColor(mmyID)
			local capsState = ffi.C.GetKeyState(20)
			local success = ffi.C.GetKeyboardLayoutNameA(KeyboardLayoutName)
			local errorCode = ffi.C.GetLocaleInfoA(tonumber(ffi.string(KeyboardLayoutName), 16), 0x00000002, LocalInfo, BuffSize)
			local localName = ffi.string(LocalInfo)
			local text = string.format(
				"%s :: {%0.6x}%s[%d] {ffffff}:: Капс: %s {FFFFFF}:: Язык: {ffeeaa}%s{ffffff}",
				os.date("%H:%M:%S"), bit.band(color,0xffffff), nname, mmyID, getStrByState(capsState), string.match(localName, "([^%(]*)")
			)
			
			if chatInfo.v and sampIsLocalPlayerSpawned() and nname ~= nil then renderFontDrawText(inputHelpText, text, fib2, fib, 0xD7FFFFFF) end
			end
		wait(0)
	end
end

function getStrByState(keyState) -- состояние клавиш для chatinfo
	if keyState == 0 then
		return "{ffeeaa}Выкл{ffffff}"
	end
	return "{9EC73D}Вкл{ffffff}"
end

function reconnect() -- реконнект игрока
	lua_thread.create(function()
		sampSetGamestate(5)
		sampDisconnectWithReason()
		wait(18000) 
		sampSetGamestate(1)
	end)
end

function sampev.onSetCheckpoint(position,radius)
	pX, pY, pZ = getCharCoordinates(playerPed)
	if getDistanceBetweenCoords3d(pX, pY, pZ, 2235.00, 1604.00, 1006.00) < 50 then -- проверяем игрока на калигулу
		if casinoBlock.v then
			sampAddChatMessage("[MoD-Helper]{FFFFFF} Ваши деньги - наша задача! Лучше отправь их на 89799(Red) или 1655(Lime)., чем слей в казике!", SCRIPTCOLOR)
			reconnect()
			return false
		end
	end
end

function random_messages() -- рандомные сообщения
	lua_thread.create(function()
		local messages = {
			{ "Прежде всего помните - вы солдат, помните свою роль и быть может играть станет интересней.", "Не забывайте про субординацию и устав армии, приятной игры." },
			{ "Если вам понравилась задумка скрипта, но вам чего то не хватает, есть выход!", "Свяжитесь с разработчиком, предложите свою идею, помогите в развитии :)" },
			{ "В случае возникновения каких либо проблем со скриптом - обратитесь к разработчику.", "Мы стараемся делать работу со скриптом приятной и комфортной для своих пользователей." },
			{ "Разработчик скрипта выступают против биндерботства и деградации.", "В связи с этим мы используем только незначительные отыгровки, которые никак не влияют на РП процесс." },
			{ "Участились случаи похищений в нелюдных местах от псевдо агентов ФБР.", "Если вы видите таких - фрапсите и старайтесь уйти от них любой ценой, кроме суицида/оффа, это наказывается." },
			{ "Если вы заметили грубое нарушение от сослуживца - не нужно молчать.", "Нужно бороться с несоблюдением правил и субординации, помогите нам, внесите свой вклад!" },
			{ "Ты считаешь, что достоин большего? Ты считаешь, что тебя должны уважать? Ты правда хочешь этого?", "Поднимайте по карьерной лестнице в Мин.Обороны, занимай высокие должности и пробивай свои преграды, как будто их нет!" },
			{ "Если вы заметили ЧС или подозрительную активность рядом с военными объектами - сообщите!", "Ведь именно ваше сообщение может предупредить сослуживцев о возможной стычке с врагами!"},
			{ "Помните, при использовании летной техники необходимо соблюдать безопасную от пуль высоту и уметь маневрировать!", "Помимо этого, если вы за штурвалом Apache или Hydra - не применяйте вооружение без приказа высшего командования!" },
			{ "При использовании рации - будьте адекватны, не оскорбляйте и не провоцируйте людей.", "Если вы хотите покинуть ряды армии - не флудите об этом, быть может вас никто физически не может уволить." },
			{ "Всегда носите бронежилет, держите при себе патроны и металл, ведь именно они могут вас спасти." }
		}
		while true do
			math.randomseed(os.time())
			wait(300000)
			for _, v in pairs(messages[math.random(1, #messages)]) do
				sampAddChatMessage("[MoD-Helper]{FFFFFF} "..v, SCRIPTCOLOR)
			end
			wait(3000000)
		end
	end)
end

function cmd_rd(params) -- доклады в /r чат
	if params:match("^.*%s.*") then		
		local post, sost = params:match("^(.*)%s(.*)")
		sampSendChat("/r "..(rtag.v ~= '' and '['..u8:decode(rtag.v)..']' or '').." Докладываю, пост: "..post.." | Состояние: "..sost)

		if screenSave.v then
			lua_thread.create(function()
				sampSendChat((srv <= 9 and '/c 60' or '/time'))
				wait(500)
				memory.setint8(sampGetBase() + 0x119CBC, 1)
			end)
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /rd [Пост] [Состояние].", SCRIPTCOLOR)
	end
end

function cmd_fd(params) -- доклады в /f чат
	if params:match("^.*%s.*") then
		local post, sost = params:match("^(.*)%s(.*)")
		if ftag.v == '' then
			sampSendChat(string.format("/f Докладываю, пост: %s | Состояние: %s", post, sost))
		else
			sampSendChat(string.format("/f [%s]: Докладываю, пост: %s | Состояние: %s", u8:decode(ftag.v), post, sost))
		end
		if screenSave.v then
			lua_thread.create(function()
				sampSendChat("/c 60")
				wait(500)
				memory.setint8(sampGetBase() + 0x119CBC, 1)
			end)
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Используйте: /fd [Пост] [Состояние].", SCRIPTCOLOR)
	end
end

function format_file() --запись чсников в таблицу
	blackbase = {}
	for line in io.lines(getWorkingDirectory().."\\MoD-Helper\\blacklist.txt") do
		name, reason = line:match("(%a+_?%a+)(.+)")
		temp = {name, reason}
		table.insert(blackbase, temp)
	end
end

function drone() -- дрон/камхак, дополнение камхака санька
	lua_thread.create(function()
		if droneActive then
			sampAddChatMessage("[MoD-Helper]{FFFFFF} На данный момент вы уже управляете дроном.", SCRIPTCOLOR)
			return
		end
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Управление дроном клавишами: {"..u8:decode(Secondcolor.v).."}W, A, S, D, Space, Shift{FFFFFF}.", SCRIPTCOLOR)
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Режимы дрона: {"..u8:decode(Secondcolor.v).."}Numpad1, Numpad2, Numpad3{FFFFFF}.", SCRIPTCOLOR)
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Скорость полета дрона: {"..u8:decode(Secondcolor.v).."}+(быстрей), -(медленней){FFFFFF}.", SCRIPTCOLOR)
		sampAddChatMessage("[MoD-Helper]{FFFFFF} Заверешить пилотирование дроном можно клавишей {"..u8:decode(Secondcolor.v).."}Enter{FFFFFF}.", SCRIPTCOLOR)
		while true do
			wait(0)
			if flymode == 0 then
				droneActive = true
				posX, posY, posZ = getCharCoordinates(playerPed)
				angZ = getCharHeading(playerPed)
				angZ = angZ * -1.0
				setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
				angY = 0.0
				flymode = 1
			end
			if flymode == 1 and not sampIsChatInputActive() and not isSampfuncsConsoleActive() then
				offMouX, offMouY = getPcMouseMovement()  
				offMouX = offMouX / 4.0
				offMouY = offMouY / 4.0
				angZ = angZ + offMouX
				angY = angY + offMouY
				
				if angZ > 360.0 then angZ = angZ - 360.0 end
				if angZ < 0.0 then angZ = angZ + 360.0 end
		
				if angY > 89.0 then angY = 89.0 end
				if angY < -89.0  then angY = -89.0 end   

				if isKeyDown(VK_W) then      
					radZ = math.rad(angZ) 
					radY = math.rad(angY)                   
					sinZ = math.sin(radZ)
					cosZ = math.cos(radZ)      
					sinY = math.sin(radY)
					cosY = math.cos(radY)       
					sinZ = sinZ * cosY      
					cosZ = cosZ * cosY 
					sinZ = sinZ * speed      
					cosZ = cosZ * speed       
					sinY = sinY * speed  
					posX = posX + sinZ 
					posY = posY + cosZ 
					posZ = posZ + sinY      
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)      
				end 
				
				if isKeyDown(VK_S) then  
					curZ = angZ + 180.0
					curY = angY * -1.0      
					radZ = math.rad(curZ) 
					radY = math.rad(curY)                   
					sinZ = math.sin(radZ)
					cosZ = math.cos(radZ)      
					sinY = math.sin(radY)
					cosY = math.cos(radY)       
					sinZ = sinZ * cosY      
					cosZ = cosZ * cosY 
					sinZ = sinZ * speed      
					cosZ = cosZ * speed       
					sinY = sinY * speed                       
					posX = posX + sinZ 
					posY = posY + cosZ 
					posZ = posZ + sinY      
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)      
				end 
				
		
				if isKeyDown(VK_A) then  
					curZ = angZ - 90.0      
					radZ = math.rad(curZ) 
					radY = math.rad(angY)                   
					sinZ = math.sin(radZ)
					cosZ = math.cos(radZ)       
					sinZ = sinZ * speed      
					cosZ = cosZ * speed                             
					posX = posX + sinZ 
					posY = posY + cosZ      
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)     
				end 
		
				radZ = math.rad(angZ) 
				radY = math.rad(angY)             
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * 1.0      
				cosZ = cosZ * 1.0     
				sinY = sinY * 1.0        
				poiX = posX
				poiY = posY
				poiZ = posZ      
				poiX = poiX + sinZ 
				poiY = poiY + cosZ 
				poiZ = poiZ + sinY      
				pointCameraAtPoint(poiX, poiY, poiZ, 2)       
		
				if isKeyDown(VK_D) then  
					curZ = angZ + 90.0      
					radZ = math.rad(curZ) 
					radY = math.rad(angY)                   
					sinZ = math.sin(radZ)
					cosZ = math.cos(radZ)       
					sinZ = sinZ * speed      
					cosZ = cosZ * speed                             
					posX = posX + sinZ 
					posY = posY + cosZ      
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)      
				end 
		
				radZ = math.rad(angZ) 
				radY = math.rad(angY)             
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * 1.0      
				cosZ = cosZ * 1.0     
				sinY = sinY * 1.0        
				poiX = posX
				poiY = posY
				poiZ = posZ      
				poiX = poiX + sinZ 
				poiY = poiY + cosZ 
				poiZ = poiZ + sinY      
				pointCameraAtPoint(poiX, poiY, poiZ, 2)   
		
				if isKeyDown(VK_SPACE) then  
					posZ = posZ + speed      
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)      
				end 
		
				radZ = math.rad(angZ) 
				radY = math.rad(angY)             
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * 1.0      
				cosZ = cosZ * 1.0     
				sinY = sinY * 1.0       
				poiX = posX
				poiY = posY
				poiZ = posZ      
				poiX = poiX + sinZ 
				poiY = poiY + cosZ 
				poiZ = poiZ + sinY      
				pointCameraAtPoint(poiX, poiY, poiZ, 2)
				
				if isKeyDown(VK_SHIFT) then  
					posZ = posZ - speed
					setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)      
				end 
				
				radZ = math.rad(angZ) 
				radY = math.rad(angY)             
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * 1.0      
				cosZ = cosZ * 1.0     
				sinY = sinY * 1.0       
				poiX = posX
				poiY = posY
				poiZ = posZ      
				poiX = poiX + sinZ 
				poiY = poiY + cosZ 
				poiZ = poiZ + sinY      
				pointCameraAtPoint(poiX, poiY, poiZ, 2) 
			
				if isKeyDown(187) then 
					speed = speed + 0.01
				end 
				if isKeyDown(189) then
					speed = speed - 0.01
					if speed < 0.01 then speed = 0.01 end
				end
				if isKeyDown(VK_NUMPAD1) then
					setInfraredVision(true)
				end
				if isKeyDown(VK_NUMPAD2) then
					setNightVision(true)
				end
				if isKeyDown(VK_NUMPAD3) then
					setInfraredVision(false)
					setNightVision(false)
				end
				if isKeyDown(VK_RETURN) then
					setInfraredVision(false)
					setNightVision(false)
					restoreCameraJumpcut()
					setCameraBehindPlayer()
					flymode = 0
					droneActive = false
					break
				end
			end
		end
	end)
end

-- ФУНКЦИИ ИЗ ШПОРЫ
function string.rlower(s)
	s = s:lower()
	local strlen = s:len()
	if strlen == 0 then return s end
	s = s:lower()
	local output = ''
	for i = 1, strlen do
		local ch = s:byte(i)
		if ch >= 192 and ch <= 223 then
			output = output .. russian_characters[ch + 32]
		elseif ch == 168 then
			output = output .. russian_characters[184]
		else
			output = output .. string.char(ch)
		end
	end
	return output
end

function string.rupper(s)
	s = s:upper()
	local strlen = s:len()
	if strlen == 0 then return s end
	s = s:upper()
	local output = ''
	for i = 1, strlen do
		local ch = s:byte(i)
		if ch >= 224 and ch <= 255 then
			output = output .. russian_characters[ch - 32]
		elseif ch == 184 then
			output = output .. russian_characters[168]
		else
			output = output .. string.char(ch)
		end
	end
	return output
end

function imgui.TextColoredRGB(string, max_float)

	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local u8 = require 'encoding'.UTF8

	local function color_imvec4(color)
		if color:upper():sub(1, 6) == 'SSSSSS' then return imgui.ImVec4(colors[clr.Text].x, colors[clr.Text].y, colors[clr.Text].z, tonumber(color:sub(7, 8), 16) and tonumber(color:sub(7, 8), 16)/255 or colors[clr.Text].w) end
		local color = type(color) == 'number' and ('%X'):format(color):upper() or color:upper()
		local rgb = {}
		for i = 1, #color/2 do rgb[#rgb+1] = tonumber(color:sub(2*i-1, 2*i), 16) end
		return imgui.ImVec4(rgb[1]/255, rgb[2]/255, rgb[3]/255, rgb[4] and rgb[4]/255 or colors[clr.Text].w)
	end

	local function render_text(string)
		for w in string:gmatch('[^\r\n]+') do
			local text, color = {}, {}
			local render_text = 1
			local m = 1
			if w:sub(1, 8) == '[center]' then
				render_text = 2
				w = w:sub(9)
			elseif w:sub(1, 7) == '[right]' then
				render_text = 3
				w = w:sub(8)
			end
			w = w:gsub('{(......)}', '{%1FF}')
			while w:find('{........}') do
				local n, k = w:find('{........}')
				if tonumber(w:sub(n+1, k-1), 16) or (w:sub(n+1, k-3):upper() == 'SSSSSS' and tonumber(w:sub(k-2, k-1), 16) or w:sub(k-2, k-1):upper() == 'SS') then
					text[#text], text[#text+1] = w:sub(m, n-1), w:sub(k+1, #w)
					color[#color+1] = color_imvec4(w:sub(n+1, k-1))
					w = w:sub(1, n-1)..w:sub(k+1, #w)
					m = n
				else w = w:sub(1, n-1)..w:sub(n, k-3)..'}'..w:sub(k+1, #w) end
			end
			local length = imgui.CalcTextSize(u8(w))
			if render_text == 2 then
				imgui.NewLine()
				imgui.SameLine(max_float / 2 - ( length.x / 2 ))
			elseif render_text == 3 then
				imgui.NewLine()
				imgui.SameLine(max_float - length.x - 5 )
			end
			if text[0] then
				for i, k in pairs(text) do
					imgui.TextColored(color[i] or colors[clr.Text], u8(k))
					imgui.SameLine(nil, 0)
				end
				imgui.NewLine()
			else imgui.Text(u8(w)) end
		end
	end

	render_text(string)
end

function removeMagicChar(text)
	for i = 1, #magicChar do text = text:gsub(magicChar[i], '') end
	return text
end

function imgui.GetMaxWidthByText(text)
	local max = imgui.GetWindowWidth()
	for w in text:gmatch('[^\r\n]+') do
		local size = imgui.CalcTextSize(w)
		if size.x > max then max = size.x end
	end
	return max - 15
end

function getFilesSpur()
	local files, window_file = {}, {}
	local handleFile, nameFile = findFirstFile('moonloader/MoD-Helper/shpora/*.txt')
	while nameFile do
		if handleFile then
			if not nameFile then 
				findClose(handleFile)
			else
				window_file[#window_file+1] = imgui.ImBool(false)
				files[#files+1] = nameFile
				nameFile = findNextFile(handleFile)
			end
		end
	end
	return files, window_file
end

function fpsUnlock(status)
    if isSampLoaded() then
        memory.setuint8(getModuleHandle("samp.dll") + 0x9D170, status and 0xC3 or 0x51, true)
    end
end


JLeYBxvRA2eDCYh6nBEv5mfKGPNn = "x-hVJ3rNnaZH?GA#ESF*#^mG-EWPsVHhMd&8Ud#9zVz7r#U2zve=Zx9f6?WuY?syRvUzwnu_5jnJ@C6qtHTG!%t34dTJMCS3k-py4eRjN2YGB+7UdbwEKS$5+TKY-qp3+umEW7DNrE?&h&D4mB3cv-AQ=!-tGd_3r4a3Q8Uu5=BSEyeKVn#9@rL2PA?d*y6qMMAz47Cwx@346bsPULwDaRpP4?ETr!^XzxHXh-hExyPnDNBexgdGYSvwHwJ-H7Lw44h@r*h9kpL8@BezMA36cKJrs#W%gbaXxHnUMY3-jJdeKHu+z5q#D7-VZ!#JJ3CxMPwVWf$dumKRvqLQRjUZtEJgjy_egY^LdcM5dWQLP8a*JAtJwTRVw*$t_Wzxxsd+b+4#pZAFc%*mGhRBne#KdEz6x_eT$p7WWBwhy6SQqbQFzR8tRF*&YMx*=guZ36URy9@fNqs9Ss9^TNZrdPwEZLQ_m9=b7V&z$crXS^e?z*=n!*A^LR27qmb?VT_$!86+5%XKVTbGJ!rGjdhMLWa&7SWPpy_geu-QL^uQzqy84yvd6!#Q?z-7hU*5?9fpwbyg7xMWMxWGBWbac*uaQzWz6$*WVf*&gY?%-c@7tH?nYkzQdd^?YUaLn*zq6GvkhPjm6fp?N3QLERv@5V9*NTnNpuJPS?@Mc3m*#qEQZtX9xrBKN+N6!63%Pmh@UP&XA-5eQK_8TB?f9g6v&Dc+%n7%tcHLs7cHsTHfFtr%ZcV3QvqGTDLbDjRYHw*3M#P9fkL*G57aUcXvK@aV_p6Uc3KWDQcRcS&&NwG#_a8wQj#6xYn^A@zG^*e_tRR9RWY?&hRwr3^H9y7gQZr#m_ZnbrhBKUNJs?PHGk9!ugHUnr7qAXjpq$2wwUe_BjdNLrwtKzf6C4YY!8KU&7Yvw^M=QsTdgT8jsX@X@fM-pBjwS@vw?C@EHEnWv+9VQ*6hY6pwZgbu%MTdWK9FxA**+5uS2jJZm2$XxEpXuXFQVA!$FVDpb@jQ#Mz6$LVj-chE@gA?ZmtKMz2KaaFD552Xe#tE9bTX5%xqHCp*$ydkH2J8ucBQmDDwZDz^m-@REcRgkX9z4JMnLMBCkL-?V93@WS+n*bTq!-89Bfy+mF??Uy7RYLEmt!Mg$5L=&aBxwryh5cV5wnXpue4mG_Q?g6W=xV5xP+@xmDMgsBChQjaWjTY_%*L^tKysLjJnz=4C##_gz5p=T$TA3#yBy&ZXYU$LFY4c?kgqWXLVS%dV+kp!XvWKp5gzy@#caDK6JZChGW?6!FBGKerk-@E#ny6_%?EjGLdYuKn!3wTY&zu$XQCtF%UqMc&Kk+*rjtnbV9H$n?Tx5uXrbNBm!rEtJUub2MEP&L%tu!PZF=&%D_r=B_GzEQS%Kz^!EYapczQG3_Pj#*h+D@txatnStfwTmVF3*CHcL&nq_xGGQcTYxR9zHr&m2$gUg-v64PqAgp-ncUvPvqG_PM5YC8EJPp^GV&%Y8QP$jGvH9&PQBJx%b*mVRN5gEs7ZrW7pJn8ge=rY3VDwk@8%RQg=!cKW==C&V@#Cf#mcLB%vtm!s&8y?9R+zj2$t5cr#bR#K@qw^k=#dTVf#44LLywdJepF_M@d&5#5*atZ!!grD-tmK_7jE-#udfvG4r#9CZ+z6+$Hch_DGnT6T3^!HByfu48fh&Ac%t!*m4_H*pLy8PaM$TEJTts9mT9SdT9!V6uyFZP?CnA&@7ww&N+Vf=CCp4#qk+BAPz^g!fnUqSSU5zr^3dgELx_XWBnbsLeX$xs^=b?!Er&HQQKY&SnLxg6j3cZbA3G%j?WrKFbk6q^ZkTmqTJjfu38X^hdRNvFZSpE+tV+4pH6!phm=&nP$cG?t^ZXvTLTrJF^CHV8H#-uWxzU#%+dwG#6r7Y5YCYPUvdyE8d-tX$f$@@EZAT$vzpJyZqP_r^%pryk@%-U_qFsc?Jztd%2Qu8W-3MKk9atygs7R9n*4+29*+_SQ_7vAmY&$nyzb*QhKx$nWuwhPMeS=GeT^r2kxsw#b?btLt4pj+S-tfYHzVH+8eCWhS8w3nJYc9AC!%"
KGd6r35fZhsFvb3xpWVZddmT3XP6B2 = "Pswyp2!7%_HCnpWn8%$EgunCkx=82W24t4T$GvWGRVby3_s5Ve5fM9nfZ338bTHf-x2vLs%NcA@S63$v#MJ@=-h*YwgArbU+jYHha&z?Q$5GM!jxE8RDHdveHS@-twZ2dnYRp+rUF+Xy5y4#c^m6j8fgkwQZRfLnAhcZ5-ZnYXzxshkqVLJE2WA-5RXN$ZTXhQv=-e#aT2K_w@u83mr*3bKgxBdg_CUukP4APQ#gbFuUkMbN3rQkGgVMeV2NHB5k_u?HtmP#g$pmnxP%GA*qz4F!D=-Hjk5ud7vMVbYVx$gvVp^b-82BNsDmqN%9N*GEc6yw9478NG3_FN!vky?TV6Pw5A6w$5HeA8uVzbymFyekhu=*9eWj+UZQaJP7Zbqwz%kr#TE7Nnt$+vEjUgbpUMPgA6SpkrZcrhL?J?#MPsWY7Zj%6H*k5unDUBu894J7zrsxrjL+CN9ypzhZvNwuydTrpcwt_Q9bmpSdbh9z2dSVh-frxryMQXD5++SZzqDdJnwt_E#?GM_dgSSk#+3WvPxMD&MhdUZWaysCYH8AdejwqR!3XU=NETDXYvU26dKtvM4qwNpgbGUM&uq%naeh!cLvKzb!sz5umR=pV@G6tmA@UYa5Pd#ucmbGvtQKqgG8Z2kvyWXUsK-4%VTzm-VF_+u@&WvZ@xQcP$G2MVf#NJT5DUK22bnZGvcz*k8=EJ9CZ3BpDpP$bzGh8SA+C67fF@XvXZM=qn_$n*TFTKf@njLufK+TdH&Nuv7CU4Yx_!LRF&5=&#9x?P*kvXk=N8&xRj%W^nkP5ga#pMKEyEZCT^_V@FYX-ZC-tDHN!#vb32RawDwnjb_XGvp?5zY9+2SHh^C=KfS#Amjb3_JSN$?BTrXMZ-_RbXuM=_fCKCYStNUAZh_udTM+f7ZvU3HdR2KYf+-?*Muw86KAAkQ7F_3g4agQ+D8J#VzsV?3tH$nAkfEf+BFG9LzYhZnf^TE2cPAyZMzt2Vt&Pd2mDEd4L$xD+bgxV%!K6Z3jc4sR3RKQ?eYS?h&%2wk#HaWgMfzbG5=DM_nh8tUg5y#Fr9Yk2STAa&%YK7LXJn@prF=y-VKx8uYN?h-hYTrs^%HauPT3W?eAyDfm4&KNPy5$yZd&vpq5_Cqvn$uf&3F&Q+GFrjKp9-kU#XUxfxT7_=tASZ&mLTX!2*Ne^Ly_D3&mXv$=9=dHb!-j98v@tS6+#Ce$#hXy=RjAnFKyRSQnD!XH7LtB82JU7ak^shWeaudbC32Cmn_Lc47__&F%8FE#V-5ZWZN4*45!bSEM6?+h6LE-Q+Gw95$qy#5#!yvRe#bGpyh=H*Je@eDh@qX3qsXqvnZ34pqeYcAvMMM^gz&W=r!$*x=sWasEyxuXKXDny3tvJ5R@mp_LNn8bQWC*H@nshXy@p^Krm6KCbtat8PQjUTu+Srxd3qwxMaTBNswSYvw_CS%%ZUA?xvZDZgaWXBxET7?Hw8@8E9VQ^GU=MwH$^hypeBsgPuE3#Pj%xJD7@b!7qxVqQFF5fUZtP4PhXn^WVM*L-q@Lz$qrQ377_vhQn4282qhQtKF6D@7KXZ_NmAKFEhfMg?7+gjGk_V?ThNYF-%G#$evfdAQpDK!&qm6zZNYURDqjD%xgj=a7xk^M6FJ6&#^=f5*PVCh_cTRjSNG?QxMETLqxjk*gFwbE7k?%#eaauXK3aGupVNfH8@7#b8!sm%Y55EqhX$*9+%CYv22gU=LcaMaE4r9b7nsT7j%yTjuhXSstGKuzh2SdVX@LP?%PfSekvb%MWbk^W5Q^$hw=L!@CCZn-fNFXVx&@DS2&#FAwHAWND&DfKY6de2uH@r?qA=C3Qz@WnspStqwUDZa=L-WXg&^-uR23f5gX84+%8MjNb?Tat^F+GLye^J4#K-W4KyBa9yANA?hCv?W^^ntYq5Q#5-jS#3P-cdXa#c77+hTs^t%b_WA8w8H!tbS_maY_TVb9_-cHQTQcr9WjxDcn?GxREVLt^RXJ&U*@s5vzXDLRJ%LVFRFaf$4mqtftWY&Mw=^Chpn5=8LnaJez6NbTe%-9Fq&YyCtJ"
QuyuqWJXUGXUmE84uxestL5unKxyF = "Q_&JQVpX#6f4WhYQpRQzEMfyyZx35cgN8SbnRALEGDwMW%c4yEvqd_TSwzJ4t7qRVdWG3C65=7uqbsA75gs7rzy48^wnd+m67mN*73M=U44S6B+9H56dN$NsGNe?pE3?*hSS39X#5Dk*ep9j%4QGVLUQ6&K2-=kQ*qr@7FbnFuTYez^w7VktKNqWXC@6gtfUD9B=aKf$6B*vds8sbwj=DuS!J+^R&Rp!#t4sUhFMGWhH9b-e*4+T5J%SF?kf4tm_=t6tt7b%XfJ-BFT#++Uks#=-MS3R-8#xT=J5ZguJ$ER!nqnc-j5tjphsS^atG=Zx@Uz+q=CTuju&cu5FjCMfhEVF^Y#Y3#j9GB4^g=CdXa-e9ts_$SM*a+Vzj-h7Vt!W!@a*Cz$KX6j@v-v_qhnD^!auGu!e6QTq@=jNzcYJc+SVGFQY%+=NS38cBrkRAe8Zt+9m=X=6n@@PyDGg+wd^^w3*V%gB?JLDA9eKk!RrPe?4gQkTu7s%stE^X=KDtBYh@BYUcgEbzFg7&vfrTScdxDbL&Jj2#KYG9yF3tT_r#qUg?S+gc#!J^qDbpDt3&Zkk_t5bj3MMfka$b$_QR4D6*uw7ePwQaZgm#q?k!KV^Re52Tx%KXXK=Bq3m*8*xmrAXKGNuF?#ykeL#y#YkZX@@%7T&T?gabA@wwnHnmC?Xrz!2&3CK$F+EMyB4%4k*NdeWya3?*T!*BVw5bXF2qSp=_WAvWWzqzbn&55U8Nm5gm_n5U8C+ny@#W?xuMfj+#aEvHyeC57hnLAMreKa!U$RyWafdCNwRfzNTLvSXdD?xA4uB=DdZV6dPQnTVppkV3rvvcrj5cKnF=MT!MmXUWV#664cvwysuUCtXzS%hbp*p8*9E=9FEp!-d_2D9AC3q%2Q29qucq&KgMF_W-a2bK+MBFQJB%gZ5t@a!DN74Ku3-vnJpA4J7u#vqjm?X^aZasauRHH#qauR#D9+$?cR98KZKT8_V546&CBT7sJgpgbjyFBkc4WzwP$ChR_-Mvb+U9@uDEUY2GT_kv$dTh#nEP#BFKCA#NEQM6wfymCmfD%&sGR=&qk7TNZ%3k+Z85HfdP&Y&Bd@4bhuF5g@QG8DsFdLhkKCN9zvL$ZHWzk*gbsw#6A@!pSPEvQYahPKXWQGMzuDSNzatxSn4RmzfkDmme*?UNe8Zh%f+FaH+NHZJ5mpY&xN4-6UuuRyhEAx@bH535mS=vpw&5T5fgt^5G8TptBMw_M_CRC!^FfCeeT2EF^AJf#yvnZjLy&-x=F3%?kEx*64S2YXa46g5#hP9tQEKJUjUC9e8REH?MukkW7b2A-dSWgbsP%5ZBynwx?-GwFrzQM$fV+ZrACx6?xV*?v!pw8pgBNg#$U3p*?W7%WfgKUSjEnPz?#cFJW$?S$uTYm4TcQk+^5Y_g2_2eFW7eTgCCyr@5&r=Y7r9=Q&xrD-&GP2vM=Lg*Ew+XmuqJX$tJBYV8_zD$%xTMN_dzXz%yv&LJ4Wds8@*rV45b7FQ87mTd==%y4wYxTk#UxGga2jKe5t*N?8P?+c*J64BLJWVPeA4p?cG4%3!uDtxTBgKLAKj%FN9rHWQ*RD!!pQ*CkU@*NTmU_#MaW#QsdLn9xVC2Cj8gnVFhq9uagu2Rm&wFXG5AWsyZ+jdk#V&ZH?+xAq7Pwr^hM-j%ywLgjYn_K$E_m?EgdHk=zu%*j+je+sZCh$335umCq4d2=YGpLEBK@QsVpf!vcvEc%#4Dt!LN6%r7&3^9vPtf#2guh9GHB@fHvV%d=kPY5+94$zCWMHkR*cBerTe4*ezXqfB5*z@=%NDcZDx%n6q7--5gj8Wz-L*EW8TYxq!k?^7$mVDj*R^px&qab+8SVJeL3^M6$LWcg_*Jx9%xmRJLRL3ZAPBKH&W#g*_&rsg&mvKp&ZvFd2&Zy$gS+RsM*U4TDcE+qFeqQvA3M!hLAEp_?rdS5#$UegkjwNX+vntQWq_T_RjvbH%ZaLsVb!8@FR7$?G8_fM!2Vvd_=k@3NPnYst2acC4jzGAaFkBXFaDAs9^4vth$QsXEjpKZPh222jE"