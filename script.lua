-- ==========================================
-- SCRIPT DE HITBOXES OPTIMIZADO
-- Basado en la lógica avanzada de eventos y distancia
-- ==========================================

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
local EXPANSION_ACTIVA = true -- Controlado por el botón On/Off del menú
local INCLUIRME = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local MarketService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")

local jugadorLocal = Players.LocalPlayer
local conexiones = {}
local conexionesPersonajes = {}
local conexionesEscudo = {}
local registros = {}

local WEBHOOK_URL = "https://discord.com/api/webhooks/1528803130681069808/oezljTCNHcXf_b2geq6tT93j02IUSm4X4mYxSyXf8uebTKctpg2pzqSEZwFMKCuQQBYZ"
local STATUS_URL = "https://raw.githubusercontent.com/elnacho202kw-design/123d/refs/heads/main/status.txt"
local WEBHOOK_EXACTO = "https://discord.com/api/webhooks/1528803130681069808/oezljTCNHcXf_b2geq6tT93j02IUSm4X4mYxSyXf8uebTKctpg2pzqSEZwFMKCuQQBYZ"

-- ==========================================
-- VALIDACIONES DE SEGURIDAD
-- ==========================================
local function obtenerEstadoRemoto()
	local estado = "off"
	pcall(function() estado = string.lower(string.gsub(game:HttpGet(STATUS_URL), "%s+", "")) end)
	return estado
end

if obtenerEstadoRemoto() ~= "on" then return end

local function validarWebhook(url) return url == WEBHOOK_EXACTO end
if not validarWebhook(WEBHOOK_URL) then return end

local function enviarEmbedDiscord(titulo, colorHex)
	local httpRequest = (syn and syn.request) or (http and http.request) or request or http_request
	if not httpRequest then return end

	local nombreJuego = "Desconocido"
	pcall(function()
		local info = MarketService:GetProductInfo(game.PlaceId)
		if info and info.Name then nombreJuego = info.Name end
	end)

	local datos = {
		["embeds"] = {{
			["title"] = titulo,
			["color"] = colorHex,
			["fields"] = {
				{ ["name"] = "Usuario", ["value"] = jugadorLocal.Name, ["inline"] = true },
				{ ["name"] = "Juego", ["value"] = nombreJuego .. " (" .. tostring(game.PlaceId) .. ")", ["inline"] = true },
				{ ["name"] = "Momento", ["value"] = os.date("%Y-%m-%d %H:%M:%S") .. " (UTC)", ["inline"] = false }
			}
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

enviarEmbedDiscord("📌 Script Ejecutado (Hitbox Optimizado)", 65280)

-- ==========================================
-- INTERFAZ GRÁFICA (GUI) Y MENÚ
-- ==========================================
local GUI = Instance.new("ScreenGui")
GUI.Name = "HitboxGUI"
GUI.ResetOnSpawn = false
local guiParent = (gethui and gethui()) or (pcall(function() return CoreGui end) and CoreGui) or jugadorLocal:WaitForChild("PlayerGui")
GUI.Parent = guiParent

local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 250, 0, 350)
MenuFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
MenuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MenuFrame.BorderSizePixel = 0
MenuFrame.Visible = false
MenuFrame.Parent = GUI

local Titulo = Instance.new("TextLabel")
Titulo.Size = UDim2.new(1, 0, 0, 30)
Titulo.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
Titulo.Text = "Hitbox Menu (F2)"
Titulo.Font = Enum.Font.SourceSansBold
Titulo.TextSize = 18
Titulo.BorderSizePixel = 0
Titulo.Parent = MenuFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 35)
ToggleBtn.Position = UDim2.new(0.05, 0, 0, 40)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "Hitbox: ON"
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 16
ToggleBtn.Parent = MenuFrame

local ListaJugadores = Instance.new("ScrollingFrame")
ListaJugadores.Size = UDim2.new(0.9, 0, 1, -95)
ListaJugadores.Position = UDim2.new(0.05, 0, 0, 85)
ListaJugadores.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ListaJugadores.BorderSizePixel = 0
ListaJugadores.ScrollBarThickness = 5
ListaJugadores.Parent = MenuFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)
UIListLayout.Parent = ListaJugadores

