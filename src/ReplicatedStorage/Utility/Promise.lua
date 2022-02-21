-- Custom Promise Implementation
-- (c) Uncontained#0729 2022

local Task = require(game.ReplicatedStorage.Utility.TaskScheduler)

local Promise = {}

function Promise.new (): Promise
	local self = {}
	setmetatable(self,{__index=Promise})
	
	self.Resolved = false
	self.Yielding = {}
	self.Functions = {}
	self.Value = {}
	
	return self
end

function Promise:Await (MaxTime: number?): (...any)
	if self.Resolved then return unpack(self.Value) end
	MaxTime = MaxTime or math.huge
	local Running = coroutine.running ()
	self.Yielding[#self.Yielding+1] = Running
	Task.new (MaxTime,Running)
	coroutine.yield ()
	Task:Cancel ()
	return unpack(self.Value)
end

function Promise:Then (Function: (...any) -> any): Promise
	self.Functions[#self.Functions+1] = Function
	return self
end

function Promise:Finally (Function: (...any) -> any): nil
	self.Functions[#self.Functions+1] = Function
end

function Promise:Resolve (...: any): nil
	if self.Resolved then error("Promise: Can only resolve once!") end
	self.Resolved = true
	self.Value = {...}
	
	for _,v in pairs(self.Functions) do
		task.spawn (v,unpack(self.Value))
	end
	
	for _,v in pairs(self.Yielding) do
		coroutine.resume (v)
	end
end

export type Promise = typeof(Promise.new())
return Promise