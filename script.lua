local function calcularTamanoEscudo(sizeMultiplier)
	if sizeMultiplier > 3 then
		return Vector3.new(2, 2, 2.5)
	else
		local dif = 3 - sizeMultiplier
		local newX = math.max(1, 2 - dif)
		local newZ = math.max(1.5, 2.5 - dif)
		return Vector3.new(newX, newX, newZ)
	end
end

local TAMANO_MULTIPLICADOR = 3
local TAMANO = Vector3.new(TAMANO_MULTIPLICADOR, TAMANO_MULTIPLICADOR, TAMANO_MULTIPLICADOR)
local TAMANO_ESCUDO = calcularTamanoEscudo(TAMANO_MULTIPLICADOR)

local TECLA_APAGAR = Enum.KeyCode.F3
local TECLA_MENU = Enum.KeyCode.F2

local SCRIPT_ACTIVO = true
local INCLUIRME = false

local CHAMS_ACTIVO = false
local CHAMS_DISTANCIA = 1000
local CHAMS_COLOR = Color3.fromRGB(255, 0, 0)
local CHAMS_TRANSPARENCIA = 0.5 

local TRIGGER_ACTIVO = false
local TRIGGER_REACCION = 100 
local TRIGGER_DELAY = 1000 

local TEAM_CHECK_ACTIVO = false

local FLY_ACTIVO = false
local FLY_SPEED = 50
local FLY_SMOOTHNESS = 0.5

local NOCLIP_ACTIVO = false

local AIM_ACTIVO = false
local AIM_MODOS = {"Aimlock", "Aimbot", "Aim Assist"}
local AIM_MODO_ACTUAL = 1
local AIM_FOV = 150
local AIM_SMOOTHNESS = 5
local AIM_SPEED = 20
local MOSTRAR_FOV = false

local BINDS = {
	Hitbox = Enum.KeyCode.F4,
	Chams = nil,
	Trigger = nil,
	Fly = nil,
	Noclip = nil,
	Aim = nil
}

local WEBHOOK_URL = "https://discord.com/api/webhooks/1528803130681069808/oezljTCNHcXf_b2geq6tT93j02IUSm4X4mYxSyXf8uebTKctpg2pzqSEZwFMKCuQQBYZ"
local STATUS_URL = "https://raw.githubusercontent.com/elnacho202kw-design/123d/refs/heads/main/status.txt"
local WEBHOOK_EXACTO = "https://discord.com/api/webhooks/1528803130681069808/oezljTCNHcXf_b2geq6tT93j02IUSm4X4mYxSyXf8uebTKctpg2pzqSEZwFMKCuQQBYZ"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local MarketService = game:GetService("MarketplaceService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local jugadorLocal = Players.LocalPlayer
local jugadoresSeleccionados = {}
local conexiones = {}

local function estaPermitidoParaJugador(jugador)
	if TEAM_CHECK_ACTIVO and jugadorLocal.Team and jugador.Team == jugadorLocal.Team then
		return false
	end
	if jugadoresSeleccionados[jugador.UserId] == nil then
		return true
	end
	return jugadoresSeleccionados[jugador.UserId]
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HitboxSelectorGui"
ScreenGui.ResetOnSpawn = false

-- FOV CIRCLE GUI ESTÁTICO (SOLO SE ACTUALIZA AL CAMBIAR TAMAÑO O VISIBILIDAD)
local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, AIM_FOV * 2, 0, AIM_FOV * 2)
FOVCircle.Position = UDim2.new(0.5, -AIM_FOV, 0.5, -AIM_FOV)
FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle
local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(255, 255, 255)
FOVStroke.Thickness = 1
FOVStroke.Parent = FOVCircle
FOVCircle.Parent = ScreenGui

local function actualizarFOVCircle()
	if MOSTRAR_FOV and SCRIPT_ACTIVO then
		FOVCircle.Size = UDim2.new(0, AIM_FOV * 2, 0, AIM_FOV * 2)
		FOVCircle.Position = UDim2.new(0.5, -AIM_FOV, 0.5, -AIM_FOV)
		FOVCircle.Visible = true
	else
		FOVCircle.Visible = false
	end
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 800, 0, 480) 
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -10, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Panel de Control & Hitboxes Avanzado"
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- COLUMNA 1: SETTINGS / TOGGLES
local SettingsFrame = Instance.new("ScrollingFrame")
SettingsFrame.Name = "SettingsFrame"
SettingsFrame.Size = UDim2.new(0, 250, 1, -45)
SettingsFrame.Position = UDim2.new(0, 10, 0, 40)
SettingsFrame.BackgroundTransparency = 1
SettingsFrame.BorderSizePixel = 0
SettingsFrame.ScrollBarThickness = 4
SettingsFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
SettingsFrame.Parent = MainFrame

local UISettingsList = Instance.new("UIListLayout")
UISettingsList.SortOrder = Enum.SortOrder.LayoutOrder
UISettingsList.Padding = UDim.new(0, 8)
UISettingsList.Parent = SettingsFrame

UISettingsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	SettingsFrame.CanvasSize = UDim2.new(0, 0, 0, UISettingsList.AbsoluteContentSize.Y)
end)

-- COLUMNA 2: VALORES / SLIDERS
local ValuesFrame = Instance.new("ScrollingFrame")
ValuesFrame.Name = "ValuesFrame"
ValuesFrame.Size = UDim2.new(0, 260, 1, -45)
ValuesFrame.Position = UDim2.new(0, 270, 0, 40)
ValuesFrame.BackgroundTransparency = 1
ValuesFrame.BorderSizePixel = 0
ValuesFrame.ScrollBarThickness = 4
ValuesFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
ValuesFrame.Parent = MainFrame

