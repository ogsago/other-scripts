local Config = {}

Config.PickupLocations = {
    vector3(-628.72, 239.10, 81.90),
    vector3(),
    vector3(),
    vector3(),
}

Config.DeliveryLocations = {
    vector3(58.04, 96.55, 78.91),
    vector3(),
    vector3(),
    vector3()
}

Config.VehicleSettings = {
    vehicleModel = "delivery_van",
    maxSpeed = 80,
    fuelConsumption = 0.1,
}

Config.Payment = {
    baseRate = 100,
    bonusRate = 50,
}

return Config