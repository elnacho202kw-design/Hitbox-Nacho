local TAMANO = Vector3.new(3, 3, 3)
local TAMANO_ESCUDO = Vector3.new(2, 2, 2.5)
local TECLA_APAGAR = Enum.KeyCode.F3
local TECLA_TOGGLE = Enum.KeyCode.F4
local TECLA_MENU = Enum.KeyCode.F2
local SCRIPT_ACTIVO = true
local INCLUIRME = false

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

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HitboxSelectorGui"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 320)
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
TitleLabel.Text = "Selector de Jugadores"
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "PlayersScroll"
ScrollFrame.Size = UDim2.new(1, -16, 1, -45)
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

-- Limpieza interna al cambiar o morir
local function limpiarRegistroCabeza(head)
	local reg = registros[head]
	if reg then
		if reg.collider then reg.collider:Destroy() end
		if reg.fake then reg.fake:Destroy() end
		registros[head] = nil
	end
end

-- EJECTA SOLO 1 VEZ AL REINICIAR / RESPAWN / UNIRSE
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

-- SEPARADO: Control mínimo de físicas por Frame (Sin recreaciones)
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

-- SEPARADO: Cambios de Shield dinámicos estrictamente cada 0.05 segundos
local acumulado = 0
conexiones[#conexiones + 1] = RunService.Heartbeat:Connect(function(dt)
	acumulado += dt
	if acumulado < 0.05 then return end
	acumulado = 0
	
	if not SCRIPT_ACTIVO then return end

	for head, reg in pairs(registros) do
		if not head:IsDescendantOf(workspace) or not reg.personaje.Parent then
			limpiarRegistroCabeza(head)
		else
			if estaPermitidoParaJugador(reg.jugador) then
				local targetSize = tieneEscudoEquipado(reg.personaje) and TAMANO_ESCUDO or TAMANO
				if head.Size ~= targetSize then
					head.Size = targetSize
				end
			else
				-- Si fue desactivado desde la lista GUI en tiempo real, restauramos valores originales
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
end)

-- Controladores UI de apagado y restauración
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