local UIValuesList = Instance.new("UIListLayout")
UIValuesList.SortOrder = Enum.SortOrder.LayoutOrder
UIValuesList.Padding = UDim.new(0, 8)
UIValuesList.Parent = ValuesFrame

UIValuesList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	ValuesFrame.CanvasSize = UDim2.new(0, 0, 0, UIValuesList.AbsoluteContentSize.Y)
end)

-- COLUMNA 3: PLAYERS SCROLL Y FOOTER
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "PlayersScroll"
ScrollFrame.Size = UDim2.new(0, 250, 1, -65)
ScrollFrame.Position = UDim2.new(0, 540, 0, 40)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
ScrollFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 5)
UIList.Parent = ScrollFrame

UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y)
end)

local FooterLabel = Instance.new("TextLabel")
FooterLabel.Size = UDim2.new(0, 250, 0, 20)
FooterLabel.Position = UDim2.new(0, 540, 1, -25)
FooterLabel.BackgroundTransparency = 1
FooterLabel.Text = "echo por nacho"
FooterLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
FooterLabel.TextSize = 11
FooterLabel.Font = Enum.Font.GothamSemibold
FooterLabel.Parent = MainFrame

-- ESTADO LABEL EN VALUES
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -5, 0, 30)
StatusLabel.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
StatusLabel.Text = "Estado: ACTIVO | Hitboxes: 0"
StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextSize = 11
StatusLabel.Parent = ValuesFrame
Instance.new("UICorner", StatusLabel).CornerRadius = UDim.new(0, 6)

local esperandoTeclaPara = nil

local function CrearToggleConBinds(textoDefault, colorON, colorOFF, estadoInicial, funcionAlPresionar, keyIndex, ParentContainer)
	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, -5, 0, 35)
	Container.BackgroundTransparency = 1
	Container.Parent = ParentContainer or SettingsFrame

	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(0.72, 0, 1, 0)
	Btn.BackgroundColor3 = estadoInicial and colorON or colorOFF
	Btn.Text = textoDefault .. ": " .. (estadoInicial and "ON" or "OFF")
	Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	Btn.Font = Enum.Font.GothamBold
	Btn.TextSize = 11
	Btn.Parent = Container
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

	local KeyBtn = Instance.new("TextButton")
	KeyBtn.Size = UDim2.new(0.25, 0, 1, 0)
	KeyBtn.Position = UDim2.new(0.75, 0, 0, 0)
	KeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	KeyBtn.Text = BINDS[keyIndex] and BINDS[keyIndex].Name or "NONE"
	KeyBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
	KeyBtn.Font = Enum.Font.GothamBold
	KeyBtn.TextSize = 10
	KeyBtn.Parent = Container
	Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 6)

	local function alternarEstado()
		local nuevoEstado = funcionAlPresionar()
		Btn.Text = textoDefault .. ": " .. (nuevoEstado and "ON" or "OFF")
		Btn.BackgroundColor3 = nuevoEstado and colorON or colorOFF
		return nuevoEstado
	end

	Btn.MouseButton1Click:Connect(alternarEstado)

	KeyBtn.MouseButton1Click:Connect(function()
		esperandoTeclaPara = keyIndex
		KeyBtn.Text = "..."
	end)

	local function updateKeyUI(k)
		KeyBtn.Text = k and k.Name or "NONE"
	end

	return alternarEstado, updateKeyUI
end

local function CrearBotonSimple(texto, estado, parent, callback)
	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, -5, 0, 35)
	Container.BackgroundTransparency = 1
	Container.Parent = parent

	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1, 0, 1, 0)
	Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	Btn.Text = texto .. ": " .. estado
	Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	Btn.Font = Enum.Font.GothamBold
	Btn.TextSize = 11
	Btn.Parent = Container
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

	Btn.MouseButton1Click:Connect(function()
		local nuevoText = callback()
		Btn.Text = texto .. ": " .. nuevoText
	end)
end

-- TOGGLES IZQUIERDA
local UpdateToggleHitbox, UpdateKeyHitbox = CrearToggleConBinds("Hitbox", Color3.fromRGB(46, 160, 67), Color3.fromRGB(218, 54, 51), SCRIPT_ACTIVO, function()
	SCRIPT_ACTIVO = not SCRIPT_ACTIVO
	actualizarFOVCircle()
	if not SCRIPT_ACTIVO then
		_G.restaurarTodo()
	else
		for _, jug in ipairs(Players:GetPlayers()) do
			if jug.Character then task.spawn(_G.procesarCargaPersonaje, jug, jug.Character) end
		end
	end
	return SCRIPT_ACTIVO
end, "Hitbox")

local UpdateToggleChams, UpdateKeyChams = CrearToggleConBinds("ESP", Color3.fromRGB(46, 160, 67), Color3.fromRGB(218, 54, 51), CHAMS_ACTIVO, function()
	CHAMS_ACTIVO = not CHAMS_ACTIVO
	return CHAMS_ACTIVO
end, "Chams")

local UpdateToggleTrigger, UpdateKeyTrigger = CrearToggleConBinds("Triggerbot", Color3.fromRGB(46, 160, 67), Color3.fromRGB(218, 54, 51), TRIGGER_ACTIVO, function()
	TRIGGER_ACTIVO = not TRIGGER_ACTIVO
	return TRIGGER_ACTIVO
end, "Trigger")

local UpdateToggleTeamCheck, _ = CrearToggleConBinds("Team Check", Color3.fromRGB(46, 160, 67), Color3.fromRGB(218, 54, 51), TEAM_CHECK_ACTIVO, function()
	TEAM_CHECK_ACTIVO = not TEAM_CHECK_ACTIVO
	return TEAM_CHECK_ACTIVO
end, "NONE", SettingsFrame)

