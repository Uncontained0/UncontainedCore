local Event = require(script.Parent.ClientNet)
local Signal = require(game.ReplicatedStorage.Utility.Signal)

local PermissionsEvent = Event.new("LocalPermissions")

local LocalPlayer = {}

function LocalPlayer.HasPermission (Permission:string): Promise
    local Promise = PermissionsEvent:Call (Permission)
    return Promise
end

LocalPlayer.HealthChanged = Signal.new ()
LocalPlayer.CharacterAdded = Signal.new ()
LocalPlayer.Died = Signal.new ()

game.Players.LocalPlayer.CharacterAdded:Connect(function(Character:Model)
    local Humanoid = Character:WaitForChild("Humanoid")
    LocalPlayer.Humanoid = Humanoid
    LocalPlayer.Character = Character
    LocalPlayer.CharacterAdded:Fire (Character)
    Humanoid.HealthChanged:Connect(function()
        LocalPlayer.HealthChanged:Fire (Humanoid.Health)
    end)
    Humanoid.Died:Connect(function()
        LocalPlayer.Died:Fire ()
    end)
end)

return LocalPlayer