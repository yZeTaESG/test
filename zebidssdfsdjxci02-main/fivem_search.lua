-- Script de búsqueda de jugadores para FiveM con UI estilo Plaid
print("[Plaid] Script cargado para FiveM")
print("[Controles] E: Buscar | F6: Toggle UI | Click: Interactuar")

local showUI = true
local selectedTab = 1
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

-- Funciones de dibujo helper
local function DrawTextUI(text, x, y, scale, font, r, g, b, a, center)
    SetTextFont(font or 4)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextOutline()
    if center then
        SetTextCentre(true)
    end
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

local function DrawRectUI(x, y, w, h, r, g, b, a)
    DrawRect(x + w/2, y + h/2, w, h, r, g, b, a)
end

local selectedButton = 1
local maxButtons = 8

local function IsMouseInBounds(x, y, w, h)
    return false -- Usaremos teclado en su lugar
end

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

local function SearchAndOpenInventory()
    local closestPlayer, distance = GetClosestPlayer()

    if closestPlayer ~= -1 and distance <= 2.0 then
        local targetPed = GetPlayerPed(closestPlayer)
        
        ForceAnimationOnPlayer(targetPed)
        TriggerEvent('ox_inventory:openInventory', 'otherplayer', GetPlayerServerId(closestPlayer))
        
        print("^2[Búsqueda]^7 Jugador encontrado a " .. string.format("%.2f", distance) .. " metros")
    else
        print("^1[Búsqueda]^7 No hay jugadores cercanos (dentro de 2 metros).")
    end
end

-- Dibujar la UI
local function DrawPlaidUI()
    if not showUI then return end
    
    local baseX, baseY = 0.05, 0.05
    local uiWidth, uiHeight = 0.25, 0.60
    
    -- Fondo principal con gradiente azul
    DrawRectUI(baseX, baseY, uiWidth, 0.08, 41, 128, 185, 255) -- Header azul
    DrawRectUI(baseX, baseY + 0.08, uiWidth, uiHeight - 0.08, 30, 30, 30, 230) -- Fondo oscuro
    
    -- Título "Plaid"
    DrawTextUI("Plaid", baseX + uiWidth/2, baseY + 0.015, 0.7, 4, 255, 255, 255, 255, true)
    
    -- Tabs
    local tabs = {"Main", "Teleport", "Appearance", "Extra"}
    local tabY = baseY + 0.08
    local tabWidth = uiWidth / 4
    
    for i, tab in ipairs(tabs) do
        local tabX = baseX + (i-1) * tabWidth
        local isSelected = i == selectedTab
        
        DrawRectUI(tabX, tabY, tabWidth, 0.04, 20, 20, 20, 255)
        
        if isSelected then
            DrawRectUI(tabX, tabY + 0.038, tabWidth, 0.002, 41, 128, 185, 255) -- Línea azul
        end
        
        DrawTextUI(tab, tabX + tabWidth/2, tabY + 0.008, 0.35, 4, 
            isSelected and 255 or 180, 
            isSelected and 255 or 180, 
            isSelected and 255 or 180, 255, true)
        
        -- No tab click for now
    end
    
    -- Contenido del tab Main
    if selectedTab == 1 then
        local buttonY = tabY + 0.055
        local buttonHeight = 0.05
        local buttonSpacing = 0.008
        
        local buttons = {
            {name = "Quick Use", key = "quickUse", desc = "< Revive >"},
            {name = "Noclip", key = "noclip", desc = "< Normal >"},
            {name = "Freecam", key = "freecam"},
            {name = "Fast Run", key = "fastRun"},
            {name = "Fast Swim", key = "fastSwim"},
            {name = "Infinite Stamina", key = "infiniteStamina"},
            {name = "Infinite Combat Roll", key = "infiniteCombatRoll"},
            {name = "MoonWalk", key = "moonWalk"}
        }
        
        for i, button in ipairs(buttons) do
            local bY = buttonY + (i-1) * (buttonHeight + buttonSpacing)
            local isHovered = IsMouseInBounds(baseX + 0.01, bY, uiWidth - 0.02, buttonHeight)
            
            -- Fondo del botón
            DrawRectUI(baseX + 0.01, bY, uiWidth - 0.02, buttonHeight, 
                isHovered and 50 or 40, 
                isHovered and 50 or 40, 
                isHovered and 50 or 40, 255)
            
            -- Línea azul izquierda si está activo
            if buttonStates[button.key] then
                DrawRectUI(baseX + 0.01, bY, 0.003, buttonHeight, 41, 128, 185, 255)
            end
            
            -- Texto del botón
            DrawTextUI(button.name, baseX + 0.02, bY + 0.012, 0.35, 4, 255, 255, 255, 255, false)
            
            -- Descripción o toggle
            if button.desc then
                DrawTextUI(button.desc, baseX + uiWidth - 0.08, bY + 0.012, 0.30, 4, 180, 180, 180, 255, false)
            else
                -- Toggle switch
                local toggleX = baseX + uiWidth - 0.04
                local toggleY = bY + 0.015
                DrawRectUI(toggleX - 0.02, toggleY - 0.01, 0.03, 0.02, 60, 60, 60, 255)
                if buttonStates[button.key] then
                    DrawRectUI(toggleX - 0.005, toggleY - 0.008, 0.015, 0.016, 41, 128, 185, 255)
                else
                    DrawRectUI(toggleX - 0.022, toggleY - 0.008, 0.015, 0.016, 100, 100, 100, 255)
                end
            end
            
            -- Highlight si está seleccionado
            if i == selectedButton then
                DrawRectUI(baseX + 0.008, bY - 0.002, uiWidth - 0.016, buttonHeight + 0.004, 41, 128, 185, 100)
            end
        end
    end
    
    -- Footer
    local footerY = baseY + uiHeight - 0.03
    DrawRectUI(baseX, footerY, uiWidth, 0.03, 20, 20, 20, 255)
    
    DrawTextUI("Plaid | 20/11 | Last Updated: 1d ago", baseX + 0.01, footerY + 0.007, 0.28, 4, 150, 150, 150, 255, false)
    DrawTextUI("3/25", baseX + uiWidth - 0.02, footerY + 0.007, 0.28, 4, 150, 150, 150, 255, false)
