script_name('MoD-Helper')
script_authors('Xavier Adamson', 'Frapsy', 'Sergey Parhutik', 'DIPIRIDAMOLE')
script_description('Ministry of Defence Helper.')
script_version_number(40)
script_version("0.4.0")
script_properties("work-in-pause")

--memory.fill(sampGetBase() + 0x9D31A, 0x90, 12, true)
--memory.fill(sampGetBase() + 0x9D329, 0x90, 12, true)
-- ���� ���� �����


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


-- ������ ����������
mlogo, errorPic, classifiedPic, pentagonPic, accessDeniedPic, gameServer, nasosal_rang = nil, nil, nil, nil, nil, nil -- ��������
srv, arm = nil, nil -- ������ ������� � �����
whitelist, superID, vigcout, narcout, order = 0, 0, 0, 0, 0 -- �������� �� ������� ��� "����������"
regDialogOpen, regAcc, UpdateNahuy, checking, getLeader, checkupd = false, false, false, false, false -- bool ���������� ��� ������ � ���������
ScriptUse = 3 -- ��� �����
armourStatus = 0 -- ������ �������(����/�����)
offscript = 0 -- ���������� ��� �������� ���������� ������� �� ������ "��������� �������"
pentcout, pentsrv, pentinv, pentuv = 0,0,0,0 -- ������ �������� /base
regStatus = false -- ��������� ������������ ��������� ���� 
gmsg = false -- �������� �� ���������� ������ �� ��
gosButton, AccessBe = true -- �������� �� �������� ����� 
dostupLvl = nil -- ������� �������
activated = nil -- ����������� �����������, ���� ������ �� ���������� � ��
isLocalPlayerSoldier = false -- �������� �� ��������� � �� �� ������� �����
getMOLeader = "Not Registred" -- ��
getSVLeader = "Not Registred" -- ��
getVVSLeader = "Not Registred" -- ���
getVMFLeader = "Not Registred" -- ���
pidr = false -- ��� ������� �����
errorSearch = nil -- ���� �� ������ ����� � ���������
vkinf = "Disabled by developer"
developMode = "Local Edition"
--assTakeDamage = 0 -- ���������� ���, ������� ����� ������� ������
flymode = 0 -- ������
isPlayerSoldier = false -- �������� �� ��������� � �� �� ������ �� ��
speed = 0.2 -- �������� �������
bstatus = 0 -- ��� ������ �� ��, 1 ���� � ��� ������
offMask = true -- ������ �����
enableStrobes = false -- �����������
skill = false -- ��� �������
fizra = false -- ���������� ��� �����
state = false -- ��������� ���� �� ��������
--assDmg = false -- ��� �������� ������� �� ������ �� ������������
--dmInfo = false -- ����� ���� � ��� � ���� �����
keystatus = false -- �������� �� ��������������� �����
workpause = false -- �������� �� ������������ ������� ��� ������ ������� ��� ��������� ���� ��� vkint
mouseCoord = false -- �������� �� ������ ����������� ���� ���������
token = 1 -- �����
mouseCoord2 = false -- ����������� ���������
mouseCoord3 = false -- ����������� ������������
phpchat = true
getServerColored = '' -- ���������� � ������� ������ ��� ���� ������������� �� ������� ��� ������� � ����


--Secondcolor = 'A7A7A7'



blackbase = {} -- ��� ������� ������
names = {} -- ��� ����������
SecNames = {}
SecNames2 = {}

mass_niki = { '', '' }

-- ���������� ��� �����, ���� �� ��������, �� ���� ������
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
russian_characters				= { [168] = '�', [184] = '�', [192] = '�', [193] = '�', [194] = '�', [195] = '�', [196] = '�', [197] = '�', [198] = '�', [199] = '�', [200] = '�', [201] = '�', [202] = '�', [203] = '�', [204] = '�', [205] = '�', [206] = '�', [207] = '�', [208] = '�', [209] = '�', [210] = '�', [211] = '�', [212] = '�', [213] = '�', [214] = '�', [215] = '�', [216] = '�', [217] = '�', [218] = '�', [219] = '�', [220] = '�', [221] = '�', [222] = '�', [223] = '�', [224] = '�', [225] = '�', [226] = '�', [227] = '�', [228] = '�', [229] = '�', [230] = '�', [231] = '�', [232] = '�', [233] = '�', [234] = '�', [235] = '�', [236] = '�', [237] = '�', [238] = '�', [239] = '�', [240] = '�', [241] = '�', [242] = '�', [243] = '�', [244] = '�', [245] = '�', [246] = '�', [247] = '�', [248] = '�', [249] = '�', [250] = '�', [251] = '�', [252] = '�', [253] = '�', [254] = '�', [255] = '�' }
magicChar						= { '\\', '/', ':', '*', '?', '"', '>', '<', '|' }
	
-- ��������� ������
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
		gnewstag = '��',
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
		textprivet = '������� �����, �������',
		textpriv = '������� �����',
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


local SeleList = {"�����", "��������", "��������"} -- ������ ������� ��� ����� "����������"

-- ��� �������� ���� �� �������� ��� ��������� ���������� ������
local SeleListBool = {}
for i = 1, #SeleList do
	SeleListBool[i] = imgui.ImBool(false)
end

-- ������ ��� ����
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

-- ��������� ����������, ������� �� ��������� ����������
pozivnoy = imgui.ImBuffer(256) -- �������� � ���� ��������������
cmd_name = imgui.ImBuffer(256) -- �������� �������
cmd_text = imgui.ImBuffer(65536) -- ����� �����
searchn = imgui.ImBuffer(256) -- ����� ���� � ���������
specOtr = imgui.ImBuffer(256) -- ����.����� ��� �������(�����)
weather = imgui.ImInt(-1) -- ��������� ������
gametime = imgui.ImInt(-1) -- ��������� ������� 
vkid = imgui.ImInt(1) -- ��������� vkid ��� �����������
binddelay = imgui.ImInt(3) -- �������� �������

-- �������� ����� ������, ����� ������ �����, ����� �������� ����� �������. P.S. ������� ��� �����
if doesFileExist(getWorkingDirectory() .. "\\config\\MoD-Helper\\keys.bind") then 
	os.remove(getWorkingDirectory() .. "\\config\\MoD-Helper\\keys.bind")
end

-- ���������� ��� ������ ������� ��� ������� � �������, ������ ����������, � ����� ����� ����� - PerfectBinder ������, ��� ������ ��� ���� ��������, ��� ����� ����� ����� imcustom/rkeys.
hk._SETTINGS.noKeysMessage = u8("�����")
local bfile = getWorkingDirectory() .. "\\config\\MoD-Helper\\key.bind" -- ���� � ����� ��� �������� ������
local tBindList = {}
if doesFileExist(bfile) then
	local fkey = io.open(bfile, "r")
	if fkey then
		tBindList = decodeJson(fkey:read("a*"))
		fkey:close()
	end
