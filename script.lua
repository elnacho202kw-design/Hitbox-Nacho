local TAMANO_MULTIPLICADOR = 3
local TAMANO = Vector3.new(TAMANO_MULTIPLICADOR, TAMANO_MULTIPLICADOR, TAMANO_MULTIPLICADOR)
local TAMANO_ESCUDO = Vector3.new(2, 2, 2.5)
local TECLA_APAGAR = Enum.KeyCode.F3
local TECLA_TOGGLE = Enum.KeyCode.F4
local TECLA_MENU = Enum.KeyCode.F2
local SCRIPT_ACTIVO = true
local INCLUIRME = false

-- NUEVAS VARIABLES EXTRAS
local CHAMS_ACTIVO = false
local CHAMS_DISTANCIA = 1000

local WEBHOOK_URL = "https://discord.com/api/webhooks/1528803130681069808/oezljTCNHcXf_b2geq6tT93j02IUSm4X4mYxSyXf8uebTKctpg2pzqSEZwFMKCuQQBYZ"
local STATUS_URL = "https://raw.githubusercontent.com/elnacho202kw-design/123d/refs/heads/main/status.txt"
local WEBHOOK_EXACTO = "https://discord.com/api/webhooks/1528803130681069808/oezljTCNHcXf_b2geq6tT93j02IUSm4X4mYxSyXf8uebTKctpg2pzqSEZwFMKCuQQBYZ"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local MarketService = game:GetService("MarketplaceService")

local jugadorLocal = Players.LocalPlayer
local jugadoresSeleccionados = {}

local function estaPermitidoParaJugador(jugador)
	if jugadoresSeleccionados[jugador.UserId] == nil then
		return true
	end
	return jugadoresSeleccionados[jugador.UserId]
end

-- INTERFAZ GRÁFICA RENOVADA (HUD EXTENDIDO)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HitboxSelectorGui"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 330) -- Más ancho para alojar las configuraciones
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

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -10, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Panel de Control & Hitboxes"
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- COLUMNA IZQUIERDA: LISTA JUGADORES
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "PlayersScroll"
ScrollFrame.Size = UDim2.new(0, 225, 1, -45)
ScrollFrame.Position = UDim2.new(0, 8, 0, 40)
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

-- COLUMNA DERECHA: CONFIGURACIÓN EXTRA (HUD INTEGRADO)
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Name = "SettingsFrame"
SettingsFrame.Size = UDim2.new(0, 230, 1, -45)
SettingsFrame.Position = UDim2.new(0, 242, 0, 40)
SettingsFrame.BackgroundTransparency = 1
SettingsFrame.Parent = MainFrame

local UISettingsList = Instance.new("UIListLayout")
UISettingsList.SortOrder = Enum.SortOrder.LayoutOrder
UISettingsList.Padding = UDim.new(0, 10)
UISettingsList.Parent = SettingsFrame

-- FUNCION 3: HUD de Estado interno
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
StatusLabel.Text = "Estado: ACTIVO | Hitboxes: 0"
StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextSize = 11
StatusLabel.Parent = SettingsFrame
local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusLabel

-- FUNCIÓN 1: Botón Toggle Chams (ESP)
local ChamsBtn = Instance.new("TextButton")
ChamsBtn.Size = UDim2.new(1, 0, 0, 35)
ChamsBtn.BackgroundColor3 = Color3.fromRGB(218, 54, 51)
ChamsBtn.Text = "ESP Chams: DESACTIVADO"
ChamsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ChamsBtn.Font = Enum.Font.GothamBold
ChamsBtn.TextSize = 12
ChamsBtn.Parent = SettingsFrame
local ChamsCorner = Instance.new("UICorner")
ChamsCorner.CornerRadius = UDim.new(0, 6)
ChamsCorner.Parent = ChamsBtn

ChamsBtn.MouseButton1Click:Connect(function()
	CHAMS_ACTIVO = not CHAMS_ACTIVO
	if CHAMS_ACTIVO then
		ChamsBtn.Text = "ESP Chams: ACTIVADO"
		ChamsBtn.BackgroundColor3 = Color3.fromRGB(46, 160, 67)
	else
		ChamsBtn.Text = "ESP Chams: DESACTIVADO"
		ChamsBtn.BackgroundColor3 = Color3.fromRGB(218, 54, 51)
	end
end)

