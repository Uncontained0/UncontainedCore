local Event = require(script.Parent.ClientNet)

local PermissionsEvent = Event.new("LocalPermissions")

local LocalPlayer = {}

function LocalPlayer.HasPermission (Permission:string): Promise
    local Promise = PermissionsEvent:Call (Permission)
    return Promise
end

return LocalPlayer