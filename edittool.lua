script_name('EditTool')
script_author('.:dipi:.', 'Dmitry Medvedev', 'Bruno Graund', 'Bruno Lottero')
script_version_number(1)
script_version('0.0.1')

require 'lib.moonloader'
local res, https = pcall(require, 'ssl.https')
local inicfg = require 'inicfg'
local sampev = require 'lib.samp.events'
local imgui = require 'imgui'
local mem = require 'memory'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

show_main_window = imgui.ImBool(false)
show_ads_window = imgui.ImBool(false)
show_upd_window = imgui.ImBool(false)

local SET = {
 	settings = {
		tag = '',
		tagLS = 'LS |',
		tagSF = 'SF |',
		tagLV = 'LV |',
		tagTV = 'TV |'
	}	
}

Openmn = false
srv = nil
gameServer = nil
fraction = ''
rang = 0
ads = {}
Scriptcrush = false
Updateend = false
checkupd = false

function new_style()

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


	colors[clr.Text] = ImVec4(0.90, 0.90, 0.93, 0.90)
    colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 0.80)
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

	colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 0.80)
    --colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.FrameBg] = ImVec4(0.13, 0.12, 0.15, 0.80)
    colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.TitleBg] = ImVec4(0.10, 0.09, 0.12, 0.30)
end

new_style()

function files_add()
	if not doesFileExist(getGameDirectory()..'\\moonloader\\config\\EditTool\\settings.ini') then 
		inicfg.save(SET, 'config\\EditTool\\settings.ini')
	end
end

function imgui.OnDrawFrame()
	local btn_size = imgui.ImVec2(-0.1, 0)
	local btn_size2 = imgui.ImVec2(160, 0)
	local btn_size3 = imgui.ImVec2(140, 0)
	local sw, sh = getScreenResolution()
	if show_main_window.v then
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(600, 600), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowSize(imgui.ImVec2(600, 400), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'Настройки EditTool', show_main_window, imgui.WindowFlags.NoResize)
        imgui.Text(u8'Введите тэг вашей организации, который будет использоваться при редактировании.')
		imgui.Text(u8'Во всех тэгах пробел в конце писать не нужно.')
		imgui.PushItemWidth(100)
		imgui.InputText(u8'Тэг вашей организации', tag)
		imgui.Separator()
		imgui.Text(u8'Введите тэги других организаций. По умолчанию они заполнены сами.')
		imgui.PushItemWidth(100)
		imgui.InputText(u8'Тэг ЛС', tagLS)
		imgui.InputText(u8'Тэг СФ', tagSF)
		imgui.InputText(u8'Тэг ЛВ', tagLV)
		imgui.InputText(u8'Тэг ТВ', tagTV)
		if imgui.Button(u8'Сбросить настройки') then
			tag.v = ''
			tagLS.v = 'LS |'
			tagSF.v = 'SF |'
			tagLV.v = 'LV |'
			tagTV.v = 'TV |'
		end
		imgui.Separator()
		imgui.Text(u8'Автор скрипта: .:dipi:.')
		imgui.Text(u8'Сказать "Спасибо" можно на счёт #1655 (Lime), #95196 (Green) или #89799 (Red).')
        imgui.End() 	
	elseif show_ads_window.v then
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(-0.6, 0.3))
		imgui.SetNextWindowSize(imgui.ImVec2(600, 400), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'EditTool', imgui.WindowFlags.NoResize)
		if imgui.Button(u8'Вставить') then
			lua_thread.create(function()
				wait(100)
				sampSetCurrentDialogEditboxText(u8:decode(tag.v)..' ПРО')
			end)
		end
		imgui.SameLine()
		imgui.Text(u8:decode(tag.v)..u8' ПРО')
		for i, v in ipairs(ads) do
			imgui.PushItemWidth(60)
			if imgui.Button(u8'Вставить##'..i) then
				lua_thread.create(function()
					wait(100)
					sampSetCurrentDialogEditboxText(u8:decode(tag.v)..' '..ads[i])
				end)
			end
			imgui.SameLine()
			imgui.Text(tostring(u8(ads[i])))
		end      
        imgui.End()
	elseif show_upd_window.v then
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(300, 130), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'Обновление EditTool', show_upd_window, imgui.WindowFlags.NoResize)
		imgui.Text(u8'Ваша версия: '..thisScript().version)
		imgui.Text(u8'Новая версия: '..updatever)
		if imgui.Button(u8'Обновиться', btn_size) then
			async_http_request('GET', 'https://raw.githubusercontent.com/DiPiDi/install/master/edittool.lua', nil, 
			function(response)
				local f = assert(io.open(getWorkingDirectory() .. '/edittool.lua', 'wb'))
				f:write(response.text)
				f:close()
				sampAddChatMessage("[EditTool]{FFFFFF} Скрипт был успешно обновлен.", 0xFFCC00)
				thisScript():reload()
			end,
			function(err)
				sampAddChatMessage("[EditTool]{FFFFFF} При обновлении произошла ошибка.", 0xFFCC00)
				show_upd_window.v = false
				return
			end)
		end
        imgui.End()
	end
