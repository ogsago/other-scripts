ESX = nil
local isOnJob = false
local currentPickup = nil
local currentDelivery = nil
local courierVehicle = nil
local jobStartLocation = vector3(52.07, 109.79, 79.16) 
local returnLocation = vector3(55.9629, 90.8497, 78.6547) 
local pickupLocation = vector3(-628.72, 239.10, 81.90) 
local hasPackage = false 
local deliveryBlip = nil 
local pickupBlip = nil 
local pickupMarkerVisible = true 
local deliveryMarkerVisible = false 
local deliveryLocation = vector3(432.59, -981.76, 30.71) 

Citizen.CreateThread(function()
    print("Rozpoczęcie inicjalizacji ESX...")
    ESX = exports['es_extended']:getSharedObject()

    if ESX then
        print("ESX został poprawnie załadowany!") 
    else
        print("Nie udało się załadować ESX!") 
    end
end)


    ESX = exports['es_extended']:getSharedObject()

    if ESX then
        print("ESX został poprawnie załadowany!") 
    else
        print("Nie udało się załadować ESX!") 
    end

function IsCourier()
    local playerData = ESX.GetPlayerData()
    return playerData.job and playerData.job.name == "kurier"
end

function GetRandomCityLocation()
    local cityLocations = {
        vector3(200.0, -800.0, 30.0),
        vector3(300.0, -700.0, 30.0),
        vector3(400.0, -600.0, 30.0),
        vector3(500.0, -500.0, 30.0),
        vector3(600.0, -400.0, 30.0)
    }
    return cityLocations[math.random(#cityLocations)]
end

function StartCourierJob()
    if not IsCourier() then
        print("Musisz być zatrudniony jako kurier, aby rozpocząć pracę!")
        ESX.ShowNotification("Musisz być zatrudniony jako kurier, aby rozpocząć pracę!")
        return
    end

    if isOnJob then
        print("Już jesteś w trakcie pracy!")
        ESX.ShowNotification("Już jesteś w trakcie pracy!")
        return
    end

    isOnJob = true
    hasPackage = false 
    currentPickup = pickupLocation 
    currentDelivery = GetRandomCityLocation() 
    pickupBlip = CreateBlip(currentPickup, "Odbiór paczki")
    pickupMarkerVisible = true 

    print("Rozpoczęto pracę kuriera. Udaj się do miejsca odbioru paczki.")
    ESX.ShowNotification("Rozpoczęto pracę kuriera. Udaj się do miejsca odbioru paczki.")

    SpawnCourierVehicle()
end

function FinishCourierJob()
    if not isOnJob then
        print("Nie masz aktywnej pracy!")
        return
    end

    local reward = math.random(1500, 3500) 

    TriggerServerEvent('courier:payReward', reward)

    isOnJob = false
    currentPickup = nil
    currentDelivery = nil
    print("Dziękujemy za dostarczenie paczki! Otrzymałeś $" .. reward)
    ESX.ShowNotification("Dziękujemy za dostarczenie paczki! Otrzymałeś $" .. reward)

    CreateBlip(returnLocation, "Zwrot pojazdu")
    print("Odstaw pojazd na wyznaczone miejsce, aby zakończyć zlecenie.")
end

function ReturnCourierVehicle()
    if courierVehicle then
        DeleteEntity(courierVehicle)
        courierVehicle = nil
        print("Pojazd został zwrócony. Zlecenie zakończone!")
    else
        print("Nie masz pojazdu do zwrotu!")
    end
end

function CreateBlip(location, label)
    local blip = AddBlipForCoord(location.x, location.y, location.z)
    SetBlipSprite(blip, 1)
    SetBlipColour(blip, 2)
    SetBlipScale(blip, 0.8)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)
    return blip 
end

function SpawnCourierVehicle()
    local vehicleModel = GetHashKey("burrito")

    RequestModel(vehicleModel)
    while not HasModelLoaded(vehicleModel) do
        Citizen.Wait(0)
    end

    local spawnLocation = vector3(58.04, 96.55, 78.91)
    local spawnHeading = 157.4172

    courierVehicle = CreateVehicle(vehicleModel, spawnLocation.x, spawnLocation.y, spawnLocation.z, spawnHeading, true, false)
    SetVehicleNumberPlateText(courierVehicle, "KURIER")

    local playerPed = PlayerPedId()
    TaskWarpPedIntoVehicle(playerPed, courierVehicle, -1)
end

function DrawMarkerAtLocation(location)
    DrawMarker(1, location.x, location.y, location.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 1.0, 0, 191, 255, 100, false, true, 2, nil, nil, false)
end

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(jobStartLocation.x, jobStartLocation.y, jobStartLocation.z)
    SetBlipSprite(blip, 477) 
    SetBlipColour(blip, 5) 
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Praca Kuriera")
    EndTextCommandSetBlipName(blip)

    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - jobStartLocation)

        DrawMarkerAtLocation(jobStartLocation)

        if distance < 5.0 then
            ESX.ShowHelpNotification("Naciśnij ~INPUT_CONTEXT~, aby rozpocząć pracę kuriera.") 
            if IsControlJustPressed(1, 38) then 
                StartCourierJob()
            end
        end
    end