else
	tBindList = { 
		[1] = { text = "����", v = {} },
		[2] = { text = "/gate", v = {} },
		[3] = { text = "����������", v = {} },
		[4] = { text = "Carlock", v = {} },
		[5] = { text = "In SMS", v = {} },
		[6] = { text = "Out SMS", v = {} },
		[7] = { text = "���������", v = {} },
		[8] = { text = "���������", v = {} },
		[9] = { text = "P.E.S. Help", v = {} },
		[10] = { text = "������� P.E.S.", v = {} },
		[11] = { text = "Fuck Pe4enka.", v = {} },
		[12] = { text = "����� ������", v = {} },
		[13] = { text = "���� �������", v = {} },
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
------------------------------- ����� � �������� ����� ----------------------------
-----------------------------------------------------------------------------------

-- ���� ����������� ���� alt+tab(������ ����� ��� �� ����� �� ����� � ���� ������ �� ������ ����� ��������� � ����)
writeMemory(0x555854, 4, -1869574000, true)
writeMemory(0x555858, 1, 144, true)

-- ������� �������� �������� ����, ������ ����� �����.. �� �����
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
-------------------------- ������� ������� � ��� ��� �� ��� -----------------------
-----------------------------------------------------------------------------------


function apply_custom_style() -- ������ imgui, �������� ����� ���������� � ��� �����, ��� �� ��� � ���� � ������� ������

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

function files_add() -- ������� ��������� ����� ������
	print("�������� ����������� ������")
	if not doesDirectoryExist("moonloader\\MoD-Helper") then print("������ MoD-Helper/") createDirectory("moonloader\\MoD-Helper") end
	if not doesDirectoryExist("moonloader\\MoD-Helper\\shpora") then print("������ MoD-Helper/shpora") createDirectory('moonloader\\MoD-Helper\\shpora') end
	if not doesDirectoryExist("moonloader\\MoD-Helper\\audio") then print("������ MoD-Helper/audio") createDirectory('moonloader\\MoD-Helper\\audio') end
	if not doesDirectoryExist("moonloader\\MoD-Helper\\images") then print("������ MoD-Helper/images") createDirectory('moonloader\\MoD-Helper\\images') end
	if not doesDirectoryExist("moonloader\\MoD-Helper\\files") then print("������ MoD-Helper/files") createDirectory("moonloader\\MoD-Helper\\files") end

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
		print("������ MoD-Helper/images/skins")
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
		print("�������� ��������� ��������")
		downloadUrlToFile('https://i.imgur.com/KkOXJJs.png', getWorkingDirectory() .. '/MoD-Helper/images/img.png')
		downloadUrlToFile('https://i.imgur.com/X99DKIb.png', getWorkingDirectory() .. '/MoD-Helper/images/errorPic.png')
		downloadUrlToFile('https://i.imgur.com/fnHuVN3.png', getWorkingDirectory() .. '/MoD-Helper/images/classified.png')
		downloadUrlToFile('https://i.imgur.com/Obl47RD.png', getWorkingDirectory() .. '/MoD-Helper/images/pentagon.png')
		downloadUrlToFile('https://i.imgur.com/jrJVpOS.png', getWorkingDirectory() .. '/MoD-Helper/images/access_denied.png')			
	end
	if not doesDirectoryExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\helpers') then
		print("������ MoD-Helper/images/helpers")
		createDirectory('moonloader\\MoD-Helper\\images\\helpers')
	end

	if not doesFileExist(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\helpers\\stefani.png') then
		print("�������� �������(����� ����������).")
		downloadUrlToFile('https://i.imgur.com/oHDkTvI.png', getWorkingDirectory() .. '/MoD-Helper/images/helpers/stefani.png')	
	end
	if not doesFileExist(getGameDirectory()..'\\moonloader\\config\\MoD-Helper\\settings.ini') then 
		inicfg.save(SET, 'config\\MoD-Helper\\settings.ini')
	end
end

function rkeys.onHotKey(id, keys) -- ��� ������ � �� ���������, �� ��� ������� ��������� ������ ������ � ������������ �����
	if sampIsChatInputActive() or sampIsDialogActive() or isSampfuncsConsoleActive() or win_state['base'].v or win_state['update'].v or win_state['player'].v or droneActive or keystatus then
		return false
	end
end

function onHotKey(id, keys) -- ������� ��������� ���� ������, ������� ��� ���������� � ������� ��������� imcustom, rkeys � ������
	local sKeys = tostring(table.concat(keys, " "))
	for k, v in pairs(tBindList) do
		if sKeys == tostring(table.concat(v.v, " ")) then
			if k == 1 then -- ������� ����
				sampSendChat("/c 60")
				return
			elseif k == 2 then -- ��������� �����
				if interior ~= 0 and isPlayerSoldier then
					sampAddChatMessage("[MoD-Helper]{FFFFFF} �� ���������� � ���������, ������� ����������.", SCRIPTCOLOR) 
				elseif interior == 0 and isPlayerSoldier then
					if gateOn.v then
						sampSendChat("/do ������ ���������� ������������� ���������� ���� "..(lady.v and '�������' or '�������')..".") 
						wait(1000)
						sampSendChat("/do ����� ����������� ��������� �������������� ������.")
						wait(150)
					end
					sampSendChat("/gate")
				end
				return
			elseif k == 3 then -- ��������� ����
				ex_find()
				return
			elseif k == 4 then -- ������� �������
				if interior ~= 0 then
					sampAddChatMessage("[MoD-Helper]{FFFFFF} �� ���������� � ���������, ������� ����������.", SCRIPTCOLOR)
				else
					if lockCar.v then
						sampSendChat("/me ������ ���� �� �������, "..(lady.v and '������' or '�����').." ������ [�������/�������]") 
						wait(150)
					end
					sampSendChat("/lock 1")
				end
				return
			elseif k == 5 then -- ��������� � ��� "/sms " � ����� ��������, ������� ��� ��������� �����
				if lastnumberon ~= nil then
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/sms "..lastnumberon.." ")
				else
					sampAddChatMessage("[MoD-Helper]{FFFFFF} �� ����� �� �������� �������� ���������.", SCRIPTCOLOR)
				end
				return
			elseif k == 6 then -- ��������� � ��� "/sms " � ����� ��������, �������� ��������� ��� ������
				if lastnumberfor ~= nil then
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/sms "..lastnumberfor.." ")
				else
					sampAddChatMessage("[MoD-Helper]{FFFFFF} �� ����� �� ���������� ��� ���������.", SCRIPTCOLOR)
				end
				return
			elseif k == 7 then -- ������ ���������
				reconnect()
				return
			elseif k == 8 then -- ��������/��������� ���������� 
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
			elseif k == 9 then -- ���������� ������
				if isPlayerSoldier then
					if cX ~= nil and cY ~= nil and cZ ~= nil then
						locationPos()
						bcX = math.ceil(cX + 3000)
						bcY = math.ceil(cY + 3000)
						bcZ = math.ceil(cZ)
						while bcZ < 1 do bcZ = bcZ + 1 end
						sampSendChat('/f [P.E.S.]: ������� ����������: '..BOL..'! N'..bcX..'E'..bcY..'Z'..bcZ..'!') 
					end
				end
				return
			elseif k == 10 then -- ��������� ������
				if isPlayerSoldier then
					sampAddChatMessage("+", -1)
					if x1 ~= nil and y1 ~= nil then
						if doesPickupExist(pickup1) or doesPickupExist(pickup1a) or doesBlipExist(marker1) then removePickup(pickup1) removePickup(pickup1a) removeBlip(marker1) end
						sampProcessChatInput('/f ���������� ������. ���������� �� ���: '..math.ceil(getDistanceBetweenCoords2d(x1, y1, cX, cY))..' �.')
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
			elseif k == 11 then -- ��������/��������� vkint
				workpause = not workpause
				if workpause then
					WorkInBackground(true)
					sampTextdrawCreate(102, "FuckPe4enka", 550, 435)
				else 
					WorkInBackground(false)
					sampTextdrawDelete(102)
				end
				return
			elseif k == 12 then -- ������� ������/������
				ClearBlip()
				return
			elseif k == 13 then -- ��������� ����
				if not sampIsChatInputActive() and not sampIsDialogActive() then
					mainmenu()
				end
				return
			elseif k == 14 then -- ��������� ��� � /r
				if not sampIsChatInputActive() and not sampIsDialogActive() then
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/r ")
				end
				return
			elseif k == 15 then -- ��������� ��� � /f
				if not sampIsChatInputActive() and not sampIsDialogActive() then
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/f ")
				end
				return
			elseif k == 16 then -- ��������� ��� � /g
				if not sampIsChatInputActive() and not sampIsDialogActive() then
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/g ")
				end
				return
			end
		end
	end

	for i, p in pairs(mass_bind) do -- ��� ������������ ������ �� �������.
		if sKeys == tostring(table.concat(p.v, " ")) then
			rcmd(nil, p.text, p.delay)		
		end
	end
end

function calc(m) -- "�����������", ������� ��� � �� ����� ���������� � �������, �� ������� ��� �� ��� ����
    local func = load('return '..tostring(m))
    local a = select(2, pcall(func))
    return type(a) == 'number' and a or nil
end

function WorkInBackground(work) -- ������ � ��������� imringa'a
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

function WriteLog(text, path, file) -- ������� ������ ����� � ����, ������������ ��� �������
	if not doesDirectoryExist(getWorkingDirectory()..'\\'..path..'\\') then
		createDirectory(getWorkingDirectory()..'\\'..path..'\\')
	end
	local file = io.open(getWorkingDirectory()..'\\'..path..'\\'..file..'.txt', 'a+')
	file:write(text..'\n')
	file:flush()
	file:close()
end

-- ���������� Base64
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

function tags(args) -- ������� � ������ �������

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

function mainmenu() -- ������� �������� ��������� ���� �������
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

	print("�������� ��������� ������� � ��� ������������")
	

	-- if doesFileExist(getWorkingDirectory().."\\MoD-Helper\\files\\regst.data") then secure_vk() end
	files_add() -- �������� ������ � ��������� �������
	
	mlogo = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\img.png')
	errorPic = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\errorPic.png')
	classifiedPic = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\classified.png')
	pentagonPic = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\pentagon.png')
	accessDeniedPic = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\access_denied.png')
	helper_stefani = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\helpers\\stefani.png')
	
	

	print("������� ���� ������� ������")
	if not doesFileExist(getWorkingDirectory().."\\MoD-Helper\\blacklist.txt") then 
		local blk = assert(io.open(getWorkingDirectory().."\\MoD-Helper\\blacklist.txt", 'a'))
		blk:write()
		blk:close()
	end
	load_settings() -- �������� ��������
	apply_custom_style()
	print("���������� ��������� �������")
	update() -- ������ ����������
	while not UpdateNahuy do wait(0) end -- ���� �� �������� ���������� �������� ������

	sampAddChatMessage("[MoD-Helper] {FFFFFF}������ �������, ������: {"..u8:decode(Secondcolor.v).."}"..thisScript().version.."{ffffff}.", SCRIPTCOLOR)
	colorf = imgui.ImFloat3(R, G, B)
	
	repeat wait(10) until sampIsLocalPlayerSpawned()
	print("��������� ������������ ������")
	print(sampGetCurrentServerName())
	if sampGetCurrentServerName():find("Red") then
		gameServer = "Red"
		srv = 1
	elseif sampGetCurrentServerName():find("Green")  then -- ��������� ������������ ������
		gameServer = "Green"
		srv = 2
	elseif sampGetCurrentServerName():find("Blue")  then -- ��������� ������������ ������
		gameServer = "Blue"
		srv = 3
	elseif sampGetCurrentServerName():find("Lime")  then -- ��������� ������������ ������
		gameServer = "Lime"
		srv = 4
		elseif sampGetCurrentServerName():find("Chocolate")  then -- ��������� ������������ ������
		gameServer = "Chocolate"
		srv = 5

	else
		print("������ �� �������, ������ ������� ���������")
		sampAddChatMessage("[MoD-Helper]{FFFFFF} � ���������, ������ ������ ���������� ��� ������ �� ������ �������.", SCRIPTCOLOR)
		sampAddChatMessage("[MoD-Helper]{FFFFFF} ��������� � ��������������, ���� ������ �������� ����������� ������� ������ ��������.", SCRIPTCOLOR)
		thisScript():unload()
		return
	end
	print("�������� ��������, ������: "..tostring(gameServer))
	
	
	-- ������� ����� ������
	
	print("����������� ����� ���")
	format_file()
	
	-- ���������� ��� � ID ���������� ������ 
	print("���������� ID � ��� ���������� ������")
	_, myID = sampGetPlayerIdByCharHandle(PLAYER_PED)
	userNick = sampGetPlayerNickname(myID)
	nickName = userNick:gsub('_', ' ')


	print("�������� ��������� ������")
	-- ����������� ������ ���������� � �������
	regDialogOpen = true
	if srv <= 9 then sampSendChat("/mn") else sampSendChat("/stats") end
	while ScriptUse == 3 do wait(0) end -- ������� ��������� �����������
	if ScriptUse == 0 then
		print("/mn -> 1: ����� ��������� ��� �����������")
		sampAddChatMessage("[MoD-Helper]{FFFFFF} �� ���������� ��� {"..u8:decode(Secondcolor.v).."}�����������{FFFFFF}, ��������� {"..u8:decode(Secondcolor.v).."}/mod{FFFFFF}.", SCRIPTCOLOR)
		isPlayerSoldier = false
	else
		print("/mn -> 1: ����� ��������� ��� �������")
		isPlayerSoldier = true
		sampAddChatMessage("[MoD-Helper]{FFFFFF} �� ���������� ��� {"..u8:decode(Secondcolor.v).."}�������{FFFFFF}, ��������� {"..u8:decode(Secondcolor.v).."}/mod{FFFFFF}.", SCRIPTCOLOR)
	end
	--sampAddChatMessage("[MoD-Helper]{FFFFFF} ��������, ������� {"..u8:decode(Secondcolor.v).."}���������{FFFFFF} ������, ��������� {"..u8:decode(Secondcolor.v).."}/mod{FFFFFF}, �����������: {"..u8:decode(Secondcolor.v).."}Xavier Adamson.", SCRIPTCOLOR)
	--sampAddChatMessage("[MoD-Helper]{FFFFFF} ����������� ��������� � �������� � ������ ������� ������� - {"..u8:decode(Secondcolor.v).."}Arina Borisova.", SCRIPTCOLOR)
	--sampAddChatMessage("[MoD-Helper]{FFFFFF} ������� {FFCC00}/whatsup{FFFFFF}, ����� ��������� ������ � ������������� � {"..u8:decode(Secondcolor.v).."}"..thisScript().version..".", SCRIPTCOLOR)
	--sampAddChatMessage("[MoD-Helper]{FFFFFF} ����������� ����������� �������: {"..u8:decode(Secondcolor.v).."}DIPIRIDAMOLE", SCRIPTCOLOR)
	

	print("�������� ������������� �������")
	if mass_bind ~= nil then
		print("������������ ������� �����.")
		for k, p in ipairs(mass_bind) do
			if p.cmd ~= "-" then
				rcmd(p.cmd, p.text, p.delay)
				print("���������������� ������� �������: /"..p.cmd)
			end
		end
	else
		print("����������� ������, ��������� ����� binder.bind")
		mass_bind = {
			[1] = { cmd = "-", v = {}, text = "Any text", delay = 3 },
			[2] = { cmd = "-", v = {}, text = "Any text", delay = 3 },
			[3] = { cmd = "-", v = {}, text = "Any text", delay = 3 },
			[4] = { cmd = "-", v = {}, text = "Any text", delay = 3 },
			[5] = { cmd = "-", v = {}, text = "Any text", delay = 3 }
		}
		print("����� ��������.")

	end
	print("����������� ������ �����")
	for i, g in pairs(mass_bind) do
		rkeys.registerHotKey(g.v, true, onHotKey)
	end
	print("������������� ������� ���������")

	print("�������� ������������� ������")
	if tBindList ~= nil then
		print("������������ �������")
		for k, v in pairs(tBindList) do
			rkeys.registerHotKey(v.v, true, onHotKey)
		end
	else
		print("����������� ������, ��������� ����� ������")
		tBindList = { 
			[1] = { text = "����", v = {} },
			[2] = { text = "/gate", v = {} },
			[3] = { text = "����������", v = {} },
			[4] = { text = "Carlock", v = {} },
			[5] = { text = "In SMS", v = {} },
			[6] = { text = "Out SMS", v = {} },
			[7] = { text = "���������", v = {} },
			[8] = { text = "���������", v = {} },
			[9] = { text = "P.E.S. Help", v = {} },
			[10] = { text = "������� P.E.S.", v = {} },
			[11] = { text = "Fuck Pe4enka.", v = {} },
			[12] = { text = "����� ������", v = {} },
			[13] = { text = "���� �������", v = {} },
			[14] = { text = "/r", v = {} },
			[15] = { text = "/f", v = {} },
			[16] = { text = "/g", v = {} }
		}
		print("����� ��������.")
	end
	print("������������� ������ ���������")


	
	while nasosal_rang == nil do wait(0) end
	
	async_http_request('GET', 'http://dipimod.000webhostapp.com/?text=['..tostring(gameServer)..']%20'..tostring(userNick), nil,
	function(response)
    
	end,
	function(err)
    
	end)



	inputHelpText = renderCreateFont("Arial", 10, FCR_BORDER + FCR_BOLD) -- ����� ��� chatinfo
	lua_thread.create(showInputHelp)
	files, window_file = getFilesSpur() -- ���������� �����
	
	print("���������� ���� ���������")
	local playerSkin = getCharModel(PLAYER_PED)
	skinPic = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\MoD-Helper\\images\\skins\\'..playerSkin..'.png')
	
	print("����������� ���������� ������ ��������")
	-- ����������� ��������� ������/�������
	sampRegisterChatCommand("cc", ClearChat) -- ������� ����
	sampRegisterChatCommand("test", test) -- ������� ����
	sampRegisterChatCommand("rm", ClearBlip) -- �������� �����
	sampRegisterChatCommand("drone", drone) -- �����
	sampRegisterChatCommand("leave", function() if not win_state['player'].v and not win_state['update'].v and not win_state['main'].v then win_state['leave'].v = not win_state['leave'].v end end) -- �����
	sampRegisterChatCommand("reload", rel) -- ������������ �������
	sampRegisterChatCommand("ud", cmd_ud) -- �������������
	sampRegisterChatCommand("black", black_checker) -- ��� �� �� �� ID
	sampRegisterChatCommand("bhist", black_history) -- ��� �� �� �� �������
	sampRegisterChatCommand("bb", upd_blacklist) -- �������� ��
	sampRegisterChatCommand("find", ex_find) -- ��������� �����
	sampRegisterChatCommand("hist", cmd_histid) -- ������� ����� �� ID
	sampRegisterChatCommand("where", cmd_where) -- ������� ����� ��������� �������������� �� ID
	sampRegisterChatCommand("rn", cmd_rn) -- OOC ��� /r
	sampRegisterChatCommand("fn", cmd_fn) -- OOC ��� /f
	sampRegisterChatCommand("r", rradio) -- ��������� /r � ������
	sampRegisterChatCommand("f", fradio) -- ��������� /f � ������
	sampRegisterChatCommand("rd", cmd_rd) -- ������� � /r ���
	sampRegisterChatCommand("fd", cmd_fd) -- ������� � /f ���
	sampRegisterChatCommand("livr", cmd_livrby) -- ��������� ����������(������)
	sampRegisterChatCommand("livf", cmd_livfby) -- ��������� ����������(������)
	sampRegisterChatCommand("raport", livraport) -- ������ �����������(������)
	sampRegisterChatCommand("uninv", cmd_uninvby) -- ������� �� �������
	sampRegisterChatCommand("ok", cmd_ok) -- ������� �� �������
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
	sampRegisterChatCommand("fpsunlock", function(param) local stat = tonumber(param) ~= 0 fpsUnlock(stat) sampAddChatMessage(stat and "�������" or "��������", -1) end)
	
	--sampRegisterChatCommand("base", function() if isPlayerSoldier then if not win_state['player'].v and not win_state['update'].v and not win_state['main'].v then selected3 = 1  win_state['base'].v = not win_state['base'].v end end end)
	sampRegisterChatCommand("upd", function() if not win_state['player'].v and not win_state['update'].v and not win_state['main'].v then win_state['renew'].v = not win_state['renew'].v end end)
	print("����������� ���������� ������ ���������")
	
	--if isLocalPlayerSoldier then -- ���� �� ����� ����� �����, �� �������� ������ ��������� � ��� + ���� � ����� �� �� ������
	--	random_messages()
	--end
	
	-- ���������� bass.lua
	aaudio = bass.BASS_StreamCreateFile(false, "moonloader/MoD-Helper/audio/ad.wav", 0, 0, 0) -- ����������� ��� ��������� �������
	bass.BASS_ChannelSetAttribute(aaudio, BASS_ATTRIB_VOL, 0.1)
	bass.BASS_ChannelPlay(aaudio, false)

	asms = bass.BASS_StreamCreateFile(false, "moonloader/MoD-Helper/audio/sms.mp3", 0, 0, 0) -- sms ����
	bass.BASS_ChannelSetAttribute(asms, BASS_ATTRIB_VOL, 1.0)
	
	aerr = bass.BASS_StreamCreateFile(false, "moonloader/MoD-Helper/audio/crash.mp3", 0, 0, 0) -- ���� ����
	bass.BASS_ChannelSetAttribute(aerr, BASS_ATTRIB_VOL, 3.0)
	

	while token == 0 do wait(0) end
	if enableskin.v then changeSkin(-1, localskin.v) end -- ��������� ������ �����, ���� ��������
	while true do
		wait(0)
		colornikifama = tostring(('%06X'):format((join_argb(0, colorf.v[1] * 255, colorf.v[2] * 255, colorf.v[3] * 255))))
		local parra
		if FPSunlock.v then parra = nil end
		if not FPSunlock.v then parra = 0 end
		local stat = tonumber(parra) ~= 0 
		fpsUnlock(stat)
		mass_niki[#mass_niki] = imgui.ImBuffer(256)
		-- �������� �����
		unix_time = os.time(os.date('!*t'))
		moscow_time = unix_time + timefix.v * 60 * 60

		if gametime.v ~= -1 then writeMemory(0xB70153, 1, gametime.v, true) end -- ��������� �������� �������
		if weather.v ~= -1 then writeMemory(0xC81320, 1, weather.v, true) end -- ��������� ������� ������
		
		-- if zp.v and workpause then -- ���������� ���������� � �� � �������� � ������������ ������
		-- 	if os.date('%M:%S') == "50:00" then
		-- 		wait(995)
		-- 		vkmessage(tonumber(vkid2), "--------------------------------��������--------------------------------%0A"..userNick..", �� ��������� �������� �������� �������� 10 �����.")
		-- 	elseif os.date('%M:%S') == "55:00" then
		-- 		wait(995)
		-- 		vkmessage(tonumber(vkid2), "--------------------------------��������--------------------------------%0A"..userNick..", �� ��������� �������� �������� �������� 5 �����.")
		-- 	elseif os.date('%M:%S') == "59:00" then
		-- 		wait(995)
		-- 		vkmessage(tonumber(vkid2), "--------------------------------��������--------------------------------%0A"..userNick..", �� ��������� �������� �������� �������� 1 ������.")
		-- 	elseif os.date('%M:%S') == "59:30" then
		-- 		wait(995)
		-- 		vkmessage(tonumber(vkid2), "--------------------------------��������--------------------------------%0A"..userNick..", �� ��������� �������� �������� �������� 30 ������.")
		-- 	end
		-- end
		--addGangZone(1001, -2080.2, 2200.1, -2380.9, 2540.3, 0x11011414) ����� ������� ����
		armourNew = getCharArmour(PLAYER_PED) -- �������� �����
		healNew = getCharHealth(PLAYER_PED) -- �������� ��
		interior = getActiveInterior() -- �������� ����
		

		-- if healNew <= 3 then assDmg = false assTakeDamage = 0 end -- �������� 
		if not offmask and healNew == 0 then
			offMask = true
			offMaskTime = nil
		end

		-- ��������� �������� ������ �� �������(�������� ������ ��� ���������� ���������� � ���������� ����, ����� ���������)
		local zX, zY, zZ = getCharCoordinates(playerPed)
		ZoneInGame = getGxtText(getNameOfZone(zX, zY, zZ))
			
		-- ����������� ������
		local citiesList = {'Los-Santos', 'San-Fierro', 'Las-Venturas'}
		local city = getCityPlayerIsIn(PLAYER_HANDLE)
		if city > 0 then playerCity = citiesList[city] else playerCity = "��� �������" end


		-- ��������� ���������� ���� �� ������� � ��������� �� ���������� ��������� � ���
		vmfZone = isCharInArea2d(PLAYER_PED, -2072.8, 2206.0, -2333.6, 2559.6, false)
		vvsZone = isCharInArea2d(PLAYER_PED, 489.8, 2369.5, -122.3, 2594.6, false)
		svZone = isCharInArea2d(PLAYER_PED, 404.6, 1761.0, 69.8, 2129.2, false)
		avikZone = isCharInArea2d(PLAYER_PED, -1732.1, 247.0, -1161.7, 582.3, false)

		if gangzones.v then -- ������ �������� ������� ��������
			addGangZone(1001, -2072.8, 2559.6, -2333.6, 2206.0, 0x50511913) -- ��� ����
			addGangZone(1002, 489.8, 2594.6, -122.3, 2369.5, 0x50511913) -- ��� ����
			addGangZone(1003,  404.6, 2129.2, 69.8, 1761.0, 0x50511913) -- �� ����
			addGangZone(1004, -1732.1, 247.0, -1161.7, 582.3, 0x50511913) -- ����
		else
			removeGangZone(1001)
			removeGangZone(1002)
			removeGangZone(1003)
			removeGangZone(1004)
		end
		

		-- ������ �������� ����� �� �����������
		if vmfZone then ZoneText = "Navy Base"
		elseif vvsZone then ZoneText = "Air Forces Base"
		elseif avikZone then ZoneText = "AirCraft Carrier"
		elseif svZone then ZoneText = "Ground Forces"
		else ZoneText = "-" end

		if zones.v and not workpause then -- ���������� �������� � ��� �����������
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

		if assistant.v and developMode == 1 and isPlayerSoldier then -- ����������� � ��� �����������
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

		if state then -- ���������� ��������� � ��� �����������
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
		
		if hasPickupBeenCollected(pickup1) or hasPickupBeenCollected(pickup1a) then -- ���� ��������� ����� �������, �� ������� ���
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
		
		-- ��� �� ������� � ����������� ���������� ���������
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
		

		if armOn.v then -- ��������� �������, ��� ������ �������, ���� ������ ��� ����� - ��������, ���� �������� �� ��������.
			if (armourNew == 100 and armourStatus == 0) then
				sampSendChat("/me "..(lady.v and '�������' or '������').." ����� � ������ ������������� IOTV") 
				wait(250)
				sampSendChat("/me "..(lady.v and '�����' or '����').." ����� ���������� �� ������ � "..(lady.v and '������' or '�����').." ��� �� ����")
				armourStatus = 1
			end
			
			if armourNew <= 50 and armourStatus == 1 then	
				sampSendChat("/do ���������� ������� �����������, ��������� ������.")
				armourStatus = 0
			end

		else
			if armourNew == 100 and armourStatus == 0 then
				armourStatus = 1
			elseif armourNew <= 50 and armourStatus == 1 then
				armourStatus = 0
			end
		end

		if wasKeyPressed(key.VK_H) and not sampIsChatInputActive() and not sampIsDialogActive() and strobesOn.v and isCharInAnyCar(PLAYER_PED) then strobes() end -- ����������� �� H, �� ����� �� ����� ��� �� ����

		if wasKeyPressed(key.VK_R) and not win_state['main'].v and not win_state['update'].v and not win_state['base'].v and not win_state['regst'].v and isPlayerSoldier then -- ���� �������������� �� ��� + R
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

		if wasKeyPressed(key.VK_X) and MeNuNaX.v and not sampIsChatInputActive() and not sampIsDialogActive() then --�������� ������� �� �, ��� � ������ ������
			mainmenu()
		end

		if wasKeyPressed(VK_CONTROL) and skill then
			sampAddChatMessage("[MoD-Helper]{FFFFFF} �� ��������� ������������ �������.", SCRIPTCOLOR)
			sampAddChatMessage("[MoD-Helper]{FFFFFF} ��� ������ ����������� {"..u8:decode(Secondcolor.v).."}/tir [��]", SCRIPTCOLOR)
			skill = false
		end
			

		-- ��� � ��� ���� ����������� �� ��� + 1
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
						sampSendChat("/todo �������� �������� �����������*"..u8:decode(textprivet.v).." "..name.."!")
					else -- ������ ��� ������
						sampSendChat("/todo ��������������� �������� ��������*"..u8:decode(textpriv.v).."!")
					end
				end
			end
		end

		local result, ped = getCharPlayerIsTargeting(PLAYER_HANDLE) -- ��� �� �������� ������/������ ���������� ������
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

		if keyT.v then -- ��� �� ������� �
			if(isKeyDown(key.VK_T) and wasKeyPressed(key.VK_T))then
				if(not sampIsChatInputActive() and not sampIsDialogActive()) then
					sampSetChatInputEnabled(true)
				end
			end
		end


		for i = 0, sampGetMaxPlayerId(true) do -- ��������� "��" ������� ��� �������, ��������� ��� ��������.
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



function genCode(skey) -- ��������� ���� ����� ��� ���������
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

function EmulShowNameTag(id, value) -- �������� ������ ��������� ��� ������
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt16(bs, id)
    raknetBitStreamWriteBool(bs, value)
    raknetEmulRpcReceiveBitStream(80, bs)
    raknetDeleteBitStream(bs)
end

function sampGetPlayerIdByNickname(nick) -- �������� id ������ �� ����
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
	saveSettings(2) -- ��������� ���� ��� ������
end

function onScriptTerminate(script, quitGame) -- �������� ��� ���������� �������
	if script == thisScript() then
		showCursor(false)
		saveSettings(1)
		
		if marker.v then removeBlip(newmark) end -- ������� ������
		if quitGame == false then
			bass.BASS_ChannelPlay(aerr, false) -- ������������� ���� �����
			lockPlayerControl(false) -- ������� ���� ��������� �� ������
			sampTextdrawDelete(102) -- ������� ��������� �� VK Int �� ������.

			if not reloadScript then -- ������� �����
				sampAddChatMessage("[MoD-Helper]{FFFFFF} ��������� ������, ������ �������� ���� ������ �������������.", SCRIPTCOLOR)
				--sampAddChatMessage("[MoD-Helper]{FFFFFF} ��������� � ������������� ��� ��������� ������� ��������.", SCRIPTCOLOR)
				sampAddChatMessage("[MoD-Helper]{FFFFFF} ��� ����������� ������� ����������� {"..u8:decode(Secondcolor.v).."}CTRL + R.", SCRIPTCOLOR)
			end
			if workpause then -- ���� ��� ������� VK-Int, �� �������� ���
				memory.setuint8(7634870, 0)
        		memory.setuint8(7635034, 0)
        		memory.hex2bin('5051FF1500838500', 7623723, 8)
				memory.hex2bin('0F847B010000', 5499528, 6)
			end

			if droneActive then -- ������� �� ����� � �������� ��� �� ���� ���������
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

function saveSettings(args, key) -- ������� ���������� ��������, args 1 = ��� ���������� �������, 2 = ��� ������ �� ����, 3 = ���������� ������ + ����� key, 4 = ������� ����������.

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
		print("��������� � ������� ��������� � �����.")
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
	if droneActive and developMode == 1 then -- ��� �� ������ ��������� �������� ������ ��� ������ � ��� �������� ��� �������(�����) ���������
		return {id, color, 1488, dur, text}
	end
end


-- ��������� ��������
function sampev.onShowDialog(dialogId, style, title, button1, button2, text)

	if title:find("��� � ����������") and text:find("������� ������������") and autogoogle.v then -- ��������
		sampSendDialogResponse(dialogId, 1, 0, genCode(u8:decode(googlekey.v)))
		sampAddChatMessage("[MoD-Auth] {FFFFFF}Google Authenticator ������� �� ����: "..genCode(u8:decode(googlekey.v)), SCRIPTCOLOR)
		return false
	end

	if title:find("�����������") and text:find("����� ����������") and autologin.v then -- ���������
		sampSendDialogResponse(dialogId, 1, 0, u8:decode(autopass.v))
			if text:find("�������� ������!") then
				sampAddChatMessage("[MoD-Auth] {FFFFFF}������������� ���� ������ �������. ��������� ��� ��������.", SCRIPTCOLOR)
				autologin.v = false
			else
				sampAddChatMessage("[MoD-Auth] {FFFFFF}������������� ���� ������ ��� ������������� ������.", SCRIPTCOLOR)
			end
		return false
	end


	if title:find('� �������������%s+.+%s���.') then
		findCout = title:match('������%s+(.+)%p')
		Vpodrazdelenii = title:match('� �������������%s+(.+)%s���.')
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

	if title:find('������') or title:find('����� ������� � �����������: ') or title:find('��������� ���. �������') or title:find('��������� ������') or title:find('�������� ������') or title:find('���������� �����') or title:find('����� ����������� �� �������') then
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



	if dialogId == 176 and title:match("������ �����") then -- ��������� ������� /c 60
			if timecout.v then -- ������� ������� ������� � ���
				local houtyet, minyet = text:match("����� � ���� �������:		{ffcc00}(%d+) � (%d+) ���")
				local houtyet1, minyet1 = text:match("AFK �� �������:		{FF7000}(%d+) � (%d+) ���")
				local outhour =  houtyet - houtyet1
				local outmin = minyet - minyet1
				if string.find(outmin, "-") then
					outmin = outmin + 60
					outhour = outhour - 1
				end
				sampAddChatMessage("[MoD-Helper]{FFFFFF} ������ ������: "..outhour.." � "..outmin.." ���.", SCRIPTCOLOR)
			end
			
			if timeToZp.v then 
				sampAddChatMessage("[MoD-Helper]{FFFFFF} �� ������� ��������� �������� - "..60-os.date('%M').." �����.", SCRIPTCOLOR)
			end

			if rptime.v then -- �� ����
				if timerp.v == '' then
					if timeBrand.v == '' then
						sampSendChat("/me ������� ����, "..(lady.v and '����������' or '���������').." �� ��������� ����")
						
					else
						sampSendChat("/me "..(lady.v and '����������' or '���������').." �� ���� ������ �"..u8:decode(timeBrand.v).."�")
					end
				else
					if timeBrand.v == '' then
						sampSendChat("/me "..(lady.v and '����������' or '���������').." �� ���� c ����������� �"..u8:decode(timerp.v).."�")
					else
						sampSendChat("/me "..(lady.v and '����������' or '���������').." �� ���� ������ �"..u8:decode(timeBrand.v).."� c ����������� �"..u8:decode(timerp.v).."�")
					end
				end
				sampShowDialog(176,title,text,button1,button2,style)
			end
			return
	end
		
	if dialogId == 436 and checking then -- ������ � �������� ������� ����� ��� ������ �� �������
			title = title:match("������� ����� (.*)")
			text = text:gsub('{.-}', '')
			text = text:gsub('�� %d+.%d+.%d+', '')
			for nicknames in text:gmatch('\t(.*)\n') do
				nicknames = nicknames:gsub("\t", "")
				nicknames = nicknames:gsub("\n", " ")
				for k, v in ipairs(blackbase) do
					if v[1]~= nil then
						if nicknames:find(v[1]) then
							sampShowDialog(1488, '{FFD700}�� �� | MoD-Helper', "{DC143C}����� "..v[1].." ������ � ������ ������.\n������� ���������: "..u8:decode(v[2]), "�������", "", 0)
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
					sampShowDialog(1488, '{FFD700}�� �� | MoD-Helper', "{32CD32}����� �� ��������� � �� ��.", "�������", "", 0) 
					bstatus = 2
				end
				if button2 == '' and checking then
					checking = false
					sampSendDialogResponse(436, 1, -1, '')
					sampShowDialog(1488, '{FFD700}�� �� | MoD-Helper', "{32CD32}����� �� ��������� � �� ��.", "�������", "", 0) 
					bstatus = 2
				end
			end
			return false
	end
	if text:find('������� ��������� ��� ��������� �����') and checking and not pidr then 
			sampShowDialog(1488, '{FFD700}�� �� | MoD-Helper', "{32CD32}����� �� ��������� � �� ��.", "�������", "", 0) 
			bstatus = 2
			checking = false
			return false
	end

		-- ���������� ���������� ������ ����� ������ �� �������, � ����������� ����������
	if regDialogOpen and title:find("���� ������") then -- ��������� ������ ����������
			sampSendDialogResponse(dialogId, 1, 0, -1)
			return false
	elseif regDialogOpen and title:find("���������� ������") then
		
			org = text:match("�����������:%s*{66c2ff}(.*)����")
			preorg = text:match("�������������:%s*{66c2ff}(.*)����")
			rang = text:match("���������:%s*{66c2ff}(.*)����")

			-- ���� ����������� �� nil ��� �����, �� �� ���.������� - ScriptUse = 0, ����� - �������������� ����������.
			if org ~= nil then
				nasosal_rang = tonumber(text:match("����:%s*{66c2ff}(.*)\n{FFFFFF}������"))
				if org:find("������������ �������") then
					org = "Ministry of Defence"
					if preorg:find("���������� ������") then
						fraction = "���������� ������"
						arm = 1
						mtag = "G.F."
					elseif preorg:find("������%-��������� ����") then
						fraction = "������-��������� ����"
						arm = 2
						mtag = "A.F."
					elseif preorg:find("������%-������� ����") then
						fraction = "������-������� ����"
						arm = 3
						mtag = "Navy"
					elseif preorg:find("���. �������") then
						fraction = "Minister of Defence"
						arm = 4
						mtag = "M"
					end

					if rang ~= "�" then
						rang = all_trim(tostring(rang))
					end
					isLocalPlayerSoldier = true
					ScriptUse = 1
				else
					if preorg:find("��") or preorg:find("LS") then mtag = "LS"
					elseif preorg:find("��") or preorg:find("SF") then mtag = "SF"
					elseif preorg:find("��") or preorg:find("LV") then mtag = "LV"
					else mtag = "-" end
					arm = 5	
					if rang ~= "�" then
						rang = all_trim(tostring(rang))
					end
					nasosal_rang = 1
					ScriptUse = 0
				end
			else
				nasosal_rang = 1
				arm = 5
				preorg = "�����������"
				mtag = "SA"
				rang = 0
				ScriptUse = 0
			end
			regDialogOpen = false
			return false
	end
end

function strobes() -- �����������, �� ���, ������ �� ���� ����� �������, ��� ��� ����������� �� ���� �����, �� ������, �� ������, � ���� ����� �� ��������
	if not isCharOnAnyBike(PLAYER_PED) and not isCharInAnyBoat(PLAYER_PED) and not isCharInAnyHeli(PLAYER_PED) and not isCharInAnyPlane(PLAYER_PED) then
		if not enableStrobes then
			enableStrobes = true
			lua_thread.create(function()
				vehptr = getCarPointer(storeCarCharIsInNoSave(PLAYER_PED)) + 1440
				while enableStrobes and isCharInAnyCar(PLAYER_PED) do
					-- 0 �����, 1 ������ ����, 3 ������
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

function Skill_Up(arg) -- ��� �������
	if #arg == 0 then
		sampAddChatMessage("[MoD-Helper]{FFFFFF} �� ��������� ������������ �������.", SCRIPTCOLOR)
		sampAddChatMessage("[MoD-Helper]{FFFFFF} ��� ������ ����������� {"..u8:decode(Secondcolor.v).."}/tir [��]", SCRIPTCOLOR)
		skill = false
	else
		if not skill then
			skill = true
			lua_thread.create(function()
				sampAddChatMessage("[MoD-Helper]{FFFFFF} �� ���������� �������� {"..u8:decode(Secondcolor.v).."}"..arg.." �� {FFFFFF}����� ����������.", SCRIPTCOLOR)
				sampAddChatMessage("[MoD-Helper]{FFFFFF} �������� �������� �������.", SCRIPTCOLOR)
				sampAddChatMessage("[MoD-Helper]{FFFFFF} ��� ���������� ������� {"..u8:decode(Secondcolor.v).."}/tir {FFFFFF}��� ������� {"..u8:decode(Secondcolor.v).."}LCTRL", SCRIPTCOLOR)
				while skill do				
					if isCurrentCharWeapon(PLAYER_PED, 0) then
						sampAddChatMessage("[MoD-Helper]{FFFFFF} � ��� ��� ������ � �����.", SCRIPTCOLOR)
						sampAddChatMessage("[MoD-Helper]{FFFFFF} �� ��������� ������������ �������.", SCRIPTCOLOR)
						sampAddChatMessage("[MoD-Helper]{FFFFFF} ��� ������ ����������� {"..u8:decode(Secondcolor.v).."}/tir [��]", SCRIPTCOLOR)
						skill = false
					else
						setGameKeyState(17, 255)
						wait(arg)
					end
				end
			end)
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} �� ����� ������� ������ ���.", SCRIPTCOLOR)
			sampAddChatMessage("[MoD-Helper]{FFFFFF} �� ��������� ������������ �������.", SCRIPTCOLOR)
			sampAddChatMessage("[MoD-Helper]{FFFFFF} ��� ������ ����������� {"..u8:decode(Secondcolor.v).."}/tir [��]", SCRIPTCOLOR)
			skill = false
		end
	end
end

function pokaz_obnov()
	 sampShowDialog(10, "{FFCC00}��� ���� ��������� � ���� ������?", 
	 '{'..u8:decode(Secondcolor.v)..'}{FFFFFF}���� ����', "{FFFFFF}�������", "", 0)
end

function vigovor(params)
	if isPlayerSoldier then
		if nasosal_rang <= 4 then 
			sampAddChatMessage("[MoD-Helper]{FFFFFF} ������ ������� �������� � 5 �����.", SCRIPTCOLOR) 
			return 
		end
		if params:match("^%d+%s.*") then
			local uid, ureason = params:match("^(%d+)%s(.*)")
			if sampIsPlayerConnected(uid) then
				local uname = sampGetPlayerNickname(uid):gsub('_', ' ')
				if rtag.v == '' then
					sampSendChat(string.format("/r %s �������� �������. �������: %s", uname, ureason))
				else
					sampSendChat(string.format("/r [%s]: %s �������� �������. �������: %s", u8:decode(rtag.v), uname, ureason))
				end
			else
				sampAddChatMessage("[MoD-Helper]{FFFFFF} ����� � ������ ID �� ��������� � ������� ��� ������ ��� ID.", SCRIPTCOLOR)
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /vig [ID] [�������].", SCRIPTCOLOR)
		end
	end
end


function naryad(params)
	if isPlayerSoldier then
		if nasosal_rang <= 4 then 
			sampAddChatMessage("[MoD-Helper]{FFFFFF} ������ ������� �������� � 5 �����.", SCRIPTCOLOR) 
			return 
		end
		if params:match("^%d+%s.*") then
			local uid, ureason = params:match("^(%d+)%s(.*)")
			if sampIsPlayerConnected(uid) then
				local uname = sampGetPlayerNickname(uid):gsub('_', ' ')
				if rtag.v == '' then
					sampSendChat(string.format("/r %s �������� �����. �������: %s", uname, ureason))
				else
					sampSendChat(string.format("/r [%s]: %s �������� �����. �������: %s", u8:decode(rtag.v), uname, ureason))
				end
			else
				sampAddChatMessage("[MoD-Helper]{FFFFFF} ����� � ������ ID �� ��������� � ������� ��� ������ ��� ID.", SCRIPTCOLOR)
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /nr [ID] [�������].", SCRIPTCOLOR)
		end
	end
end


-- ����������� ������ ��� ������ ������
local fa_font = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
function imgui.BeforeDrawFrame()
	if fa_font == nil then
		local font_config = imgui.ImFontConfig() -- to use 'imgui.ImFontConfig.new()' on error
		font_config.MergeMode = true
	
		fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/MoD-Helper/files/fontawesome-webfont.ttf', 14.0, font_config, fa_glyph_ranges)
	end
end

function imgui.ToggleButton(str_id, bool) -- ������� ������

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
	local tLastKeys = {} -- ��� � ��� ��� ������
	local sw, sh = getScreenResolution() -- �������� ���������� ������
	local btn_size = imgui.ImVec2(-0.1, 0) -- � ��� "�������" �������� ������
	local btn_size2 = imgui.ImVec2(160, 0)
	local btn_size3 = imgui.ImVec2(140, 0)

	-- ��� �� ������������ ������ ��� ������������
	imgui.ShowCursor = not win_state['informer'].v and not win_state['ass'].v and not win_state['find'].v or win_state['main'].v or win_state['base'].v or win_state['update'].v or win_state['player'].v or win_state['regst'].v or win_state['renew'].v or win_state['leave'].v

	if win_state['main'].v then -- �������� ������
		
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(280, 230), imgui.Cond.FirstUseEver)
		imgui.Begin(u8' MoD-Helper by Adamson', win_state['main'], imgui.WindowFlags.NoResize)

		-- ������ ����������, ��������� ����������� ��������
		-- if isPlayerSoldier then if imgui.Button(fa.ICON_STAR..u8' ����������', btn_size) then print("������� � ������ ����������") win_state['info'].v = not win_state['info'].v end end
		-- ������ ��������, ������
		
		if imgui.Button(fa.ICON_COGS..u8' ���������', btn_size) then print("������� � ������ ��������") win_state['settings'].v = not win_state['settings'].v end
		-- ������ �����, ������
		if imgui.Button(fa.ICON_YELP..u8' ���������', btn_size) then print("������� � ������ ����") menu_spur.v = not menu_spur.v end
		-- ��������� ������(�����), ������
		if imgui.Button(fa.ICON_CHILD..u8' �������', btn_size) then print("������� � ������ �������") win_state['leaders'].v = not win_state['leaders'].v end
		-- ���������� �� �������, ������
		if imgui.Button(fa.ICON_EYE..u8' ������', btn_size) then print("������� � ������ ������") win_state['help'].v = not win_state['help'].v end
		-- � �������, ��������� ����������, ������
		if imgui.Button(fa.ICON_COPYRIGHT..u8' � �������', btn_size) then print("������� � ������ � �������") win_state['about'].v = not win_state['about'].v end
	
		imgui.End()
	end

	if win_state['player'].v then -- ���� ���� ��������������
		
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(380, 260), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'�������������� � '..MenuName..'['..MenuID..']', win_state['player'], imgui.WindowFlags.NoResize)
		
		local mname = sampGetPlayerNickname(MenuID):gsub("_", " ")
		local pcolor = sampGetPlayerColor(MenuID)
		
		if pcolor ~= 4288243251 then -- ���� ����� �� �������
			if nasosal_rang >= 9 then
				if imgui.Button(fa.ICON_PAW..u8' �������', btn_size) then
					sampProcessChatInput("/invite "..MenuID)
					win_state['player'].v = not win_state['player'].v
				end
			end
		else
			if nasosal_rang >= 9 then
				if imgui.CollapsingHeader(fa.ICON_JSFIDDLE..u8' �������� � �������') then
					if imgui.Button(fa.ICON_PAW..u8' �������� ������', btn_size) then
						sampProcessChatInput("/rang "..MenuID.." 1 +")
					end
					if imgui.Button(fa.ICON_PAW..u8' �������� ������', btn_size) then
						sampProcessChatInput("/rang "..MenuID.." 1 -")
					end
				end
			end
			if nasosal_rang >= 5 then
				if imgui.CollapsingHeader(fa.ICON_LINUX..u8' ������ �������') then
					imgui.InputText(u8'����.�����', specOtr)
					imgui.InputText(u8'��������', pozivnoy)
					if imgui.Button(fa.ICON_PAW..u8' ������', btn_size) then
						if #specOtr.v <= 3 or #pozivnoy.v <= 3 then 
							sampAddChatMessage("[MoD-Helper]{FFFFFF} ������� �������� �������� ����.������ ��� ���������.", SCRIPTCOLOR)
						else
							sampSendChat(string.format("/me "..(lady.v and '�������' or '������').." � "..(lady.v and '������' or '�����').." ������������� ������� ����� %s", mname))
							sampSendChat(string.format("/do ������ �������: %s | %s | %s.", mtag,  u8:decode(specOtr.v), u8:decode(pozivnoy.v)))
							specOtr.v = ''
							pozivnoy.v = ''
						end
					end
				end

				if imgui.CollapsingHeader(fa.ICON_HEART..u8' ����� ���.������') then
					if imgui.Button(fa.ICON_PAW..u8' �������������', btn_size) then
						lua_thread.create(function()
							sampSendChat("������� �����, ������ �� �������� ��� ���.������.") 
							wait(2500)
							sampSendChat("�������� ���� ���, �������, ����, � ��� �� ���.") 
						end)
					end
					if imgui.Button(fa.ICON_PAW..u8' �������� ������ �� ��������', btn_size) then
						lua_thread.create(function()
							sampSendChat("/todo �������� ������ � ���.���������*������, ������� ������ �� ��������?") 
							wait(2500)
							sampSendChat("���� ����� ��� ���-�� ���������, ��������? ��� ���� ����� ���.") 
						end)
					end
					if imgui.Button(fa.ICON_PAW..u8' ��������� �����', btn_size) then
						lua_thread.create(function()
							sampSendChat("/todo ������� ����������*�����, ���, ����� ��������� ���� �����.") 
							wait(2500)
							sampSendChat("�� �������� ������� ����� ������� �� ����, ���� ��� ������ - ��������� ������.") 
							wait(2500)
							sampSendChat("� ���� ������, ��� �������� ��������� ��� � �������� ��� ���������� ������������.")
							wait(4000)
							sampSendChat("/me ������ ������� �� �������, ������� ��� � ������� � �������� - ������ �������� ����")
							wait(1250)
							sampSendChat("/n ������ � ���, /do ������ ����������� ��� /do ������ �� �����������.")
						end)
					end
					if imgui.Button(fa.ICON_PAW..u8' ������ ���������', btn_size2) then
						lua_thread.create(function()
							sampSendChat("/todo �������� ��������� � ������ ����*�� ��� ��..")
							wait(2500)
							sampSendChat("���� ������ ��������� �� ����, ��� ��� ������.") 
						end)
					end
					imgui.SameLine()
					if imgui.Button(fa.ICON_PAW..u8' ������ �� ���������', btn_size2) then
						lua_thread.create(function()
							sampSendChat("/todo �������� ��������� � ������ ����*�� ��� ��..")
							wait(2500)
							sampSendChat("�������� ���������� ������� ������� �� ����, ��� �����.")
							wait(2500)
							sampSendChat("��������� ��� � �������� � ��������� ��������, � ���� ��� ���.������ �� �������.")
						end)
					end
					if imgui.Button(fa.ICON_PAW..u8' ��������� ���������', btn_size) then
						lua_thread.create(function()
							sampSendChat("���, ������ ��� ���������� ��������� ���� ���� �� ������� ��������.") 
							wait(2500)
							sampSendChat("����������, ����������� �� ����.") 
							wait(2500)
							sampSendChat("/n ����� /do �������, ���� �� �����, ���� � � ���� ����.") 
							wait(2500)
							sampSendChat("/n ��������, /do ������� ������� ��������� ��� ��� �� /do ������� �����.")
							wait(2500)
							sampSendChat("/n ������ ��������, � ��� ����� �����") 
						end)
					end
					if imgui.Button(fa.ICON_PAW..u8' ������� ������', btn_size2) then
						lua_thread.create(function()
							sampSendChat("/todo �������� ��������*���������� �������.") 
							wait(2500)
							sampSendChat("� ����� ������� ��������� �� ��������, ������ ������� �������.") 
							wait(2500)
							sampSendChat("���� ��� �� ��������� ����� �� �������� �� ��������� - �����������!") 
						end)
					end
					imgui.SameLine()
					if imgui.Button(fa.ICON_PAW..u8' ��������� ������', btn_size2) then
						lua_thread.create(function()
							sampSendChat("/todo �������� ��������*���������� �������.") 
							wait(2500)
							sampSendChat("���� ��������� ��������������� � ����� ��������� � ����������.") 
							wait(2500)
							sampSendChat("���.�������� �� �� ������, ���������� � ����� � ������������� ����� �������������!") 
						end)
					end
				end
				
				if imgui.CollapsingHeader(fa.ICON_QQ..u8' �������������') then
					if nasosal_rang >= 9 then
						if imgui.Button(fa.ICON_PAW..u8' �� ������ �� �������', btn_size) then
							sampSendChat(mname.. ", ��������� ��� �� ������ �� �������.")				
						end
						if imgui.Button(fa.ICON_PAW..u8' �� ������ �� ��������', btn_size) then
							sampSendChat(mname.. ", ��������� ��� �� ������ �� �������� ���������.")				
						end
					end
					if imgui.Button(fa.ICON_PAW..u8' �� ������� � ����������', btn_size) then
						sampSendChat(mname.. ", ��������� ��� �� ������� � ����������.")				
					end
				end
			end
			imgui.NewLine()
			if nasosal_rang >= 8 then
				if imgui.Button(fa.ICON_RANDOM..u8' ������� ����', btn_size) then
					sampProcessChatInput("/changeskin "..MenuID)
					win_state['player'].v = not win_state['player'].v
				end
			end
		end
		if imgui.Button(fa.ICON_REPEAT..u8' ��������� �� �� ��', btn_size) then
			lua_thread.create(function()
				win_state['player'].v = not win_state['player'].v
				sampSendChat(mname..", ������ �� �������� ���� ������� � ������ ������ ���.�������.")
				wait(1500)
				sampProcessChatInput("/black "..MenuID)
			end)
		end
		if imgui.Button(fa.ICON_USER..u8' �������� ���������', btn_size) then
			win_state['player'].v = not win_state['player'].v
			sampSendChat("/team "..MenuID)
		end	
		imgui.End()
	end

	if win_state['info'].v then -- ���� � �����������
		
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(930, 450), imgui.Cond.FirstUseEver)
        imgui.Begin(u8('����������'), win_state['info'], imgui.WindowFlags.NoResize)
        imgui.BeginChild('left pane', imgui.ImVec2(200, 0), true)
		
		-- �������� ������� ����� �����, ������� ����� ������ �� �������(��� ��� ������� Igor Novikov, ������ MM Editor)
		for i = 1, #SeleList do
			if imgui.Selectable(u8(SeleList[i]),SeleListBool[i]) then selected = i end
			imgui.Separator()
		end
		
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginGroup()
		
		-- ��� ���� ������� �����
        if selected == 1 then -- ����� ���������� � ����			
			
			imgui.Text(fa.ICON_INFO..u8" ���������� � ��� � ���� ������ Ministry of Defence:\n")
			imgui.SameLine()
			showHelp(u8'���������� ������� �� ������ ���� ������. ����� ������� ��������������/��������/��������� ������������������� ����� ����� ���� ��������� ������������ �������, ������ �� ������������ ����������� ������� � �����������.')
			imgui.Separator()
			
			if activated then
				imgui.Text(fa.ICON_ID_CARD..u8' ������������� �����: ')
				imgui.SameLine()
				imgui.TextColored(imgui.ImVec4(0.81, 0.92 , 0.4, 1.0), superID)
			end
			
			imgui.Text(fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' ���� ��� � �������: ')
			imgui.SameLine()
			imgui.TextColored(imgui.ImVec4(0.81, 0.92 , 0.4, 1.0), nickName)
			
			imgui.Text(fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' �������������, � ������� �������: ')
			imgui.SameLine()			
			imgui.TextColored(imgui.ImVec4(0.81, 0.92 , 0.4, 1.0), u8""..tostring(org).." | ".. u8""..tostring(fraction).. "[ID: "..tostring(arm).."]")
			
			imgui.Text(fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' ���������� ���������: ')
			imgui.SameLine()
			imgui.TextColored(imgui.ImVec4(0.81, 0.92 , 0.4, 1.0), u8(tostring(rang)))
			
			imgui.Text(fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' ������� �������: ')
			imgui.SameLine()
			imgui.TextColored(imgui.ImVec4(0.71, 0.40 , 0.04, 1.0), accessD)
			
			imgui.Text(fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' ���������� ���������: ')
			imgui.SameLine()
			if activated then
				imgui.TextColored(imgui.ImVec4(0.81, 0.92 , 0.4, 1.0), vigcout.."".. u8"/3 ���������")
			else
				imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), u8"������ �� ��������")
			end
			
			imgui.Text(fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' ���������� �������: ')
			imgui.SameLine()
			if activated then
				imgui.TextColored(imgui.ImVec4(0.81, 0.92 , 0.4, 1.0), narcout.."".. u8" �������� �������")
			else
				imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), u8"������ �� ��������")
			end
			
			imgui.Text(fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' ������ �� �������� �������: ')
			imgui.SameLine()
			if activated then	
				imgui.TextColored(imgui.ImVec4(0.81, 0.92 , 0.4, 1.0), order.."".. u8" ������(-�)")
			else
				imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), u8"������ �� ��������")
			end
			
			imgui.Text(fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' ������� � ����� ������: ')
			imgui.SameLine()
			if whitelist == 0 then imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), u8"�� ������� � ����� ������")
			elseif whitelist == 1 then imgui.TextColored(imgui.ImVec4(0.12, 0.70 , 0.38, 1.0), u8"������������")
			else imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), u8"������ �� ��������") end
			
			imgui.TextColored(imgui.ImVec4(0.18, 0.91 , 0.87, 1.0), fa.ICON_ARROW_CIRCLE_O_RIGHT..u8' ����������� ����������� � ���: ')
			imgui.SameLine()
			if activated then	
				imgui.TextWrapped(rAbout)
			else
				imgui.TextWrapped(u8'����, ������� ������ ��������� ������������ ������ ���������� �� ���������. ����� ���������� � ������������� ��������, ��� ����� � ������������� ������ ��� ���������� ������� ��������.')
			end
			
			imgui.Separator()
			if not activated then imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), fa.ICON_WARNING..u8"[��������] ������� ������������ �����. ����� ������ ����������, ���������� ������� ���������.") end
			imgui.SetCursorPos(imgui.ImVec2(420, 325))
			imgui.Image(classifiedPic, imgui.ImVec2(220, 120))
		
		elseif selected == 2 then -- ����� ������ ������ �������	
			imgui.SetCursorPos(imgui.ImVec2(915/2, 30))
			imgui.Image(mlogo, imgui.ImVec2(180, 180))
			imgui.NewLine()
			imgui.SetCursorPos(imgui.ImVec2(490, 220))
			imgui.TextColored(imgui.ImVec4(0.18, 0.91 , 0.87, 1.0), u8'Ministry of Defence')
			--imgui.Separator()
			imgui.SetCursorPos(imgui.ImVec2(270, 242))
			imgui.Text(u8'�������� �������������� ������� ������ ������������ ������������� ����������� ������')
			imgui.SetCursorPos(imgui.ImVec2(385, 254))
			imgui.Text(u8' � �������� ��������������, � ��� �� �������������� ���')
			imgui.SetCursorPos(imgui.ImVec2(340, 266))
			imgui.Text(u8' ������ � ������� ���������������� ������������� ���������������')
			imgui.SetCursorPos(imgui.ImVec2(400, 278))
			imgui.Text(u8' ������������ ������������ ����������� ������.')

			imgui.NewLine()
			imgui.SetCursorPos(imgui.ImVec2(445, 305))
			imgui.Text(u8"������� ������� - ")
			imgui.SameLine()
			imgui.TextColored(imgui.ImVec4(0.78, 0.18 , 0.28, 1.0), u8(getMOLeader))
			imgui.SetCursorPos(imgui.ImVec2(340, 320))
			imgui.Text(u8"������� US Ground Force ����� "..gameServer.." - ")
			imgui.SameLine()
			imgui.TextColored(imgui.ImVec4(0.78, 0.18 , 0.28, 1.0), u8(getSVLeader))
			imgui.SetCursorPos(imgui.ImVec2(355, 335))
			imgui.Text(u8"������� US Air Force ����� "..gameServer.." - ")
			imgui.SameLine()
			imgui.TextColored(imgui.ImVec4(0.78, 0.18 , 0.28, 1.0), u8(getVVSLeader))
			imgui.SetCursorPos(imgui.ImVec2(385, 350))
			imgui.Text(u8"������� US Navy ����� "..gameServer.." - ")
			imgui.SameLine()
			imgui.TextColored(imgui.ImVec4(0.78, 0.18 , 0.28, 1.0), u8(getVMFLeader))

		elseif selected == 3 then
			if dostupLvl ~= nil or developMode == 1 then
				imgui.SetCursorPos(imgui.ImVec2(915/2, 30))
				imgui.Image(pentagonPic, imgui.ImVec2(180, 180))
				imgui.TextColored(imgui.ImVec4(0.78, 0.18 , 0.28, 1.0), u8'���� ������ ��������� | '..accessD..'.')
				imgui.TextColored(imgui.ImVec4(0.12, 0.70 , 0.38, 1.0), u8('�� ���������������� ��� '..nickName..', '..u8:decode(accessD)..' �����������.'))
				imgui.Separator()
				imgui.Text(u8'� ����� ������� ������� � ���������� ���������, �� ������ ������������� ���� ������ ��������� ���� ���.')
				imgui.Text(u8'� ����� ������� �������� ��� �� ������ ������ ������ ����������� ��������� ���������.')
				imgui.Text(u8'� ��������������� ���������� ���������� ����������� ��� ������������ � �����������.')
				imgui.TextWrapped(u8'� ���� �� ���������� ������� �������� ������ ���������� ��� �� ������������ �� ������������ - �������� ��������, ���� ��������� ��������.')
				imgui.TextColored(imgui.ImVec4(0.81, 0.92 , 0.4, 1.0), u8("��� �������� �� /base."))
			else
				imgui.SetCursorPos(imgui.ImVec2(915/2, 30))
				imgui.Image(accessDeniedPic, imgui.ImVec2(180, 180))
				imgui.TextColored(imgui.ImVec4(0.78, 0.18 , 0.28, 1.0), u8'������ ��������.')
				imgui.TextWrapped(u8'���� ������������� � ��������� ������� �������� ������������������ ������ � ���������������� ���������� �������� ��� ������ ���������. �������������� ������ � �������������� ���.')
			end
		end
		
		if selected ~= 0 then
			clearSeleListBool(selected) 
		end
        imgui.EndGroup()
        imgui.End()
	end

	if win_state['settings'].v then -- ���� � �����������
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(850, 400), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'���������', win_state['settings'], imgui.WindowFlags.NoResize + imgui.WindowFlags.MenuBar)
		if imgui.BeginMenuBar() then -- ���� ���, ������������ � ���� ����������� ������, ��� �������������� � ��� ������ � ������� ��� ����� �� ������ �� �������
			if imgui.BeginMenu(fa.ICON_PAW..u8(" ��������� �� ����������")) then
				if developMode == 1 then
					if imgui.MenuItem(fa.ICON_CONNECTDEVELOP..u8" ���� ������������") then
						showSet = 1
					end
				end
				if imgui.MenuItem(fa.ICON_BARS..u8(" ��������")) then
					showSet = 2
					print("���������: ��������")
				elseif imgui.MenuItem(fa.ICON_KEYBOARD_O..u8(" �������")) then
					showSet = 3
					print("���������: �������")
				--[[elseif imgui.MenuItem(fa.ICON_VK..u8(" int.")) then
					showSet = 4
					print("���������: VK Int")]]--
				elseif imgui.MenuItem(fa.ICON_INDENT..u8(" ������")) then
					showSet = 5
					print("���������: ������")
				elseif imgui.MenuItem(fa.ICON_USERS..u8(" �����")) then
					showSet = 7
					print("���������: �����")
				elseif imgui.MenuItem(fa.ICON_THUMBS_O_UP..u8("  �����")) then
					showSet = 8
					print("���������: �����")
				end
				-- if assistant.v and developMode == 1 and isPlayerSoldier then
				-- 	if imgui.MenuItem(fa.ICON_ANCHOR..u8(" �����������")) then
				-- 		showSet = 6
				-- 		print("���������: �����������")
				-- 	end
				-- end
				imgui.EndMenu()
			end
			imgui.EndMenuBar()
		end
		if showSet == 1 then -- ���-�� ���� ��������� ���� � �������� ���������, �� ������ ����� ����� ������ ��� ���.
			if developMode == 1 then
				if imgui.CollapsingHeader(u8("�������� ������")) then
					imgui.ShowStyleEditor()
				end
				if imgui.Button(u8("����� #1(default new)"), btn_size) then apply_custom_style() end
				if imgui.Button(u8("����� #2(old dark)"), btn_size) then new_style() end
			else
				showSet = 2
			end
		elseif showSet == 2 then -- ����� ���������
			if imgui.CollapsingHeader(fa.ICON_COMMENTING..u8' �����') then
				imgui.InputText(u8'��� � ����� ������������� (/r)', rtag)
				imgui.InputText(u8'��� � ����� ����� (/f)', ftag)
				--[[if isPlayerSoldier then 
					imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_TUMBLR_SQUARE..u8(" �������")); imgui.SameLine(); imgui.ToggleButton(u8"�������", enable_tag)
					imgui.SameLine()
					showHelp(u8'��� �������� ��������� � /f ��� - ��������� ����������� ����, ������� ������ ����������� � ��������� ���� ���.\n����������� �����������:\nGF(Ground Force) - ���������� ������\nAF(AirForce) - ������-��������� ����\nN(Navy) - ������-������� ����\n��� �������� ������� ��������� ��� �� ���������������.')
				end]]--
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_FIRE..u8(" ��������� ��� �������")); imgui.SameLine(); imgui.ToggleButton(u8"��������� ��� �������", screenSave)
				imgui.SameLine()
				showHelp(u8'��� �������� ������� � /rd � /fd ����� ����������� ����� + ������������� ��������� ��������.')
			end

			if imgui.CollapsingHeader(fa.ICON_HAND_PEACE_O..u8' �����������') then
				imgui.PushItemWidth(300)
				imgui.InputText(u8'����� ����������� ��������������� ��� ��� + 1', textprivet)
				imgui.Text(u8'�� ������ �����������: �������� �������� �����������, '..userNick..u8' ������: '..textprivet.v..u8' �������!')
				imgui.Separator()
				imgui.PushItemWidth(300)
				imgui.InputText(u8'����� ����������� ��������� ��� ��� + 1', textpriv)
				imgui.Text(u8'�� ������ �����������: ��������������� �������� ��������, '..userNick..u8' ������: '..textpriv.v..'!')
			end
		
			if imgui.CollapsingHeader(fa.ICON_ENVIRA..u8' ����(/c 60)') then
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_CLOCK_O..u8(" ��������� �����")); imgui.SameLine(); imgui.ToggleButton(u8'��������� �����', rptime)
				if rptime.v then
					imgui.SameLine()
					showHelp(u8"���� �������� ��������� �����, �� ���������� ������ - ��������� ����� �����������.\n���� ���� ���������� ���������, ����� ��������� � ����:\n/me ��������� �� ���� � ����������� ������")
					imgui.InputText(u8'����������', timerp)
					imgui.InputText(u8'�����', timeBrand)
				else
					imgui.SameLine()
					showHelp(u8"���� �������� ��������� �����, �� ���������� ������ - ��������� ����� �����������.\n���� ���� ���������� ���������, ����� ��������� � ����:\n/me ��������� �� ���� � ����������� ������")
				end
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_FLAG..u8(" ������ ������")); imgui.SameLine(); imgui.ToggleButton(u8'������ ������', timecout)
				imgui.SameLine()
				showHelp(u8'����� ������������ ������ ������ �� ����������� ���� � �������� ���������� � ���.')
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_CROP..u8(" ���������� ����� �� ��")); imgui.SameLine(); imgui.ToggleButton(u8'���������� ����� �� ��', timeToZp)
			end	
			if imgui.CollapsingHeader(fa.ICON_HEADER..u8' ������ ���������') then
				imgui.BeginChild('##asdasasdf', imgui.ImVec2(750, 150), false)
				imgui.Columns(2, _, false)
				if isPlayerSoldier then
					imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ����.����� � /ud")); imgui.SameLine(); imgui.ToggleButton(u8'����.����� � /ud', specUd)
					if specUd.v then
						imgui.InputText(u8'����.�����', spOtr)
					end
					imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ��������� /find")); imgui.SameLine(); imgui.ToggleButton(u8'��������� /find', rpFind)
					imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ��������� /gate")); imgui.SameLine(); imgui.ToggleButton(u8'��������� /gate', gateOn)
					imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ��������� ������ �� ��")); imgui.SameLine(); imgui.ToggleButton(u8'��������� ������ ��', rpblack)
				end
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ��������� /lock 1")); imgui.SameLine(); imgui.ToggleButton(u8'��������� /lock 1', lockCar)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ��������� ��������� ���")); imgui.SameLine(); imgui.ToggleButton(u8'��������� ��������� ���', inComingSMS)
				if inComingSMS.v then
					imgui.InputText(u8'������ ��������', phoneModel)
				end
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ��������� �������")); imgui.SameLine(); imgui.ToggleButton(u8'��������� �������', armOn)
				imgui.NextColumn()
					if isPlayerSoldier then
						imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ��������� /uninvite")); imgui.SameLine(); imgui.ToggleButton(u8'��������� /uninvite', rpuninv)
						imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ��������� ����� �����")); imgui.SameLine(); imgui.ToggleButton(u8'��������� ����� �����', rpskin)
						imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ��������� /invite")); imgui.SameLine(); imgui.ToggleButton(u8'��������� /invite', rpinv)
						imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ��������� ������ �����")); imgui.SameLine(); imgui.ToggleButton(u8'��������� ������ �����', rprang)				
						imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ��������� /uninviteoff")); imgui.SameLine(); imgui.ToggleButton(u8'��������� /uninviteoff', rpuninvoff)
					end
				imgui.EndChild()
			end
			if imgui.CollapsingHeader(fa.ICON_GIFT..u8' �����������') then
				imgui.BeginChild('##as2dasasdf', imgui.ImVec2(750, 130), false)
				imgui.Columns(2, _, false)
				
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ChatInfo")); imgui.SameLine(); imgui.ToggleButton(u8'ChatInfo', chatInfo)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" �������� ��")); imgui.SameLine(); imgui.ToggleButton(u8'�������� ��', gangzones)
				imgui.SameLine()
				showHelp(u8'����������� ���������� ���.������� �� ���� �������. ��� �������� ����� ����� �������� �� ���������, ������� ����������.')
				
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ������� ���")); imgui.SameLine(); imgui.ToggleButton(u8'������� ���', lady)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ����-������")); imgui.SameLine(); imgui.ToggleButton(u8'����-������', casinoBlock)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ������ ������")); imgui.SameLine(); imgui.ToggleButton(u8'������ ������', marker)
				--imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(' �������� ���� �� �')); imgui.SameLine(); imgui.ToggleButton(u8'�������� ���� �� �', MeNuNaX)
				imgui.NextColumn()
				-- if isPlayerSoldier then
				-- 	imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" �����������")); imgui.SameLine(); imgui.ToggleButton(u8'�����������', assistant)
				-- end
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ��� �� ������� �")); imgui.SameLine(); imgui.ToggleButton(u8'��� �� ������� T', keyT)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ���������� ����������")); imgui.SameLine(); imgui.ToggleButton(u8'���������� ����������', ads)
				imgui.SameLine()
				showHelp(u8'��� ���������� /ad �� ���� ����� ���������� � ������� SF, ������� ����������� �� ������� ~.')
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ���� ��������� ���")); imgui.SameLine(); imgui.ToggleButton(u8'���� ��������� ���', smssound)
				imgui.SameLine()
				showHelp(u8'��� ������ �������� ��� ����� ����������� ����, ������� ���������� � MoD-Helper/audio/sms.mp3. �� ������ ������� ����� ������ ����, ��� ����� �������� ��� � �������� � ������������ � "sms", ������ ����������� ������ ���� mp3.')
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" �����������")); imgui.SameLine(); imgui.ToggleButton(u8'�����������', strobesOn)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" FPSunlock")); imgui.SameLine(); imgui.ToggleButton(u8'FPSunlock', FPSunlock)
				--imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(' ����� � ����� �� "������� �����"')); imgui.SameLine(); imgui.ToggleButton(u8'����� � ����� �� "������� �����"', Zdravia)
				--imgui.SameLine()
				--showHelp(u8'���� � ����� ������������� ���-���� ������ "������� �����", �� �� ������������� ��������: "������� �����, ������� �������!"')
				--imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(' FPS unlock')); imgui.SameLine(); imgui.ToggleButton(u8'FPS unlock', Fixtune)
				--imgui.SameLine()
				--showHelp(u8'���� �� ���� ��� �������� �� �� ����������, �� ����� ��������, ��� ��������� ���� ����� ��������� ��������. ������� ���� �����, ������ ������ ������� ����������. ������� ������� ��������� �� �������� ��� ������� �����.')
				imgui.EndChild()
			end
			if imgui.CollapsingHeader(fa.ICON_GAMEPAD..u8' �������� MoD-Helper') then
				imgui.BeginChild('##25252', imgui.ImVec2(750, 130), false)
				imgui.Columns(2, _, false)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" �������� ��������")); imgui.SameLine(); imgui.ToggleButton(u8'�������� ��������', zones)
				if zones.v then
					imgui.SameLine()
					if imgui.Button(u8'�����������') then 
						sampAddChatMessage("[MoD-Helper]{FFFFFF} �������� ������� � ������� {"..u8:decode(Secondcolor.v).."}Enter{FFFFFF} ����� ��������� ��.", SCRIPTCOLOR)
						win_state['settings'].v = not win_state['settings'].v 
						win_state['main'].v = not win_state['main'].v 
						mouseCoord = true 
					end
				end
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ������ �����")); imgui.SameLine(); imgui.ToggleButton(u8'������ �����', infMask)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ����������� ������� ����")); imgui.SameLine(); imgui.ToggleButton(u8'����������� ������� ����', infZone)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ����������� �����")); imgui.SameLine(); imgui.ToggleButton(u8'����������� �����', infArmour)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ����������� ��������")); imgui.SameLine(); imgui.ToggleButton(u8'����������� ��������', infHP)
				imgui.NextColumn()
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ����������� ������")); imgui.SameLine(); imgui.ToggleButton(u8'����������� ������', infCity)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ����������� ������")); imgui.SameLine(); imgui.ToggleButton(u8'����������� ������', infRajon)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ����������� ��������")); imgui.SameLine(); imgui.ToggleButton(u8'����������� ��������', infKv)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ����������� �������")); imgui.SameLine(); imgui.ToggleButton(u8'����������� �������', infTime)
				imgui.EndChild()
			end
			if imgui.CollapsingHeader(fa.ICON_UNIVERSAL_ACCESS..u8' �����������') then
				imgui.BeginChild('##asdasasddf', imgui.ImVec2(750, 60), false)
				imgui.Columns(2, _, false)
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ���������")); imgui.SameLine(); imgui.ToggleButton(u8("���������"), autologin)
				if autologin.v then
					imgui.InputText(u8'������', autopass)
				end
				imgui.NextColumn()
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ��������")); imgui.SameLine(); imgui.ToggleButton(u8("��������"), autogoogle)
				imgui.SameLine()
				showHelp(u8"��� �������� ����-������ ������� ��� �������� ����, ������� ���������� ���������. ������� ������ ���� ��� �������� � ������ ������, ����� ���� ����������� ����� ��������� �������������.")
				if autogoogle.v then
					imgui.InputText(u8'��������� ���', googlekey)
				end
				imgui.EndChild()
			end
			if imgui.CollapsingHeader(fa.ICON_DRUPAL..u8' ��������') then
				if weather.v == -1 then weather.v = readMemory(0xC81320, 1, true) end
				if gametime.v == -1 then gametime.v = readMemory(0xB70153, 1, true) end
				imgui.SliderInt(u8"ID ������", weather, 0, 50)
				imgui.SliderInt(u8"������� ���", gametime, 0, 23)
			end
			if imgui.CollapsingHeader(fa.ICON_PAW..u8' ������ ���������') then
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_PAW..u8(" ���������� ����")); imgui.SameLine(); imgui.ToggleButton(u8("���������� ����"), enableskin)
				if enableskin.v then
					imgui.InputInt("##229", localskin, 0, 0)
					imgui.SameLine()
					if imgui.Button(u8("���������")) then
						if localskin.v <= 0 or localskin.v == 74 or localskin.v == 53 then
							localskin.v = 1
						end
						changeSkin(-1, localskin.v)
					end
				end
				imgui.InputText(fa.ICON_PAW..u8' ������ ��� ������', blackcheckerpath)
				imgui.SliderInt(fa.ICON_PAW..u8" ��������� �������", timefix, 0, 5)
			end
			

			if state and isPlayerSoldier then
				if imgui.Button(fa.ICON_ELLIPSIS_H..u8' ����������� ���������', btn_size) then 
					sampAddChatMessage("[MoD-Helper]{FFFFFF} �������� ������� � ������� {"..u8:decode(Secondcolor.v).."}Enter{FFFFFF} ����� ��������� ��.", SCRIPTCOLOR)
					win_state['settings'].v = not win_state['settings'].v 
					win_state['main'].v = not win_state['main'].v 
					mouseCoord2 = true 
				end
			end
		elseif showSet == 3 then -- ��������� ������
			imgui.Columns(2, _, false)
			for k, v in ipairs(tBindList) do
				--[[if isPlayerSoldier then -- ������� ������� ��� ��������
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
				else]]-- -- ������� ������� ��� ������� ��������
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
		elseif showSet == 4 then -- ��������� VK Int.
			if token ~= 1 and vkid2 ~= nil then
				imgui.Columns(2, _, false)
				imgui.Text(u8("��� ID ��: "..tostring((vkid2 == nil and 'N/A' or vkid2))))
				imgui.Text(u8("������ ���: "))
				imgui.SameLine()
				if workpause then
					imgui.TextColored(imgui.ImVec4(0.12, 0.70 , 0.38, 1.0), u8"�������")
				else
					imgui.TextColored(imgui.ImVec4(0.60, 0.14 , 0.14, 1.0), u8"���������.")
				end
				imgui.SameLine()
				showHelp(u8("����� ���, ��� ����������� ����, ���� �� ������, ����� ������ ������� ��������� - ��� ���������� ������������ ������ ��� �������� VK int, ������� �� ��������� � ����������. ���� �� ������ � ���, �� �� ����������� ������ - ������ �������� ��� �������� ������ ����� ������ �� ���, ������� ��� � ���, ��� ������ �� ����� �������� � ��� ������ ��� ��������� ������� '������'. � ������, ���� ������� ������ ����� - ��� �� ���� ������������."))
				imgui.Text(u8("������� �� ����� ��������, ���� VK Int � ������� - '���������'."))	
				imgui.NewLine()
				imgui.TextWrapped(u8("�� ��������� �������� ����� ���������� ����� ���������� ������������ �������, ��� �� �����, VK Int �� ���� �������� ������������ �������, ���:"))
				imgui.Text(u8("- ���������� � �� ����������� ����������."))
				imgui.TextWrapped(u8("- ������ ���� ����� ���� ����������� � �������� � �������� ����������."))
				imgui.TextWrapped(u8("- ��������� ����� ��������� ������ ���, ��� �� ����� ��������� ����������."))
					
				imgui.NextColumn()
				imgui.AlignTextToFramePadding(); imgui.Text(u8("��������� ����� ��")); imgui.SameLine(); imgui.ToggleButton(u8'��������� ����� ��', zp)
				imgui.SameLine()
				showHelp(u8("��������� ���������� � �� ����� �� �� 10, 5, 1 ������, 30 ������ �� ��������."))
				imgui.AlignTextToFramePadding(); imgui.Text(u8("������ ������ ����")); imgui.SameLine(); imgui.ToggleButton(u8'������ ������ ����', nickdetect)
				imgui.SameLine()
				showHelp(u8("���� � ���� �������� ��� ��� � ������� Nick_Name - ������ ���������� � ������, � ������� ��� ����������."))
				imgui.AlignTextToFramePadding(); imgui.Text(u8("�������� ���������� �� SMS")); imgui.SameLine(); imgui.ToggleButton(u8'�������� ���������� �� SMS', smsinfo)
				imgui.SameLine()
				showHelp(u8("���� ��� ������ ��� ��� �� ��� ��������� - ��� ������� �� ���� � ��. �������, ���� ����������� ��� �� �������."))
				imgui.AlignTextToFramePadding(); imgui.Text(u8("�������� ��������� �� /r, /f")); imgui.SameLine(); imgui.ToggleButton(u8'�������� ��������� �� /r, /f', getradio)
				imgui.SameLine()
				showHelp(u8("���������� ��� ��������� �� �����, ���� �������� ������ �����."))
				imgui.AlignTextToFramePadding(); imgui.Text(u8("�������� ��������� �� /g")); imgui.SameLine(); imgui.ToggleButton(u8'�������� ��������� �� /g', familychat)
				imgui.SameLine()
				showHelp(u8("���������� ��� ��������� �� ���� �����/������."))
				imgui.AlignTextToFramePadding(); imgui.Text(u8("��������� �����")); imgui.SameLine(); imgui.ToggleButton(u8'��������� �����', remotev)
				imgui.SameLine()
				showHelp(u8("��������� ���������� ������� /f(n), /r(n), /sms �� ������� ������� � ����������� � ��, ������� �������� � ��������."))
			else
				imgui.Text(u8("� ���������, ������� VK Int. �������� ����������. ���������� ������������� ������ ��� ����������� �����."))
			end
		elseif showSet == 5 then -- ���� �������
			imgui.Columns(4, _, false)
			imgui.NextColumn()
			imgui.NextColumn()
			imgui.NextColumn()
			for k, v in ipairs(mass_bind) do -- ������� ��� �����
				imgui.NextColumn()
				if hk.HotKey("##ID" .. k, v, tLastKeys, 100) then -- ������� ������, ���� ����� ������, ����� ��������� �������
					if not rkeys.isHotKeyDefined(v.v) then
						if rkeys.isHotKeyDefined(tLastKeys.v) then
							rkeys.unRegisterHotKey(tLastKeys.v)
						end
					end
					rkeys.registerHotKey(v.v, true, onHotKey)
					saveSettings(3, "KEY") -- ��������� ���������
				end
				imgui.NextColumn()
				if v.cmd ~= "-" then -- ������� ������ ������
					imgui.Text(u8("�������: /"..v.cmd))
				else
					imgui.Text(u8("������� �� ���������"))
				end
				imgui.NextColumn()
				if imgui.Button(fa.ICON_CC..u8(" ������������� ���� ##"..k)) then imgui.OpenPopup(u8"��������� ������� ##modal"..k) end
				if k ~= 0 then
					imgui.NextColumn()
					if imgui.Button(fa.ICON_SLIDESHARE..u8(" ������� ���� ##"..k)) then
						if v.cmd ~= "-" then sampUnregisterChatCommand(v.cmd) print("����������������� ������� /"..v.cmd) end
						if rkeys.isHotKeyDefined(tLastKeys.v) then rkeys.unRegisterHotKey(tLastKeys.v) end
						table.remove(mass_bind, k)
						saveSettings(3, "DROP BIND")
					end
				end
				
				if imgui.BeginPopupModal(u8"��������� ������� ##modal"..k, _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
					if imgui.Button(fa.ICON_ODNOKLASSNIKI..u8(' �������/��������� �������'), imgui.ImVec2(200, 0)) then
						imgui.OpenPopup(u8"������� - /"..v.cmd)
					end
					if imgui.Button(fa.ICON_REBEL..u8(' ������������� ����������'), imgui.ImVec2(200, 0)) then
						cmd_text.v = u8(v.text):gsub("~", "\n")
						binddelay.v = v.delay
						imgui.OpenPopup(u8'�������� ������ ##second'..k)
					end

					if imgui.BeginPopupModal(u8"������� - /"..v.cmd, _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize) then
						imgui.Text(u8"������� �������� �������, ������� ������ ��������� � �����, ���������� ��� '/':")						
						imgui.Text(u8"����� ������� ��������, ������� ������� � ���������.")						
						imgui.InputText("##FUCKITTIKCUF_1", cmd_name)

						if imgui.Button(fa.ICON_SIGN_LANGUAGE..u8" ���������", imgui.ImVec2(100, 0)) then
							v.cmd = u8:decode(cmd_name.v)

							if u8:decode(cmd_name.v) ~= "-" then
								rcmd(v.cmd, v.text, v.delay)
								print("���������������� ������� /"..v.cmd)
								cmd_name.v = ""
							end
							saveSettings(3, "CMD "..v.cmd)
							imgui.CloseCurrentPopup()
						end
						imgui.SameLine()
						if imgui.Button(fa.ICON_SLACK..u8" �������") then
							cmd_name.v = ""
							imgui.CloseCurrentPopup()
						end
						imgui.EndPopup()
					end

					if imgui.BeginPopupModal(u8'�������� ������ ##second'..k, _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize) then
						imgui.BeginChild('##sdaadasdd', imgui.ImVec2(1100, 600), true)
						imgui.Columns(2, _, false)
						--[[imgui.InputInt(u8("�������� �����(���.)"), binddelay)
						if binddelay.v <= 0 then
							binddelay.v = 1
						elseif binddelay.v >= 1801 then
							binddelay.v = 1800
						end
						imgui.SameLine()
						showHelp(u8("600 ������ - 10 �����\n1200 ������ - 20 �����\n1800 ������ - 30 �����"))]]--
						imgui.TextWrapped(u8("�������� {bwait:time} ���������� ����� ������ ������. �������� ������������� �� ������������."))
						imgui.TextWrapped(u8"�������� ������ �������(��������� ������� �� �������� ��� ������ ��������):")
						imgui.InputTextMultiline('##FUCKITTIKCUF_2', cmd_text, imgui.ImVec2(550, 300))
						
						imgui.Text(u8("���������:"))
						local example = tags(u8:decode(cmd_text.v))
						imgui.Text(u8(example))
						imgui.NextColumn()
						imgui.BeginChild('##sdaadddasdd', imgui.ImVec2(525, 480), true)
						imgui.TextColoredRGB('� {bwait:1500} {21BDBF}- �������� ����� ����� - {fff555}������������ ��������')
						imgui.Separator()
						
						imgui.TextColoredRGB('� {params} {21BDBF}- �������� ������� - {fff555}/'..v.cmd..' [��������]')
						imgui.TextColoredRGB('� {paramNickByID} {21BDBF}- �������� ��������, �������� ��� �� ID.')
						imgui.TextColoredRGB('� {paramFullNameByID} {21BDBF}- �������� ��������, �������� �� ��� �� ID.')
						imgui.TextColoredRGB('� {paramNameByID} {21BDBF}- �������� ��������, �������� ��� �� ID.')
						imgui.TextColoredRGB('� {paramSurnameByID} {21BDBF}- �������� ��������, �������� ������� �� ID.')

						if imgui.CollapsingHeader(u8'��� ���� ����������') then
							imgui.TextColoredRGB('� {fff555}/'..v.cmd..' [�������� 1 | �������� 2] ("|" - �����������)')
							imgui.Separator()
							imgui.TextColoredRGB('� {par1} {21BDBF}- ������ �������� �������.')
							imgui.TextColoredRGB('� {NickByIDpar1} {21BDBF}- ������ �������� ��������, �������� ��� �� ID.')
							imgui.TextColoredRGB('� {FullNameByIDpar1} {21BDBF}- ������ �������� ��������, �������� �� ��� �� ID.')
							imgui.TextColoredRGB('� {NameByIDpar1} {21BDBF}- ������ �������� ��������, �������� ��� �� ID.')
							imgui.TextColoredRGB('� {SurnameByIDpar1} {21BDBF}- ������ �������� ��������, �������� ������� �� ID.')
							imgui.Separator()
							imgui.TextColoredRGB('� {par2} {21BDBF}- ������ �������� �������.')
							imgui.TextColoredRGB('� {NickByIDpar2} {21BDBF}- ������ �������� ��������, �������� ��� �� ID.')
							imgui.TextColoredRGB('� {FullNameByIDpar2} {21BDBF}- ������ �������� ��������, �������� �� ��� �� ID.')
							imgui.TextColoredRGB('� {NameByIDpar2} {21BDBF}- ������ �������� ��������, �������� ��� �� ID.')
							imgui.TextColoredRGB('� {SurnameByIDpar2} {21BDBF}- ������ �������� ��������, �������� ������� �� ID.')
						end

						imgui.Separator()
						imgui.TextColoredRGB('� {mynick} {21BDBF}- ��� ������ ��� - {fff555}'..tostring(userNick))
						imgui.TextColoredRGB('� {myfname} {21BDBF}- ��� �� ��� - {fff555}'..tostring(nickName))
						imgui.TextColoredRGB('� {myname} {21BDBF}- ���� ��� - {fff555}'..tostring(userNick:gsub("_.*", "")))
						imgui.TextColoredRGB('� {mysurname} {21BDBF}- ���� ������� - {fff555}'..tostring(userNick:gsub(".*_", "")))
						imgui.TextColoredRGB('� {myid} {21BDBF}- ��� ID - {fff555}'..tostring(myID))
						imgui.TextColoredRGB('� {myhp} {21BDBF}- ��� ������� HP - {fff555}'..tostring(healNew))
						imgui.TextColoredRGB('� {myarm} {21BDBF}- ��� ������� ����� - {fff555}'..tostring(armourNew))
						imgui.Separator()
						imgui.TextColoredRGB('� {arm} {21BDBF}- ���� ����� - {fff555}'..tostring(fraction))
						imgui.TextColoredRGB('� {org} {21BDBF}- ���� ����������� - {fff555}'..tostring(org))
						imgui.TextColoredRGB('� {mtag} {21BDBF}- ��� ����������� - {fff555}'..tostring(mtag))
						imgui.TextColoredRGB('� {rtag} {21BDBF}- ��� ��� � /r - {fff555}'..tostring(u8:decode(rtag.v)))
						imgui.TextColoredRGB('� {ftag} {21BDBF}- ��� ��� � /f - {fff555}'..tostring(u8:decode(ftag.v)))
						imgui.TextColoredRGB('� {myrang} {21BDBF}- ���� ��������� - {fff555}'..tostring(rang))
						imgui.TextColoredRGB('� {steam} {21BDBF}- ��� ����.�����(������ ���� �������� � ����������) - {fff555}'..tostring(u8:decode(spOtr.v)))
						imgui.Separator()
						imgui.TextColoredRGB('� {city} {21BDBF}- �����, � ������� ���������� - {fff555}'..tostring(playerCity))
						imgui.TextColoredRGB('� {base} {21BDBF}- ����������� ������� ���� - {fff555}'..tostring(ZoneText))
						imgui.TextColoredRGB('� {kvadrat} {21BDBF}- ����������� �������� - {fff555}'..tostring(locationPos()))
						imgui.TextColoredRGB('� {zone} {21BDBF}- ����������� ������ - {fff555}'..tostring(ZoneInGame))
						imgui.TextColoredRGB('� {time} {21BDBF}- ��� ����� - {fff555}'..string.format(os.date('%H:%M:%S', moscow_time)))
						imgui.Separator()
						if newmark ~= nil then
							imgui.TextColoredRGB('� {targetnick} {21BDBF}- ������ ��� ������ �� ������� - {fff555}'..tostring(sampGetPlayerNickname(blipID)))
							imgui.TextColoredRGB('� {targetfname} {21BDBF}- �� ��� ������ �� ������� - {fff555}'..tostring(sampGetPlayerNickname(blipID):gsub("_", " ")))
							imgui.TextColoredRGB('� {tID} {21BDBF}- ID ������ �� ������� - {fff555}'..tostring(blipID))
							imgui.TextColoredRGB('� {targetname} {21BDBF}- ��� ������ �� ������� - {fff555}'..tostring(sampGetPlayerNickname(blipID):gsub("_.*", "")))
							imgui.TextColoredRGB('� {targetsurname} {21BDBF}- ������� ������ �� ������� - {fff555}'..tostring(sampGetPlayerNickname(blipID):gsub(".*_", "")))
						else
							imgui.TextColoredRGB('� {targetnick} {21BDBF}- ������ ��� ������ �� �������')
							imgui.TextColoredRGB('� {targetfname} {21BDBF}- �� ��� ������ �� �������')
							imgui.TextColoredRGB('� {tID} {21BDBF}- ID ������ �� �������')
							imgui.TextColoredRGB('� {targetname} {21BDBF}- ��� ������ �� �������')
							imgui.TextColoredRGB('� {targetsurname} {21BDBF}- ������� ������ �� �������')
						end
						imgui.Separator()
						imgui.TextColoredRGB('� {fid} {21BDBF}- ��������� ID �� /f ����  - {fff555}'..tostring(lastfradioID))
						imgui.TextColoredRGB('� {fidrang} {21BDBF}- ������ ���������� � /f - {fff555}'..tostring(lastfradiozv))
						imgui.TextColoredRGB('� {fidnick} {21BDBF}- ��� ���������� � /f - {fff555}'..tostring(sampGetPlayerNickname(lastfradioID)))
						imgui.TextColoredRGB('� {finfname} {21BDBF}- �� ��� ���������� � /f - {fff555}'..tostring(sampGetPlayerNickname(lastfradioID):gsub("_", " ")))
						imgui.TextColoredRGB('� {fidname} {21BDBF}- ��� ���������� � /f - {fff555}'..tostring(sampGetPlayerNickname(lastfradioID):gsub("_.*", " ")))
						imgui.TextColoredRGB('� {fidsurname} {21BDBF}- ������� ���������� � /f - {fff555}'..tostring(sampGetPlayerNickname(lastfradioID):gsub(".*_", " ")))
						imgui.Separator()
						imgui.TextColoredRGB('� {rid} {21BDBF}- ��������� ID �� /r ���� - {fff555}'..tostring(lastrradioID))
						imgui.TextColoredRGB('� {ridrang} {21BDBF}- ������ ���������� � /r - {fff555}'..tostring(lastrradiozv))
						imgui.TextColoredRGB('� {ridnick} {21BDBF}- ��� ���������� � /r - {fff555}'..tostring(sampGetPlayerNickname(lastrradioID)))
						imgui.TextColoredRGB('� {ridfname} {21BDBF}- �� ��� ���������� � /r - {fff555}'..tostring(sampGetPlayerNickname(lastrradioID):gsub("_", " ")))
						imgui.TextColoredRGB('� {ridname} {21BDBF}- ��� ���������� � /r - {fff555}'..tostring(sampGetPlayerNickname(lastrradioID):gsub("_.*", " ")))
						imgui.TextColoredRGB('� {ridsurname} {21BDBF}- ������� ���������� � /r - {fff555}'..tostring(sampGetPlayerNickname(lastrradioID):gsub(".*_", " ")))

						
						imgui.EndChild()
						imgui.NewLine()
						if imgui.Button(fa.ICON_SIGN_LANGUAGE..u8" ���������", btn_size) then

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

						if imgui.Button(fa.ICON_SLACK..u8" ������� �� ��������", btn_size) then
							imgui.CloseCurrentPopup()
						end
						imgui.EndChild()
						imgui.EndPopup()
					end

					if imgui.Button(fa.ICON_SLACK..u8" �������", imgui.ImVec2(200, 0)) then
						imgui.CloseCurrentPopup()
					end
					imgui.EndPopup()
				end
			end
			
			imgui.NextColumn()
			imgui.NewLine()
			if imgui.Button(fa.ICON_WHEELCHAIR..u8(" �������� ����")) then mass_bind[#mass_bind + 1] = {delay = "3", v = {}, text = "n/a", cmd = "-"} end	
		elseif showSet == 7 then			
				imgui.SetCursorPosX(300)
				imgui.Text(u8"��������� ��� ����� (by DIPIRIDAMOLE).")
				imgui.Separator()
				imgui.AlignTextToFramePadding(); imgui.Text(fa.ICON_APPLE..u8(" ����� ����� ����� � ����")); imgui.SameLine(); imgui.ToggleButton(u8("����� ����� ����� � ����"), ColorFama)
				imgui.PushItemWidth(200)	
				if imgui.ColorEdit3("", colorf) then
					colornikifama = tostring(('%06X'):format((join_argb(0, colorf.v[1] * 255, colorf.v[2] * 255, colorf.v[3] * 255))))
					R = colorf.v[1]
					G = colorf.v[2]
					B = colorf.v[3]
				end
				imgui.SameLine()
				imgui.Text(u8"������� �� ������ � �������� ����.")
				imgui.Separator()
				imgui.SetCursorPosX(260)
				imgui.Text(u8"������� ����, ������� ������ �������� � ����.")
				imgui.Separator()
				imgui.Columns(2, _, false)
				imgui.PushItemWidth(200)
				imgui.InputText(fa.ICON_USER_CIRCLE..u8' ��� 1', nikifama1)
				imgui.InputText(fa.ICON_USER_CIRCLE..u8' ��� 2', nikifama2)
				imgui.InputText(fa.ICON_USER_CIRCLE..u8' ��� 3', nikifama3)
				imgui.InputText(fa.ICON_USER_CIRCLE..u8' ��� 4', nikifama4)
				imgui.InputText(fa.ICON_USER_CIRCLE..u8' ��� 5', nikifama5)
				imgui.NextColumn()
				imgui.PushItemWidth(200)
				imgui.InputText(fa.ICON_USER_CIRCLE..u8' ��� 6', nikifama6)
				imgui.InputText(fa.ICON_USER_CIRCLE..u8' ��� 7', nikifama7)
				imgui.InputText(fa.ICON_USER_CIRCLE..u8' ��� 8', nikifama8)
				imgui.InputText(fa.ICON_USER_CIRCLE..u8' ��� 9', nikifama9)
				imgui.InputText(fa.ICON_USER_CIRCLE..u8' ��� 10', nikifama10)
				
				--[[for i, v in ipairs(mass_niki) do
					--mass_niki[#mass_niki] = imgui.ImBuffer(256)				
					imgui.PushItemWidth(400)
					imgui.InputText(fa.ICON_USER_CIRCLE..u8' ��� '..i, mass_niki[i])
					imgui.SameLine()
					if imgui.Button(fa.ICON_SLIDESHARE..u8(" ������� ��� ##"..i)) then
						table.remove(mass_niki, i)
						saveSettings(3, "DROP NICK")
					end

				end
				imgui.Columns(1, _, false)
				if imgui.Button(fa.ICON_WHEELCHAIR..u8(" �������� ���")) then 
					mass_niki[#mass_niki + 1] = { '' } 
				end]]
		elseif showSet == 8 then
			if imgui.Button(u8("�����������"), btn_size) then 
				Theme = 1
				apply_custom_style()
			end
			if imgui.Button(u8("���������"), btn_size) then 
				Theme = 2
				apply_custom_style()
			end
			if imgui.Button(u8("�����-���������"), btn_size) then 
				Theme = 3
				apply_custom_style()
			end	
			if imgui.Button(u8("����������"), btn_size) then 
				Theme = 4
				apply_custom_style()
			end	
			if imgui.Button(u8("�����"), btn_size) then 
				Theme = 5
				apply_custom_style()
			end	
			if imgui.Button(u8("����-�������"), btn_size) then 
				Theme = 6
				apply_custom_style()
			end
			if imgui.Button(u8("�����-�����"), btn_size) then 
				Theme = 7
				apply_custom_style()
			end
			if imgui.Button(u8("�����-�������"), btn_size) then 
				Theme = 8
				apply_custom_style()
			end
			if imgui.Button(u8("��������"), btn_size) then 
				Theme = 9
				apply_custom_style()
			end

		end

		imgui.End()
	end

	if win_state['leaders'].v then -- ���� ��� �������
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(900, 430), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'�������', win_state['leaders'], imgui.WindowFlags.NoResize)

			imgui.Columns(2, _, false)
			imgui.SetColumnWidth(-1, 640)
			imgui.Text(u8'����� �����:')
			imgui.PushItemWidth(530)
			imgui.InputText(u8'##gsk1', gos1)
			imgui.InputText(u8'##gsk2', gos2)
			imgui.InputText(u8'##gsk3', gos3)
			imgui.SameLine()
			if imgui.Button(u8'���������') then
				if #gos1.v == 0 or #gos2.v == 0 or #gos3.v == 0 then
					sampAddChatMessage("[MoD-Helper]{FFFFFF} ������� ���� ���� ������, ��������� ��� ����.", SCRIPTCOLOR)
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
						sampAddChatMessage("[MoD-Helper]{FFFFFF} ���������� ��������� ��������� ������ ���.�������.", SCRIPTCOLOR)
					end
				end
			end
			imgui.Text(u8'��������� �����:')
			imgui.InputText(u8'##gsk4', gos4)
			imgui.SameLine()
			if imgui.Button(u8'���p�����') then
				if #gos4.v == 00 then 
					sampAddChatMessage("[MoD-Helper]{FFFFFF} ���� ������, ������ ������ ������ ����������.", SCRIPTCOLOR)
				else
					if gosButton then
						gosButton = false
						lua_thread.create(function()
							sampSendChat("/gnews "..u8:decode(gnewstag.v).." "..u8:decode(gos4.v))
							wait(5000)
							gosButton = true
						end)
					else
						sampAddChatMessage("[MoD-Helper]{FFFFFF} ���������� ��������� ��������� ������ ���.�������.", SCRIPTCOLOR)
					end
				end
			end
			imgui.Text(u8'���������:')
			imgui.InputText(u8'##gsk5', gos5)
			imgui.SameLine()
			if imgui.Button(u8'���������') then
				if #gos5.v == 0 then
					sampAddChatMessage("[MoD-Helper]{FFFFFF} ���� ������, ������ ������ ������ ����������.", SCRIPTCOLOR)
				else
					if gosButton then
						gosButton = false
						lua_thread.create(function()
							sampSendChat("/gnews "..u8:decode(gnewstag.v).." "..u8:decode(gos5.v))
							wait(5000)
							gosButton = true
						end)
					else
						sampAddChatMessage("[MoD-Helper]{FFFFFF} ���������� ��������� ��������� ������ ���.�������.", SCRIPTCOLOR)
					end
				end
			end
			imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"����� �� ���: ")
			imgui.SameLine()
			imgui.Text(u8(string.format(os.date('%H:%M:%S', moscow_time))))
			imgui.NextColumn()
			if imgui.CollapsingHeader(u8'�������������') then
				if imgui.Button(u8"��") then
					gos1.v = u8("������ ������� ������������� � ������������� ����������.")
					gos2.v = u8("������������� ����� �������� � ������ �������������.")
					gos3.v = u8("��������: 5 ��� � �����, ����� ��������, ���� ���������������.")
					gos4.v = u8("���������, �������� ������������� � ������������� ����������.")
					gos5.v = u8("������������� � ������������� ���������� ��������.")
				end
				imgui.SameLine()
				if imgui.Button(u8"����� ��") then
					gos1.v = u8("��������� ������ �����, ��������� ��������.")
					gos2.v = u8("������ ������ ������������� � ����� �.���-������.")
					gos3.v = u8("����������: 5 ��� � �����, �������� � �������� Desert Eagle.")
					gos4.v = u8("������������� � ����� �.���-������ ������������.")
					gos5.v = u8("������������� � ����� �.���-������ ��������.")
				end
				imgui.SameLine()
				if imgui.Button(u8"����� ��") then
					gos1.v = u8("��������� ������ �����, ��������� ��������.")
					gos2.v = u8("������ ������ ������������� � ����� �.���-������.")
					gos3.v = u8("����������: 5 ��� � �����, �������� � �������� Desert Eagle.")
					gos4.v = u8("������������� � ����� �.���-������ ������������.")
					gos5.v = u8("������������� � ����� �.���-������ ��������.")
				end
				imgui.SameLine()
				if imgui.Button(u8"����� ��") then
					gos1.v = u8("��������� ������ �����, ��������� ��������.")
					gos2.v = u8("������ ������ ������������� � ����� �.���-��������.")
					gos3.v = u8("����������: 5 ��� � �����, �������� � �������� Desert Eagle.")
					gos4.v = u8("������������� � ����� �.���-�������� ������������.")
					gos5.v = u8("������������� � ����� �.���-�������� ��������.")
				end
			end
			if imgui.CollapsingHeader(u8'������������ ���������� ���') then
				if imgui.Button(u8"����") then
					gos1.v = u8("������ ������� ������������� � ������� �.���-������.")
					gos2.v = u8("������������� ������� � ������ ������������.")
					gos3.v = u8("��������: 4 ���� � �����, ����� ��������, ���� ���������������.")
					gos4.v = u8("���������, �������� ������������� � ������� �.���-������.")
					gos5.v = u8("������������� � ������� �.���-������ ��������.")
				end
				imgui.SameLine()
				if imgui.Button(u8"����") then
					gos1.v = u8("������ ������� ������������� � ������� �.���-������.")
					gos2.v = u8("������������� ������� � ������ ������������.")
					gos3.v = u8("��������: 4 ���� � �����, ����� ��������, ���� ���������������.")
					gos4.v = u8("���������, �������� ������������� � ������� �.���-������.")
					gos5.v = u8("������������� � ������� �.���-������ ��������.")
				end
				imgui.SameLine()
				if imgui.Button(u8"����") then
					gos1.v = u8("������ ������� ������������� � ������� �.���-��������.")
					gos2.v = u8("������������� ������� � ������ ������������.")
					gos3.v = u8("��������: 4 ���� � �����, ����� ��������, ���� ���������������.")
					gos4.v = u8("���������, �������� ������������� � ������� �.���-��������.")
					gos5.v = u8("������������� � ������� �.���-�������� ��������.")
				end
			end		
			if imgui.CollapsingHeader(u8'������������ �������') then
				if imgui.Button(u8"��") then
					gos1.v = u8("������ ������� ������ � ���������� ������.")
					gos2.v = u8("������ ����� ��������� � ���������� �.���-��������.")
					gos3.v = u8("��������: 3 ���� � �����, ����� ��������, ���� ���������������.")
					gos4.v = u8("���������, �������� ������ � ���������� ������.")
					gos5.v = u8("������ ���������� � ����� ���������� ����� ��������.")
				end
				imgui.SameLine()
				if imgui.Button(u8"���") then
					gos1.v = u8("������ ������� ������ � ������-��������� ����.")
					gos2.v = u8("������ ����� ��������� � ���������� �.���-��������.")
					gos3.v = u8("��������: 3 ���� � �����, ����� ��������, ���� ���������������.")
					gos4.v = u8("���������, �������� ������ � ������-��������� ����.")
					gos5.v = u8("������ ���������� � ����� ������-��������� ��� ��������.")
				end
				imgui.SameLine()
				if imgui.Button(u8"���") then
					gos1.v = u8("������ ������� ������ � ������-������� ����.")
					gos2.v = u8("������ ����� ��������� � ���������� �.���-��������.")
					gos3.v = u8("��������: 3 ���� � �����, ����� ��������, ���� ���������������.")
					gos4.v = u8("���������, �������� ������ � ������-������� ����.")
					gos5.v = u8("������ ���������� � ����� ������-�������� ����� ��������.")
				end
				imgui.SameLine()
				if imgui.Button(u8"���.���") then
					gos1.v = u8("��������� ������ �����, ����� ������� ��� ��������� ��������!")
					gos2.v = u8("� 21:00 �� 09:00 �� ���� ������� ����������� ������ ������������� ���.")
					gos3.v = u8("������� ����� ����� ������� ����� �� ��������� � ������ �������������.")
					gos4.v = ''
					gos5.v = ''
				end
			end		
			if imgui.CollapsingHeader(u8'������������ ���������������') then
				if imgui.Button(u8"������ ��") then
					gos1.v = u8("��������� ������ �����, ��������� ��������.")
					gos2.v = u8("������ ������� ������������� � �������� �.���-������.")
					gos3.v = u8("����������: 3 ���� � �����, �����������������. ��� ���.")
					gos4.v = u8("���������, �������� ������������� � �������� �.���-������.")
					gos5.v = u8("������������� � �������� �.���-������ ���������.")
				end
				imgui.SameLine()
				if imgui.Button(u8"������ ��") then
					gos1.v = u8("��������� ������ �����, ��������� ��������.")
					gos2.v = u8("������ ������� ������������� � �������� �.���-������.")
					gos3.v = u8("����������: 3 ���� � �����, �����������������. ��� ���.")
					gos4.v = u8("���������, �������� ������������� � �������� �.���-������.")
					gos5.v = u8("������������� � �������� �.���-������ ���������.")
				end
				imgui.SameLine()			
				if imgui.Button(u8"������ ��") then
					gos1.v = u8("��������� ������ �����, ��������� ��������.")
					gos2.v = u8("������ ������� ������������� � �������� �.���-��������.")
					gos3.v = u8("����������: 3 ���� � �����, �����������������. ��� ���.")
					gos4.v = u8("���������, �������� ������������� � �������� �.���-��������.")
					gos5.v = u8("������������� � �������� �.���-�������� ���������.")
				end
			end
			if imgui.CollapsingHeader(u8'�������� �������� ����������') then
				if imgui.Button(u8"����") then
					gos1.v = u8("��������� ������ �����, ������ ��������.")
					gos2.v = u8("� ����������� �.���-������ �������� �������������!")
					gos3.v = u8("����������: 4 ���� � �����, �����������������.")
					gos4.v = u8("���������, �������� ������������� � ���������� �.���-������.")
					gos5.v = u8("������������� � ���������� �.���-������ ���������.")
				end
				imgui.SameLine()
				if imgui.Button(u8"����") then
					gos1.v = u8("��������� ������ �����, ������ ��������.")
					gos2.v = u8("� ����������� �.���-������ �������� �������������!")
					gos3.v = u8("����������: 4 ���� � �����, �����������������.")
					gos4.v = u8("���������, �������� ������������� � ���������� �.���-������.")
					gos5.v = u8("������������� � ���������� �.���-������ ���������.")
				end
				imgui.SameLine()
				if imgui.Button(u8"����") then
					gos1.v = u8("��������� ������ �����, ������ ��������.")
					gos2.v = u8("� ����������� �.���-�������� �������� �������������!")
					gos3.v = u8("����������: 4 ���� � �����, �����������������.")
					gos4.v = u8("���������, �������� ������������� � ���������� �.���-��������.")
					gos5.v = u8("������������� � ���������� �.���-�������� ���������.")
				end
				imgui.SameLine()
				if imgui.Button(u8"��-�") then
					gos1.v = u8("��������� ������ �����, ������ ��������.")
					gos2.v = u8("������ � ��������� ����� ������� �������������!")
					gos3.v = u8("����������: 4 ���� � �����, ���� ���������������.")
					gos4.v = u8("���������, ��� ������ �������� ������������� � ���������.")
					gos5.v = u8("������������� � ��������� ����� ��������.")
				end
			end
			--imgui.NewLine()
			if imgui.Button(u8'�������� ������') then
				gos1.v = ''
				gos2.v = ''
				gos3.v = ''
				gos4.v = ''
				gos5.v = ''
			end
			--imgui.NewLine()
			imgui.PushItemWidth(60.0)
			imgui.InputText(u8'��� /gnews', gnewstag)
			imgui.PopItemWidth()
			imgui.SameLine()
			if imgui.Button(u8("���������##228")) then saveSettings(4) end
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

	if win_state['help'].v then -- ���� "������"
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(970, 400), imgui.Cond.FirstUseEver)
		imgui.Begin(u8('������'), win_state['help'], imgui.WindowFlags.NoResize)
		imgui.BeginGroup()
		imgui.BeginChild('left pane', imgui.ImVec2(180, 350), true)
		
		if imgui.Selectable(u8"������� �������") then selected2 = 1 end
		imgui.Separator()
		if imgui.Selectable(u8"����� ��") then selected2 = 2 end
		imgui.Separator()
		if imgui.Selectable(u8"���������") then selected2 = 3 end
		imgui.Separator()
		if imgui.Selectable(u8"������") then selected2 = 4 end
		imgui.Separator()		
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild('##ddddd', imgui.ImVec2(745, 350), true)
		if selected2 == 0 then
			selected2 = 1
		elseif selected2 == 1 then
			imgui.Text(u8"������� �������")
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
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/rd [����] [���������]")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/fd [����] [���������]")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/reload")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/where [ID]")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/hist [ID]")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/��")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/drone")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/ok [ID]")
				imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/rm")
				if isPlayerSoldier then
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/ud [ID]")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/uninv [ID] [ID �������] [�������]")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/livr [ID] [�������]")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/livf [ID] [�������]")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/raport [ID] [�������]")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/upd")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/tir [��]")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/vig [id] [�������]")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/nr [id] [�������]")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/ffind")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"��� + 1")
					imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"��� + R")
				end
			imgui.NextColumn()
				if isPlayerSoldier then
					imgui.Text(u8"������ �������� ������ �� �� ��(�� ���� + ������� �����).")
					imgui.Text(u8"�������� ������ �� �� �� �� ��� �������� ����� ������� ����� (�� �������� �� Red �������).")
					imgui.Text(u8"���������� ������� ������ � ������.")
				end
				imgui.Text(u8"�������� ��� ��������� � ����� ����������.")
				imgui.Text(u8"�������� ��� ��������� � ����� ����� �������.")
				imgui.Text(u8"������� ������ � ����� � ����� �������.")
				imgui.Text(u8"������� ������ � ����� � ����� �����.")
				imgui.Text(u8"������������ �������.")
				imgui.Text(u8"��������� �������������� ������ � ����� �� ��� ID.")
				imgui.Text(u8"��������� ������� ����� �� ID.")
				imgui.Text(u8"������� ����.")
				imgui.Text(u8"�������� �������� � ����� �� ����������.")
				imgui.Text(u8"������� ������ ������.")
				imgui.Text(u8"������� ����� � ������.")
				if isPlayerSoldier then
					imgui.Text(u8"�������� ������������� ��������.")
					imgui.Text(u8"������� ����� �� ������� �������.")
					imgui.Text(u8"��������� ���������� ����� � /r.")
					imgui.Text(u8"��������� ���������� ����� � /f.")
					imgui.Text(u8"������ ����������� special for Red.")
					imgui.Text(u8"�������� ������ � ������� MoD-Helper(���, �������).")
					imgui.Text(u8"������������ �������. �������� � ������������.")
					imgui.Text(u8"������ �������� � /r. �������� � 5 �����.")
					imgui.Text(u8"������ ������ � /r. �������� � 5 �����.")
					imgui.Text(u8"����������� ��������� �������.")
					imgui.Text(u8"������ ����� ������.")
					imgui.Text(u8"���� ��������������.")
				end
		elseif selected2 == 2 then
			imgui.Text(u8"����� �� by Adamson(�������� ������� deddosouru)")
			imgui.Separator()
			imgui.Text(u8"������ �� ���������� ������ ������ �� �� ������� �������.")
			imgui.Text(u8"������ ����� �������� �������, � ������� �� ���������: ")
			imgui.SameLine()
			imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"/bb, /bhist, /black.")
			imgui.TextWrapped(u8"�������� ������ ������ ���� � ����� ������, �� ������ ��� �� ����� �����. ��� ��������� ������� ���������� ������� ������, ������ �������� �������� ���������� � ������ �������, ��� ������������ ������� �������� ���� � ������, ������� ��������� � ��������� �������. ����� ���� ��� �� ���������/�������� ������ - � ����� ������� �������� ���� blacklist.txt, ������� �������� � ���� ������ ������ ������� � �� ������� ���������.")
			imgui.TextWrapped(u8"�����, ����� ���� ��� � ��� �������� ������ �������, �� ����� �������� ��� ��������� ������. �� ������ ������������� �������� �������� /black, ��� ��� ��� ��������� ����� ������ �� ��� ID ������ � ��� �������� �����, ��� ��������������� �� ���������� �������.")
			imgui.TextWrapped(u8"���� �� � ��� ��������� �������� ���������� ����, ��������� �� � �� ��, ��������, ��� ������, �� � ���� ��� ��� - �������� �� ������ ������� /bhist, ������� ������� ��������� ������ �� ���������� � �� �� ����.")
			imgui.TextWrapped(u8"��� ����� ��������� ���������� � ���, �� ����� ������� ����� ������� � ��, �� �� ���������, � ������ ���� �������, ��� ��� �� �������, ��� ��� �� ����� ������������ � ���������� ����������, ���� ����� �������� - �� ��� ������ ��������� ���� �� ������� � ��. ��� �� �����, ���� ����� ������ ���������� �� ���, ��� ��� ��� � ������ ������ - �� ������ ��������� ������� ���������� ����� �� �����, ���������� ����, ���� ����� ���������� ������ ������ ����������(������ ������), ����������� �������� ������ �����.")
			imgui.TextWrapped(u8"������ ���������� ������ �������� �������� ������. ����� �� ���������� �������� ������ �� �� ��� ��� ���� ����� - ��� ������ �������� ���������, ���� ����� � �� ��� ���. ���� �� ������, ��� ������� �������� ���-�� �����������, �� ���� � ��� �������� ����� ������� ������ - ��������� �����, ����� ������� � �� �� �� ������ ��� ������� �������������, ��� �� �����, ��� ����� �� ������ �� ���������(�� ������ ��������). ���� ����� ��������� � �� �� ��� ����������� ������, ��� ������ ��������� ������ �� ������� �� ���. ����� � ���� ������� �� ��� ���� ������ ������, ��������� �����������.")

		elseif selected2 == 3 then
			imgui.Text(u8"���������")
			imgui.Separator()
			imgui.Text(u8"������ �� ���������� ������ � ����������� ����, ������� ������������� � ������.")
			imgui.TextWrapped(u8"� �����, ���� ������� ����� � �������� - ��� ������� ���������. �� ������ ��������� ��������� ��������� � ������ ����������, ��������� �� ��� ����� ���� ������, ������� �� � ������ ������������. ��� ������� �����, �� ����� ��� ������������, ��?")
			imgui.TextWrapped(u8"����� ����� �������� �������������� ����������, ������� ����� ������� ��� ���������� ����� ��������������� �������. � ��� ���� ����? ���� ���� � ��������� �����, � ������:")
			imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"[center], [left], [right].")
			imgui.TextColored(imgui.ImVec4(0.80, 0.73 , 0, 1.0), u8"{HTML �����}.")
			imgui.TextWrapped(u8"�����������, ������ ����� ����� �������� � �������� �����������, ������ ���������� �������, ������� ������ ��� ��� ���������� �� ������ � ������ :D ��������, ��� ������ ������ ����� ������ ��� � �������������, �� � �� ���������� ����������� �����������.")
			imgui.TextWrapped(u8"������ ����� ����� ���� ������������ ��� �������� ����������� ������ � ����� ��� �� ��� �����, �� � �������� ����������������� ������� - � ���� ������ ��� ������������� � ������ ����� ��������� ������������� ���� ������� � ������ ����, � �� ������������ �� ��������, �� ����� � ��� ������� ������� ����� �������� ���� �� ���� ��������� ������ � ����������� ������� �������, ��� ���������� �������� �����, ������ � ������.")
			imgui.TextWrapped(u8"���������� �� ���� � ����������� ������������ ������������ ��������������� ���������, ��������, ��� ���������� ��� � ������������� � �� ������ ��������, ��������� �����������.")
		elseif selected2 == 4 then
			imgui.Text(u8"������������� ������ by X.Adamson")
			imgui.Separator()
			imgui.Text(u8"������ �� ���������� ������ � ����������� �������������� �������, ������� ����� ���� ��� �������.")
			imgui.TextWrapped(u8"������ �����, ������� ������� ������ ������� �� ������ ��������� - ���������� ������ ������������, ���������� ����� ������������, ���������� ����� �������� ��� �� �������, ��� � �� �������, �� ������ ��������� ����� ��������� ������� �������� ����� ��������. ������� ����� ����������� �����, �� ��� ������ �� ������� :)")
			imgui.TextWrapped(u8"����� ��� ��� ������� �������, ��� ���������� ������� �� �������� ���� ������ ����:")
			imgui.Text(u8("- ������ ������� �� ������������ � �������� ��� �� �� �������"))
			imgui.TextWrapped(u8"���� �� ��������� �������, ������� ������������ � ����� ���� ������� - �� �� ������������ ��, ���� �� ����� ��������, ��, ��� �����/�������� ����� ����� �� ��������� ������� ���������� �� ����, ������� � ��� �� ��� ���� ��� ���. ����� ������������ ������ ������� �������, ������ ���������� ����� �������������. ��� �� ������ ������������ � ������ ����� ����� �������, ������� ������������ ��� ������ �����. ������ ��������� � ���� :)")
			imgui.TextWrapped(u8"����������� �����, ������.. ��� ��� ������, �� ����� �� ������������� �� ���������� ������, ������� �������� ������ � �������. ���� ��� ������������ ��������� - �������� ��� � ���.��������� ���� ���� � �� ��������� ��� ������ :)")
		end
		imgui.EndChild()
        imgui.EndGroup()
        imgui.End()
	end

	if win_state['about'].v then -- ���� "� �������"
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(330, 270), imgui.Cond.FirstUseEver)
		imgui.Begin(u8('� �������'), win_state['about'], imgui.WindowFlags.NoResize)

		if developMode == 1 then imgui.Text(u8'MoD-Helper | Developer Mode')
		elseif developMode == 2 then imgui.Text(u8'MoD-Helper | Correction Mode')
		else imgui.Text(u8'MoD-Helper') end
		imgui.Text(u8'�����������: Xavier Adamson')
		imgui.Text(u8'���������: Arina Borisova')
		imgui.Text(u8'��������: DIPIRIDAMOLE')
		imgui.Text(u8'������ �������: '..thisScript().version)
		imgui.Text(u8'������ Moonloader: 026')
		imgui.Text(u8'������� blast.hk � ���������� ����� �� ������')
		imgui.Separator()
		--[[if imgui.Button(u8'VK') then
			print("��������: ��������� - � ������� - ��")
			sampAddChatMessage("[MoD-Helper]{FFFFFF} ������ ��������� ������ �� ����������� ������ ��.", SCRIPTCOLOR)
			print(shell32.ShellExecuteA(nil, 'open', 'https://vk.com/public168899283', nil, nil, 1))
		end
		imgui.SameLine()
		if imgui.Button(u8'���������') then
			print("��������: ��������� - � ������� - ���������")
			sampAddChatMessage("[MoD-Helper]{FFFFFF} ������ ��������� ������ �� ����������� ���� ���������.", SCRIPTCOLOR)
			print(shell32.ShellExecuteA(nil, 'open', 'https://forum.advance-rp.ru/threads/ministerstvo-oborony-mod-helper-dlja-voennosluzhaschix.1649378/', nil, nil, 1))
		end
		imgui.SameLine()]]
		if imgui.Button(u8'���������� �� ��������� ������', btn_size) then
			sampAddChatMessage("[MoD-Helper]{FFFFFF} �������� �������� ����������.", SCRIPTCOLOR)
			checkupd = true
			update()
		end
		if imgui.Button(u8'��������� ������', btn_size) then 
			offscript = offscript + 1
			if offscript ~= 2 then
				sampAddChatMessage("[MoD-Helper]{FFFFFF} �� ����������� ��������� ������, �������� �������� ���������� ��� ��������� �������� ��� ����������.", SCRIPTCOLOR)
				sampAddChatMessage("[MoD-Helper]{FFFFFF} ����������� ���������� �������, ���� ������� � ������������� ��� ����������.", SCRIPTCOLOR)
			else
				print("��������� ������ �� ��������")
				reloadScript = true
				thisScript():unload()
			end
		end
		imgui.End()
	end

	if win_state['leave'].v then -- ����, ������� ����������� ��� /leave � ������ �������������
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(360, 225), imgui.Cond.FirstUseEver)

		imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.0, 0.0, 0.0, 0.3))
		if imgui.Begin(u8('������������� ���������������� ����������'), win_state['leave'], imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoSavedSettings) then
			imgui.OpenPopup(u8"������������� /leave")
			if imgui.BeginPopupModal(u8"������������� /leave", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
				imgui.Text(u8("�� ����� ������� ��� ���������������� ���������� �� �������, ������ ��� ���������� ������� � ��� ����� ��������� ��������, �� ����� ������ ������� ������ �����������.\n������� ���� ������������� � ����� ������������, ���� �� ������ ���������� - ������� �� ������, � ���� ������ - �� ������."))
				if imgui.Button(u8('� ������'), btn_size) then
					print("����������� ���������� /leave")
					win_state['leave'].v = not win_state['leave'].v
					imgui.CloseCurrentPopup()
					sampSendChat("/leave")
				end
				if imgui.Button(u8('� ���������'), btn_size) then
					win_state['leave'].v = not win_state['leave'].v
					imgui.CloseCurrentPopup()
				end
				imgui.EndPopup()
			end
			imgui.End()
		end
		imgui.PopStyleColor()
	end

	if win_state['update'].v then -- ���� ���������� �������
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(450, 200), imgui.Cond.FirstUseEver)
        imgui.Begin(u8('����������'), nil, imgui.WindowFlags.NoResize)
		imgui.Text(u8'���������� ���������� �� ������: '..updatever)
		imgui.Separator()
		imgui.TextWrapped(u8("��� ��������� ���������� ���������� ������������� ������������, ����������� ������������ ����������� ��������� ���������� ����� ����, ��� ������� ������ ����� ������������ ����� ����������� � ����� �� ��������."))
		if imgui.Button(u8'������� � ���������� ����������', btn_size) then
			async_http_request('GET', 'https://raw.githubusercontent.com/DiPiDi/install/master/MO.luac', nil, 
				function(response) -- ��������� ��� �������� ���������� � ��������� ������
				local f = assert(io.open(getWorkingDirectory() .. '/MO.luac', 'wb'))
				f:write(response.text)
				f:close()
				sampAddChatMessage("[MoD-Helper]{FFFFFF} ���������� �������, ������������� ������.", SCRIPTCOLOR)
				thisScript():reload()
			end,
			function(err) -- ��������� ��� ������, err - ����� ������. ��� ������� ����� �� ���������
				print(err)
				sampAddChatMessage("[MoD-Helper]{FFFFFF} ��������� ������ ��� ����������, ���������� �����.", SCRIPTCOLOR)
				win_state['update'].v = not win_state['update'].v
				return
			end)
		end
		if imgui.Button(u8'�������', btn_size) then win_state['update'].v = not win_state['update'].v end
		imgui.End()
	end


	if win_state['informer'].v then -- ���� ���������

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

				imgui.Text(u8("� ����� �����: "..tostring(maskMinutes)..":"..(maskSeconds >= 10 and '' or '0')..""..tostring(maskSeconds)))
				if maskSeconds <= 0 and maskMinutes <= 0 then offMask = true end
			end
			if infZone.v then imgui.Text(u8("� ����: "..ZoneText)) end
			if infArmour.v then imgui.Text(u8("� �����: "..armourNew)) end
			if infHP.v then imgui.Text(u8("� ��������: "..healNew)) end
			if infCity.v then imgui.Text(u8("� �����: "..playerCity)) end
			if infRajon.v then imgui.Text(u8("� �����: "..ZoneInGame)) end
			
			if infKv.v then imgui.Text(u8("� �������: "..tostring(locationPos()))) end
			if infTime.v then imgui.Text(u8("� �����: "..os.date("%H:%M:%S"))) end
			imgui.End()
		end
		imgui.PopStyleColor()
	end

	if win_state['find'].v then -- ���������, ������� ������ ����������� ����������, �� �������� ;D

		imgui.SetNextWindowPos(imgui.ImVec2(infoX2, infoY2), imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(500, 170), imgui.Cond.FirstUseEver)

		imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.0, 0.0, 0.0, 0.3))
		if imgui.Begin(u8"���������", win_state['find'], imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoSavedSettings) then
			imgui.Columns(3, _, false)
			imgui.SetColumnWidth(-1, 150)
			imgui.Text(u8("� �����:"))
			for i = 1, #names do
				imgui.Text(u8(names[i]))
			end

			imgui.NextColumn(2)
			imgui.SetColumnWidth(-1, 150)
			imgui.Text(u8("�����:"))
			for i = 1, #SecNames do
				imgui.TextColored(imgui.ImVec4(0.12, 0.70 , 0.38, 1.0), u8(SecNames[i].."["..secID[i].."]"))
			end
	
			imgui.NextColumn(3)
			imgui.SetColumnWidth(-1, 160)
			imgui.Text(u8("�� � �����:"))
			for i = 1, #SecNames2 do 
				imgui.TextColored(imgui.ImVec4(0.12, 0.70 , 0.38, 1.0), u8(SecNames2[i].."["..sec2ID[i].."]"))
			end
			imgui.End()
		end
		imgui.PopStyleColor()
	end

	if menu_spur.v then -- ���� ��� ����
		local t_find_text = {}
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(1110, 720), imgui.Cond.FirstUseEver)
		imgui.Begin(u8("��������� | MoD-Helper"), menu_spur)
		imgui.BeginChild(1, imgui.ImVec2(imgui.GetWindowWidth()/3.8, 0), true)
		if imgui.Selectable(u8("����� ���������")) then add_spur = true end
		imgui.Separator()
		imgui.InputText(u8("������"), find_text_spur)
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
			imgui.InputText(u8("��������"), name_add_spur)
			imgui.SameLine()
			imgui.Text("Sym: "..tostring(#name_add_spur.v)..", finded: "..(tostring(name_add_spur.v):match("%s") and "yes" or "no"))
			if imgui.Button(u8("�������")) then
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
			if imgui.Button(u8("������")) then add_spur = false end
		elseif t_find_text[1] then
			for i = 1, #t_find_text do
				local nameFileOpen = t_find_text[i]:match('(.*).txt')
				imgui.BeginChild(i+50, imgui.ImVec2(0, 150), true)
				imgui.AlignTextToFramePadding()
				imgui.Text(u8(nameFileOpen))
				imgui.SameLine()
				if imgui.Button(u8('������� ����� ##'..i)) then
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
			imgui.InputText(u8("��������"), name_edit_spur)
			imgui.SameLine()
			if imgui.Button(u8("���������")) then
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
			if imgui.Button(u8("������")) then edit_nspur = false end
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
						if imgui.Button(u8("���������")) then
							edit_text_spur.v = edit_text_spur.v:gsub('\n\n', '\n \n')
							local file = io.open('moonloader/MoD-Helper/shpora/'..files[id_spur], 'w')
							file:write(u8:decode(edit_text_spur.v))
							file:flush()
							file:close()
							text_spur = true
							edit_spur = false
						end
						imgui.SameLine()
						if imgui.Button(u8("������")) then
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
					if imgui.Button(u8("��������")) then
						text_spur = false
						edit_spur = true
						edit_text_spur.v = u8(fileText)
					end
					imgui.SameLine()
					if imgui.Button(u8("�������������")) then
						edit_nspur = true
						name_edit_spur.v = u8(files[id_spur]:match('(.*).txt'))
					end
					imgui.SameLine()
					if imgui.Button(u8("�������")) then
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

function rcmd(cmd, text, delay) -- ������� ��� �������, ��� ������� �� ����� �� ������, �� ������.
	if cmd ~= nil then -- ������������ ������, ������� �������� �� �������
		if cmd ~= '-' then sampUnregisterChatCommand(cmd) end -- ������ ��� ��� ��������������� ������
		sampRegisterChatCommand(cmd, function(params) -- ������������ ������� + ������ �������
			globalcmd = lua_thread.create(function() -- ����� ����� � ����������, ����� ����� � ��� ������� �����, �� ���-�� ����� �� ��� � ��� ������� �� ����������� ;D
				if not keystatus then -- ���������, �� ������� �� ������ ���� ����
					cmdparams = params -- ������ ��������� �����
					if text:find("{par1") or text:find("{par2") or text:find("IDpar1}") or text:find("IDpar2}") then
						cmdparams1 = cmdparams:match("(.+) | .+")
						cmdparams2 = cmdparams:match(".+ | (.+)")
					end  -- (text:find("{par") or text:find("IDpar")) and (cmdparams == '' or cmdparams1 == nil or cmdparams2 == nil)
					
					
					if (((text:find("{par1}") or text:find("{par2}") or text:find("IDpar")) and (cmdparams1 == nil or cmdparams2 == nil)) or ((text:find("{params}") or text:find("ByID}")) and cmdparams == '')) then -- ���� � ������ ����� ���� ����� �� ��� ��������� � �������� ����, ������� ��������� ���
						--sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /"..cmd.." ["..(text:find("byID}") and 'ID' or '��������').."].", 0x046D63)
						local partype = '' -- ������� ��������� ����������
						if text:find("ByID}") then 
							partype = "ID"
							sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: {"..u8:decode(Secondcolor.v).."}/"..cmd.." ["..partype.."].", SCRIPTCOLOR)
						elseif text:find("{par1}") and text:find("{par2}") then 
							partype = "�������� 1 | �������� 2"
							sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: {"..u8:decode(Secondcolor.v).."}/"..cmd.." ["..partype.."].", SCRIPTCOLOR)
						elseif text:find("IDpar1}") and text:find("{par2") then
							partype = "ID | �������� 2"
							sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: {"..u8:decode(Secondcolor.v).."}/"..cmd.." ["..partype.."].", SCRIPTCOLOR)
						elseif text:find("IDpar2}") and text:find("{par1") then 
							partype = "�������� 1 | ID"
							sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: {"..u8:decode(Secondcolor.v).."}/"..cmd.." ["..partype.."].", SCRIPTCOLOR)
						elseif text:find("IDpar1}") and text:find("IDpar2}") then 
							partype = "ID | ID"
							sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: {"..u8:decode(Secondcolor.v).."}/"..cmd.." ["..partype.."].", SCRIPTCOLOR)
						elseif text:find("{params}") then
							partype = "��������"
							sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: {"..u8:decode(Secondcolor.v).."}/"..cmd.." ["..partype.."].", SCRIPTCOLOR)
						else
							sampAddChatMessage("[MoD-Helper]{FFFFFF} � ������ ����� ��������� ���������� ���� ���� ������.", SCRIPTCOLOR)
						end -- ������� �� �������� �� �������
					else
						keystatus = true
						local strings = split(text, '~', false) -- ������������ ����� �����
						for i, g in ipairs(strings) do -- �������� ����������������� ����� ������ �� �������
							if not g:find("{bwait:") then sampSendChat(tags(tostring(g))) end
							wait(g:match("%{bwait:(%d+)%}"))
						end
						keystatus = false
						cmdparams = nil -- �������� ��������� ����� �������������
						cmdparams1 = nil
						cmdparams2 = nil
					end
				end
			end)
		end)
	else
		-- ��� ��� ����������, ��� � � ���������, ������ ����� �����.
		globalkey = lua_thread.create(function()
			if text:find("{par") or text:find("par1}") or text:find("par2}") then
				sampAddChatMessage("[MoD-Helper]{FFFFFF} � ������ ����� ������� ���� ��� ����� ����������, ������������� ��������� ����������.", SCRIPTCOLOR)
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

function split(str, delim, plain) -- ������� ����, ������� ������� ������ �������
    local tokens, pos, plain = {}, 1, not (plain == false) 
    repeat
        local npos, epos = string.find(str, delim, pos, plain)
        table.insert(tokens, string.sub(str, pos, npos and npos - 1))
        pos = epos and epos + 1
    until not pos
    return tokens
end

function showHelp(param) -- "��������" ��� �������
    imgui.TextDisabled('(?)')
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(imgui.GetFontSize() * 35.0)
        imgui.TextUnformatted(param)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function all_trim(s) -- �������� �������� �� ������ �� �� ��������
   return s:match( "^%s*(.-)%s*$" )
end

function ClearChat() -- ������� ����
    memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200)
    memory.write(sampGetChatInfoPtr() + 306, 25562, 4, 0x0)
    memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1)