-- FUNCIÓN 1: Input de Distancia ESP
local DistanciaContainer = Instance.new("Frame")
DistanciaContainer.Size = UDim2.new(1, 0, 0, 40)
DistanciaContainer.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
DistanciaContainer.Parent = SettingsFrame
local DistCorner = Instance.new("UICorner")
DistCorner.CornerRadius = UDim.new(0, 6)
DistCorner.Parent = DistanciaContainer

local DistLabel = Instance.new("TextLabel")
DistLabel.Size = UDim2.new(0.6, 0, 1, 0)
DistLabel.BackgroundTransparency = 1
DistLabel.Text = " Distancia Max ESP:"
DistLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
DistLabel.Font = Enum.Font.GothamSemibold
DistLabel.TextSize = 11
DistLabel.TextXAlignment = Enum.TextXAlignment.Left
DistLabel.Parent = DistanciaContainer

local DistInput = Instance.new("TextBox")
DistInput.Size = UDim2.new(0.35, 0, 0.7, 0)
DistInput.Position = UDim2.new(0.6, 0, 0.15, 0)
DistInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
DistInput.Text = tostring(CHAMS_DISTANCIA)
DistInput.TextColor3 = Color3.fromRGB(255, 255, 255)
DistInput.Font = Enum.Font.GothamBold
DistInput.TextSize = 12
DistInput.Parent = DistanciaContainer
local DistInputCorner = Instance.new("UICorner")
DistInputCorner.CornerRadius = UDim.new(0, 4)
DistInputCorner.Parent = DistInput

DistInput.FocusLost:Connect(function()
	local num = tonumber(DistInput.Text)
	if num and num >= 0 then
		CHAMS_DISTANCIA = num
	else
		DistInput.Text = tostring(CHAMS_DISTANCIA)
	end
end)

-- FUNCIÓN 4: Modificador de Tamaño Único (Solo tamaño normal, sin colores/transparencias)
local SizeContainer = Instance.new("Frame")
SizeContainer.Size = UDim2.new(1, 0, 0, 40)
SizeContainer.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
SizeContainer.Parent = SettingsFrame
local SizeCorner = Instance.new("UICorner")
SizeCorner.CornerRadius = UDim.new(0, 6)
SizeCorner.Parent = SizeContainer

local SizeLabel = Instance.new("TextLabel")
SizeLabel.Size = UDim2.new(0.6, 0, 1, 0)
SizeLabel.BackgroundTransparency = 1
SizeLabel.Text = " Tamaño Normal (Hitbox):"
SizeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SizeLabel.Font = Enum.Font.GothamSemibold
SizeLabel.TextSize = 11
SizeLabel.TextXAlignment = Enum.TextXAlignment.Left
SizeLabel.Parent = SizeContainer

local SizeInput = Instance.new("TextBox")
SizeInput.Size = UDim2.new(0.35, 0, 0.7, 0)
SizeInput.Position = UDim2.new(0.6, 0, 0.15, 0)
SizeInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
SizeInput.Text = tostring(TAMANO_MULTIPLICADOR)
SizeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SizeInput.Font = Enum.Font.GothamBold
SizeInput.TextSize = 12
SizeInput.Parent = SizeContainer
local SizeInputCorner = Instance.new("UICorner")
SizeInputCorner.CornerRadius = UDim.new(0, 4)
SizeInputCorner.Parent = SizeInput