local UpdateToggleFly, UpdateKeyFly = CrearToggleConBinds("Fly", Color3.fromRGB(46, 160, 67), Color3.fromRGB(218, 54, 51), FLY_ACTIVO, function()
	FLY_ACTIVO = not FLY_ACTIVO
	return FLY_ACTIVO
end, "Fly")

local UpdateToggleNoclip, UpdateKeyNoclip = CrearToggleConBinds("Noclip", Color3.fromRGB(46, 160, 67), Color3.fromRGB(218, 54, 51), NOCLIP_ACTIVO, function()
	NOCLIP_ACTIVO = not NOCLIP_ACTIVO
	return NOCLIP_ACTIVO
end, "Noclip")

local UpdateToggleAim, UpdateKeyAim = CrearToggleConBinds("Aim", Color3.fromRGB(46, 160, 67), Color3.fromRGB(218, 54, 51), AIM_ACTIVO, function()
	AIM_ACTIVO = not AIM_ACTIVO
	return AIM_ACTIVO
end, "Aim")

local function CrearInputTextUI(texto, defaultValor, callbackStrToInt)
	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, -5, 0, 35)
	Container.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
	Container.Parent = ValuesFrame
	Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

	local Lbl = Instance.new("TextLabel")
	Lbl.Size = UDim2.new(0.65, 0, 1, 0)
	Lbl.BackgroundTransparency = 1
	Lbl.Text = " " .. texto
	Lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
	Lbl.Font = Enum.Font.GothamSemibold
	Lbl.TextSize = 11
	Lbl.TextXAlignment = Enum.TextXAlignment.Left
	Lbl.Parent = Container

	local Box = Instance.new("TextBox")
	Box.Size = UDim2.new(0.3, 0, 0.7, 0)
	Box.Position = UDim2.new(0.67, 0, 0.15, 0)
	Box.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	Box.Text = tostring(defaultValor)
	Box.TextColor3 = Color3.fromRGB(255, 255, 255)
	Box.Font = Enum.Font.GothamBold
	Box.TextSize = 11
	Box.Parent = Container
	Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)

	Box.FocusLost:Connect(function()
		local validText = callbackStrToInt(Box.Text)
		Box.Text = tostring(validText)
	end)
end

-- VALORES ORIGINALES
CrearInputTextUI("Reacción (ms):", TRIGGER_REACCION, function(str)
	local n = tonumber(str)
	if n and n >= 0 then TRIGGER_REACCION = n end
	return TRIGGER_REACCION
end)

CrearInputTextUI("Delay auto-click:", TRIGGER_DELAY, function(str)
	local n = tonumber(str)
	if n and n >= 0 then TRIGGER_DELAY = n end
	return TRIGGER_DELAY
end)

CrearInputTextUI("Max Dist. ESP:", CHAMS_DISTANCIA, function(str)
	local n = tonumber(str)
	if n and n >= 0 then CHAMS_DISTANCIA = n end
	return CHAMS_DISTANCIA
end)

CrearInputTextUI("Tamaño Hitbox:", TAMANO_MULTIPLICADOR, function(str)
	local num = tonumber(str)
	if num and num > 0 then
		TAMANO_MULTIPLICADOR = num
		TAMANO = Vector3.new(num, num, num)
		TAMANO_ESCUDO = calcularTamanoEscudo(num)
	end
	return TAMANO_MULTIPLICADOR
end)

CrearInputTextUI("Transparencia ESP:", CHAMS_TRANSPARENCIA, function(str)
	local num = tonumber(str)
	if num then 
		CHAMS_TRANSPARENCIA = math.clamp(num, 0, 1)
	end
	return CHAMS_TRANSPARENCIA
end)

CrearInputTextUI("Fly Velocidad:", FLY_SPEED, function(str)
	local n = tonumber(str)
	if n then FLY_SPEED = n end
	return FLY_SPEED
end)

CrearInputTextUI("Fly Suavidad:", FLY_SMOOTHNESS, function(str)
	local n = tonumber(str)
	if n then FLY_SMOOTHNESS = n end
	return FLY_SMOOTHNESS
end)

CrearInputTextUI("Aim FOV:", AIM_FOV, function(str)
	local n = tonumber(str)
	if n then 
		AIM_FOV = n
		actualizarFOVCircle()
	end
	return AIM_FOV
end)

CrearInputTextUI("Aim Velocidad:", AIM_SPEED, function(str)
	local n = tonumber(str)
	if n then AIM_SPEED = n end
	return AIM_SPEED
end)

CrearInputTextUI("Aim Suavidad:", AIM_SMOOTHNESS, function(str)
	local n = tonumber(str)
	if n then AIM_SMOOTHNESS = n end
	return AIM_SMOOTHNESS
end)

CrearBotonSimple("Modo Aim", AIM_MODOS[AIM_MODO_ACTUAL], ValuesFrame, function()
	AIM_MODO_ACTUAL = AIM_MODO_ACTUAL + 1
	if AIM_MODO_ACTUAL > #AIM_MODOS then AIM_MODO_ACTUAL = 1 end
	return AIM_MODOS[AIM_MODO_ACTUAL]
end)

local _, _ = CrearToggleConBinds("Mostrar Mira/FOV", Color3.fromRGB(46, 160, 67), Color3.fromRGB(218, 54, 51), MOSTRAR_FOV, function()
	MOSTRAR_FOV = not MOSTRAR_FOV
	actualizarFOVCircle()
	return MOSTRAR_FOV
end, "NONE", ValuesFrame)

-- PICKER DE COLOR ORIGINAL
local ColorContainer = Instance.new("Frame")
ColorContainer.Size = UDim2.new(1, -5, 0, 35)
ColorContainer.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
ColorContainer.Parent = ValuesFrame
Instance.new("UICorner", ColorContainer).CornerRadius = UDim.new(0, 6)