end

function ClearBlip() -- �������� �������/�������
	if newmark ~= nil then
		if marker.v then
			removeBlip(newmark)	
			print("������� ������ ������ � ������ "..sampGetPlayerNickname(blipID))
			sampAddChatMessage("[MoD-Helper]{FFFFFF} ������ � ������ "..sampGetPlayerNickname(blipID).." ��� ������� ������.", SCRIPTCOLOR)
		else
			print("������� ������ � ������ "..sampGetPlayerNickname(blipID))
			sampAddChatMessage("[MoD-Helper]{FFFFFF} ������ � ������ "..sampGetPlayerNickname(blipID).." ��� ������� ����.", SCRIPTCOLOR)
		end
		blipID = nil
		newmark = nil
	end
end

function locationPos() -- ��������� �������� ������
	if not workpause then
		if interior == 0 then
			local KV = {
				[1] = "�",
				[2] = "�",
				[3] = "�",
				[4] = "�",
				[5] = "�",
				[6] = "�",
				[7] = "�",
				[8] = "�",
				[9] = "�",
				[10] = "�",
				[11] = "�",
				[12] = "�",
				[13] = "�",
				[14] = "�",
				[15] = "�",
				[16] = "�",
				[17] = "�",
				[18] = "�",
				[19] = "�",
				[20] = "�",
				[21] = "�",
				[22] = "�",
				[23] = "�",
				[24] = "�",
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

function ARGBtoRGB(color) return bit32 or require'bit'.band(color, 0xFFFFFF) end -- ������� ������

function rel() -- ������������ �������
	sampAddChatMessage("[MoD-Helper]{FFFFFF} ������ ���������������.", SCRIPTCOLOR)
	reloadScript = true
	thisScript():reload()
end

function clearSeleListBool(var) -- �� ��� ���-��� ������ ;D
	for i = 1, #SeleList do
		SeleListBool[i].v = false
	end
	SeleListBool[var].v = true
end


function update() -- �������� ����������
	local zapros = https.request("https://raw.githubusercontent.com/DiPiDi/install/master/update.json")

	if zapros ~= nil then
		local info2 = decodeJson(zapros)

		if info2.latest_number ~= nil and info2.latest ~= nil and info2.drop ~= nil then
			updatever = info2.latest
			version = tonumber(info2.latest_number)
			dropver = tonumber(info2.drop)
			
			print("[Update] �������� �������� ������")
			
			if tonumber(thisScript().version_num) <= dropver then
				print("[Update] Used non supported version: "..thisScript().version_num..", actual: "..version)
				sampAddChatMessage("[MoD-Helper]{FFFFFF} ���� ������ ����� �� �������������� �������������, ������ ������� ����������.", SCRIPTCOLOR)
				reloadScript = true
				thisScript():unload()
			elseif version > tonumber(thisScript().version_num) then
				print("[Update] ���������� ����������")
				sampAddChatMessage("[MoD-Helper]{FFFFFF} ���������� ���������� �� ������ {"..u8:decode(Secondcolor.v).."}"..updatever..".", SCRIPTCOLOR)
				win_state['update'].v = true
				UpdateNahuy = true
			else
				print("[Update] ����� ���������� ���, �������� ������ �������")
				if checkupd then
					sampAddChatMessage("[MoD-Helper]{FFFFFF} � ��� ����� ���������� ������ �������: {"..u8:decode(Secondcolor.v).."}"..thisScript().version..".", SCRIPTCOLOR)
					sampAddChatMessage("[MoD-Helper]{FFFFFF} ������������� ��������� ������ - ���, ��������� �����������.", SCRIPTCOLOR)
					checkupd = false
				end
				UpdateNahuy = true
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} ������ ��� ��������� ���������� �� ����������.", SCRIPTCOLOR)
			print("[Update] JSON file read error")
			UpdateNahuy = true
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} �� ������� ��������� ������� ����������, ���������� �����.", SCRIPTCOLOR)
		UpdateNahuy = true
	end
