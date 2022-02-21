local Utility = require(game.ReplicatedStorage.Utility.Utility)

local Replicater = {}
Replicater._Cache = {}

function Replicater.new (Player:Player): Replicater
    if Replicater.Cache[Player] then return Replicater._Cache[Player] end 

    local self = {}
    setmetatable(self,{__index=Replicater})

    self.Player = Player
    self.Folder = Utility.Create("ScreenGui",{
        Name = "Replicated",
        Enabled = false,
        ResetOnSpawn = false,
        Parent = Player.PlayerGui,
    })
    self.Replicated = {}

    return self
end

function Replicater:Replicate (Object:Instance)
    if self.Replicated[Object] then return end
    Object = Object:Clone()
    self.Replicated[Object] = true
    Object.Parent = self.Folder
end

export type Replicater = typeof(Replicater.new())

return Replicater