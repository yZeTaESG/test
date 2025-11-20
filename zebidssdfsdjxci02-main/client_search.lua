-- Cliente Lua para manejar la búsqueda de jugadores cercanos
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

-- Registrar el callback NUI
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
    
    -- Responder al callback
    cb('ok')
end)

print("^2[Sistema de Búsqueda]^7 Script de búsqueda de jugadores cercanos cargado correctamente.")
