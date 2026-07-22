local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local MarketService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local conexiones = {}
local conexionesPersonajes = {}
local conexionesEscudo = {}
local registros = {}
local cabezasGuardadas = {}
local filasUI = {}
local estadoJugadores = {}

local function calcularTamanoEscudo(sizeMultiplier)
    if sizeMultiplier > 3 then return Vector3.new(2, 2, 2.5) end
    local dif = 3 - sizeMultiplier
    return Vector3.new(math.max(1, 2 - dif), math.max(1, 2 - dif), math.max(1.5, 2.5 - dif))
end

-- Variables globales de tamaño y configuración
local TAMANO_MULTIPLICADOR = 2.5
local TAMANO = Vector3.new(TAMANO_MULTIPLICADOR, TAMANO_MULTIPLICADOR, TAMANO_MULTIPLICADOR)
local TAMANO_ESCUDO = calcularTamanoEscudo(TAMANO_MULTIPLICADOR)

local TECLA_APAGAR = Enum.KeyCode.F3
local TECLA_MENU = Enum.KeyCode.F2
local SCRIPT_ACTIVO = true
local EXPANSION_ACTIVA = true 
local INCLUIRME = false

local WEBHOOK_URL = "https://discord.com/api/webhooks/1528803130681069808/oezljTCNHcXf_b2geq6tT93j02IUSm4X4mYxSyXf8uebTKctpg2pzqSEZwFMKCuQQBYZ"
local STATUS_URL = "https://raw.githubusercontent.com/elnacho202kw-design/Hitbox-Nacho/refs/heads/main/status.txt?v=" .. tick()
local WEBHOOK_EXACTO = "https://discord.com/api/webhooks/1528803130681069808/oezljTCNHcXf_b2geq6tT93j02IUSm4X4mYxSyXf8uebTKctpg2pzqSEZwFMKCuQQBYZ"

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
            ["title"] = titulo, ["color"] = colorHex,
            ["fields"] = {
                { ["name"] = "Usuario", ["value"] = LocalPlayer.Name, ["inline"] = true },
                { ["name"] = "Juego", ["value"] = nombreJuego .. " (" .. tostring(game.PlaceId) .. ")", ["inline"] = true },
                { ["name"] = "Momento", ["value"] = os.date("%Y-%m-%d %H:%M:%S") .. " (UTC)", ["inline"] = false }
            }
        }}
    }
    task.spawn(function()
        pcall(function() httpRequest({Url = WEBHOOK_URL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(datos)}) end)
    end)
end

local function verificarAccesoJugador()
    local autorizado = false
    pcall(function()
        local data = game:HttpGet(STATUS_URL)
        for linea in string.gmatch(data, "[^\r\n]+") do
            local usuario, estado = string.match(linea, "([^=]+)=([^=]+)")
            if usuario and estado then
                usuario = string.gsub(usuario, "%s+", "")
                estado = string.lower(string.gsub(estado, "%s+", ""))
                if usuario == LocalPlayer.Name and estado == "on" then
                    autorizado = true
                    break
                end
            end
        end
    end)
    return autorizado
end

if not verificarAccesoJugador() then 
    warn("No estás autorizado en la whitelist o tu estado es OFF.")
    enviarEmbedDiscord("⚠️ Intento de Ejecución Sin Permiso", 16776960) 
    return 
end

local function validarWebhook(url) return url == WEBHOOK_EXACTO end
if not validarWebhook(WEBHOOK_URL) then return end

enviarEmbedDiscord("📌 Script Ejecutado (Optimización Extrema)", 65280)

local uiParent = nil
pcall(function() uiParent = CoreGui end)
if not uiParent then uiParent = LocalPlayer:WaitForChild("PlayerGui") end

local HitboxUI = Instance.new("ScreenGui")
HitboxUI.Name = "HitboxUI_Optimizada"
HitboxUI.ResetOnSpawn = false
HitboxUI.Parent = uiParent
HitboxUI.Enabled = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 480) 
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = HitboxUI
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local TopCover = Instance.new("Frame")
TopCover.Size = UDim2.new(1, 0, 0, 8)
TopCover.Position = UDim2.new(0, 0, 1, -8)
TopCover.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TopCover.BorderSizePixel = 0
TopCover.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Hitbox Control | Jugadores: 0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(1, -20, 0, 80)
SettingsFrame.Position = UDim2.new(0, 10, 0, 50)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SettingsFrame.Parent = MainFrame
Instance.new("UICorner", SettingsFrame).CornerRadius = UDim.new(0, 6)