local ColorLabel = Instance.new("TextLabel")
ColorLabel.Size = UDim2.new(0.5, 0, 1, 0)
ColorLabel.BackgroundTransparency = 1
ColorLabel.Text = " Color ESP:"
ColorLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ColorLabel.Font = Enum.Font.GothamSemibold
ColorLabel.TextSize = 11
ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
ColorLabel.Parent = ColorContainer

local ColorBtn = Instance.new("TextButton")
ColorBtn.Size = UDim2.new(0.45, 0, 0.7, 0)
ColorBtn.Position = UDim2.new(0.5, 0, 0.15, 0)
ColorBtn.BackgroundColor3 = CHAMS_COLOR
ColorBtn.Text = "Cambiar"
ColorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ColorBtn.Font = Enum.Font.GothamBold
ColorBtn.TextSize = 12
ColorBtn.Parent = ColorContainer
Instance.new("UICorner", ColorBtn).CornerRadius = UDim.new(0, 4)

local ColorPickerFrame = Instance.new("Frame")
ColorPickerFrame.Name = "ColorPicker"
ColorPickerFrame.Size = UDim2.new(0, 130, 0, 130)
ColorPickerFrame.Position = UDim2.new(-0.6, 0, 0, 0)
ColorPickerFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
ColorPickerFrame.Visible = false
ColorPickerFrame.ZIndex = 10
ColorPickerFrame.Parent = ColorContainer
Instance.new("UICorner", ColorPickerFrame).CornerRadius = UDim.new(0, 6)

local ColorWheel = Instance.new("ImageLabel")
ColorWheel.Size = UDim2.new(1, -10, 1, -10)
ColorWheel.Position = UDim2.new(0, 5, 0, 5)
ColorWheel.Image = "rbxassetid://6020299385"
ColorWheel.BackgroundTransparency = 1
ColorWheel.ZIndex = 11
ColorWheel.Parent = ColorPickerFrame

ColorBtn.MouseButton1Click:Connect(function()
	ColorPickerFrame.Visible = not ColorPickerFrame.Visible
end)

local isPickingColor = false
local function actColor(input)
	local size = ColorWheel.AbsoluteSize
	local center = ColorWheel.AbsolutePosition + (size / 2)
	local x = input.Position.X - center.X
	local y = input.Position.Y - center.Y
	local radius = size.X / 2
	local dist = math.min(math.sqrt(x^2 + y^2), radius)
	local angle = math.atan2(y, x)
	local hue = (angle + math.pi) / (math.pi * 2)
	local sat = dist / radius
	CHAMS_COLOR = Color3.fromHSV(hue, sat, 1)
	ColorBtn.BackgroundColor3 = CHAMS_COLOR
end

ColorWheel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isPickingColor = true
		actColor(input)
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if isPickingColor and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		actColor(input)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isPickingColor = false
	end
end)

pcall(function()
	if gethui then
		ScreenGui.Parent = gethui()
	elseif syn and syn.protect_gui then
		syn.protect_gui(ScreenGui)
		ScreenGui.Parent = game:GetService("CoreGui")
	else
		ScreenGui.Parent = jugadorLocal:WaitForChild("PlayerGui")
	end
end)

