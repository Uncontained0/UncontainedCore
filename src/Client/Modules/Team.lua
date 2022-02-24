local Signal = require(game.ReplicatedStorage.Utility.Signal)
local TeamFolder = game.ReplicatedStorage.Teams

local Team = {}
Team._Teams = {}

function Team.new (Name:string)
	if Team._Teams[Name] then return Team._Teams[Name] end

	local self = {}
	setmetatable(self,{__index=Team})

	self._Object = TeamFolder[Name]

	self.Color = self._Object.Properties.Color.Value
	self.LayoutOrder = self._Object.Properties.LayoutOrder.Value

	self.PlayerAdded = Signal.new ()
	self.PlayerRemoved = Signal.new ()

	self._ChildAdded = self._Object.Players.ChildAdded:Connect(function(Child:ObjectValue)
		if not Child:IsA("ObjectValue") then return end
		self.PlayerAdded:Fire(Child.Value)
	end)

	self._ChildRemoved = self._Object.Players.ChildRemoved:Connect(function(Child:ObjectValue)
		if not Child:IsA("ObjectValue") then return end
		self.PlayerRemoved:Fire(Child.Value)
	end)

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

function Team:GetPlayers (): {Player}
	local List = {}
	for _,v in pairs(self._Object.Players:GetChildren()) do
		List[#List+1] = v.Value
	end
	return List
end

export type CustomTeam = typeof(Team.new())

return Team