local KeybindBtn = Instance.new("TextButton")
KeybindBtn.Size = UDim2.new(1, -10, 0, 26)
KeybindBtn.Position = UDim2.new(0, 5, 0, 5)
KeybindBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
KeybindBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
KeybindBtn.Font = Enum.Font.GothamSemibold
KeybindBtn.TextSize = 13
KeybindBtn.Text = "Tecla Menú: " .. TECLA_MENU.Name
KeybindBtn.Parent = SettingsFrame
Instance.new("UICorner", KeybindBtn).CornerRadius = UDim.new(0, 4)

local cambiandoTecla = false
KeybindBtn.MouseButton1Click:Connect(function()
    cambiandoTecla = true
    KeybindBtn.Text = "Presiona una tecla..."
    KeybindBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end)

local SizeLabel = Instance.new("TextLabel")
SizeLabel.Size = UDim2.new(1, -10, 0, 20)
SizeLabel.Position = UDim2.new(0, 5, 0, 35)
SizeLabel.BackgroundTransparency = 1
SizeLabel.Text = "Tamaño Hitbox: 2.5"
SizeLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
SizeLabel.Font = Enum.Font.GothamMedium
SizeLabel.TextSize = 13
SizeLabel.TextXAlignment = Enum.TextXAlignment.Left
SizeLabel.Parent = SettingsFrame

local SliderBG = Instance.new("Frame")
SliderBG.Size = UDim2.new(1, -10, 0, 8)
SliderBG.Position = UDim2.new(0, 5, 0, 60)
SliderBG.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
SliderBG.Parent = SettingsFrame
Instance.new("UICorner", SliderBG).CornerRadius = UDim.new(1, 0)

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
SliderFill.Parent = SliderBG
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

local SliderKnob = Instance.new("TextButton")
SliderKnob.Size = UDim2.new(0, 16, 0, 16)
SliderKnob.Position = UDim2.new(0, -8, 0.5, -8)
SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderKnob.Text = ""
SliderKnob.Parent = SliderFill
Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(1, 0)

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -150)
ScrollFrame.Position = UDim2.new(0, 10, 0, 140)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ScrollFrame

local dragToggle, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragToggle then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local ActualizarEstadoJugador

local function AplicarNuevoTamano(nuevoValor)
    TAMANO_MULTIPLICADOR = nuevoValor
    TAMANO = Vector3.new(nuevoValor, nuevoValor, nuevoValor)
    TAMANO_ESCUDO = calcularTamanoEscudo(nuevoValor)
    
    for jugador, _ in pairs(estadoJugadores) do
        ActualizarEstadoJugador(jugador, nil)
    end
end

local arrastrandoSlider = false
SliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        arrastrandoSlider = true
    end
end)
SliderBG.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        arrastrandoSlider = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        arrastrandoSlider = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if arrastrandoSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local posAbsoluta = input.Position.X - SliderBG.AbsolutePosition.X
        local porcentaje = math.clamp(posAbsoluta / SliderBG.AbsoluteSize.X, 0, 1)
        
        local valorMin = 2.5
        local valorMax = 10.0
        local valorReal = valorMin + (porcentaje * (valorMax - valorMin))
        valorReal = math.floor(valorReal * 10) / 10 
        
        SliderFill.Size = UDim2.new(porcentaje, 0, 1, 0)
        SizeLabel.Text = "Tamaño Hitbox: " .. tostring(valorReal)
        
        AplicarNuevoTamano(valorReal)
    end
end)

local function actualizarContadorUI()
    local count = 0
    for _ in pairs(filasUI) do count = count + 1 end
    Title.Text = "Hitbox Control | Jugadores: " .. count
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

