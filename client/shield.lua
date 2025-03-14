local gunAnim = nil
local holdingShield = false
local ox_inventory = exports.ox_inventory
local createdProps = {}
local shieldPositions = {
    onBack = {
        bone = 38,
        pos = vec3(0.0, -0.25, 0.0),
        rot = vec3(-10.0, 90.0, 0.0),
        rotationOrder = 1
    },
    inUse = {
        bone = 62,
        pos = vec3(-0.05, -0.06, -0.09),
        rot = vec3(-35.0, 180.0, 40.0),
        rotationOrder = 0
    }
}

local function createProp(ped, bone, pos, rot, rotationOrder)
    local model = `lspd_ballistic_shieldoff_d`
    lib.requestModel(model)

    local object = CreateObject(model, GetEntityCoords(ped), false, false, false)
    AttachEntityToEntity(object, ped, bone, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, false, false, true, true, rotationOrder, true)
    SetModelAsNoLongerNeeded(model)
    SetEntityNoCollisionEntity(ped, object, false)
    SetEntityCollision(object, false, true)

    return object
end

local function deleteAttachedProps(serverId)
    local playerProps = createdProps[serverId]
    if not playerProps then return end
    for i = 1, #playerProps do
        local prop = playerProps[i]
        if DoesEntityExist(prop) then
            DeleteEntity(prop)
        end
    end
    createdProps[serverId] = nil
end

RegisterNetEvent("onPlayerDropped", function(serverId)
    deleteAttachedProps(serverId)
end)

AddStateBagChangeHandler("Police:hasShield", nil, function(bagName, key, value, reserved, replicated)
    if replicated then return end

    local ply = GetPlayerFromStateBagName(bagName)
    if ply == 0 then return end

    local serverId = GetPlayerServerId(ply)
    if not value then
        return deleteAttachedProps(serverId)
    end

    createdProps[serverId] = { createProp(GetPlayerPed(ply), value.bone, value.pos, value.rot, value.rotationOrder) }
end)

local function setShieldState(status, position)
    LocalPlayer.state:set("Police:hasShield", status and position, true)
    SetPlayerSprint(cache.playerId, not status)
end

local function disableShield()
    local ped = cache.ped
    StopAnimTask(ped, "combat@gestures@gang@pistol_1h@beckon", "-90", 2.0)

    lib.RequestAnimDict("combat@gestures@gang@pistol_1h@beckon")
    TaskPlayAnim(ped, "combat@gestures@gang@pistol_1h@beckon", "-180", 8.0, -8.0, -1, 50, 0.0, false, false, false)

    Wait(500)
    StopAnimTask(ped, "combat@gestures@gang@pistol_1h@beckon", "-180", 2.0)
    Wait(200)
    SetPlayerSprint(cache.playerId, true)
    
    if gunAnim then
        exports["a_riotShield"]:setAimAnim("default")
    end

    LocalPlayer.state.blockHandsUp = false
    holdingShield = false
    setShieldState(false, shieldPositions.inUse)

    SetTimeout(50, function()
        ClearPedTasks(ped)
        SetControlNormal(0, 36, 1.0)
    end)

    return ox_inventory:Search("count", "shield") > 0 and setShieldState(true, shieldPositions.onBack)
end

local function enableShield()
    if holdingShield then
        return disableShield()
    end

    local ped = cache.ped
    local hasWeapon, weaponHash = GetCurrentPedWeapon(ped, true)
    if not hasWeapon or GetWeapontypeGroup(weaponHash) ~= 416676503 then
        return lib.notify({
            title = "You must hold a handgun",
            type = "inform"
        })
    end

    gunAnim = exports["a_riotShield"]:getAimAnim()
    exports["a_riotShield"]:setAimAnim("gang")

    LocalPlayer.state.blockHandsUp = true
    holdingShield = true

    lib.RequestAnimDict("combat@gestures@gang@pistol_1h@beckon")
    TaskPlayAnim(ped, "combat@gestures@gang@pistol_1h@beckon", "-90", 8.0, -8.0, -1, 50, 0.0, false, false, false)
    Wait(600)
    setShieldState(false, shieldPositions.onBack)
    setShieldState(true, shieldPositions.inUse)
    
    CreateThread(function()
        while holdingShield do
            Wait(0)
            DisableControlAction(0, 186, true)
            DisableControlAction(0, 36, true)

            local weapon = cache.weapon

            if not weapon or IsDisabledControlJustPressed(0, 186) then
                return disableShield()
            end

            if weapon and not IsEntityPlayingAnim(ped, "combat@gestures@gang@pistol_1h@beckon", "-90", 3) then
                lib.RequestAnimDict("combat@gestures@gang@pistol_1h@beckon")
                TaskPlayAnim(ped, "combat@gestures@gang@pistol_1h@beckon", "-90", 8.0, -8.0, -1, 50, 0.0, false, false, false)
            end

            if not GetPedStealthMovement(ped) then
                ForcePedMotionState(ped, 0x422d7a25, true, 1, false)
            end
        end
    end)
end

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    local count = ox_inventory:Search("count", "shield")
    return count > 0 and setShieldState(true, shieldPositions.onBack)
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    local count = ox_inventory:Search("count", "shield")
    return count > 0 and setShieldState(false, shieldPositions.onBack)
end)

exports("hasShield", function(status)
    setShieldState(status, shieldPositions.onBack)
end)

exports("useShield", function(data, slot)
    ox_inventory:useItem(data, function(data)
        if not data then return end
        enableShield()
    end)
end)