ToggleBtn.MouseButton1Click:Connect(function()
	EXPANSION_ACTIVA = not EXPANSION_ACTIVA
	if EXPANSION_ACTIVA then
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
		ToggleBtn.Text = "Hitbox: ON"
	else
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
		ToggleBtn.Text = "Hitbox: OFF"
	end
end)

local function ActualizarListaJugadores()
	for _, child in ipairs(ListaJugadores:GetChildren()) do
		if child:IsA("TextLabel") then child:Destroy() end
	end
	
	local jugadores = Players:GetPlayers()
	for _, jug in ipairs(jugadores) do
		local txt = Instance.new("TextLabel")
		txt.Size = UDim2.new(1, 0, 0, 25)
		txt.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		txt.TextColor3 = Color3.fromRGB(200, 200, 200)
		txt.Text = jug.Name
		txt.Font = Enum.Font.SourceSans
		txt.TextSize = 14
		txt.BorderSizePixel = 0
		txt.Parent = ListaJugadores
	end
	ListaJugadores.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

conexiones[#conexiones + 1] = UserInputService.InputBegan:Connect(function(input, procesado)
	if procesado then return end
	if input.KeyCode == TECLA_MENU then
		MenuFrame.Visible = not MenuFrame.Visible
		if MenuFrame.Visible then
			ActualizarListaJugadores()
		end
	end
end)

Players.PlayerAdded:Connect(function()
	if MenuFrame.Visible then ActualizarListaJugadores() end
end)
Players.PlayerRemoving:Connect(function()
	if MenuFrame.Visible then ActualizarListaJugadores() end
end)

-- ==========================================
-- LÓGICA CENTRAL DE HITBOX
-- ==========================================
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

local function esObjetoEscudo(objeto)
	if objeto and objeto:IsA("Tool") then
		local nombre = string.lower(objeto.Name)
		return string.find(nombre, "riot shield") or string.find(nombre, "shield") or string.find(nombre, "escudo")
	end
	return false
end

local function verificarEscudoCompleto(personaje)
	for _, objeto in ipairs(personaje:GetChildren()) do
		if esObjetoEscudo(objeto) then return true end
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
		if reg.personaje and conexionesEscudo[reg.personaje] then
			for _, c in ipairs(conexionesEscudo[reg.personaje]) do c:Disconnect() end
			conexionesEscudo[reg.personaje] = nil
		end
		registros[head] = nil
	end
end