local function crearFilaUI(jugador)
    if filasUI[jugador] then return end
    if estadoJugadores[jugador] == nil then estadoJugadores[jugador] = true end

    local PlayerRow = Instance.new("Frame")
    PlayerRow.Size = UDim2.new(1, -10, 0, 40)
    PlayerRow.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    PlayerRow.Parent = ScrollFrame
    Instance.new("UICorner", PlayerRow).CornerRadius = UDim.new(0, 6)

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -80, 1, 0); NameLabel.Position = UDim2.new(0, 10, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = jugador.DisplayName .. " (@" .. jugador.Name .. ")"
    NameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    NameLabel.Font = Enum.Font.GothamMedium; NameLabel.TextSize = 13
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left; NameLabel.Parent = PlayerRow

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 60, 0, 26); ToggleBtn.Position = UDim2.new(1, -70, 0, 7)
    ToggleBtn.Text = estadoJugadores[jugador] and "ON" or "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.BackgroundColor3 = estadoJugadores[jugador] and Color3.fromRGB(40, 200, 80) or Color3.fromRGB(200, 40, 40)
    ToggleBtn.Font = Enum.Font.GothamBold; ToggleBtn.TextSize = 12
    ToggleBtn.Parent = PlayerRow
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 4)

    ToggleBtn.MouseButton1Click:Connect(function()
        estadoJugadores[jugador] = not estadoJugadores[jugador]
        ToggleBtn.Text = estadoJugadores[jugador] and "ON" or "OFF"
        ToggleBtn.BackgroundColor3 = estadoJugadores[jugador] and Color3.fromRGB(40, 200, 80) or Color3.fromRGB(200, 40, 40)
        ActualizarEstadoJugador(jugador, nil)
    end)

    filasUI[jugador] = PlayerRow
    actualizarContadorUI()
end

local function buscarCabeza(personaje)
    local head = personaje:WaitForChild("Head", 3)
    return (head and head:IsA("BasePart")) and head or nil
end

local function visualEscalaConSize(head)
    if head:IsA("MeshPart") then return true end
    local mesh = head:FindFirstChildOfClass("SpecialMesh")
    return not (mesh and mesh.MeshType == Enum.MeshType.FileMesh)
end

local function esObjetoEscudo(objeto)
    if objeto and objeto:IsA("Tool") then
        local nombre = string.lower(objeto.Name)
        return string.find(nombre, "shield") or string.find(nombre, "escudo") or string.find(nombre, "riot")
    end
    return false
end

local function crearColisionador(head, tamanoStock)
    local col = Instance.new("Part")
    col.Name = "ColisionCabeza"; col:SetAttribute("HitboxFalsa", true)
    col.Size = tamanoStock; col.Transparency = 1
    col.CanCollide = true; col.CanQuery = false; col.CanTouch = false
    col.Massless = true; col.CastShadow = false; col.Anchored = false
    col.CFrame = head.CFrame
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = head; weld.Part1 = col; weld.Parent = col
    col.Parent = head.Parent
    return col
end

local function crearYColocarVisual(head)
    local plantilla = head:Clone()
    plantilla.Name = "CabezaVisual"; plantilla:SetAttribute("HitboxFalsa", true)
    for _, obj in ipairs(plantilla:GetDescendants()) do
        if obj:IsA("JointInstance") or obj:IsA("WeldConstraint") or obj:IsA("Attachment") or obj:IsA("Sound") or obj:IsA("BaseScript") or obj:IsA("BillboardGui") or obj:IsA("ParticleEmitter") then obj:Destroy() end
    end
    plantilla.CanCollide = false; plantilla.CanQuery = false; plantilla.CanTouch = false; plantilla.Massless = true; plantilla.Anchored = false
    
    local fake = plantilla:Clone()
    fake.CFrame = head.CFrame
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = head; weld.Part1 = fake; weld.Parent = fake
    fake.Parent = head.Parent
    return fake, plantilla
end

ActualizarEstadoJugador = function(jugador, tieneEscudoNuevo)
    local head = cabezasGuardadas[jugador]
    if not head then return end
    local reg = registros[head]
    if not reg or not head.Parent then return end

    if tieneEscudoNuevo ~= nil then reg.esEscudo = tieneEscudoNuevo end

    local activadoEnJugador = (EXPANSION_ACTIVA and estadoJugadores[jugador] ~= false)

    if activadoEnJugador then
        local targetSize = reg.esEscudo and TAMANO_ESCUDO or TAMANO
        if head.Size ~= targetSize then head.Size = targetSize end
        if visualEscalaConSize(head) and head.Transparency ~= 1 then head.Transparency = 1 end
        for d in pairs(reg.decals) do d.Transparency = 1 end
        if reg.fake and reg.fake.Parent == nil then reg.fake.Parent = head.Parent end
    else
        if head.Size ~= reg.size then head.Size = reg.size end
        if visualEscalaConSize(head) and head.Transparency ~= reg.transp then head.Transparency = reg.transp end
        for d, t in pairs(reg.decals) do d.Transparency = t end
        if reg.fake and reg.fake.Parent ~= nil then reg.fake.Parent = nil end
    end
end

