local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local Event = require(script.Parent.ServerNet)

local Task = require(game.ReplicatedStorage.Utility.TaskScheduler)
local Signal = require(game.ReplicatedStorage.Utility.Signal)

local PlayerDataStore: DataStore

if game:GetService("RunService"):IsStudio() then
	PlayerDataStore = DataStoreService:GetDataStore("StudioPlayerDataStore")
else
	PlayerDataStore = DataStoreService:GetDataStore("PlayerDataStore")
end

local Vault = {}
Vault.MaxRetries = 10
Vault.HttpCacheTime = 5

Vault.Player = {}
Vault.Player._Cache = {}

game.Players.PlayerRemoving:Connect(function(Player:Player)
	if Vault.Player._Cache[Player.UserId] ~= nil then
		Vault.Player._Cache[Player.UserId]:Save ()
		Vault.Player._Cache[Player.UserId] = nil
	end
end)

game:BindToClose(function()
	for _,v in pairs(Vault.Player._Cache) do
		v:Save ()
	end
end)

local Sync = Event.new("VaultSync")
local Update = Event.new("VaultUpdate")

Sync:SetCallback(function(Player)
	return Vault.Player.new(Player)._Data
end)

function Vault.Player.new (Player:Player|number): VaultPlayer
	local UserId
	if type(Player) ~= "number" then
		UserId = Player.UserId
	end

	if Vault.Player._Cache[UserId] ~= nil then return Vault.Player._Cache[UserId] end

	local self = {}
	setmetatable(self,{__index=Vault.Player})

	self._Temp = {}
	self.UserId = UserId
	self.KeySignals = {}
	self.Player = if type(Player) ~= "number" then Player else nil

	local Success,Value = pcall(PlayerDataStore.GetAsync,PlayerDataStore,UserId)
	local RetryNum = 0
	while not Success and RetryNum < Vault.MaxRetries do
		RetryNum += 1
		Success,Value = pcall(PlayerDataStore.SetAsync,PlayerDataStore,UserId)
	end
	if Success then
		self._Data = Value
		self._Save = true
	else
		self._Data = {}
		self._Save = false
	end

	Vault.Player._Cache[UserId] = self

	return self
end

function Vault.Player:Save (): boolean
	if self._Save == false then return true end
	local Success = pcall(PlayerDataStore.SetAsync,PlayerDataStore,self.UserId,self._Data,{self.UserId})
	local RetryNum = 0
	while not Success and RetryNum < Vault.MaxRetries do
		RetryNum += 1
		Success = pcall(PlayerDataStore.SetAsync,PlayerDataStore,self.UserId,self._Data,{self.UserId})
	end
	return Success
end

function Vault.Player:Get (Key:string,DefaultValue:any?): any
	local KeyPath = Key:split("/")
	local Data = self._Data
	for i,v in ipairs(KeyPath) do
		if i == #KeyPath then
			if Data[v] == nil then
				Data[v] = DefaultValue
			end
			return Data[v]
		end
		if Data[v] == nil then
			Data[v] = {}
		end
		Data = Data[v]
	end
end

function Vault.Player:Set (Key:string,Value:any)
	if self.KeySignals[Key] then
		self.KeySignals[Key]:Fire ()
	end
	if self.Player then
		Update:FireClient (self.Player,Key,Value)
	end
	self._Data[Key] = Value
end

function Vault.Player:GetTemp (Key:string,DefaultValue:any?)
	if self._Temp[Key] == nil then
		self._Temp[Key] = DefaultValue
	end
	return self._Temp[Key]
end

function Vault.Player:SetTemp (Key:string,Value:any)
	self._Temp[Key] = Value
end

function Vault.Player:CombineTemp (TempHasPriority:boolean?)
	if TempHasPriority then
		for i,v in pairs(self._Temp) do
			self:Set(i,v)
		end
	else
		for i,v in pairs(self._Temp) do
			if self._Data[i] ~= nil then continue end
			self:Set(i,v)
		end
	end
end

function Vault.Player:ClearTemp ()
	self._Temp = {}
end

function Vault.Player:GetKeyChangedSignal (Key:string): Signal
	if self.KeySignals[Key] then return self.KeySignals[Key] end
	self.KeySignals[Key] = Signal.new()
	return self.KeySignals[Key]
end

Vault.Firebase = {}
Vault.Firebase._Cache = {}

function Vault.Firebase.new (URL:string,Token:string): VaultFirebase
	if Vault.Firebase._Cache[URL] ~= nil then return Vault.Firebase._Cache[URL] end

	local self = {}
	setmetatable(self,{__index=Vault.Firebase})

	self.URL = URL
	self.Token = Token
	self._Data = {}

	Vault.Firebase._Cache[URL] = self

	return self
end

function Vault.Firebase:Get (Path:string): any?
	if self._Data[Path] ~= nil then return self._Data[Path] end
	local Success,Response = pcall(HttpService.RequestAsync,HttpService,{
		Url = self.URL..Path..".json?auth="..self.Token,
		Method = "GET",
	})
	local RetryCount = 0
	while not Success and RetryCount < 10 do
		RetryCount += 1
		Success,Response = pcall(HttpService.RequestAsync,HttpService,{
			Url = self.URL..Path..".json?auth="..self.Token,
			Method = "GET",
		})
	end
	if Success then
		local Value = HttpService:JSONDecode(Response.Body)
		self._Data[Path] = Value
		Task.new(Vault.HttpCacheTime,function()
			self._Data[Path] = nil
		end)
		return Value
	end
	return nil
end

function Vault.Firebase:Set (Path:string,Value:any): boolean
	local Success = pcall(HttpService.RequestAsync,HttpService,{
		Url = self.URL..Path..".json?auth="..self.Token,
		Body = HttpService:JSONEncode(Value),
		Method = "PUT",
	})
	local RetryCount = 0
	while not Success and RetryCount < 10 do
		RetryCount += 1
		Success = pcall(HttpService.RequestAsync,HttpService,{
			Url = self.URL..Path..".json?auth="..self.Token,
			Body = HttpService:JSONEncode(Value),
			Method = "PUT",
		})
	end
	if Success then
		self._Data[Path] = Value
		Task.new(Vault.HttpCacheTime,function()
			self._Data[Path] = nil
		end)
	end
	return Success
end

function Vault.Firebase:Delete (Path:string): boolean
	local Success = pcall(HttpService.RequestAsync,HttpService,{
		Url = self.URL..Path..".json?auth="..self.Token,
		Method = "DELETE",
	})
	local RetryCount = 0
	while not Success and RetryCount < 10 do
		RetryCount += 1
		Success = pcall(HttpService.RequestAsync,HttpService,{
			Url = self.URL..Path..".json?auth="..self.Token,
			Method = "DELETE",
		})
	end
	if Success then
		self._Data[Path] = nil
	end
	return Success
end

export type VaultPlayer = typeof(Vault.Player.new())
export type VaultFirebase = typeof(Vault.Firebase.new())

return Vault