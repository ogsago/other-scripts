ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) 
    ESX = obj 
end)

RegisterServerEvent('courier:completeDelivery')
AddEventHandler('courier:completeDelivery', function()
    local src = source
    local reward = math.random(1500, 3500) -

    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        xPlayer.addMoney(reward)
        TriggerClientEvent('chat:addMessage', src, {
            args = {"System", "Otrzymałeś $" .. reward .. " za dostarczenie paczki!"}
        })
    else
        print("[CourierJob] Nie udało się znaleźć gracza o ID: " .. tostring(src))
    end
end)

RegisterServerEvent('courier:payReward')
AddEventHandler('courier:payReward', function(reward)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.addMoney(reward) 

        print(("[CourierJob] Gracz %s otrzymał $%d za dostarczenie paczki."):format(xPlayer.getIdentifier(), reward))

        TriggerClientEvent('chat:addMessage', source, {
            args = {"System", "Otrzymałeś $" .. reward .. " za dostarczenie paczki!"}
        })
    else
        print("[CourierJob] Nie udało się znaleźć gracza o ID: " .. tostring(source))
    end
end)