local function MonitorearEscudoPersonaje(jugador, personaje)
    local tieneEscudo = false
    for _, child in ipairs(personaje:GetChildren()) do
        if esObjetoEscudo(child) then tieneEscudo = true; break end
    end
    
    ActualizarEstadoJugador(jugador, tieneEscudo)

    local cAdded = personaje.ChildAdded:Connect(function(child)
        if esObjetoEscudo(child) then ActualizarEstadoJugador(jugador, true) end
    end)

    local cRemoved = personaje.ChildRemoved:Connect(function(child)
        if esObjetoEscudo(child) then
            local todaviaTiene = false
            for _, item in ipairs(personaje:GetChildren()) do
                if item ~= child and esObjetoEscudo(item) then todaviaTiene = true; break end
            end
            ActualizarEstadoJugador(jugador, todaviaTiene)
        end
    end)

    conexionesEscudo[personaje] = {cAdded, cRemoved}

    local hum = personaje:WaitForChild("Humanoid", 3)
    if hum then
        local cDied
        cDied = hum.Died:Connect(function()
            if conexionesEscudo[personaje] then
                for _, c in ipairs(conexionesEscudo[personaje]) do c:Disconnect() end
                conexionesEscudo[personaje] = nil
            end
            
            local head = buscarCabeza(personaje)
            if head and registros[head] then
                local reg = registros[head]
                head.Size = reg.size
                head.Transparency = reg.transp
                head.CanCollide = reg.canCollide
                for d, t in pairs(reg.decals) do d.Transparency = t end
                if reg.collider then reg.collider:Destroy() end
                if reg.fake then reg.fake:Destroy() end
                registros[head] = nil
            end
            
            if cDied then cDied:Disconnect() end
        end)
    end
end

local function procesarCargaPersonaje(jugador, personaje)
    if not SCRIPT_ACTIVO then return end
    if not INCLUIRME and jugador == LocalPlayer then return end

    local head = buscarCabeza(personaje)
    if not head or not personaje:IsDescendantOf(workspace) then return end
    if registros[head] then return end 

    local t = 0
    while not jugador:HasAppearanceLoaded() and t < 3 do task.wait(0.1); t = t + 0.1 end

    cabezasGuardadas[jugador] = head

    local reg = {
        size = head.Size, canCollide = head.CanCollide, transp = head.Transparency, decals = {},
        personaje = personaje, jugador = jugador, esEscudo = false
    }
    reg.collider = crearColisionador(head, reg.size)

    if visualEscalaConSize(head) then
        for _, d in ipairs(head:GetDescendants()) do if d:IsA("Decal") or d:IsA("Texture") then reg.decals[d] = d.Transparency end end
        reg.fake, reg.plantilla = crearYColocarVisual(head)
        head.Transparency = 1
        for d in pairs(reg.decals) do d.Transparency = 1 end
        reg.fake.Color = head.Color; reg.fake.Material = head.Material
        if reg.fake:IsA("MeshPart") and head:IsA("MeshPart") then reg.fake.TextureID = head.TextureID end
    end
    
    local originalSize = head:FindFirstChild("OriginalSize")
    if originalSize then originalSize:Destroy() end

    registros[head] = reg

    MonitorearEscudoPersonaje(jugador, personaje)
    
    ActualizarEstadoJugador(jugador, nil)
end

local function gestionarConexionJugador(jugador)
    conexionesPersonajes[jugador] = jugador.CharacterAdded:Connect(function(personaje)
        procesarCargaPersonaje(jugador, personaje)
    end)
    
    jugador.CharacterRemoving:Connect(function(personaje)
        local head = personaje:FindFirstChild("Head")
        if head and registros[head] then
            local reg = registros[head]
            if reg.collider then reg.collider:Destroy() end
            if reg.fake then reg.fake:Destroy() end
            registros[head] = nil
        end
    end)

    if jugador.Character then task.spawn(procesarCargaPersonaje, jugador, jugador.Character) end
end

for _, jug in ipairs(Players:GetPlayers()) do 
    if estadoJugadores[jug] == nil then estadoJugadores[jug] = true end
    crearFilaUI(jug)
    gestionarConexionJugador(jug) 
end

Players.PlayerAdded:Connect(function(jugador)
    estadoJugadores[jugador] = true
    crearFilaUI(jugador)
    gestionarConexionJugador(jugador)
end)

