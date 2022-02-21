local Signal = require(game.ReplicatedStorage.Utility.Signal)
local Utility = require(game.ReplicatedStorage.Utility.Utility)

local TeamFolder = Utility.Create("Folder",{
	Name = "Teams",
	Parent = game.ReplicatedStorage,
})

local Team = {}
Team._Teams = {}

game.Players.PlayerRemoving:Connect(function(Player)
	local PastTeam = Team.fromPlayer(Player)
	if PastTeam then PastTeam:RemovePlayer(Player) end
end)

function Team.new (Name:string,Color:Color3): CustomTeam
	if Team._Teams[Name] then return Team._Teams[Name] end

	local self = {}
	setmetatable(self,{__index=Team})

	self._Object = Utility.Create("Folder",{
		Name = Name,
		Parent = TeamFolder,
	},{
		Utility.Create("Folder",{
			Name = "Properties",
		},{
			Utility.Create("Color3Value",{
				Name = "Color",
				Value = Color,
			})
		}),
		Utility.Create("Folder",{
			Name = "Players",
		})
	})

	self.PlayerAdded = Signal.new ()
	self.PlayerRemoved = Signal.new ()

	Team._Teams[Name] = self

	return self
end

function Team.fromPlayer (Player:Player): CustomTeam?
	for _,v:Folder in pairs(TeamFolder:GetChildren()) do
		for _,p:ObjectValue in pairs(v.Players:GetChildren()) do
			if p.Name == Player.Name then return Team._Teams[v.Name] end
		end
	end
end

function Team.getAll (): {CustomTeam}
	local List = {}
	for _,v in pairs(TeamFolder:GetChildren()) do
		List[#List+1] = Team.new(v.Name)
	end
	return List
end

function Team:AddPlayer (Player:Player)
	local PastTeam = Team.fromPlayer(Player)
	if PastTeam then PastTeam:RemovePlayer(Player) end
	Utility.Create("ObjectValue",{
		Name = Player.Name,
		Value = Player,
		Parent = self._Object.Players
	})
	self.PlayerAdded:Fire (Player)
end

function Team:RemovePlayer (Player:Player)
	if self._Object.Players:FindFirstChild(Player.Name) then
		self._Object.Players[Player.Name]:Destroy ()
		self.PlayerRemoved:Fire (Player)
	end
end

function Team:GetPlayers (): {Player}
	local List = {}
	for _,v in pairs(self._Object.Players:GetChildren()) do
		List[#List+1] = v.Value
	end
	return List
end

export type CustomTeam = typeof(Team.new())

return Team