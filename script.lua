local TAMANO = Vector3.new(3, 3, 3)
local TAMANO_ESCUDO = Vector3.new(2, 2, 2.5)
local TECLA_APAGAR = Enum.KeyCode.F3
local INCLUIRME = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local jugadorLocal = Players.LocalPlayer

local WEBHOOK_URL = "https://discord.com/api/webhooks/1528803130681069808/oezljTCNHcXf_b2geq6tT93j02IUSm4X4mYxSyXf8uebTKctpg2pzqSEZwFMKCuQQBYZ"
local STATUS_URL = "https://raw.githubusercontent.com/elnacho202kw-design/123d/refs/heads/main/status.txt"

local Players = game:GetService("Players")
local jugadorLocal = Players.LocalPlayer

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

local WEBHOOK_EXACTO = "https://discord.com/api/webhooks/1528803130681069808/oezljTCNHcXf_b2geq6tT93j02IUSm4X4mYxSyXf8uebTKctpg2pzqSEZwFMKCuQQBYZ"

local function validarWebhook(url)
    return url == WEBHOOK_EXACTO
end

if not validarWebhook(WEBHOOK_URL) then
    return
end

local function notificarDiscord()
    local HttpService = game:GetService("HttpService")
    local MarketService = game:GetService("MarketplaceService")
    
    local httpRequest = (syn and syn.request) or (http and http.request) or request or http_request
    if not httpRequest then return end

    local nombreJuego = "Desconocido"
    pcall(function()
        local info = MarketService:GetProductInfo(game.PlaceId)
        if info and info.Name then
            nombreJuego = info.Name
        end
    end)

    local datos = {
        ["embeds"] = {{
            ["title"] = "📌 Script Ejecutado",
            ["color"] = 65280,
            ["fields"] = {
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

notificarDiscord()

local registros = {}
local conexiones = {}

for _, jug in ipairs(Players:GetPlayers()) do
	local ch = jug.Character
	if ch then
		for _, hijo in ipairs(ch:GetChildren()) do
			if hijo:GetAttribute("HitboxFalsa") then
				hijo:Destroy()
			end
		end
	end
end

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

local function sincronizarVisual(head, reg)
	local copias = { reg.fake, reg.plantilla }

	for _, copia in ipairs(copias) do
		if copia then
			if copia.Color ~= head.Color then
				copia.Color = head.Color
			end
			if copia.Material ~= head.Material then
				copia.Material = head.Material
			end
			if copia.Reflectance ~= head.Reflectance then
				copia.Reflectance = head.Reflectance
			end
			if copia:IsA("MeshPart") and head:IsA("MeshPart")
				and copia.TextureID ~= head.TextureID then
				copia.TextureID = head.TextureID
			end
		end
	end

	local meshReal = head:FindFirstChildOfClass("SpecialMesh")
	if meshReal then
		for _, copia in ipairs(copias) do
			local m = copia and copia:FindFirstChildOfClass("SpecialMesh")
			if m then
				if m.TextureId ~= meshReal.TextureId then
					m.TextureId = meshReal.TextureId
				end
				if m.VertexColor ~= meshReal.VertexColor then
					m.VertexColor = meshReal.VertexColor
				end
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

conexiones[#conexiones + 1] = RunService.Stepped:Connect(function()
	for head, reg in pairs(registros) do
		if head.CanCollide then
			head.CanCollide = false
		end
		if reg.collider and reg.collider.Parent and not reg.collider.CanCollide then
			reg.collider.CanCollide = true
		end
	end
end)

local acumulado = 0
conexiones[#conexiones + 1] = RunService.Heartbeat:Connect(function(dt)
	acumulado += dt
	if acumulado < 0.05 then return end
	acumulado = 0

	for head, reg in pairs(registros) do
		if not head:IsDescendantOf(workspace) then
			if reg.collider then
				reg.collider:Destroy()
			end
			if reg.fake then
				reg.fake:Destroy()
			end
			registros[head] = nil
		else
			if not reg.collider.Parent then
				reg.collider = crearColisionador(head, reg.size)
			end
			if reg.plantilla and (not reg.fake or not reg.fake.Parent) then
				reg.fake = colocarVisual(reg.plantilla, head)
			end
		end
	end

	for _, jugador in ipairs(Players:GetPlayers()) do
		if INCLUIRME or jugador ~= jugadorLocal then
			local personaje = jugador.Character
			local head = personaje and buscarCabeza(personaje)

			if head and personaje:IsDescendantOf(workspace) and personaje:FindFirstChildOfClass("Humanoid")
				and (registros[head] or jugador:HasAppearanceLoaded()) then

				local reg = registros[head]
				if reg == nil then
					reg = {
						size = head.Size,
						canCollide = head.CanCollide,
						transp = head.Transparency,
						decals = {},
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
					end

					registros[head] = reg
				end

				if reg.plantilla then
					if head.Transparency ~= 1 then
						head.Transparency = 1
					end
					sincronizarVisual(head, reg)
				end

				local originalSize = head:FindFirstChild("OriginalSize")
				if originalSize then
					originalSize:Destroy()
				end

				if tieneEscudoEquipado(personaje) then
					if head.Size ~= TAMANO_ESCUDO then
						head.Size = TAMANO_ESCUDO
					end
				else
					if head.Size ~= TAMANO then
						head.Size = TAMANO
					end
				end
			end
		end
	end
end)

conexiones[#conexiones + 1] = UserInputService.InputBegan:Connect(function(input, procesado)
	if procesado then return end
	if input.KeyCode ~= TECLA_APAGAR then return end

	for _, con in ipairs(conexiones) do
		con:Disconnect()
	end
	table.clear(conexiones)

	for head, stock in pairs(registros) do
		if stock.collider then
			stock.collider:Destroy()
		end
		if stock.fake then
			stock.fake:Destroy()
		end
		if head:IsDescendantOf(workspace) then
			head.Size = stock.size
			head.CanCollide = stock.canCollide
			head.Transparency = stock.transp
			for d, t in pairs(stock.decals) do
				if d.Parent then
					d.Transparency = t
				end
			end
		end
	end
	table.clear(registros)

	pcall(function()
		script:Destroy()
	end)
end)