Players.PlayerRemoving:Connect(function(jugador)
    estadoJugadores[jugador] = nil
    cabezasGuardadas[jugador] = nil

    if filasUI[jugador] then
        filasUI[jugador]:Destroy()
        filasUI[jugador] = nil
        actualizarContadorUI()
    end

    if conexionesPersonajes[jugador] then 
        conexionesPersonajes[jugador]:Disconnect()
        conexionesPersonajes[jugador] = nil 
    end
    if jugador.Character and conexionesEscudo[jugador.Character] then
        for _, c in ipairs(conexionesEscudo[jugador.Character]) do c:Disconnect() end
        conexionesEscudo[jugador.Character] = nil
    end
end)

conexiones[#conexiones + 1] = RunService.Stepped:Connect(function()
    if not SCRIPT_ACTIVO then return end
    for head, reg in pairs(registros) do
        -- FIX 2: Evitamos errores si la cabeza deja de existir abruptamente
        if not head or not head.Parent then continue end

        local activadoEnJugador = (EXPANSION_ACTIVA and estadoJugadores[reg.jugador] ~= false)
        if activadoEnJugador then
            if head.CanCollide then head.CanCollide = false end
            if reg.collider and reg.collider.Parent and not reg.collider.CanCollide then reg.collider.CanCollide = true end
            
            -- FIX 2: Reforzamos el tamaño (Evita que el juego achique la hitbox de repente)
            local targetSize = reg.esEscudo and TAMANO_ESCUDO or TAMANO
            if (head.Size - targetSize).Magnitude > 0.05 then
                ActualizarEstadoJugador(reg.jugador, nil)
            end
        else
            if not head.CanCollide and reg.canCollide then head.CanCollide = true end
            if reg.collider and reg.collider.Parent and reg.collider.CanCollide then reg.collider.CanCollide = false end
            
            -- FIX 2: Reforzamos el tamaño original cuando está apagado
            if (head.Size - reg.size).Magnitude > 0.05 then
                ActualizarEstadoJugador(reg.jugador, nil)
            end
        end
    end
end)

task.spawn(function()
    while SCRIPT_ACTIVO do
        -- FIX 1: Limpiamos la caché de jugadores que Roblox eliminó del mapa por la distancia (StreamingEnabled)
        for head, reg in pairs(registros) do
            if not head or not head.Parent or not head:IsDescendantOf(workspace) then
                if reg.collider then pcall(function() reg.collider:Destroy() end) end
                if reg.fake then pcall(function() reg.fake:Destroy() end) end
                registros[head] = nil
            end
        end

        -- LOGICA AGREGADA AQUI: Bucle cada 1 segundo que revisa a TODOS forzosamente
        for _, jug in ipairs(Players:GetPlayers()) do
            if INCLUIRME or jug ~= LocalPlayer then
                local char = jug.Character
                if char and char:IsDescendantOf(workspace) then
                    local head = char:FindFirstChild("Head")
                    if head and head:IsA("BasePart") then
                        if not registros[head] then
                            -- Si por alguna razón no se registró (bug de carga), lo registra aquí.
                            task.spawn(procesarCargaPersonaje, jug, char)
                        else
                            -- Si ya está registrado, fuerza a que el hitbox tome el valor exacto del menú.
                            ActualizarEstadoJugador(jug, nil)
                        end
                    end
                end
            end
        end
        task.wait(1)
    end
end)

conexiones[#conexiones + 1] = UserInputService.InputBegan:Connect(function(input, procesado)
    if cambiandoTecla then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            TECLA_MENU = input.KeyCode
            KeybindBtn.Text = "Tecla Menú: " .. TECLA_MENU.Name
            KeybindBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            cambiandoTecla = false
        end
        return
    end

    if procesado then return end
    
    if input.KeyCode == TECLA_MENU then
        HitboxUI.Enabled = not HitboxUI.Enabled
    end
    
    if input.KeyCode == TECLA_APAGAR then
        SCRIPT_ACTIVO = false
        for _, con in ipairs(conexiones) do con:Disconnect() end
        for _, conCh in pairs(conexionesPersonajes) do conCh:Disconnect() end
        
        for head, stock in pairs(registros) do
            if head:IsDescendantOf(workspace) then
                head.Size = stock.size; head.CanCollide = stock.canCollide; head.Transparency = stock.transp
                for d, t in pairs(stock.decals) do if d.Parent then d.Transparency = t end end
            end
            if stock.collider then stock.collider:Destroy() end
            if stock.fake then stock.fake:Destroy() end
        end
        
        for _, list in pairs(conexionesEscudo) do
            for _, c in ipairs(list) do c:Disconnect() end
        end
        
        if HitboxUI then HitboxUI:Destroy() end
        enviarEmbedDiscord("🛑 Script Desactivado", 16711680)
        pcall(function() script:Destroy() end)
    end
end)
