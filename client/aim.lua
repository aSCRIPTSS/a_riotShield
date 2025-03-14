local animations = {
    default = `Default`,
    gang = `Gang1H`,
    hillbilly = `Hillbilly`
}

local function setAimAnim(anim)
    local animHash = animations[anim and anim:lower() or "default"]
    if not animHash then return end
    LocalPlayer.state:set("weaponAnimOverride", animHash, true)
end

AddStateBagChangeHandler("weaponAnimOverride", nil, function(bagName, key, value, reserved, replicated)
    if replicated or not value then return end
    local ply = GetPlayerFromStateBagName(bagName)
    if ply == 0 then return end
    SetWeaponAnimationOverride(GetPlayerPed(ply), value)
end)

lib.onCache("ped", function()
    local currentAnim = LocalPlayer.state.weaponAnimOverride
    if currentAnim then
        SetWeaponAnimationOverride(cache.ped, currentAnim)
    end
end)

exports("setAimAnim", setAimAnim)

exports("getAimAnim", function()
    return LocalPlayer.state.weaponAnimOverride or animations.default
end)