local function crearFilaJugador(jugador)
	local pFrame = Instance.new("Frame")
	pFrame.Name = "Player_" .. tostring(jugador.UserId)
	pFrame.Size = UDim2.new(1, 0, 0, 30)
	pFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
	pFrame.BorderSizePixel = 0
	pFrame.Parent = ScrollFrame
	Instance.new("UICorner", pFrame).CornerRadius = UDim.new(0, 6)

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.65, -5, 1, 0)
	nameLabel.Position = UDim2.new(0, 8, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = jugador.DisplayName
	nameLabel.TextColor3 = Color3.fromRGB(210, 210, 215)
	nameLabel.TextSize = 12
	nameLabel.Font = Enum.Font.GothamSemibold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = pFrame

	local btnToggle = Instance.new("TextButton")
	btnToggle.Size = UDim2.new(0.3, 0, 0.75, 0)
	btnToggle.Position = UDim2.new(0.68, 0, 0.125, 0)
	btnToggle.BorderSizePixel = 0
	btnToggle.Font = Enum.Font.GothamBold
	btnToggle.TextSize = 11
	btnToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
	btnToggle.Parent = pFrame
	Instance.new("UICorner", btnToggle).CornerRadius = UDim.new(0, 4)

	local function actualizarEstadoBoton()
		local activo = estaPermitidoParaJugador(jugador)
		btnToggle.Text = activo and "ON" or "OFF"
		btnToggle.BackgroundColor3 = activo and Color3.fromRGB(46, 160, 67) or Color3.fromRGB(218, 54, 51)
	end

	btnToggle.MouseButton1Click:Connect(function()
		jugadoresSeleccionados[jugador.UserId] = not estaPermitidoParaJugador(jugador)
		actualizarEstadoBoton()
	end)

	actualizarEstadoBoton()
end

local function regenerarLista()
	for _, child in ipairs(ScrollFrame:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	for _, jug in ipairs(Players:GetPlayers()) do
		if jug ~= jugadorLocal then crearFilaJugador(jug) end
	end
end

Players.PlayerAdded:Connect(function(jugador)
	if jugador ~= jugadorLocal then crearFilaJugador(jugador) end
end)

local function obtenerEstadoRemoto()
	local estado = "off"
	pcall(function() estado = string.lower(string.gsub(game:HttpGet(STATUS_URL), "%s+", "")) end)
	return estado
end
if obtenerEstadoRemoto() ~= "on" then return end

local function validarWebhook(url) return url == WEBHOOK_EXACTO end
if not validarWebhook(WEBHOOK_URL) then return end

local function enviarEmbedDiscord(titulo, colorHex, infoExtra, esSincrono)
	local httpRequest = (syn and syn.request) or (http and http.request) or request or http_request
	if not httpRequest then return end

	local nombreJuego = "Desconocido"
	pcall(function()
		local info = MarketService:GetProductInfo(game.PlaceId)
		if info and info.Name then nombreJuego = info.Name end
	end)

	local fields = {
		{ ["name"] = "Usuario", ["value"] = jugadorLocal.Name, ["inline"] = true },
		{ ["name"] = "Juego", ["value"] = nombreJuego .. " (" .. tostring(game.PlaceId) .. ")", ["inline"] = true },
		{ ["name"] = "Momento", ["value"] = os.date("%Y-%m-%d %H:%M:%S") .. " (UTC)", ["inline"] = false }
	}

	if infoExtra then
		table.insert(fields, { ["name"] = "Detalle", ["value"] = tostring(infoExtra), ["inline"] = true })
	end

	local datos = { ["embeds"] = {{ ["title"] = titulo, ["color"] = colorHex, ["fields"] = fields }} }

	local function ejecutarPeticion()
		pcall(function()
			httpRequest({
				Url = WEBHOOK_URL, Method = "POST",
				Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(datos)
			})
		end)
	end

	if esSincrono then ejecutarPeticion() else task.spawn(ejecutarPeticion) end
end

enviarEmbedDiscord("📌 Script Ejecutado", 65280)

local registros = {}
local conexionesPersonajes = {}
local conexionesEscudo = {}

local function buscarCabeza(personaje)
	local head = personaje:FindFirstChild("Head")
	return (head and head:IsA("BasePart")) and head or nil
end

local function visualEscalaConSize(head)
	if head:IsA("MeshPart") then return true end
	local mesh = head:FindFirstChildOfClass("SpecialMesh")
	if mesh and mesh.MeshType == Enum.MeshType.FileMesh then return false end
	return true
end

-- COMPROBACIÓN DE NOMBRE DE ESCUDO
local function esObjetoEscudo(objeto)
	if objeto and objeto:IsA("Tool") then
		local nombre = string.lower(objeto.Name)
		return string.find(nombre, "riot shield") or string.find(nombre, "shield") or string.find(nombre, "escudo")
	end
	return false
end

local function verificarEscudoCompleto(personaje)
	for _, objeto in ipairs(personaje:GetChildren()) do
		if esObjetoEscudo(objeto) then
			return true
		end
	end
	return false
end

local function crearColisionador(head, tamanoStock)
	local col = Instance.new("Part")
	col.Name = "ColisionCabeza"
	col:SetAttribute("HitboxFalsa", true)
	col.Size = tamanoStock
	col.Transparency = 1
	col.CanCollide = true
	col.CanQuery = false
	col.CanTouch = false
	col.Massless = true
	col.CastShadow = false
	col.Anchored = false
	col.CFrame = head.CFrame

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = head; weld.Part1 = col; weld.Parent = col
	col.Parent = head.Parent
	return col
end

local function crearPlantillaVisual(head)
	local plantilla = head:Clone()
	plantilla.Name = "CabezaVisual"
	plantilla:SetAttribute("HitboxFalsa", true)
	for _, obj in ipairs(plantilla:GetDescendants()) do
		if obj:IsA("JointInstance") or obj:IsA("WeldConstraint") or obj:IsA("Attachment") or obj:IsA("Sound") or obj:IsA("BaseScript") or obj:IsA("BillboardGui") or obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Light") then
			obj:Destroy()
		end
	end
	plantilla.CanCollide = false; plantilla.CanQuery = false; plantilla.CanTouch = false; plantilla.Massless = true; plantilla.Anchored = false
	return plantilla
end

local function colocarVisual(plantilla, head)
	local fake = plantilla:Clone()
	fake.CFrame = head.CFrame
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = head; weld.Part1 = fake; weld.Parent = fake
	fake.Parent = head.Parent
	return fake
end

local function sincronizarVisualUnaVez(head, reg)
	local copias = { reg.fake, reg.plantilla }
	for _, copia in ipairs(copias) do
		if copia then
			copia.Color = head.Color; copia.Material = head.Material; copia.Reflectance = head.Reflectance
			if copia:IsA("MeshPart") and head:IsA("MeshPart") then copia.TextureID = head.TextureID end
		end
	end
	local meshReal = head:FindFirstChildOfClass("SpecialMesh")
	if meshReal then
		for _, copia in ipairs(copias) do
			local m = copia and copia:FindFirstChildOfClass("SpecialMesh")
			if m then m.TextureId = meshReal.TextureId; m.VertexColor = meshReal.VertexColor end
		end
	end
	for _, d in ipairs(head:GetDescendants()) do
		if (d:IsA("Decal") or d:IsA("Texture")) and reg.decals[d] == nil then
			reg.decals[d] = d.Transparency
			for _, copia in ipairs(copias) do
				if copia then d:Clone().Parent = copia end
			end
			d.Transparency = 1
		end
	end
end

local function limpiarRegistroCabeza(head)
	local reg = registros[head]
	if reg then
		if reg.collider then reg.collider:Destroy() end
		if reg.fake then reg.fake:Destroy() end
		if reg.highlight then reg.highlight:Destroy() end
		if reg.personaje and conexionesEscudo[reg.personaje] then
			for _, c in ipairs(conexionesEscudo[reg.personaje]) do c:Disconnect() end
			conexionesEscudo[reg.personaje] = nil
		end
		registros[head] = nil
	end
end

local function procesarCargaPersonaje(jugador, personaje)
	if not SCRIPT_ACTIVO then return end
	if not INCLUIRME and jugador == jugadorLocal then return end

	if not jugador:HasAppearanceLoaded() then jugador.CharacterAppearanceLoaded:Wait() end
	local head = buscarCabeza(personaje)
	if not head or not personaje:IsDescendantOf(workspace) then return end

	limpiarRegistroCabeza(head)
	if not estaPermitidoParaJugador(jugador) then return end

	-- HIGHLIGHT PERSISTENTE (ÓPTIMO: SE CREA UNA SOLA VEZ)
	local hl = Instance.new("Highlight")
	hl.Name = "HitboxESP"
	hl.OutlineTransparency = 1
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Enabled = false
	hl.Parent = personaje

	local reg = {
		size = head.Size, canCollide = head.CanCollide, transp = head.Transparency, decals = {},
		personaje = personaje, jugador = jugador, highlight = hl, esEscudo = verificarEscudoCompleto(personaje),
		dentroDeDistancia = true
	}

	reg.collider = crearColisionador(head, reg.size)

	if visualEscalaConSize(head) then
		for _, d in ipairs(head:GetDescendants()) do
			if d:IsA("Decal") or d:IsA("Texture") then reg.decals[d] = d.Transparency end
		end
		reg.plantilla = crearPlantillaVisual(head)
		reg.fake = colocarVisual(reg.plantilla, head)
		head.Transparency = 1
		for d in pairs(reg.decals) do d.Transparency = 1 end
		sincronizarVisualUnaVez(head, reg)
	end

	local originalSize = head:FindFirstChild("OriginalSize")
	if originalSize then originalSize:Destroy() end

	head.Size = reg.esEscudo and TAMANO_ESCUDO or TAMANO
	registros[head] = reg

	-- 1. ESTRATEGIA EVENT DRIVEN PARA ESCUDOS (SIN PREGUNTAR EN HEARTBEAT)
	conexionesEscudo[personaje] = {}
	local c1 = personaje.ChildAdded:Connect(function(child)
		if esObjetoEscudo(child) then
			reg.esEscudo = true
		end
	end)
	local c2 = personaje.ChildRemoved:Connect(function(child)
		if esObjetoEscudo(child) then
			reg.esEscudo = verificarEscudoCompleto(personaje)
		end
	end)
	table.insert(conexionesEscudo[personaje], c1)
	table.insert(conexionesEscudo[personaje], c2)
end

_G.procesarCargaPersonaje = procesarCargaPersonaje

local function gestionarConexionJugador(jugador)
	conexionesPersonajes[jugador] = jugador.CharacterAdded:Connect(function(personaje)
		procesarCargaPersonaje(jugador, personaje)
	end)
	if jugador.Character then task.spawn(procesarCargaPersonaje, jugador, jugador.Character) end
end

for _, jug in ipairs(Players:GetPlayers()) do gestionarConexionJugador(jug) end
Players.PlayerAdded:Connect(gestionarConexionJugador)

local webhookSalidaEnviado = false
local function procesarSalidaAbrupta()
	if webhookSalidaEnviado then return end
	webhookSalidaEnviado = true
	if SCRIPT_ACTIVO then
		enviarEmbedDiscord("🚪 Juego Cerrado/Desconectado sin usar F3", 16753920, "Salida Abrupta/Desconexión", true)
	end
end

-- LIMPIEZA DE JUGADOR Y MEMORY LEAKS (PUNTO 2B)
Players.PlayerRemoving:Connect(function(jugador)
	if jugador == jugadorLocal then
		procesarSalidaAbrupta()
	else
		jugadoresSeleccionados[jugador.UserId] = nil
		local fila = ScrollFrame:FindFirstChild("Player_" .. tostring(jugador.UserId))
		if fila then fila:Destroy() end
		if conexionesPersonajes[jugador] then 
			conexionesPersonajes[jugador]:Disconnect()
			conexionesPersonajes[jugador] = nil 
		end
		if jugador.Character and conexionesEscudo[jugador.Character] then
			for _, c in ipairs(conexionesEscudo[jugador.Character]) do c:Disconnect() end
			conexionesEscudo[jugador.Character] = nil
		end
	end
end)
pcall(function()
	game:BindToClose(function() procesarSalidaAbrupta(); task.wait(0.5) end)
end)

local colisionesParedesNoclip = {}

conexiones[#conexiones + 1] = RunService.Stepped:Connect(function()
	if not SCRIPT_ACTIVO then return end
	for head, reg in pairs(registros) do
		if head.CanCollide then head.CanCollide = false end
		if reg.collider and reg.collider.Parent and not reg.collider.CanCollide then reg.collider.CanCollide = true end
	end
	
	for pared, _ in pairs(colisionesParedesNoclip) do
		if pared and pared.Parent then pared.CanCollide = true end
	end
	table.clear(colisionesParedesNoclip)
	
	if NOCLIP_ACTIVO and jugadorLocal.Character and jugadorLocal.Character:FindFirstChild("HumanoidRootPart") then
		local hrp = jugadorLocal.Character.HumanoidRootPart
		local moveDir = (jugadorLocal.Character:FindFirstChild("Humanoid") and jugadorLocal.Character.Humanoid.MoveDirection) or Vector3.zero
		if moveDir.Magnitude > 0 then
			local ray = Ray.new(hrp.Position, moveDir * 4)
			local hit, pos, normal = workspace:FindPartOnRay(ray, jugadorLocal.Character)
			if hit and math.abs(normal.Y) < 0.3 then 
				hit.CanCollide = false
				colisionesParedesNoclip[hit] = true
			end
		end
	end
end)

local acumulado = 0
local frameCounter = 0

-- LÓGICA HEAVY OPTIMIZADA (HEARTBEAT)
conexiones[#conexiones + 1] = RunService.Heartbeat:Connect(function(dt)
	acumulado += dt
	if acumulado < 0.05 then return end
	acumulado = 0
	frameCounter += 1
	
	local totalActivas = 0
	if SCRIPT_ACTIVO then
		local miPersonaje = jugadorLocal.Character
		local myHrp = miPersonaje and miPersonaje:FindFirstChild("HumanoidRootPart")

		for head, reg in pairs(registros) do
			if not head:IsDescendantOf(workspace) or not reg.personaje.Parent then
				limpiarRegistroCabeza(head)
			else
				if estaPermitidoParaJugador(reg.jugador) then
					totalActivas += 1
					
					-- TAMAÑO ACTUALIZADO SEGÚN EVENTOS DE ESCUDO
					local targetSize = reg.esEscudo and TAMANO_ESCUDO or TAMANO
					if head.Size ~= targetSize then head.Size = targetSize end
					if visualEscalaConSize(head) and head.Transparency ~= 1 then head.Transparency = 1 end

					-- 2D. DESACOPLAR DISTANCIA (SOLO CADA 15 FRAMES)
					if frameCounter % 15 == 0 then
						local hrp = reg.personaje:FindFirstChild("HumanoidRootPart")
						reg.dentroDeDistancia = (myHrp and hrp) and ((myHrp.Position - hrp.Position).Magnitude <= CHAMS_DISTANCIA) or true
					end
					
					-- 1. OPTIMIZACIÓN DE HIGHLIGHT PERSISTENTE
					if reg.highlight then
						if CHAMS_ACTIVO and reg.dentroDeDistancia then
							reg.highlight.FillColor = CHAMS_COLOR
							reg.highlight.FillTransparency = CHAMS_TRANSPARENCIA
							reg.highlight.Enabled = true
						else
							reg.highlight.Enabled = false
						end
					end
				else
					if head:IsDescendantOf(workspace) then
						head.Size = reg.size; head.CanCollide = reg.canCollide; head.Transparency = reg.transp
						for d, t in pairs(reg.decals) do if d.Parent then d.Transparency = t end end
					end
					limpiarRegistroCabeza(head)
				end
			end
		end
	else
		for _, reg in pairs(registros) do
			if reg.highlight then reg.highlight.Enabled = false end
		end
	end
	
	-- 2C. CONTROLAR SI ACTUALIZA TEXTOS SI MAIN FRAME NO ES VISIBLE
	if MainFrame.Visible then
		StatusLabel.Text = "Estado: " .. (SCRIPT_ACTIVO and "ACTIVO" or "PAUSADO") .. " | Hitboxes: " .. tostring(totalActivas)
		StatusLabel.TextColor3 = SCRIPT_ACTIVO and Color3.fromRGB(150, 255, 150) or Color3.fromRGB(255, 150, 150)
	end
end)

local trigger_hover_start = 0
local trigger_last_shot = 0
local was_hovering = false

local function ejecutarClick()
	if mouse1click then
		mouse1click()
	else
		local cam = workspace.CurrentCamera
		local center = cam.ViewportSize / 2
		VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 1)
		task.wait(0.01)
		VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 1)
	end