end

function cmd_color() -- ������� ��������� ����� ������, �� ����� ��� ���, �� ����� �� ����
	local text, prefix, color, pcolor = sampGetChatString(99)
	sampAddChatMessage(string.format("���� ��������� ������ ���� - {934054}[%d] (���������� � ����� ������)",color),-1)
	setClipboardText(color)
end

function async_http_request(method, url, args, resolve, reject) -- ����������� �������, ������� ����� �������, ��� ��� ������������ ������������� ���� ����� ������� � ��� ;D
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

function black_checker(params) -- ����� ��� �� ID
	if params:match("^%d+") then
		local blackid  = params:match("^(%d+)")
		blackid = tonumber(blackid)
		if sampIsPlayerConnected(blackid) or blackid == myID then
			local blacknick = sampGetPlayerNickname(blackid)
			sampAddChatMessage("[MoD-Helper]{FFFFFF} ���� ������� ����������� ����� ����� ��������� ��� - ������ ��� � ��.", SCRIPTCOLOR)
			sampAddChatMessage("[MoD-Helper]{FFFFFF} ��������� ������ "..blacknick.." �� ������� � ������ ������ ���.�������.", SCRIPTCOLOR)
			
			if rpblack.v then
				lua_thread.create(function() 
					sampSendChat("/me ������ ��� �� �������, "..(lady.v and '�����' or '����').." ������ �������� � ������� ������ � ��������")
					wait(2000)
					sampSendChat("/todo ����� ��������� ����� ������*"..(lady.v and '�������' or '������').." ������, �������.")
					wait(2000)
					if bstatus == 1 then
						bstatus = 0
						sampSendChat("/do ���: "..blacknick:gsub("_", " ").." ������� � ������ ������ ������������ �������.")
						wait(2000)
						sampSendChat(blacknick:gsub("_.*", "")..", ���������, �� �� �������� � ������ ������ ������������ �������.")
					elseif bstatus == 2 then
						bstatus = 0
						sampSendChat("/do ���: ������� �� "..blacknick:gsub("_", " ").." � ������ ������ �� ����������.")
						wait(2000)
						sampSendChat(blacknick:gsub("_.*", "")..", �������, ��� ��� � ������ ������ ������������ �������.")
					end
				end)
			end
		
			for k, v in ipairs(blackbase) do
				if v[1]~= nil then
					if blacknick:find(v[1]) then
						sampShowDialog(1488, '{FFD700}�� �� | MoD-Helper', "{DC143C}����� "..blacknick.." ������ � ������ ������.\n������� ���������: "..u8:decode(v[2]), "�������", "", 0)
						bstatus = 1
						checking = false
						break
					end
				end
			end
			black_history(blacknick) -- ��� �� ������� �����
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} ����� � ������ ID �� ��������� � ������� ��� ������ ��� ID.", SCRIPTCOLOR)
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /black [ID].", SCRIPTCOLOR)
		return
	end
