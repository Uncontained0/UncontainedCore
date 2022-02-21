local Utility = require(game.ReplicatedStorage.Utility.Utility)
local PhysicsService = game:GetService("PhysicsService")

PhysicsService:CreateCollisionGroup("Ragdolls")
PhysicsService:CreateCollisionGroup("Characters")
PhysicsService:CollisionGroupSetCollidable("Ragdolls","Ragdolls",true)
PhysicsService:CollisionGroupSetCollidable("Characters","Ragdolls",true)

local CharacterFolder = Utility.Create("Folder",{
	Name = "Characters",
	Parent = game.Workspace,
})

local RagdollFolder = Utility.Create("Folder",{
	Name = "Ragdolls",
	Parent = game.Workspace,
})

Utility.Each(game.Players,function(Player:Player)
	Player.CharacterAppearanceLoaded:Connect(function(Character:Model)
		Character.Parent = CharacterFolder
	end)
end)

return true