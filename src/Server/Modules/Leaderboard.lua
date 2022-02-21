local Utility = require(game.ReplicatedStorage.Utility.Utility)
local Signal = require(game.ReplicatedStorage.Utility.Signal)

local LeaderboardFolder = Utility.Create("Folder",{
	Name = "Leaderboard",
	Parent = game.ReplicatedStorage,
})

local LeaderstatFolder = Utility.Create("Folder",{
	Name = "Leaderstats",
	Parent = game.ReplicatedStorage,
})

local Leaderboard = {}

game.Players.PlayerRemoving:Connect(function(Player:Player)
	if Leaderboard.Player._Cache[Player] ~= nil then Leaderboard.Players._Cache[Player]:Destroy () end
end)

Leaderboard.Leaderstat = {}
Leaderboard.Leaderstat._Cache = {}

function Leaderboard.Leaderstat.new (Name:string,Type:string?,ScoreWeight:number?,LayoutOrder:number,DefaultValue:any?): Leaderstat
	if Leaderboard.Leaderstat._Cache[Name] then return Leaderboard.Leaderstat._Cache[Name] end

	local self = {}
	setmetatable(self,{__index=Leaderboard.Leaderstat})

	self.Name = Name
	self.Type = Type
	self.ScoreWeight = ScoreWeight or 0
	self.LayoutOrder = LayoutOrder or 0
	self.DefaultValue = DefaultValue

	Utility.Create("Folder",{
		Name = Name,
		Parent = LeaderstatFolder,
	},{
		Utility.Create("StringValue",{
			Name = "Type",
			Value = Type,
		}),
		Utility.Create("IntValue",{
			Name = "LayoutOrder",
			Value = self.LayoutOrder,
		}),
	})

	Leaderboard.Leaderstat._Cache[Name] = self

	for _,v in pairs(Leaderboard.Player._Cache) do
		v:_AddLeaderstat (self)
	end

	Leaderboard.Player.CalculatePositions ()

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

function Leaderboard.Player.new (Player:Player): LeaderboardPlayer
	if Leaderboard.Player._Cache[Player] then return Leaderboard.Player._Cache[Player] end

	local self = {}
	setmetatable(self,{__index=Leaderboard.Player})

	self.Player = Player
	self.Active = true
	self.Position = 0
	self._Object = Utility.Create("ObjectValue",{
		Name = Player.Name,
		Value = Player,
		Parent = LeaderboardFolder,
	},{
		Utility.Create("Folder",{
			Name = "Properties",
		},{
			Utility.Create("IntValue",{
				Name = "Position",
				Value = 0,
			}),
		}),
		Utility.Create("Folder",{
			Name = "Leaderstats",
		})
	})

	self.Changed = Signal.new ()

	self.Changed:Connect(function()
		self.Position = self._Object.Properties.Position.Value
	end)

	for _,v in pairs(Leaderboard.Leaderstat._Cache) do
		Utility.Create(v.Type,{
			Name = v.Name,
			Value = v.DefaultValue,
			Parent = self._Object.Leaderstats,
		})
	end

	Leaderboard.Player._Cache[Player] = self

	Leaderboard.Player.CalculatePositions ()

	return self
end

function Leaderboard.Player.CalculatePositions ()
	local ScoreList = {}
	for _,PlayerValue:ObjectValue in pairs(LeaderboardFolder:GetChildren()) do
		local Score = 0
		for _,LeaderstatValue:ValueBase in pairs(PlayerValue.Leaderstats:GetChildren()) do
			local Leaderstat = Leaderboard.Leaderstat._Cache[LeaderstatValue.Name]
			if Leaderstat.ScoreWeight == 0 then continue end
			Score += LeaderstatValue.Value * Leaderstat.ScoreWeight
		end
		ScoreList[#ScoreList+1] = {Score,PlayerValue}
	end
	table.sort(ScoreList,function(a,b)
		return a[1] > b[1]
	end)
	for i,v in pairs(ScoreList) do
		v[2].Properties.Position.Value = i
	end
	for _,v in pairs(Leaderboard.Player._Cache) do
		v.Changed:Fire ()
	end
end

function Leaderboard.Player:SetLeaderstatValue (Leaderstat:string,Value:any)
	LeaderboardFolder[self.Player.Name].Leaderstats[Leaderstat].Value = Value
	Leaderboard.Player.CalculatePositions ()
end

function Leaderboard.Player:GetLeaderstatValue (Leaderstat:string): any
	return LeaderboardFolder[self.Player.Name].Leaderstats[Leaderstat].Value
end

function Leaderboard.Player:_AddLeaderstat (Leaderstat:Leaderstat)
	Utility.Create(Leaderstat.Type,{
		Name = Leaderstat.Name,
		Value = Leaderstat.DefaultValue,
		Parent = self._Object.Leaderstats,
	})
end

function Leaderboard.Player:Destroy ()
	self.Active = false
	Leaderboard.Player._Cache[self.Player] = nil
	self._Object:Destroy ()
end

export type Leaderstat = typeof(Leaderboard.Leaderstat.new())
export type LeaderboardPlayer = typeof(Leaderboard.Player.new())

return Leaderboard