end

function black_history(params) -- ����� ��� �� ����
	if params:match("^.*") then
		blackn = params:match("^(.*)")
		pidr = false
		for k, v in ipairs(blackbase) do
			if v[1]~= nil then
				if blackn:find(v[1]) then
					sampShowDialog(1488, '{FFD700}�� �� | MoD-Helper', "{DC143C}����� "..blackn.." ������ � ������ ������.\n������� ���������: "..u8:decode(v[2]), "�������", "", 0)
					bstatus = 1
					pidr = true
					break
				end
			end
		end
		if not pidr then
			sampAddChatMessage("[MoD-Helper]{FFFFFF} ��������� ������� ����� "..params..".", SCRIPTCOLOR)
			checking = true
			sampSendChat("/history "..blackn.."")
		end
	else 
		sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /bhist [nick].", SCRIPTCOLOR)
		return
	end
end


function changeSkin(id, skinId) -- ���������� ����� �����(imring ����� �� �������� ��)
    bs = raknetNewBitStream()
    if id == -1 then _, id = sampGetPlayerIdByCharHandle(PLAYER_PED) end
    raknetBitStreamWriteInt32(bs, id)
    raknetBitStreamWriteInt32(bs, skinId)
    raknetEmulRpcReceiveBitStream(153, bs)
    raknetDeleteBitStream(bs)
