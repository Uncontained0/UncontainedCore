local Task = require(game.ReplicatedStorage.Utility.TaskScheduler)

local Signal = {}
local Connection = {}

function Signal.new (): Signal
	local self = {}
	setmetatable(self,{__index=Signal})

	self.Yielding = {}
	self.Connections = {}

	return self
end

function Signal:Fire (...:any)
	for _,v in pairs(self.Yielding) do
		coroutine.resume(v,...)
	end
	for _,v in pairs(self.Connections) do
		task.spawn(v.Function,...)
	end
end

function Signal:Connect (Function:(...any)->any): Connection
	return Connection.new(self,Function)
end

function Signal:Wait (MaxTime:number?): (...any)
	MaxTime = MaxTime or math.huge
	local Running = coroutine.running ()
	local n = #self.Yielding+1
	self.Yielding[n] = Running
	Task.new (MaxTime,Running)
	local Data = {coroutine.yield ()}
	Task:Cancel ()
	table.remove(self.Yielding,n)
	return unpack(Data)
end

function Signal:Once (Function: (...any)->boolean): Connection
	local Connection
	Connection = Connection.new(self,function(...)
		local Success = Function (...)
		if Success then Connection:Disconnect() end
	end)
	return Connection
end

function Connection.new (Event:Signal,Function:(...any)->any): Connection
	local self = {}
	setmetatable(self,{__index=Connection})

	self.Event = Event
	self.Function = Function
	self.Id = #Event.Connections+1

	Event.Connections[self.Id] = self
	return self
end

function Connection:Disconnect ()
	self.Event.Connections[self.Id] = nil
end

export type Signal = typeof(Signal.new())
export type Connection = typeof(Connection.new())

return Signal