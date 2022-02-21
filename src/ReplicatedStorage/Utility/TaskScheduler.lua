local Task = {}

function Task.new (Time: number, Function: (...any) -> (...any) | thread): Task
	local self = {}
	setmetatable(self,{__index=Task})
	
	self.Task = Function
	self.Active = true
	
	task.delay (Time,function ()
		if self.Active then self:Run () end
	end)
	
	return self
end

function Task:Cancel ()
	self.Active = false
end

function Task:Run ()
	task.spawn (self.Task)
end

export type Task = typeof (Task.new())
return Task