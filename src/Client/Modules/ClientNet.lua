local Network = game.ReplicatedStorage.Network
local Task = require(game.ReplicatedStorage.Utility.TaskScheduler)
local Promise = require(game.ReplicatedStorage.Utility.Promise)
local Utility = require(game.ReplicatedStorage.Utility.Utility)

local Event = {}
local Connection = {}

local EventList = {}

function Event.new (Name:string): Event
	if EventList[Name] then return EventList[Name] end

	local self = {}
	setmetatable(self,{__index=Event})
	
	self.Event = Network[Name]
	self.Requests = {}
	self.Connections = {}
	self.Yielding = {}
	
	EventList[Name] = self
	
	self.EventConnection = self.Event.OnClientEvent:Connect(function(RequestType:string,Data:{[any]:any})
		if RequestType == "Fire" then
			for _,v in pairs(self.Connections) do
				task.spawn(v.Function,unpack(Data.Arguments))
			end
			for _,v in pairs(self.Yielding) do
				coroutine.resume(v,Data)
			end
		elseif RequestType == "Call" then
			if self.Requests[Data.RequestId] ~= nil then
				error("FATAL ERROR: SERVER SENT USED REQUESTID!")
			end
			self.Requests[Data.RequestId] = true
			if self.Callback then
				local Value = table.pack(self.Callback (unpack(Data.Arguments)))
				self.Event:FireServer ("CallResponse",Data.RequestId,Value)
				self.Requests[Data.RequestId] = nil
			else
				self.Event:FireServer ("CallResponse",Data.RequestId,{})
				self.Requests[Data.RequestId] = nil
			end
		elseif RequestType == "CallResponse" then
			if self.Requests[Data.RequestId] == nil then return end
			self.Requests[Data.RequestId]:Resolve(unpack(Data.Arguments))
			self.Request[Data.RequestId] = nil
		end
	end)
	
	return self
end

function Event.get (Name:string): Event?
	return EventList[Name]
end

function Event:FireServer (...:any)
	self.Event:FireServer ("Fire",nil,{...})
end

function Event:Call (...:any): Promise
	local RequestId = Utility.RandomString(6)
	while self.Requests[RequestId] ~= nil do
		RequestId = Utility.RandomString(6)
	end
	self.Requests[RequestId] = Promise.new ()
	self.Event:FireServer ("Call",RequestId,{...})
	return self.Requests[RequestId]
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