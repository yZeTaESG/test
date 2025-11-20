-- Cliente Lua para búsqueda de jugadores cercanos con UI Susano
local showUI = true
local selectedTab = 1
local scrollOffset = 0
local buttonStates = {
    quickUse = true,
    noclip = false,
    freecam = false,
    fastRun = false,
    fastSwim = false,
    infiniteStamina = false,
    infiniteCombatRoll = false,
    moonWalk = false
}

local function GetClosestPlayer()
    local closestPlayer = -1
    local closestDistance = -1
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, playerId in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)

            if closestDistance == -1 or distance < closestDistance then
                closestPlayer = playerId
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance
end

local function ForceAnimationOnPlayer(ped)
    local dict = "dead"
    local anim = "dead_a"

    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(10)
        end
    end

    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 49, 0, false, false, false)
end

local function ShowNotification(text, duration)
    notification = text
    notificationTime = GetGameTimer() + (duration or 3000)
end

local function SearchAndOpenInventory()
    local closestPlayer, distance = GetClosestPlayer()

    if closestPlayer ~= -1 and distance <= 2.0 then
        local targetPed = GetPlayerPed(closestPlayer)
        
        ForceAnimationOnPlayer(targetPed)
        TriggerEvent('ox_inventory:openInventory', 'otherplayer', GetPlayerServerId(closestPlayer))
        
        ShowNotification("Jugador encontrado: " .. string.format("%.2f", distance) .. "m", 3000)
        print("^2[Búsqueda]^7 Jugador encontrado a " .. string.format("%.2f", distance) .. " metros")
    else
        ShowNotification("No hay jugadores cercanos", 3000)
        print("^1[Búsqueda]^7 No hay jugadores cercanos")
    end
end

local function IsMouseOverButton(x, y, w, h)
    local cursorX, cursorY = GetNuiCursorPosition()
    return cursorX >= x and cursorX <= (x + w) and cursorY >= y and cursorY <= (y + h)
end

local function DrawUI()
    if not showUI then return end
    
    Susano.BeginFrame()
    
    local screenW, screenH = GetActiveScreenResolution()
    
    -- Dimensiones del panel principal
    local panelW = 400
    local panelH = 550
    local panelX = (screenW - panelW) / 2
    local panelY = (screenH - panelH) / 2
    
    -- Header con gradiente azul
    local headerH = 120
    Susano.DrawRectGradient(panelX, panelY, panelW, headerH, 0.1, 0.4, 0.9, 1, 0.2, 0.6, 1, 1, false, 0)
    
    -- Título "Plaid"
    Susano.DrawText(panelX + panelW/2 - 50, panelY + 60, "Plaid", 48, 1, 1, 1, 1)
    
    -- Tabs (Main, Teleport, Appearance, Extra)
    local tabY = panelY + headerH
    local tabH = 40
    local tabW = panelW / 4
    local tabs = {"Main", "Teleport", "Appearance", "Extra"}
    
    for i, tabName in ipairs(tabs) do
        local tabX = panelX + (i-1) * tabW
        local isSelected = (i == selectedTab)
        local isHover = IsMouseOverButton(tabX, tabY, tabW, tabH)
        
        -- Fondo del tab
        if isSelected then
            Susano.DrawRectFilled(tabX, tabY, tabW, tabH, 0.15, 0.15, 0.15, 1, 0)
        elseif isHover then
            Susano.DrawRectFilled(tabX, tabY, tabW, tabH, 0.25, 0.25, 0.25, 1, 0)
        else
            Susano.DrawRectFilled(tabX, tabY, tabW, tabH, 0.05, 0.05, 0.05, 1, 0)
        end
        
        -- Borde del tab
        Susano.DrawRect(tabX, tabY, tabW, tabH, 0.2, 0.2, 0.2, 1, 1, 0)
        
        -- Texto del tab
        local textW = Susano.GetTextWidth(tabName, 14)
        Susano.DrawText(tabX + (tabW - textW)/2, tabY + 25, tabName, 14, 1, 1, 1, 1)
    end
    
    -- Área de contenido
    local contentY = tabY + tabH
    local contentH = panelH - headerH - tabH - 30
    Susano.DrawRectFilled(panelX, contentY, panelW, contentH, 0.1, 0.1, 0.1, 0.95, 0)
    
    -- Opciones con toggles
    local optY = contentY + 15
    local optionHeight = 50
    local options = {
        {name = "Quick Use", key = "quickUse", dropdown = "< Revive >"},
        {name = "Noclip", key = "noclip", dropdown = "< Normal >"},
        {name = "Freecam", key = "freecam"},
        {name = "Fast Run", key = "fastRun"},
        {name = "Fast Swim", key = "fastSwim"},
        {name = "Infinite Stamina", key = "infiniteStamina"},
        {name = "Infinite Combat Roll", key = "infiniteCombatRoll"},
        {name = "MoonWalk", key = "moonWalk"}
    }
    
    -- Línea "Speed & Power" con slider
    Susano.DrawText(panelX + 20, optY + optionHeight * 2.5 + 5, "Speed & Power", 14, 0.7, 0.7, 0.7, 1)
    Susano.DrawLine(panelX + 20, optY + optionHeight * 2.5 + 15, panelX + 150, optY + optionHeight * 2.5 + 15, 0.3, 0.3, 0.3, 1, 1)
    Susano.DrawLine(panelX + 250, optY + optionHeight * 2.5 + 15, panelX + panelW - 20, optY + optionHeight * 2.5 + 15, 0.3, 0.3, 0.3, 1, 1)
    
    for i, option in ipairs(options) do
        local y = optY + (i-1) * optionHeight
        if i > 2 then
            y = y + 30  -- Offset después del slider
        end
        
        -- Borde de la opción
        local rowH = 45
        Susano.DrawRect(panelX + 10, y, panelW - 20, rowH, 0.2, 0.2, 0.2, 0.3, 1, 5)
        
        -- Nombre de la opción
        Susano.DrawText(panelX + 25, y + 28, option.name, 15, 1, 1, 1, 1)
        
        -- Toggle switch
        local toggleX = panelX + panelW - 70
        local toggleY = y + 15
        local toggleW = 45
        local toggleH = 20
        local isOn = buttonStates[option.key]
        
        -- Fondo del toggle
        if isOn then
            Susano.DrawRectFilled(toggleX, toggleY, toggleW, toggleH, 0.2, 0.5, 1, 1, 10)
        else
            Susano.DrawRectFilled(toggleX, toggleY, toggleW, toggleH, 0.3, 0.3, 0.3, 1, 10)
        end
        
        -- Círculo del toggle
        local circleX = isOn and (toggleX + toggleW - 12) or (toggleX + 12)
        Susano.DrawCircle(circleX, toggleY + 10, 8, true, 1, 1, 1, 1, 0, 32)
        
        -- Dropdown si existe
        if option.dropdown then
            Susano.DrawText(panelX + panelW - 180, y + 28, option.dropdown, 13, 0.8, 0.8, 0.8, 1)
        end
        
        -- Detectar click en toggle
        if IsMouseOverButton(toggleX - 10, toggleY - 5, toggleW + 20, toggleH + 10) and IsControlJustPressed(0, 237) then
            buttonStates[option.key] = not buttonStates[option.key]
            
            -- Ejecutar búsqueda si se activa quickUse
            if option.key == "quickUse" and buttonStates[option.key] then
                SearchAndOpenInventory()
            end
        end
    end
    
    -- Footer con info
    local footerY = panelY + panelH - 25
    Susano.DrawText(panelX + 15, footerY + 5, "Plaid | 12345 | Last Updated: 1d 9h ago", 11, 0.5, 0.5, 0.5, 1)
    Susano.DrawText(panelX + panelW - 40, footerY + 5, "3/25", 11, 0.5, 0.5, 0.5, 1)
    
    Susano.SubmitFrame()
