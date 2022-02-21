local Event = require(script.Parent.ClientNet)

local PermissionsEvent = Event.new("LocalPermissions")
local VaultEvent = Event.new("LocalVault")

local LocalPlayer = {}

function LocalPlayer.VaultGet (Key:string): Promise
    local Promise = VaultEvent:Call (Key)
    return Promise
end

function LocalPlayer.HasPermission (Permission:string): Promise
    local Promise = PermissionsEvent:Call (Permission)
    return Promise
end

return LocalPlayer