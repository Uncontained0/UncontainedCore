local Signal = require(game.ReplicatedStorage.Utility.Signal)

local LeaderboardFolder = game.ReplicatedStorage.Leaderboard
local LeaderstatFolder = game.ReplicatedStorage.Leaderstats

local Leaderboard = {}

Leaderboard.Leaderstat = {}
Leaderboard.Leaderstat._Cache = {}

LeaderstatFolder.ChildAdded:Connect(function(Child)
	Leaderboard.Leaderstat.new (Child.Name)
end)

function Leaderboard.Leaderstat.new (Name:string): Leaderstat
	if Leaderboard.Leaderstat._Cache[Name] then return Leaderboard.Leaderstat._Cache[Name] end

	local self = {}
	setmetatable(self,{__index=Leaderboard.Leaderstat})

	self.Name = Name
	self._Object = LeaderstatFolder[Name]
	self.Type = self._Object.Type.Value
	self.LayoutOrder = self._Object.LayoutOrder.Value 

	Leaderboard.Leaderstat._Cache[Name] = self

	return self
end

function Leaderboard.Leaderstat.getAll (): {Leaderstat}
	local List = {}
	for _,v in pairs(Leaderboard.Leaderstat._Cache) do
		List[#List+1] = v
	end
	return List
end

Leaderboard.Player = {}
Leaderboard.Player._Cache = {}

LeaderboardFolder.ChildAdded:Connect(function(Child)
	Leaderboard.Player.new (Child.Value)
end)

LeaderboardFolder.ChildRemoved:Connect(function(Child)
	Leaderboard.Player._Cache[Child.Name]:Destroy ()
end)

function Leaderboard.Player.new (Player:Player): LeaderboardPlayer
	if Leaderboard.Player._Cache[Player] then return Leaderboard.Player._Cache[Player] end

	local self = {}
	setmetatable(self,{__index=Leaderboard.Player})

	self.Player = Player
	self.Active = true
	self._Object = LeaderboardFolder[Player.Name]
	self.Position = self._Object.Properties.Position.Value

	self.Changed = Signal.new ()

	self._Object.Properties.Position.Changed:Connect(function()
		self.Position = self._Object.Properties.Position.Value
		self.Changed:Fire ()
	end)

	self._Object.Leaderstats.ChildAdded:Connect(function(Child)
		self.Changed:Fire ()
		Child.Changed:Connect(function()
			self.Changed:Fire ()
		end)
	end)

	Leaderboard.Player._Cache[Player] = self

	return self
end

function Leaderboard.Player:GetLeaderstatValue (Leaderstat:string): any
	return LeaderboardFolder[self.Player.Name].Leaderstats[Leaderstat].Value
end

export type Leaderstat = typeof(Leaderboard.Leaderstat.new())
export type LeaderboardPlayer = typeof(Leaderboard.Player.new())

return Leaderboard