end)

Citizen.CreateThread(function()
    pickupBlip = CreateBlip(pickupLocation, "Odbiór paczki") 

    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - pickupLocation)

        if pickupMarkerVisible then
            DrawMarkerAtLocation(pickupLocation)
        end
        

        if distance < 5.0 and isOnJob and not hasPackage then
            ESX.ShowHelpNotification("Naciśnij ~INPUT_CONTEXT~, aby odebrać paczkę.") 
            if IsControlJustPressed(1, 38) then 
                hasPackage = true 
                pickupMarkerVisible = false 
                print("Paczka została odebrana!")
                ESX.ShowNotification("Paczka została odebrana. Udaj się do miejsca dostawy.") 

                if pickupBlip then
                    RemoveBlip(pickupBlip)
                    pickupBlip = nil
                end

                deliveryMarkerVisible = true
                pickupBlipVisible = false
            end
        end
    end
end)

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(returnLocation.x, returnLocation.y, returnLocation.z)
    SetBlipSprite(blip, 1) 
    SetBlipColour(blip, 3) 
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Zwrot pojazdu")
    EndTextCommandSetBlipName(blip)

    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - returnLocation)

        DrawMarkerAtLocation(returnLocation)

        if distance < 5.0 and courierVehicle then
            ESX.ShowHelpNotification("Naciśnij ~INPUT_CONTEXT~, aby zwrócić pojazd i zakończyć zlecenie.") 
            if IsControlJustPressed(1, 38) then 
                ReturnCourierVehicle()
                break
            end
        end
    end
end)


Citizen.CreateThread(function()

    deliveryBlip = CreateBlip(deliveryLocation, "Dostawa paczki")

    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - deliveryLocation)

        if deliveryMarkerVisible then
            DrawMarkerAtLocation(deliveryLocation)
        end

        if distance < 5.0 and hasPackage then
            ESX.ShowHelpNotification("Naciśnij ~INPUT_CONTEXT~, aby dostarczyć paczkę.") 
            if IsControlJustPressed(1, 38) then 
                hasPackage = false 
                deliveryMarkerVisible = false 
                print("Paczka została dostarczona!")
                ESX.ShowNotification("Paczka została dostarczona. Gratulacje!")

                
                if deliveryBlip then
                    RemoveBlip(deliveryBlip)
                    deliveryBlip = nil
                end

                FinishCourierJob() 
            end
        end
    end
end)

Citizen.CreateThread(function()
    deliveryBlip = CreateBlip(deliveryLocation, "Dostawa paczki")
    SetBlipColour(deliveryBlip, 1) 
end)