end

function upd_blacklist() -- �������� ������ �������
	sampAddChatMessage("[MoD-Helper]{FFFFFF} �������� ���������� ������ ��.", SCRIPTCOLOR)
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
					sampAddChatMessage("[MoD-Helper]{FFFFFF} ��������� ������ ��� ���������� ������ ��.", SCRIPTCOLOR)
				end
			end)
		end
	end)
end

function ex_find() -- ��������� �����
	sampSendChat("/find")
	lua_thread.create(function()
		if rpFind.v then
			sampSendChat("/me "..(lady.v and '�������' or '������').." ��� �� ������� � "..(lady.v and '�������' or '������').." ������ ������ "..(arm == 3 and '�����' or '�����'))
			wait(800)
			sampSendChat("/do ��� "..(findCout ~= nil and '������� ����������, ���������� ������ '..(arm == 3 and '�����' or '�����')..': '..findCout or '����� ���������� � ���������� ������ '..(arm == 3 and '�����' or '�����')..'')..".")
			wait(800)
			sampSendChat("/me ����� ������������ �� ������� "..(lady.v and '�������' or '������').." � "..(lady.v and '��������' or '�������').." ��� �������")				
		end
	end)
end

function sampev.onSendPlayerSync(data)
	if workpause then -- ������� ��� ������ ������� ��� ��������� ����
		return false
	end
