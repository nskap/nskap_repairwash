local ESX = ESX or (exports["es_extended"] and exports["es_extended"]:getSharedObject())
local using = false


local function hasJob()
    if not Config.JobRequired then return true end
    if not ESX or not ESX.GetPlayerData then return false end
    local xPlayer = ESX.GetPlayerData()
    if not xPlayer or not xPlayer.job then return false end
    for _, job in ipairs(Config.AllowedJobs) do
        if xPlayer.job.name == job then
            return true
        end
    end
    return false
end


local function canInteractVehicle(entity, distance)
    if not DoesEntityExist(entity) or GetEntityType(entity) ~= 2 then return false end
    if distance and distance > (Config.Target.distance or 2.0) then return false end
    if Config.RequireOnFoot and IsPedInAnyVehicle(PlayerPedId(), false) then return false end
    if not hasJob() then return false end
    return true
end


local function loadAnimDict(dict)
    if not dict or dict == '' then return false end
    if HasAnimDictLoaded(dict) then return true end
    RequestAnimDict(dict)
    local start = GetGameTimer()
    while not HasAnimDictLoaded(dict) do
        if GetGameTimer() - start > 5000 then return false end
        Wait(0)
    end
    return true
end


local function progress(label, duration, action)
    local opts = {
        duration = duration,
        label = label,
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true }
    }

    if action and Config.Anims and Config.Anims[action] then
        local a = Config.Anims[action]
        if a.type == 'dict' and a.dict and a.clip and loadAnimDict(a.dict) then
            opts.anim = { dict = a.dict, clip = a.clip, flag = a.flag or 49 }
        end
    end

    return lib.progressBar(opts)
end


local function doRepair(entity)
    if using then return end
    if not canInteractVehicle(entity) then return end
    using = true

    local item = Config.RepairItem
    if not lib.callback.await('vehmaint:hasItem', 5000, item) then
        using = false
        lib.notify({ type = 'error', description = ('Chybí předmět: %s'):format(item) })
        return
    end

    local ok = progress(Config.Target.repair.label, Config.RepairDuration, 'repair')
    if not ok then using = false return end

    SetVehicleUndriveable(entity, false)
    SetVehicleFixed(entity)
    SetVehicleEngineHealth(entity, 1000.0)
    SetVehiclePetrolTankHealth(entity, 1000.0)
    if Config.CleanOnRepair then
        
        WashDecalsFromVehicle(entity, 1.0)
        SetVehicleDirtLevel(entity, 0.0)
    end

    if Config.ConsumeOnSuccess then
        local consumed = lib.callback.await('vehmaint:consumeItem', 5000, item, 1)
        if not consumed then
            lib.notify({ type = 'warning', description = 'Nepodařilo se odebrat předmět.' })
        end
    end

    lib.notify({ type = 'success', description = 'Vozidlo opraveno.' })
    using = false
end


local function doWash(entity)
    if using then return end
    if not canInteractVehicle(entity) then return end
    using = true

    local item = Config.WashItem
    if not lib.callback.await('vehmaint:hasItem', 5000, item) then
        using = false
        lib.notify({ type = 'error', description = ('Chybí předmět: %s'):format(item) })
        return
    end

    local ok = progress(Config.Target.wash.label, Config.WashDuration, 'wash')
    if not ok then using = false return end

    WashDecalsFromVehicle(entity, 1.0)
    SetVehicleDirtLevel(entity, 0.0)

    if Config.ConsumeOnSuccess then
        local consumed = lib.callback.await('vehmaint:consumeItem', 5000, item, 1)
        if not consumed then
            lib.notify({ type = 'warning', description = 'Nepodařilo se odebrat předmět.' })
        end
    end

    lib.notify({ type = 'success', description = 'Vozidlo umyto.' })
    using = false
end


local function doAction(entity, action)
    if action == 'repair' then
        doRepair(entity)
    elseif action == 'wash' then
        doWash(entity)
    end
end


CreateThread(function()
    exports.ox_target:addGlobalVehicle({
        {
            icon = Config.Target.repair.icon,
            label = Config.Target.repair.label,
            distance = Config.Target.distance,
            canInteract = function(entity, distance)
                if not canInteractVehicle(entity, distance) then return false end
                local engHealth = GetVehicleEngineHealth(entity)
                if Config.RepairAlways then return true end
                return engHealth < Config.MinEngineHealthForRepair
            end,
            onSelect = function(data)
                doAction(data.entity, 'repair')
            end
        },
        {
            icon = Config.Target.wash.icon,
            label = Config.Target.wash.label,
            distance = Config.Target.distance,
            canInteract = function(entity, distance)
                return canInteractVehicle(entity, distance)
            end,
            onSelect = function(data)
                doAction(data.entity, 'wash')
            end
        }
    })
end)