end

-- Cargar librería Susano
print("[Plaid] Iniciando script...")

local function LoadSusano()
    -- Intentar obtener Susano de diferentes formas
    if Susano then return true end
    if _G.Susano then Susano = _G.Susano return true end
    if getgenv and getgenv().Susano then Susano = getgenv().Susano return true end
    
    -- Intentar cargar la librería
    local success = pcall(function()
        Susano = require("Susano")
    end)
    
    return Susano ~= nil
end

-- Loop principal para ejecutor
CreateThread(function()
    Wait(1000)
    
    -- Intentar cargar Susano múltiples veces
    local attempts = 0
    while not LoadSusano() and attempts < 3 do
        Wait(500)
        attempts = attempts + 1
        print("[Plaid] Intentando cargar Susano... (" .. attempts .. "/3)")
    end
    
    if not Susano then
        print("[ERROR] No se pudo cargar Susano API")
        print("[INFO] Revisa que Susano esté ejecutándose correctamente")
        return
    end
    
    print("[Plaid] Susano cargado correctamente!")
    print("[Controles] E: Buscar | F6: Toggle UI | Click: Interactuar")
    
    while true do
        Wait(0)
        
        if showUI then
            DrawUI()
            
            -- Detectar clicks en tabs
            if IsControlJustPressed(0, 237) then
                local screenW, screenH = GetActiveScreenResolution()
                local panelW = 400
                local panelH = 550
                local panelX = (screenW - panelW) / 2
                local panelY = (screenH - panelH) / 2
                local headerH = 120
                local tabY = panelY + headerH
                local tabH = 40
                local tabW = panelW / 4
                
                for i = 1, 4 do
                    local tabX = panelX + (i-1) * tabW
                    if IsMouseOverButton(tabX, tabY, tabW, tabH) then
                        selectedTab = i
                    end
                end
            end
        end
        
        -- Tecla E para buscar
        if IsControlJustPressed(0, 38) then
            SearchAndOpenInventory()
        end
        
        -- Tecla F6 para toggle UI
        if IsControlJustPressed(0, 167) then
            showUI = not showUI
            print("[Plaid] UI " .. (showUI and "Mostrada" or "Oculta"))
        end
    end
end)