end

function sampev.onServerMessage(color, text)

	WriteLog(os.date('[%H:%M:%S | %d.%m.%Y]')..' '..text:gsub("{.-}", ""),  'MoD-Helper', 'chatlog') -- ������ ���� ��������� � ���, ��� � �������� ������� � ���� �������� ��

	if ads.v then -- ��������� ������� � ��������� �� � ���������
		if color == 13369599 and text:find("��������") then print("{14ccbd}[ADS]{279c40}".. text) return false end
		if color == 10027263 and text:find("���������") then print("{14ccbd}[ADS]{0f6922}"..text) return false end
	end

	if text == "�� ����� �����" or text == "�� ������ ����� ����� � ��������� ������" then -- ������ ����� ���, ������ �� �����, ������� ���������� � ��������� +- 30 ������(�� ��� �� �����).
		offMask = true
	elseif color == 865730559 and text:find("���� ����������������� �� GPS ������") then
		offMaskTime = os.clock() * 1000 + 600000
		offMask = false
	end


	if color == 1721355519 and text:match("%[F%] .*") then -- ��������� ����� � ID ������, ������� ��������� ������� � /f ���, ��� ����� �������
		lastfradiozv, lastfradioID = text:match('%[F%]%s(.+)%s%a+_%a+%[(%d+)%]: .+')
	elseif color == 869033727 and text:match("%[R%] .*") then -- ��������� ����� � ID ������, ������� ��������� ������� � /r ���, ��� ����� �������
		lastrradiozv, lastrradioID = text:match('%[R%]%s(.+)%s%a+_%a+%[(%d+)%]: .+')
	end

	if color == -577699841 and text:find("����%(�%)") then -- �������������� ����� � ������� ��������
		if text:find("���") or text:find("��������") or text:find("������") then
			lua_thread.create(function()
				wait(500)
				sampSendChat("/eat")
			end)
		end
		return {color, text}
	end

	if text:match("SMS: .* | �����������: .* %[�%.%d+%]") then -- ��������� �������� ����� + ��������� ������� + ����
		local tsms, tname, SMS = text:match("SMS: (.*) | �����������: (.*) %[�%.(%d+)%]") 
		-- if smsinfo.v and workpause then vkmessage(tonumber(vkid2), text) end
		if inComingSMS.v then
			if phoneModel.v == '' then
				sampSendChat(string.format("/do �� ������� ������ ��������� � ������ %d.", SMS))
			else
				sampSendChat(string.format("/do �� ������� ������ %s ������ ��������� � ������ %d.", u8:decode(phoneModel.v), SMS))
			end
			sampAddChatMessage(text, 0xFFFF00)
		end
		if smssound.v then bass.BASS_ChannelPlay(asms, false) end
		lastnumberon = SMS 
	end
		
	if text:match("SMS: .* | ����������: .* %[�%.%d+%]") then -- ��������� ��������� �����
		local SMSfor = text:match("SMS: .* | ����������: .* %[�%.(%d+)%]") 
		-- if smsinfo.v and workpause then vkmessage(tonumber(vkid2), text) end
		lastnumberfor = SMSfor 
	end

	if color == 1721355519 and text:find("%[P.E.S.%]: ������� ����������:") then -- ��������� ������ �� ���, ���� ����� � /f ����
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
	----------------- �������� ����� � ��� ��� � ���� ������� -------------------
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
			elseif text:find(''..u8:decode(masss[i])..'%[.+%]') and not text:find('| ��������') then
				local idc = text:match('%[(%d+)%]')
				if tostring(u8:decode(masss[i])):match('%a') then	
					text = text:gsub(u8:decode(masss[i])..'%['..idc..'%]', '{'..colornikifama..'}'..u8:decode(masss[i])..'['..idc..']{'..string.format('%X', bit.rshift(color, 8))..'}')
				end
			elseif text:find(''..u8:decode(masss[i])..'%[.+%]') and text:find('| ��������') then
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
			elseif text:find(u8:decode(masss[i])) and not text:find('���������� �������� ��������� ���') then
				if tostring(u8:decode(masss[i])):match('%a') then	
					text = text:gsub(u8:decode(masss[i]), '{'..colornikifama..'}'..u8:decode(masss[i])..'{'..string.format('%X', bit.rshift(color, 8))..'}')
				end
			elseif text:find(u8:decode(masss[i])) and text:find('���������� �������� ��������� ���') then
				if tostring(u8:decode(masss[i])):match('%a') then	
					text = text:gsub(u8:decode(masss[i]), '{'..colornikifama..'}'..u8:decode(masss[i])..'{00'..string.format('%X', bit.rshift(color, 8))..'}')
				end
			end
		end
		return { color, text }
	end
end


function load_settings() -- �������� ��������
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


function cmd_histid(params) -- ������� ����� �� ID
	if params:match("^%d+") then
		params = tonumber(params:match("^(%d+)"))
		if sampIsPlayerConnected(params) or myID == tonumber(params) then
			local histnick = sampGetPlayerNickname(params)
			sampAddChatMessage("[MoD-Helper]{FFFFFF} ��������� ������� ����� ������ "..histnick..".", SCRIPTCOLOR)
			sampSendChat("/history "..histnick)
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} ����� � ������ ID �� ��������� � �������.", SCRIPTCOLOR)
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /hist [ID].", SCRIPTCOLOR)
	end
end

function rradio(params) -- ��������� /r
	if mtag ~= "M" then -- ��������� �������� ������� /r ���
		if #params:match("^.*") > 0 then
			local params = params:match("^(.*)")
			if params:find("%(%(") or params:find("%)%)") or params:find("%)") or params:find("%(") then
				params = params:gsub("%(", "")
				params = params:gsub("%)", "")
				sampAddChatMessage("[MoD-Helper]{FFFFFF} ��������� ���������� ��� OOC � ������������� ����������. ����������� �������: %( � %).", SCRIPTCOLOR)
				sampSendChat(string.format("/r (( %s ))", params))
			else
				if rtag.v == '' then
					sampSendChat(string.format("/r %s", params))
				else
					sampSendChat(string.format("/r [%s]: %s", u8:decode(rtag.v), params))
				end
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /r [text].", SCRIPTCOLOR)	
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} ��� ���������� ������ �����.", SCRIPTCOLOR)
	end
end

function fradio(params) -- ��������� /f
	if #params:match("^.*") > 0 then
		local params = tostring(params:match("^(.*)"))
		if params:find("%(%(") or params:find("%)%)") or params:find("%)") or params:find("%(") then
			params = params:gsub("%(", "")
			params = params:gsub("%)", "")
			sampAddChatMessage("[MoD-Helper]{FFFFFF} ��������� ���������� ��� OOC � ������������� ����������. ����������� �������: %( � %).", SCRIPTCOLOR)
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
		sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /f [text].", SCRIPTCOLOR)
	end
end

function cmd_livrby(params) -- ������� �����
	if isPlayerSoldier then
		if nasosal_rang <= 4 and nasosal_rang ~= 10 and nasosal_rang ~= 8 and nasosal_rang ~= 8 then sampAddChatMessage("[MoD-Helper]{FFFFFF} ������ ������� �������� � 5 �� 7 ����.", SCRIPTCOLOR) return end
		if params:match("^%d+%s.*") then
			local livid, rsn = params:match("^(%d+)%s(.*)")
			if sampIsPlayerConnected(livid) then
				local livname = string.gsub(sampGetPlayerNickname(livid), '_', ' ')
				if rtag.v == '' then
					sampSendChat(string.format("/r ���������� �������� ����� %s#%d.", livname, livid))
					sampSendChat(string.format("/r �������: %s", rsn))
				else
					sampSendChat(string.format("/r [%s]: ���������� �������� ����� %s#%d.", u8:decode(rtag.v), livname, livid))
					sampSendChat(string.format("/r [%s]: �������: %s", u8:decode(rtag.v), rsn))
				end
			else
				sampAddChatMessage("[MoD-Helper]{FFFFFF} ����� � ������ ID �� ��������� � ������� ��� ������ ��� ID.", SCRIPTCOLOR)
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /livr [ID] [�������].", SCRIPTCOLOR)
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} ���������� �� ������ ������� ��� �� �� ��������������.", SCRIPTCOLOR)
	end
end

function cmd_livfby(params) -- ������� �����
	if isPlayerSoldier then
		if nasosal_rang <= 4 and nasosal_rang ~= 10 and nasosal_rang ~= 8 and nasosal_rang ~= 8 then sampAddChatMessage("[MoD-Helper]{FFFFFF} ������ ������� �������� � 5 �� 7 ����.", SCRIPTCOLOR) return end
		if params:match("^%d+%s.*") then
			local livid, rsn = params:match("^(%d+)%s(.*)")
			if sampIsPlayerConnected(livid) then
				local livname = string.gsub(sampGetPlayerNickname(livid), '_', ' ')
				if ftag.v == '' then
					sampSendChat(string.format("/f ���������� �������� ����� %s#%d.", livname, livid))
					sampSendChat(string.format("/f �������: %s", rsn))
				else
					sampSendChat(string.format("/f [%s]: ���������� �������� ����� %s#%d.", u8:decode(ftag.v), livname, livid))
					sampSendChat(string.format("/f [%s]: �������: %s", u8:decode(ftag.v), rsn))
				end
			else
				sampAddChatMessage("[MoD-Helper]{FFFFFF} ����� � ������ ID �� ��������� � ������� ��� ������ ��� ID.", SCRIPTCOLOR)
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /livf [ID] [�������].", SCRIPTCOLOR)
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} ���������� �� ������ ������� ��� �� �� ��������������.", SCRIPTCOLOR)
	end
