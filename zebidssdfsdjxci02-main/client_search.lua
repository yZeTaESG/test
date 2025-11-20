-- Cliente Lua para manejar la búsqueda de jugadores cercanos
local uiOpen = false

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

-- Función para abrir/cerrar la UI
local function ToggleUI()
    uiOpen = not uiOpen
    SetNuiFocus(uiOpen, uiOpen)
    SendNUIMessage({
        action = "toggleUI",
        show = uiOpen
    })
end

-- Registrar el callback NUI para buscar jugador
RegisterNUICallback('searchNearbyPlayer', function(data, cb)
    local closestPlayer, distance = GetClosestPlayer()

    if closestPlayer ~= -1 and distance <= 2.0 then
        local targetPed = GetPlayerPed(closestPlayer)
        
        -- Forzar animación en el jugador objetivo
        ForceAnimationOnPlayer(targetPed)
        
        -- Abrir inventario del otro jugador
        TriggerEvent('ox_inventory:openInventory', 'otherplayer', GetPlayerServerId(closestPlayer))
        
        -- Notificación de éxito
        print("Jugador encontrado a " .. string.format("%.2f", distance) .. " metros")
    else
        print("No hay jugadores cercanos (dentro de 2 metros).")
    end
    
    cb('ok')
end)

-- Registrar callback para cerrar la UI
RegisterNUICallback('closeUI', function(data, cb)
    ToggleUI()
    cb('ok')
end)

-- Comando para abrir/cerrar la UI
RegisterCommand('searchui', function()
    ToggleUI()
end, false)

-- Tecla para abrir/cerrar la UI (F6 por defecto)
RegisterKeyMapping('searchui', 'Abrir/Cerrar UI de Búsqueda', 'keyboard', 'F6')

-- Abrir la UI automáticamente al cargar el script
Citizen.CreateThread(function()
    Wait(1000)
    ToggleUI()
    print("^2[Sistema de Búsqueda]^7 UI abierta. Presiona F6 para abrir/cerrar.")
end)

print("^2[Sistema de Búsqueda]^7 Script cargado correctamente.")