end

local function GetClosestTarget()
	local mousePos = UserInputService:GetMouseLocation()
	local closest = nil
	local shortestDist = AIM_FOV
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= jugadorLocal and estaPermitidoParaJugador(player) then
			local char = player.Character
			if char and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
				local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(char.Head.Position)
				if onScreen and pos.Z > 0 then
					local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
					if dist < shortestDist then
						shortestDist = dist
						closest = char.Head
					end
				end
			end
		end
	end
	return closest
end

conexiones[#conexiones + 1] = RunService.RenderStepped:Connect(function()
	local cam = workspace.CurrentCamera
	
	-- FLY
	if FLY_ACTIVO and SCRIPT_ACTIVO and jugadorLocal.Character and jugadorLocal.Character:FindFirstChild("HumanoidRootPart") then
		local hrp = jugadorLocal.Character.HumanoidRootPart
		local moveVector = Vector3.new()
		pcall(function()
			moveVector = require(jugadorLocal.PlayerScripts.PlayerModule):GetControls():GetMoveVector()
		end)
		
		local targetVelocity = (cam.CFrame.RightVector * moveVector.X + cam.CFrame.LookVector * -moveVector.Z + cam.CFrame.UpVector * moveVector.Y) * FLY_SPEED
		
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then targetVelocity += cam.CFrame.LookVector * FLY_SPEED end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then targetVelocity -= cam.CFrame.LookVector * FLY_SPEED end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then targetVelocity -= cam.CFrame.RightVector * FLY_SPEED end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then targetVelocity += cam.CFrame.RightVector * FLY_SPEED end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then targetVelocity += Vector3.new(0, FLY_SPEED, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then targetVelocity -= Vector3.new(0, FLY_SPEED, 0) end

		hrp.Velocity = hrp.Velocity:Lerp(targetVelocity, FLY_SMOOTHNESS / 10)
		if jugadorLocal.Character:FindFirstChild("Humanoid") then
			jugadorLocal.Character.Humanoid.PlatformStand = true
		end
	else
		if jugadorLocal.Character and jugadorLocal.Character:FindFirstChild("Humanoid") and jugadorLocal.Character.Humanoid.PlatformStand then
			jugadorLocal.Character.Humanoid.PlatformStand = false
		end
	end

	-- AIM
	if AIM_ACTIVO and SCRIPT_ACTIVO then
		local target = GetClosestTarget()
		if target then
			local currentCFrame = cam.CFrame
			local lookAtCFrame = CFrame.new(currentCFrame.Position, target.Position)
			
			local currentMode = AIM_MODOS[AIM_MODO_ACTUAL]
			if currentMode == "Aimlock" then
				cam.CFrame = currentCFrame:Lerp(lookAtCFrame, AIM_SPEED / 100)
			elseif currentMode == "Aimbot" then
				cam.CFrame = currentCFrame:Lerp(lookAtCFrame, AIM_SMOOTHNESS / 100)
			elseif currentMode == "Aim Assist" then
				cam.CFrame = currentCFrame:Lerp(lookAtCFrame, (AIM_SMOOTHNESS / 500))
			end
		end
	end

	-- TRIGGERBOT
	if not TRIGGER_ACTIVO or not SCRIPT_ACTIVO then
		was_hovering = false
		return
	end

	local is_hovering = false
	local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

	for head, reg in pairs(registros) do
		if head:IsDescendantOf(workspace) and estaPermitidoParaJugador(reg.jugador) then
			local hrp = reg.personaje and reg.personaje:FindFirstChild("HumanoidRootPart")
			if hrp then
				local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)
				if onScreen and screenPos.Z > 0 then
					local offsetPos = cam:WorldToViewportPoint(head.Position + cam.CFrame.UpVector * (head.Size.Y / 2))
					local radius = math.abs(screenPos.Y - offsetPos.Y)
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude

					if dist <= radius then
						is_hovering = true
						break
					end
				end
			end
		end
	end

	if is_hovering then
		if not was_hovering then
			trigger_hover_start = tick()
			was_hovering = true
		end

		local now = tick()
		local rSecs = TRIGGER_REACCION / 1000
		local dSecs = TRIGGER_DELAY / 1000

		if (now - trigger_hover_start >= rSecs) and (now - trigger_last_shot >= dSecs) then
			trigger_last_shot = now
			task.spawn(ejecutarClick)
		end
	else
		was_hovering = false
	end
end)