end

function livraport(params) -- ������� ����� [������ �����������]: ��� ���������. �������: ��� � ������������ �����.               [������ �����������]: ����� id ���������. �������: �������
	if isPlayerSoldier then
		if nasosal_rang <= 4 then 
			sampAddChatMessage("[MoD-Helper]{FFFFFF} ������ ������� �������� � 5 �� 7 ����.", SCRIPTCOLOR) 
			return 
		end
		if params:match("^%d+%s.*") then
			local livid, rsn = params:match("^(%d+)%s(.*)")
			if sampIsPlayerConnected(livid) then
				local livname = string.gsub(sampGetPlayerNickname(livid), '_', ' ')	
				sampSendChat(string.format("/do [������ �����������]: ����� %d ���������. �������: %s", livid, rsn))
				if nasosal_rang > 7 then
					lua_thread.create(function()
						if rpuninvoff.v then
							sampSendChat("/me "..(lady.v and '�������' or '������').." ���, ����� ���� "..(lady.v and '�����' or '�����').." � ���� ������ ��������������")
							wait(1000)
							sampSendChat(string.format("/me "..(lady.v and '��������' or '�������').." ������ ���� %d ��� ��������", livid))
							wait(250)
						end
						sampSendChat(string.format("/uninviteoff %d %s", livid, rsn))
					end)
				end
			else
				sampAddChatMessage("[MoD-Helper]{FFFFFF} ����� � ������ ID �� ��������� � ������� ��� ������ ��� ID.", SCRIPTCOLOR)
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /raport [ID] [�������].", SCRIPTCOLOR)
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} ���������� �� ������ ������� ��� �� �� ��������������.", SCRIPTCOLOR)
	end
end

function ex_uninvite(params) -- ���� �� �����������
	if isPlayerSoldier then
		if nasosal_rang <= 7 and developMode ~= 1 then sampAddChatMessage("[MoD-Helper]{FFFFFF} ������ ������� �������� � 8 �����.", SCRIPTCOLOR) return end
		if params:match("^%d+%s.*") then
			local uid, ureason = params:match("^(%d+)%s(.*)")
			if sampIsPlayerConnected(uid) then
				local uname = sampGetPlayerNickname(uid):gsub('_', ' ')
				lua_thread.create(function()
					if rpuninv.v then
						sampSendChat("/me "..(lady.v and '�������' or '������').." ���, ����� ���� "..(lady.v and '�����' or '�����').." � ���� ������ ��������������")
						wait(1000)
						sampSendChat(string.format("/me "..(lady.v and '��������' or '�������').." ������ ���� %s ��� ��������", uname))
						wait(250)

						if ftag.v == '' then
							sampSendChat(string.format("/f ���� %s ��� ��������� � ��������.", mtag, uname))
							wait(500)
							sampSendChat(string.format("/f ������� ��������: %s", ureason))
						else
							sampSendChat(string.format("/f [%s]: ���� %s ��� ��������� � ��������.", u8:decode(ftag.v), uname))
							wait(500)
							sampSendChat(string.format("/f [%s]: ������� ��������: %s", u8:decode(ftag.v), ureason))
						end
					end
					wait(250)
					sampSendChat(string.format("/uninvite %d %s", uid, ureason))
				end)
			else
				sampAddChatMessage("[MoD-Helper]{FFFFFF} ����� � ������ ID �� ��������� � ������� ��� ������ ��� ID.", SCRIPTCOLOR)
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /uninvite [ID] [�������].", SCRIPTCOLOR)
		end
	else
		sampSendChat("/uninvite "..params)
	end
end

function ex_uninviteoff(params) -- ���� � ����
	if isPlayerSoldier then
		if nasosal_rang ~= 10 and developMode ~= 1 then sampAddChatMessage("[MoD-Helper]{FFFFFF} ������ ������� �������� ������ ������.", SCRIPTCOLOR) return end
		if params:match("^%S+%s.*") then
			local uid, ureason = params:match("^(%S+)%s(.*)")	
			local uname = uid:gsub('_', ' ')
			lua_thread.create(function()
				if rpuninvoff.v then
					sampSendChat("/me "..(lady.v and '�������' or '������').." ���, ����� ���� "..(lady.v and '�����' or '�����').." � ���� ������ ��������������")
					wait(1000)
					sampSendChat(string.format("/me "..(lady.v and '��������' or '�������').." ������ ���� %s ��� ��������", uname))
					wait(250)

					if ftag.v == '' then
						sampSendChat(string.format("/f ���� %s ��� ��������� � ��������.", uname))
						wait(500)
						sampSendChat(string.format("/f ������� ��������: %s", ureason))
					else
						sampSendChat(string.format("/f [%s]: ���� %s ��� ��������� � ��������.", u8:decode(ftag.v), uname))
						wait(500)
						sampSendChat(string.format("/f [%s]: ������� ��������: %s", u8:decode(ftag.v), ureason))
					end
				end
				sampSendChat(string.format("/uninviteoff %s %s", uid, ureason))
			end)
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /uninviteoff [���] [�������].", SCRIPTCOLOR)
		end
	else
		sampSendChat("/uninviteoff "..params)
	end
end

function ex_skin(params) -- ����� �����
	if isPlayerSoldier then
		if (nasosal_rang <= 7) and (developMode ~= 1) then sampAddChatMessage("[MoD-Helper]{FFFFFF} ������ ������� �������� � 8 �����.", SCRIPTCOLOR) return end
		if params:match("^%d+") then
			local uid = params:match("^(%d+)")
			if sampIsPlayerConnected(uid) or myID == tonumber(params) then
				local uname = sampGetPlayerNickname(uid):gsub('_', ' ')
				lua_thread.create(function()
					if rpskin.v then
						sampSendChat("/do � ����� ������� �������������� �������� � ������.")
						wait(1000)						
						sampSendChat(string.format("/me "..(lady.v and '��������' or '�����').." ����� � ������ ��� %s", uname))
						wait(500)
					end
					sampSendChat(string.format("/changeskin %d", uid))
				end)
			else
				sampAddChatMessage("[MoD-Helper]{FFFFFF} ����� � ������ ID �� ��������� � �������.", SCRIPTCOLOR)
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /changeskin [ID].", SCRIPTCOLOR)
		end
	else
		sampSendChat("/changeskin "..params)
	end
end

function ex_rang(params) -- ��������� �����
	if isPlayerSoldier then
		if nasosal_rang <= 8 and developMode ~= 1 then sampAddChatMessage("[MoD-Helper]{FFFFFF} ������ ������� �������� � 9 �����.", SCRIPTCOLOR) return end
		if params:match("^%d+%s%d+%s.*") then
			local uid, rcout, utype = params:match("^(%d+)%s(%d+)%s(.*)")
			rcout = tonumber(rcout)
			if sampIsPlayerConnected(uid) then
				lua_thread.create(function()
					if rcout <= 0 or rcout >= 5 then sampAddChatMessage("[MoD-Helper]{FFFFFF} ����������� �� ���������� ��������� �� 1 �� 4.", SCRIPTCOLOR) return end
					if rprang.v then
						local uname = sampGetPlayerNickname(uid):gsub('_', ' ')
						sampSendChat("/do ����� � ������ �������� � ����.")
						wait(1500)
						sampSendChat(string.format("/me "..(lady.v and '�������' or '������').." ����� � �������� � "..(lady.v and '�������' or '������').." ������ ��� %s", uname))
						wait(1500)
						sampSendChat(string.format("/me "..(lady.v and '��������' or '�����').." ����� ������ %s", uname))
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
							sampSendChat("/me �����, ��� ���-�� ����� �� ���")
							wait(1500)
							sampSendChat("���� ���������, � ������� �����������..")
						else
							sampAddChatMessage("[MoD-Helper]{FFFFFF} �� ����� �������� ��� [+/-].", SCRIPTCOLOR) return
						end
					end
				end)
			else
				sampAddChatMessage("[MoD-Helper]{FFFFFF} ����� � ������ ID �� ��������� � ������� ��� ������ ��� ID.", SCRIPTCOLOR)
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /rang [ID] [����������] [+/-].", SCRIPTCOLOR)
		end
	else
		sampSendChat("/rang "..params)
	end
end

function ex_invite(params) -- ������� �������
	if isPlayerSoldier then
		if nasosal_rang <= 8 and developMode ~= 1 then sampAddChatMessage("[MoD-Helper]{FFFFFF} ������ ������� �������� � 9 �����.", SCRIPTCOLOR) return end
		if params:match("^%d+") then
			local uid, utype = params:match("^(%d+)")
			if sampIsPlayerConnected(uid) then
				local uname = sampGetPlayerNickname(uid):gsub('_', ' ')
				lua_thread.create(function()
					if rpinv.v then
						if arm == 3 then
							sampSendChat("/do � ����� ����� � ����� ������� ������ � ������ U.S. Navy.")
						elseif arm == 1 then
							sampSendChat("/do � ����� ����� � ����� ������� ������ � ������ U.S. Ground Force.")
						elseif arm == 2 then
							sampSendChat("/do � ����� ����� � ����� ������� ������ � ������ U.S. Air Force.")
						end
						wait(1000)

						sampSendChat(string.format("/me "..(lady.v and '��������' or '�����').." ����� ���������� �� ����� %s", uname))
						wait(1000)

						sampSendChat(string.format("%s, ��������������, ����� �� ����.", uname))
						wait(1500)
						sampSendChat("�� ������� ����� �� ������� ������������ � ������� � ���������.")
						wait(100)
					end
					sampSendChat(string.format("/invite %d", uid))
				end)
			else
				sampAddChatMessage("[MoD-Helper]{FFFFFF} ����� � ������ ID �� ��������� � ������� ��� ������ ��� ID.", SCRIPTCOLOR)
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /invite [ID].", SCRIPTCOLOR)
		end
	else
		sampSendChat("/invite "..params)
	end
end

function cmd_uninvby(params) -- ���� �� �������
	if isPlayerSoldier then
		if nasosal_rang <= 7 and developMode ~= 1 and mtag ~= "M" then sampAddChatMessage("[MoD-Helper]{FFFFFF} ������ ������� �������� � 8 ����� � ������ �����������.", SCRIPTCOLOR) return end
		if params:match("^%d+%s%d+%s.*") then
			local livid, fromid, rsn = params:match("^(%d+)%s(%d+)%s(.*)")
			if sampIsPlayerConnected(livid) then 
				local fromid = string.gsub(sampGetPlayerNickname(fromid), '_', ' ')
				local uname = string.gsub(sampGetPlayerNickname(livid), '_', ' ')

				lua_thread.create(function()
					if rpuninv.v then
						sampSendChat("/me "..(lady.v and '�������' or '������').." ���, ����� ���� "..(lady.v and '�����' or '�����').." � ���� ������ ��������������")
						wait(1000)
						sampSendChat(string.format("/me "..(lady.v and '��������' or '�������').." ������ ���� %s ��� ��������", uname))
						wait(250)

						if ftag.v == '' then
							sampSendChat(string.format("/f ���� %s ��� ��������� � �������� �� ������ �������.", uname))
							sampSendChat(string.format("/f ������� ��������: %s | ������: %s", rsn, fromid))
						else
							sampSendChat(string.format("/f [%s]: ���� %s ��� ��������� � �������� �� ������ �������.", u8:decode(ftag.v), uname))
							sampSendChat(string.format("/f [%s]: ������� ��������: %s | ������: %s", u8:decode(ftag.v), rsn, fromid))
						end
					end
					sampSendChat(string.format("/uninvite %d %s | %s ", livid, rsn, fromid))
				end)
			else
				sampAddChatMessage("[MoD-Helper]{FFFFFF} ����� � ������ ID �� ��������� � ������� ��� ������ ��� ID.", SCRIPTCOLOR)
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /uninv [ID] [ID �������] [�������].", SCRIPTCOLOR)
		end
	end
end

function cmd_where(params) -- ������ ��������������
	if params:match("^%d+") then
		params = tonumber(params:match("^(%d+)"))
		if sampIsPlayerConnected(params) then
			local name = string.gsub(sampGetPlayerNickname(params), "_", " ")
			if rtag.v == '' then
				sampSendChat(string.format("/r %s, �������� ���� ��������������. �� ����� 20 ������.", name))
			else
				sampSendChat(string.format("/r [%s]: %s, �������� ���� ��������������. �� ����� 20 ������.", u8:decode(rtag.v), name))
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} ����� � ������ ID �� ��������� � ������� ��� ������ ��� ID.", SCRIPTCOLOR)
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /where [ID].", SCRIPTCOLOR)
	end
end

function cmd_ok(params) -- ����� ��������
	if params:match("^%d+") then
		params = tonumber(params:match("^(%d+)"))
		if sampIsPlayerConnected(params) then
			local name = string.gsub(sampGetPlayerNickname(params), "_", " ")
			if rtag.v == '' then
				sampSendChat(string.format("/r %s, ��� ������ ������!", name))
			else
				sampSendChat(string.format("/r [%s]: %s, ��� ������ ������!", u8:decode(rtag.v), name))
			end
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} ����� � ������ ID �� ��������� � ������� ��� ������ ��� ID.", SCRIPTCOLOR)
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /ok [ID].", SCRIPTCOLOR)
	end
end

function ex_dice(params) -- ��� ���� ����� ����������, ���� �������� - /dice ��������
	if not casinoBlock.v then
		if params:match("^%d+%s%d+") then
			local casinoID, cmoney = params:match("^(%d+)%s(%d+)")
			sampSendChat(string.format("/dice %d %d", casinoID, cmoney))
		else
			sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /dice [ID] [������].", SCRIPTCOLOR)
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} �� �������� ���� ��������! ����� ������� �� �� 89799(Red) ��� 1655(Lime).", SCRIPTCOLOR)
	end
end

function cmd_ud(params) -- ������������� ������ ��� ����
	lua_thread.create(function()
		if isPlayerSoldier then
			if params:match("^%d+") then
				local udID = params:match("^(%d+)")	
				if myID == tonumber(udID) or sampIsPlayerConnected(udID) then
					local name = sampGetPlayerNickname(udID):gsub("_", " ")
					if arm == 1 then
						sampSendChat("/do ������������� U.S. Ground Force � ����� �������.")
					elseif arm == 2 then
						sampSendChat("/do ������������� U.S. Air Force � ����� �������.")
					elseif arm == 3 then
						sampSendChat("/do ������������� U.S. Navy � ����� �������.")
					end
					wait(800)
					sampSendChat(string.format("/me ������ �������������, "..(lady.v and '����������' or '���������').." ��� %s", name))
					wait(800)
					if specUd.v and spOtr.v ~= '' then
						sampSendChat(string.format("/do %s | %s | %s | �������������� ���.������� ���.", mtag, nickName, u8:decode(spOtr.v)))
					else
						sampSendChat(string.format("/do %s | %s | �������������� ���.������� ���.", mtag, nickName))
					end
					wait(800)
					sampSendChat("/me "..(lady.v and '������' or '�����').." ������������� �������")
				else
					sampAddChatMessage("[MoD-Helper]{FFFFFF} ����� � ������ ID �� ��������� � �������.", SCRIPTCOLOR)
				end
			else
				sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /ud [ID].", SCRIPTCOLOR)
			end
		end
	end)
end

function cmd_rn(params) -- OOC ��� /r
	if #params:match("^.*") > 0 then
		params = tostring(params:match("^(.*)"))
		sampSendChat("/r (( "..params.. " ))")
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /rn [text].", SCRIPTCOLOR)
	end
end

function cmd_fn(params) -- OOC ��� /f
	if #params:match("^.*") > 0 then
		params = tostring(params:match("^(.*)"))
		sampSendChat("/f (( "..params.. " ))")
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /fn [text].", SCRIPTCOLOR)
	end
end

function addGangZone(id, left, up, right, down, color) -- �������� ��������
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

function removeGangZone(id) -- �������� ��������
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt16(bs, id)
    raknetEmulRpcReceiveBitStream(120, bs)
    raknetDeleteBitStream(bs)
end

function showInputHelp() -- chatinfo(��� ����) � showinputhelp �� ������ �� �� ��������
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
				"%s :: {%0.6x}%s[%d] {ffffff}:: ����: %s {FFFFFF}:: ����: {ffeeaa}%s{ffffff}",
				os.date("%H:%M:%S"), bit.band(color,0xffffff), nname, mmyID, getStrByState(capsState), string.match(localName, "([^%(]*)")
			)
			
			if chatInfo.v and sampIsLocalPlayerSpawned() and nname ~= nil then renderFontDrawText(inputHelpText, text, fib2, fib, 0xD7FFFFFF) end
			end
		wait(0)
	end
end

function getStrByState(keyState) -- ��������� ������ ��� chatinfo
	if keyState == 0 then
		return "{ffeeaa}����{ffffff}"
	end
	return "{9EC73D}���{ffffff}"
end

function reconnect() -- ��������� ������
	lua_thread.create(function()
		sampSetGamestate(5)
		sampDisconnectWithReason()
		wait(18000) 
		sampSetGamestate(1)
	end)
end

function sampev.onSetCheckpoint(position,radius)
	pX, pY, pZ = getCharCoordinates(playerPed)
	if getDistanceBetweenCoords3d(pX, pY, pZ, 2235.00, 1604.00, 1006.00) < 50 then -- ��������� ������ �� ��������
		if casinoBlock.v then
			sampAddChatMessage("[MoD-Helper]{FFFFFF} ���� ������ - ���� ������! ����� ������� �� �� 89799(Red) ��� 1655(Lime)., ��� ���� � ������!", SCRIPTCOLOR)
			reconnect()
			return false
		end
	end
end

--function random_messages() -- ��������� ���������
--	lua_thread.create(function()
--		local messages = {
--			{ "������ ����� ������� - �� ������, ������� ���� ���� � ���� ����� ������ ������ ����������.", "�� ��������� ��� ������������ � ����� �����, �������� ����." },
--			{ "���� ��� ����������� ������� �������, �� ��� ���� �� �� �������, ���� �����!", "��������� � �������������, ���������� ���� ����, �������� � �������� :)" },
--			{ "� ������ ������������� ����� ���� ������� �� �������� - ���������� � ������������.", "�� ��������� ������ ������ �� �������� �������� � ���������� ��� ����� �������������." },
--			{ "����������� ������� ��������� ������ ������������� � ����������.", "� ����� � ���� �� ���������� ������ �������������� ���������, ������� ����� �� ������ �� �� �������." },
--			{ "���������� ������ ��������� � �������� ������ �� ������ ������� ���.", "���� �� ������ ����� - �������� � ���������� ���� �� ��� ����� �����, ����� �������/����, ��� ������������." },
--			{ "���� �� �������� ������ ��������� �� ���������� - �� ����� �������.", "����� �������� � ������������� ������ � ������������, �������� ���, ������� ���� �����!" },
--			{ "�� ��������, ��� ������� ��������? �� ��������, ��� ���� ������ �������? �� ������ ������ �����?", "���������� �� ��������� �������� � ���.�������, ������� ������� ��������� � �������� ���� ��������, ��� ����� �� ���!" },
--			{ "���� �� �������� �� ��� �������������� ���������� ����� � �������� ��������� - ��������!", "���� ������ ���� ��������� ����� ������������ ����������� � ��������� ������ � �������!"},
--			{ "�������, ��� ������������� ������ ������� ���������� ��������� ���������� �� ���� ������ � ����� �������������!", "������ �����, ���� �� �� ��������� Apache ��� Hydra - �� ���������� ���������� ��� ������� ������� ������������!" },
--			{ "��� ������������� ����� - ������ ���������, �� ����������� � �� ������������ �����.", "���� �� ������ �������� ���� ����� - �� ������� �� ����, ���� ����� ��� ����� ��������� �� ����� �������." },
--			{ "������ ������ ����������, ������� ��� ���� ������� � ������, ���� ������ ��� ����� ��� ������." }
--		}
--		while true do
--			math.randomseed(os.time())
--			wait(300000)
--			for _, v in pairs(messages[math.random(1, #messages)]) do
--				sampAddChatMessage("[MoD-Helper]{FFFFFF} "..v, SCRIPTCOLOR)
--			end
--			wait(3000000)
--		end
--	end)
--end

function cmd_rd(params) -- ������� � /r ���
	if params:match("^.*%s.*") then		
		local post, sost = params:match("^(.*)%s(.*)")
		sampSendChat("/r "..(rtag.v ~= '' and '['..u8:decode(rtag.v)..']' or '').." ����������, ����: "..post.." | ���������: "..sost)

		if screenSave.v then
			lua_thread.create(function()
				sampSendChat((srv <= 9 and '/c 60' or '/time'))
				wait(500)
				memory.setint8(sampGetBase() + 0x119CBC, 1)
			end)
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /rd [����] [���������].", SCRIPTCOLOR)
	end
end

function cmd_fd(params) -- ������� � /f ���
	if params:match("^.*%s.*") then
		local post, sost = params:match("^(.*)%s(.*)")
		if ftag.v == '' then
			sampSendChat(string.format("/f ����������, ����: %s | ���������: %s", post, sost))
		else
			sampSendChat(string.format("/f [%s]: ����������, ����: %s | ���������: %s", u8:decode(ftag.v), post, sost))
		end
		if screenSave.v then
			lua_thread.create(function()
				sampSendChat("/c 60")
				wait(500)
				memory.setint8(sampGetBase() + 0x119CBC, 1)
			end)
		end
	else
		sampAddChatMessage("[MoD-Helper]{FFFFFF} �����������: /fd [����] [���������].", SCRIPTCOLOR)
	end
end

function format_file() --������ ������� � �������
	blackbase = {}
	for line in io.lines(getWorkingDirectory().."\\MoD-Helper\\blacklist.txt") do
		name, reason = line:match("(%a+_?%a+)(.+)")
		temp = {name, reason}
		table.insert(blackbase, temp)
	end
end

function drone() -- ����/������, ���������� ������� ������
	lua_thread.create(function()
		if droneActive then
			sampAddChatMessage("[MoD-Helper]{FFFFFF} �� ������ ������ �� ��� ���������� ������.", SCRIPTCOLOR)
			return
		end
		sampAddChatMessage("[MoD-Helper]{FFFFFF} ���������� ������ ���������: {"..u8:decode(Secondcolor.v).."}W, A, S, D, Space, Shift{FFFFFF}.", SCRIPTCOLOR)
		sampAddChatMessage("[MoD-Helper]{FFFFFF} ������ �����: {"..u8:decode(Secondcolor.v).."}Numpad1, Numpad2, Numpad3{FFFFFF}.", SCRIPTCOLOR)
		sampAddChatMessage("[MoD-Helper]{FFFFFF} �������� ������ �����: {"..u8:decode(Secondcolor.v).."}+(�������), -(���������){FFFFFF}.", SCRIPTCOLOR)
		sampAddChatMessage("[MoD-Helper]{FFFFFF} ���������� ������������� ������ ����� �������� {"..u8:decode(Secondcolor.v).."}Enter{FFFFFF}.", SCRIPTCOLOR)
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

-- ������� �� �����
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