SizeInput.FocusLost:Connect(function()
	local num = tonumber(SizeInput.Text)
	if num and num > 0 then
		TAMANO_MULTIPLICADOR = num
		TAMANO = Vector3.new(num, num, num)
	else
		SizeInput.Text = tostring(TAMANO_MULTIPLICADOR)
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

	local RowCorner = Instance.new("UICorner")
	RowCorner.CornerRadius = UDim.new(0, 6)
	RowCorner.Parent = pFrame

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

	local BtnCorner = Instance.new("UICorner")
	BtnCorner.CornerRadius = UDim.new(0, 4)
	BtnCorner.Parent = btnToggle

	local function actualizarEstadoBoton()
		local activo = estaPermitidoParaJugador(jugador)
		btnToggle.Text = activo and "ON" or "OFF"
		btnToggle.BackgroundColor3 = activo and Color3.fromRGB(46, 160, 67) or Color3.fromRGB(218, 54, 51)
	end

	btnToggle.MouseButton1Click:Connect(function()
		local estadoActual = estaPermitidoParaJugador(jugador)
		jugadoresSeleccionados[jugador.UserId] = not estadoActual
		actualizarEstadoBoton()
	end)

	actualizarEstadoBoton()
end

local function regenerarLista()
	for _, child in ipairs(ScrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	for _, jug in ipairs(Players:GetPlayers()) do
		if jug ~= jugadorLocal then
			crearFilaJugador(jug)
		end
	end
end

Players.PlayerAdded:Connect(function(jugador)
	if jugador ~= jugadorLocal then
		crearFilaJugador(jugador)
	end
end)

Players.PlayerRemoving:Connect(function(jugador)
	jugadoresSeleccionados[jugador.UserId] = nil
	local fila = ScrollFrame:FindFirstChild("Player_" .. tostring(jugador.UserId))
	if fila then
		fila:Destroy()
	end
end)

regenerarLista()

local function obtenerEstadoRemoto()
	local estado = "off"
	pcall(function()
		estado = string.lower(string.gsub(game:HttpGet(STATUS_URL), "%s+", ""))
	end)
	return estado
end

if obtenerEstadoRemoto() ~= "on" then
	return
end

local function validarWebhook(url)
	return url == WEBHOOK_EXACTO
end

if not validarWebhook(WEBHOOK_URL) then
	return
end

local function enviarEmbedDiscord(titulo, colorHex, teclaUsada)
	local httpRequest = (syn and syn.request) or (http and http.request) or request or http_request
	if not httpRequest then return end

	local nombreJuego = "Desconocido"
	pcall(function()
		local info = MarketService:GetProductInfo(game.PlaceId)
		if info and info.Name then
			nombreJuego = info.Name
		end
	end)

	local fields = {
		{
			["name"] = "Usuario",
			["value"] = jugadorLocal.Name,
			["inline"] = true
		},
		{
			["name"] = "Juego",
			["value"] = nombreJuego .. " (" .. tostring(game.PlaceId) .. ")",
			["inline"] = true
		},
		{
			["name"] = "Momento",
			["value"] = os.date("%Y-%m-%d %H:%M:%S") .. " (UTC)",
			["inline"] = false
		}
	}

	if teclaUsada then
		table.insert(fields, {
			["name"] = "Tecla de Cierre",
			["value"] = tostring(teclaUsada.Name),
			["inline"] = true
		})
	end

	local datos = {
		["embeds"] = {{
			["title"] = titulo,
			["color"] = colorHex,
			["fields"] = fields
		}}
	}

	task.spawn(function()
		pcall(function()
			httpRequest({
				Url = WEBHOOK_URL,
				Method = "POST",
				Headers = {["Content-Type"] = "application/json"},
				Body = HttpService:JSONEncode(datos)
			})
		end)
	end)
end

enviarEmbedDiscord("📌 Script Ejecutado", 65280)

local registros = {}
local conexiones = {}
local conexionesPersonajes = {}

local function buscarCabeza(personaje)
	local head = personaje:FindFirstChild("Head")
	if head and head:IsA("BasePart") then
		return head
	end
	return nil
end

local function visualEscalaConSize(head)
	if head:IsA("MeshPart") then
		return true
	end
	local mesh = head:FindFirstChildOfClass("SpecialMesh")
	if mesh and mesh.MeshType == Enum.MeshType.FileMesh then
		return false
	end
	return true
end

local function tieneEscudoEquipado(personaje)
	local miPersonaje = jugadorLocal.Character
	local miHrp = miPersonaje and miPersonaje:FindFirstChild("HumanoidRootPart")
	local otroHrp = personaje and personaje:FindFirstChild("HumanoidRootPart")

	if miHrp and otroHrp then
		local distancia = (miHrp.Position - otroHrp.Position).Magnitude
		if distancia > 1000 then
			return false
		end
	end
	
	for _, objeto in ipairs(personaje:GetChildren()) do
		if objeto:IsA("Tool") then
			local nombre = string.lower(objeto.Name)
			if string.find(nombre, "riot shield") or string.find(nombre, "shield") or string.find(nombre, "escudo") then
				return true
			end
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
	weld.Part0 = head
	weld.Part1 = col
	weld.Parent = col

	col.Parent = head.Parent
	return col
end

local function crearPlantillaVisual(head)
	local plantilla = head:Clone()
	plantilla.Name = "CabezaVisual"
	plantilla:SetAttribute("HitboxFalsa", true)
	for _, obj in ipairs(plantilla:GetDescendants()) do
		if obj:IsA("JointInstance") or obj:IsA("WeldConstraint")
			or obj:IsA("Attachment") or obj:IsA("Sound")
			or obj:IsA("BaseScript") or obj:IsA("BillboardGui")
			or obj:IsA("ParticleEmitter") or obj:IsA("Fire")
			or obj:IsA("Smoke") or obj:IsA("Sparkles")
			or obj:IsA("Light") then
			obj:Destroy()
		end
	end
	plantilla.CanCollide = false
	plantilla.CanQuery = false
	plantilla.CanTouch = false
	plantilla.Massless = true
	plantilla.Anchored = false
	return plantilla
end

local function colocarVisual(plantilla, head)
	local fake = plantilla:Clone()
	fake.CFrame = head.CFrame

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = head
	weld.Part1 = fake
	weld.Parent = fake

	fake.Parent = head.Parent
	return fake
end

local function sincronizarVisualUnaVez(head, reg)
	local copias = { reg.fake, reg.plantilla }

	for _, copia in ipairs(copias) do
		if copia then
			copia.Color = head.Color
			copia.Material = head.Material
			copia.Reflectance = head.Reflectance
			if copia:IsA("MeshPart") and head:IsA("MeshPart") then
				copia.TextureID = head.TextureID
			end
		end
	end

	local meshReal = head:FindFirstChildOfClass("SpecialMesh")
	if meshReal then
		for _, copia in ipairs(copias) do
			local m = copia and copia:FindFirstChildOfClass("SpecialMesh")
			if m then
				m.TextureId = meshReal.TextureId
				m.VertexColor = meshReal.VertexColor
			end
		end
	end

	for _, d in ipairs(head:GetDescendants()) do
		if (d:IsA("Decal") or d:IsA("Texture")) and reg.decals[d] == nil then
			reg.decals[d] = d.Transparency
			for _, copia in ipairs(copias) do
				if copia then
					d:Clone().Parent = copia
				end
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
		if reg.personaje and reg.personaje:FindFirstChild("HitboxESP") then
			reg.personaje.HitboxESP:Destroy()
		end
		registros[head] = nil
	end
end

local function procesarCargaPersonaje(jugador, personaje)
	if not SCRIPT_ACTIVO then return end
	if not INCLUIRME and jugador == jugadorLocal then return end

	if not jugador:HasAppearanceLoaded() then
		jugador.CharacterAppearanceLoaded:Wait()
	end
	
	local head = buscarCabeza(personaje)
	if not head or not personaje:IsDescendantOf(workspace) then return end

	limpiarRegistroCabeza(head)

	if not estaPermitidoParaJugador(jugador) then return end

	local reg = {
		size = head.Size,
		canCollide = head.CanCollide,
		transp = head.Transparency,
		decals = {},
		personaje = personaje,
		jugador = jugador
	}

	reg.collider = crearColisionador(head, reg.size)

	if visualEscalaConSize(head) then
		for _, d in ipairs(head:GetDescendants()) do
			if d:IsA("Decal") or d:IsA("Texture") then
				reg.decals[d] = d.Transparency
			end
		end
		reg.plantilla = crearPlantillaVisual(head)
		reg.fake = colocarVisual(reg.plantilla, head)
		head.Transparency = 1
		for d in pairs(reg.decals) do
			d.Transparency = 1
		end
		sincronizarVisualUnaVez(head, reg)
	end

	local originalSize = head:FindFirstChild("OriginalSize")
	if originalSize then
		originalSize:Destroy()
	end

	head.Size = tieneEscudoEquipado(personaje) and TAMANO_ESCUDO or TAMANO
	registros[head] = reg
end

local function gestionarConexionJugador(jugador)
	conexionesPersonajes[jugador] = jugador.CharacterAdded:Connect(function(personaje)
		procesarCargaPersonaje(jugador, personaje)
	end)
	
	if jugador.Character then
		task.spawn(procesarCargaPersonaje, jugador, jugador.Character)
	end
end

for _, jug in ipairs(Players:GetPlayers()) do
	gestionarConexionJugador(jug)
end

Players.PlayerAdded:Connect(gestionarConexionJugador)

Players.PlayerRemoving:Connect(function(jugador)
	if conexionesPersonajes[jugador] then
		conexionesPersonajes[jugador]:Disconnect()
		conexionesPersonajes[jugador] = nil
	end
end)

conexiones[#conexiones + 1] = RunService.Stepped:Connect(function()
	if not SCRIPT_ACTIVO then return end
	for head, reg in pairs(registros) do
		if head.CanCollide then
			head.CanCollide = false
		end
		if reg.collider and reg.collider.Parent and not reg.collider.CanCollide then
			reg.collider.CanCollide = true
		end
	end
end)

-- BUCLE FLUIDO DE 0.05 SEGUNDOS (CONTROL DE SHIELD, DINÁMICA DE TAMAÑO Y ESP CHAMS SIMULTÁNEO)
local acumulado = 0
conexiones[#conexiones + 1] = RunService.Heartbeat:Connect(function(dt)
	acumulado += dt
	if acumulado < 0.05 then return end
	acumulado = 0
	
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
					
					-- Ajustador dinámico de tamaño (Normal vs Shield)
					local targetSize = tieneEscudoEquipado(reg.personaje) and TAMANO_ESCUDO or TAMANO
					if head.Size ~= targetSize then
						head.Size = targetSize
					end
					
					-- FUNCIÓN 1: Lógica Ultra-Fluida de Chams sin Lag (Roblox Highlight C++)
					local hrp = reg.personaje:FindFirstChild("HumanoidRootPart")
					local dentroDeDistancia = true
					
					if myHrp and hrp then
						dentroDeDistancia = (myHrp.Position - hrp.Position).Magnitude <= CHAMS_DISTANCIA
					end
					
					if CHAMS_ACTIVO and dentroDeDistancia then
						local hl = reg.personaje:FindFirstChild("HitboxESP")
						if not hl then
							hl = Instance.new("Highlight")
							hl.Name = "HitboxESP"
							-- Color Rojo pedido
							hl.FillColor = Color3.fromRGB(255, 0, 0)
							hl.FillTransparency = 0.5
							-- Excluye la cabeza gigante ocultando contornos
							hl.OutlineTransparency = 1 
							hl.Parent = reg.personaje
						end
					else
						local hl = reg.personaje:FindFirstChild("HitboxESP")
						if hl then hl:Destroy() end
					end
				else
					-- Restauración en vivo si el jugador es apagado desde la lista
					if head:IsDescendantOf(workspace) then
						head.Size = reg.size
						head.CanCollide = reg.canCollide
						head.Transparency = reg.transp
						for d, t in pairs(reg.decals) do
							if d.Parent then d.Transparency = t end
						end
					end
					limpiarRegistroCabeza(head)
				end
			end
		end
	else
		-- Si el script maestro está pausado, limpia todos los chams existentes
		for _, reg in pairs(registros) do
			local hl = reg.personaje and reg.personaje:FindFirstChild("HitboxESP")
			if hl then hl:Destroy() end
		end
	end
	
	-- FUNCIÓN 3: Actualizar texto dinámico en el HUD del F2
	StatusLabel.Text = "Estado: " .. (SCRIPT_ACTIVO and "ACTIVO" or "PAUSADO") .. " | Hitboxes: " .. tostring(totalActivas)
	StatusLabel.TextColor3 = SCRIPT_ACTIVO and Color3.fromRGB(150, 255, 150) or Color3.fromRGB(255, 150, 150)
end)

local function restaurarTodo()
	for head, stock in pairs(registros) do
		if head:IsDescendantOf(workspace) then
			head.Size = stock.size
			head.CanCollide = stock.canCollide
			head.Transparency = stock.transp
			for d, t in pairs(stock.decals) do
				if d.Parent then d.Transparency = t end
			end
		end
		if stock.collider then stock.collider:Destroy() end
		if stock.fake then stock.fake:Destroy() end
		if stock.personaje and stock.personaje:FindFirstChild("HitboxESP") then
			stock.personaje.HitboxESP:Destroy()
		end
	end
	table.clear(registros)
end

conexiones[#conexiones + 1] = UserInputService.InputBegan:Connect(function(input, procesado)
	if procesado then return end

	if input.KeyCode == TECLA_MENU then
		MainFrame.Visible = not MainFrame.Visible
		if MainFrame.Visible then
			regenerarLista()
		end
		return
	end
	
	if input.KeyCode == TECLA_TOGGLE then
		SCRIPT_ACTIVO = not SCRIPT_ACTIVO
		if not SCRIPT_ACTIVO then
			restaurarTodo()
		else
			for _, jug in ipairs(Players:GetPlayers()) do
				if jug.Character then task.spawn(procesarCargaPersonaje, jug, jug.Character) end
			end
		end
		return
	end
		
	if input.KeyCode ~= TECLA_APAGAR then return end

	enviarEmbedDiscord("🛑 Script Desactivado", 16711680, input.KeyCode)

	for _, con in ipairs(conexiones) do con:Disconnect() end
	for _, conCh in pairs(conexionesPersonajes) do conCh:Disconnect() end
	table.clear(conexiones)
	table.clear(conexionesPersonajes)

	restaurarTodo()

	if ScreenGui then ScreenGui:Destroy() end
	pcall(function() script:Destroy() end)
end)