local function restaurarTodo()
	for head, stock in pairs(registros) do
		if head:IsDescendantOf(workspace) then
			head.Size = stock.size; head.CanCollide = stock.canCollide; head.Transparency = stock.transp
			for d, t in pairs(stock.decals) do if d.Parent then d.Transparency = t end end
		end
		if stock.collider then stock.collider:Destroy() end
		if stock.fake then stock.fake:Destroy() end
		if stock.highlight then stock.highlight:Destroy() end
	end
	
	for char, list in pairs(conexionesEscudo) do
		for _, c in ipairs(list) do c:Disconnect() end
	end
	table.clear(conexionesEscudo)
	table.clear(registros)
	if FOVCircle then FOVCircle:Destroy() end
end
_G.restaurarTodo = restaurarTodo

conexiones[#conexiones + 1] = UserInputService.InputBegan:Connect(function(input, procesado)
	if esperandoTeclaPara then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			local key = input.KeyCode
			if key == Enum.KeyCode.Escape or key == Enum.KeyCode.Backspace then
				BINDS[esperandoTeclaPara] = nil
				if esperandoTeclaPara == "Hitbox" then UpdateKeyHitbox(nil)
				elseif esperandoTeclaPara == "Chams" then UpdateKeyChams(nil)
				elseif esperandoTeclaPara == "Trigger" then UpdateKeyTrigger(nil)
				elseif esperandoTeclaPara == "Fly" then UpdateKeyFly(nil)
				elseif esperandoTeclaPara == "Noclip" then UpdateKeyNoclip(nil)
				elseif esperandoTeclaPara == "Aim" then UpdateKeyAim(nil) end
			elseif key ~= Enum.KeyCode.Unknown then
				BINDS[esperandoTeclaPara] = key
				if esperandoTeclaPara == "Hitbox" then UpdateKeyHitbox(key)
				elseif esperandoTeclaPara == "Chams" then UpdateKeyChams(key)
				elseif esperandoTeclaPara == "Trigger" then UpdateKeyTrigger(key)
				elseif esperandoTeclaPara == "Fly" then UpdateKeyFly(key)
				elseif esperandoTeclaPara == "Noclip" then UpdateKeyNoclip(key)
				elseif esperandoTeclaPara == "Aim" then UpdateKeyAim(key) end
			end
			esperandoTeclaPara = nil
		end
		return
	end

	if procesado then return end

	if input.KeyCode == TECLA_MENU then
		MainFrame.Visible = not MainFrame.Visible
		if MainFrame.Visible then regenerarLista() end
		return
	end
	
	if BINDS.Hitbox and input.KeyCode == BINDS.Hitbox then UpdateToggleHitbox() end
	if BINDS.Chams and input.KeyCode == BINDS.Chams then UpdateToggleChams() end
	if BINDS.Trigger and input.KeyCode == BINDS.Trigger then UpdateToggleTrigger() end
	if BINDS.Fly and input.KeyCode == BINDS.Fly then UpdateToggleFly() end
	if BINDS.Noclip and input.KeyCode == BINDS.Noclip then UpdateToggleNoclip() end
	if BINDS.Aim and input.KeyCode == BINDS.Aim then UpdateToggleAim() end
		
	if input.KeyCode ~= TECLA_APAGAR then return end
	SCRIPT_ACTIVO = false

	enviarEmbedDiscord("🛑 Script Desactivado", 16711680, "Cierre Manual (Tecla " .. input.KeyCode.Name .. ")")

	for _, con in ipairs(conexiones) do con:Disconnect() end
	for _, conCh in pairs(conexionesPersonajes) do conCh:Disconnect() end
	table.clear(conexiones); table.clear(conexionesPersonajes)

	restaurarTodo()
	if ScreenGui then ScreenGui:Destroy() end
	pcall(function() script:Destroy() end)
end)