end

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then
		return
	end
	while not isSampAvailable() do
		wait(100)
	end

	files_add()
	
	load_settings()
	
	sampAddChatMessage('[EditTool]{FFFFFF} Идёт загрузка. Версия скрипта: {FFE373}'..thisScript().version..".", 0xFFCC00)

	repeat wait(10) until sampIsLocalPlayerSpawned()
	print("Проверяем подключаемый сервер")
	print(sampGetCurrentServerName())
	if sampGetCurrentServerName():find("Red") then
		gameServer = "Red"
		srv = 1
	elseif sampGetCurrentServerName():find("Green")  then
		gameServer = "Green"
		srv = 2
	elseif sampGetCurrentServerName():find("Blue")  then
		gameServer = "Blue"
		srv = 3
	elseif sampGetCurrentServerName():find("Lime")  then
		gameServer = "Lime"
		srv = 4		
	else
		print("Сервер не адванс")
		sampAddChatMessage('[EditTool]{FFFFFF} Данный скрипт работает только на серверах Advance RolePlay.', 0xFFCC00)
		Scriptcrush = true
		thisScript():unload()
		return
	end
	print('Скрипт запущен. Сервер'..tostring(gameServer))

	sampAddChatMessage('[EditTool]{FFFFFF} Скрипт был загружен и готов к использованию.', 0xFFCC00)
	sampAddChatMessage('[EditTool]{FFFFFF} Введите {FFE373}/edh {FFFFFF}для настройки скрипта.', 0xFFCC00)
	
	Openmn = true
	
	sampRegisterChatCommand('edh', function()
        show_main_window.v = true
    end)

	sampSendChat('/mn')

	update()
	while not Updateend do
		wait(0)
	end
	while true do
		wait(0)
		imgui.Process = show_main_window.v or show_ads_window.v or show_upd_window.v
		if not sampIsDialogActive() then
			show_ads_window.v = false
		end

	end
end

function load_settings()
	ini = inicfg.load(SET, getGameDirectory()..'\\moonloader\\config\\EditTool\\settings.ini')

	tag = imgui.ImBuffer(u8(ini.settings.tag), 10)
	tagLS = imgui.ImBuffer(u8(ini.settings.tagLS), 60)
	tagSF = imgui.ImBuffer(u8(ini.settings.tagSF), 60)
	tagLV = imgui.ImBuffer(u8(ini.settings.tagLV), 60)
	tagTV = imgui.ImBuffer(u8(ini.settings.tagTV), 60)
end

function saveSettings()
	ini.settings.tag = u8:decode(tag.v)
	ini.settings.tagLS = u8:decode(tagLS.v)
	ini.settings.tagSF = u8:decode(tagSF.v)
	ini.settings.tagLV = u8:decode(tagLV.v)
	ini.settings.tagTV = u8:decode(tagTV.v)

	inicfg.save(SET, "/EditTool/settings.ini")
end

function onQuitGame()
	saveSettings()
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
	if Openmn and title:find('Меню игрока') then
		sampSendDialogResponse(dialogId, 1, 0, -1)
		return false
	elseif Openmn and title:find('Статистика игрока') then
		if text:match("Организация:			(.*)\nРабота") == 'Нет' then
			sampAddChatMessage('[EditTool]{FFFFFF} Вы не работник ТВ и радио. Скрипт выключен.', 0xFFCC00)
			Scriptcrush = true
			thisScript():unload()
		elseif text:match("Организация:			(.*)\nПодразделение") == 'ТВ и радио' then
			fraction = text:match("Организация:			(.*)\nПодразделение")
			rang = tonumber(text:match("Ранг:				(%d+)\n\nПроживание"))
			if rang < 3 then
				sampAddChatMessage('[EditTool]{FFFFFF} Ваш ранг меньше 3. Скрипт выключен.', 0xFFCC00)
			Scriptcrush = true	
			thisScript():unload()
			end
		end
		Openmn = false
		return false
	end

	if title:find('Публикация объявления') then
		lua_thread.create(function()
			wait(100)
			sampSetCurrentDialogEditboxText(u8:decode(tag.v)..' ')
		end)
		show_ads_window.v = true
	end
end

function sampev.onServerMessage(color, text)
	if text:find (''..u8:decode(tagLS.v)..'%s+.+%s| Отправил') and color == 13369599 then		
		ads[#ads+1] = tostring(text:match(''..u8:decode(tagLS.v)..' (.+) | Отправил'))
	elseif text:find (''..u8:decode(tagSF.v)..'%s+.+%s| Отправил') and color == 13369599 then			
		ads[#ads+1] =  tostring(text:match(''..u8:decode(tagSF.v)..' (.+) | Отправил'))
	elseif text:find (''..u8:decode(tagLV.v)..'%s+.+%s| Отправил') and color == 13369599 then			
		ads[#ads+1] =  tostring(text:match(''..u8:decode(tagLV.v)..' (.+) | Отправил'))
	elseif text:find (''..u8:decode(tagTV.v)..'%s+.+%s| Отправил') and color == 13369599 then			
		ads[#ads+1] =  tostring(text:match(''..u8:decode(tagTV.v)..' (.+) | Отправил'))
	end
end

function onScriptTerminate(script, quitGame)
	if not Scriptcrush then
		saveSettings()
		sampAddChatMessage('[EditTool]{FFFFFF} Что-то пошло не так и скрипт завершил свою работу.', 0xFFCC00)
	end
end

function update() -- проверка обновлений
	local zapros = https.request("https://raw.githubusercontent.com/DiPiDi/install/master/edhupdate.json")

	if zapros ~= nil then
		local info2 = decodeJson(zapros)

		if info2.latest_number ~= nil and info2.latest ~= nil then
			updatever = info2.latest
			version = tonumber(info2.latest_number)
						
			if version > tonumber(thisScript().version_num) then
				sampAddChatMessage("[EditTool]{FFFFFF} Вышла новая версия скрипта: {FFE373}"..updatever..".", 0xFFCC00)
				show_upd_window.v = true
				Updateend = true
			end
		else
			sampAddChatMessage("[EditTool]{FFFFFF} Ошибка при получении информации об обновлении.", 0xFFCC00)
			Updateend = true
		end
	else
		sampAddChatMessage("[EditTool]{FFFFFF} Не удалось проверить наличие обновлений, попробуйте позже.", 0xFFCC00)
		Updateend = true
	end
end