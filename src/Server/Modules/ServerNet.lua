local Network = Instance.new("Folder")
local Task = require(game.ReplicatedStorage.Utility.TaskScheduler)
local Utility = require(game.ReplicatedStorage.Utility.Utility)
local Promise = require(game.ReplicatedStorage.Utility.Promise)

Network.Name = "Network"
Network.Parent = game.ReplicatedStorage

local Event = {}
local Connection = {}

local EventList = {}

function Event.new (Name:string): Event
	local self = {}
	setmetatable(self,{__index=Event})
	
	self.Event = Instance.new ("RemoteEvent")
	self.Requests = {}
	self.Connections = {}
	self.Yielding = {}
	
	self.Event.Name = Name
	self.Event.Parent = Network
	
	EventList[Name] = self
	
	self.EventConnection = self.Event.OnServerEvent:Connect(function (Player:Player,RequestType:string,Data:{[any]:any})
		if type(RequestType) ~= "string" then return end
		if type(Data) ~= "table" then return end
		if type(Data.Arguments) ~= "table" then return end
		
		if RequestType == "Fire" then
			for _,v in pairs(self.Connections) do
				task.spawn(v.Function,Player,unpack(Data.Arguments))
			end
			for _,v in pairs(self.Yielding) do
				coroutine.resume(v)
			end
		elseif RequestType == "Call" then
			if type(Data.RequestId) ~= "string" then return end
			if self.Requests[Player] == nil then 
				self.Requests[Player] = {} 
			end
			if self.Requests[Player][Data.RequestId] == true then return end
			self.Requests[Player][Data.RequestId] = true
			if self.Callback then
				local Value = table.pack(self.Callback (Player,unpack(Data.Arguments)))
				self.Event:FireClient (Player,"CallResponse",Data.RequestId,Value)
				self.Requests[Player][Data.RequestId] = nil
			else
				self.Event:FireClient (Player,"CallResponse",Data.RequestId,{})
				self.Requests[Player][Data.RequestId] = nil
			end
		elseif RequestType == "CallResponse" then
			if type(Data.RequestId) ~= "string" then return end
			if self.Requests[Player] == nil then 
				self.Requests[Player] = {} 
			end
			if self.Requests[Player][Data.RequestId] == nil then return end
			self.Requests[Player][Data.RequestId]:Resolve(unpack(Data.Arguments))
			self.Request[Player][Data.RequestId] = nil
		end
	end)
	
	return self
end

function Event.get (Name:string): Event?
	return EventList[Name]
end

function Event:FireClient (Player,...)
	self.Event:FireClient (Player,"Fire",nil,{...})
end

function Event:FireAllClients (...)
	self.Event:FireAllClients ("Fire",nil,{...})
end

function Event:Connect (Function: (Player:Player,...any) -> (...any)): Connection
	return Connection.new (self,Function)
end

function Event:Call (Player:Player,...:any): Promise
	local RequestId = Utility.RandomString(6)
	while self.Requests[Player][RequestId] ~= nil do
		RequestId = Utility.RandomString(6)
	end
	self.Requests[Player][RequestId] = Promise.new ()
	self.Event:FireClient (Player,"Call",RequestId,{...})
	return self.Requests[Player][RequestId]
end

function Event:SetCallback (Function: (Player:Player,...any) -> (...any))
	self.Callback = Function
end

function Event:Wait (MaxTime:number?)
	MaxTime = if MaxTime then MaxTime else math.huge
	local Running = coroutine.running ()
	local n = #self.Yielding+1
	self.Yielding[n] = Running
	local WaitTask = Task.new (MaxTime,Running)
	local Data = coroutine.yield ()
	WaitTask:Cancel ()
	table.remove(self.Yielding,n)
	return unpack(Data)
end

function Event:Once (Function: (Player:Player,...any) -> boolean): Connection
	local OnceConnection
	OnceConnection = Connection.new(self,function(...)
		local Success = Function (...)
		if Success then 
			OnceConnection:Disconnect() 
		end
	end)
	return OnceConnection
end

function Connection.new (ConnectionEvent:Event,Function:(Player:Player,...any)->(...any)): Connection
	local self = {}
	setmetatable(self,{__index=Connection})

	self.Event = ConnectionEvent
	self.Function = Function
	self.Id = #Event.Connections+1

	ConnectionEvent.Connections[self.Id] = self
	return self
end

function Connection:Disconnect ()
	self.Event.Connections[self.Id] = nil
end

export type Event = typeof(Event.new())
export type Connection = typeof(Connection.new())

return Event