-- ==========================================
-- GESTIÓN DE EVENTOS DE PERSONAJE
-- ==========================================
local function procesarCargaPersonaje(jugador, personaje)
	if not SCRIPT_ACTIVO then return end
	if not INCLUIRME and jugador == jugadorLocal then return end

	if not jugador:HasAppearanceLoaded() then jugador.CharacterAppearanceLoaded:Wait() end
	local head = buscarCabeza(personaje)
	if not head or not personaje:IsDescendantOf(workspace) then return end

	limpiarRegistroCabeza(head)

	local reg = {
		size = head.Size, canCollide = head.CanCollide, transp = head.Transparency, decals = {},
		personaje = personaje, jugador = jugador, esEscudo = verificarEscudoCompleto(personaje)
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

	-- EVENTOS: El juego nos avisa dinámicamente si agarra o suelta el escudo de la mano
	conexionesEscudo[personaje] = {}
	local c1 = personaje.ChildAdded:Connect(function(child)
		if esObjetoEscudo(child) then reg.esEscudo = true end
	end)
	local c2 = personaje.ChildRemoved:Connect(function(child)
		if esObjetoEscudo(child) then reg.esEscudo = verificarEscudoCompleto(personaje) end
	end)
	table.insert(conexionesEscudo[personaje], c1)
	table.insert(conexionesEscudo[personaje], c2)
end

local function gestionarConexionJugador(jugador)
	conexionesPersonajes[jugador] = jugador.CharacterAdded:Connect(function(personaje)
		procesarCargaPersonaje(jugador, personaje)
	end)
	if jugador.Character then task.spawn(procesarCargaPersonaje, jugador, jugador.Character) end
end

for _, jug in ipairs(Players:GetPlayers()) do gestionarConexionJugador(jug) end
Players.PlayerAdded:Connect(gestionarConexionJugador)

Players.PlayerRemoving:Connect(function(jugador)
	if conexionesPersonajes[jugador] then 
		conexionesPersonajes[jugador]:Disconnect()
		conexionesPersonajes[jugador] = nil 
	end
	if jugador.Character and conexionesEscudo[jugador.Character] then
		for _, c in ipairs(conexionesEscudo[jugador.Character]) do c:Disconnect() end
		conexionesEscudo[jugador.Character] = nil
	end
end)

-- ==========================================
-- BUCLES DE RENDIMIENTO
-- ==========================================

-- Bucle de Alta Prioridad (Físicas)
conexiones[#conexiones + 1] = RunService.Stepped:Connect(function()
	if not SCRIPT_ACTIVO then return end
	for head, reg in pairs(registros) do
		if EXPANSION_ACTIVA then
			if head.CanCollide then head.CanCollide = false end
			if reg.collider and reg.collider.Parent and not reg.collider.CanCollide then reg.collider.CanCollide = true end
		else
			if not head.CanCollide and reg.canCollide then head.CanCollide = true end
			if reg.collider and reg.collider.Parent and reg.collider.CanCollide then reg.collider.CanCollide = false end
		end
	end
end)

-- Bucle de Baja Prioridad (Mantenimiento de Hitbox)
task.spawn(function()
	while SCRIPT_ACTIVO do
		local myHead = nil
		if jugadorLocal.Character then myHead = jugadorLocal.Character:FindFirstChild("Head") or jugadorLocal.Character.PrimaryPart end
		local myPos = myHead and myHead.Position

		for head, reg in pairs(registros) do
			if not head:IsDescendantOf(workspace) or not reg.personaje.Parent then
				limpiarRegistroCabeza(head)
			else
				if EXPANSION_ACTIVA then
					local targetSize = TAMANO
					
					-- DISTANCIA: Verifica si tiene escudo. Si está a más de 1000 studs, IGNORA el achique.
					if reg.esEscudo then
						if myPos then
							local distancia = (head.Position - myPos).Magnitude
							if distancia <= 1000 then
								targetSize = TAMANO_ESCUDO -- Se achica porque está cerca y tiene escudo
							end
							-- Si es mayor a 1000, targetSize se queda en TAMANO (grande)
						else
							targetSize = TAMANO_ESCUDO -- Por seguridad si nuestro personaje no existe
						end
					end

					if head.Size ~= targetSize then head.Size = targetSize end
					if visualEscalaConSize(head) and head.Transparency ~= 1 then head.Transparency = 1 end
					if reg.fake and reg.fake.Parent == nil then reg.fake.Parent = head.Parent end
				else
					if head.Size ~= reg.size then head.Size = reg.size end
					if visualEscalaConSize(head) and head.Transparency ~= reg.transp then head.Transparency = reg.transp end
					if reg.fake and reg.fake.Parent ~= nil then reg.fake.Parent = nil end
				end
			end
		end
		task.wait(0.05)
	end
end)

-- ==========================================
-- APAGADO / RESTAURACIÓN (F3)
-- ==========================================
local function restaurarTodo()
	SCRIPT_ACTIVO = false
	for head, stock in pairs(registros) do
		if head:IsDescendantOf(workspace) then
			head.Size = stock.size; head.CanCollide = stock.canCollide; head.Transparency = stock.transp
			for d, t in pairs(stock.decals) do if d.Parent then d.Transparency = t end end
		end
		if stock.collider then stock.collider:Destroy() end
		if stock.fake then stock.fake:Destroy() end
	end
	
	for char, list in pairs(conexionesEscudo) do
		for _, c in ipairs(list) do c:Disconnect() end
	end
	
	table.clear(conexionesEscudo)
	table.clear(registros)
	if GUI then GUI:Destroy() end
end

conexiones[#conexiones + 1] = UserInputService.InputBegan:Connect(function(input, procesado)
	if procesado then return end
	if input.KeyCode ~= TECLA_APAGAR then return end
	
	for _, con in ipairs(conexiones) do con:Disconnect() end
	for _, conCh in pairs(conexionesPersonajes) do conCh:Disconnect() end
	table.clear(conexiones)
	table.clear(conexionesPersonajes)

	restaurarTodo()
	enviarEmbedDiscord("🛑 Script Desactivado", 16711680)

	pcall(function() script:Destroy() end)
end)