end

-- Loop principal
CreateThread(function()
    while true do
        Wait(0)
        
        -- F6 para toggle UI
        if IsControlJustPressed(0, 167) then -- F6 key
            showUI = not showUI
        end
        
        -- DELETE para eliminar el menu completamente
        if IsControlJustPressed(0, 178) then -- DELETE key
            print("[Plaid] Menu eliminado - reinicia el script para volver a usarlo")
            return -- Sale del loop y termina el script
        end
        
        if showUI then
            -- Flecha arriba
            if IsControlJustPressed(0, 172) then -- Arrow Up
                selectedButton = selectedButton - 1
                if selectedButton < 1 then selectedButton = maxButtons end
            end
            
            -- Flecha abajo
            if IsControlJustPressed(0, 173) then -- Arrow Down
                selectedButton = selectedButton + 1
                if selectedButton > maxButtons then selectedButton = 1 end
            end
            
            -- Enter para activar botón
            if IsControlJustPressed(0, 191) then -- Enter key
                local buttons = {
                    {name = "Quick Use", key = "quickUse"},
                    {name = "Noclip", key = "noclip"},
                    {name = "Freecam", key = "freecam"},
                    {name = "Fast Run", key = "fastRun"},
                    {name = "Fast Swim", key = "fastSwim"},
                    {name = "Infinite Stamina", key = "infiniteStamina"},
                    {name = "Infinite Combat Roll", key = "infiniteCombatRoll"},
                    {name = "MoonWalk", key = "moonWalk"}
                }
                
                local button = buttons[selectedButton]
                if button.key == "quickUse" then
                    SearchAndOpenInventory()
                else
                    buttonStates[button.key] = not buttonStates[button.key]
                    print("[Plaid] " .. button.name .. ": " .. (buttonStates[button.key] and "ON" or "OFF"))
                end
            end
        end
        
        -- Tecla E para buscar (sin UI visible)
        if IsControlJustPressed(0, 38) and not showUI then
            SearchAndOpenInventory()
        end
        
        -- Dibujar UI
        if showUI then
            DrawPlaidUI()
        end
    end
end)
