local Cmdr = require(game.ReplicatedStorage:WaitForChild("CmdrClient"))
local LocalPlayer = require(script.Parent.LocalPlayer)

if LocalPlayer.HasPermission("VIEW_CMDR"):Await() then
    Cmdr:SetActivationKeys({Enum.KeyCode.BackSlash})
end

return Cmdr