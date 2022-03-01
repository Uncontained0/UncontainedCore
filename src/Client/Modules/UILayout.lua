local Utility = require(game.ReplicatedStorage.Utility.Utility)

local UILayout = {}

UILayout.VerticalList = {}

function UILayout.VerticalList.new (Gui:GuiObject): VerticalList
	local self = {}
	setmetatable(self,{__index=UILayout.VerticalList})

	self.Padding = UDim.new(0,0)
	self.HorizontalAlignment = Enum.HorizontalAlignment.Center

	self.TweenTime = 0.2
	self.TweenStyle = Enum.EasingStyle.Sine
	self.TweenDirection = Enum.EasingDirection.In

	self._Gui = Gui

	self._EventList = {}

	self._ChildAdded = Gui.ChildAdded:Connect(function(Child:GuiObject)
		if not Child:IsA("GuiObject") then return end
		self._EventList[Child] = Child.Changed:Connect(function(Property:string)
			if Property == "Position" or Property == "AbsolutePosition" then return end
			self:_Update ()
		end)
		self:_Update ()
	end)

	self._ChildRemoved = Gui.ChildRemoved:Connect(function(Child:GuiObject)
		if not Child:IsA("GuiObject") then return end
		self._EventList[Child]:Disconnect()
		self:_Update ()
	end)

	self:_Start ()

	return self
end

function UILayout.VerticalList:_Start ()
	local List = {}
	local AnchorPoint,Position
	
	if self.HorizontalAlignment == Enum.HorizontalAlignment.Left then
		AnchorPoint = Vector2.new(0,0)
		Position = UDim2.new(0,0,0,0)
	elseif self.HorizontalAlignment == Enum.HorizontalAlignment.Center then
		AnchorPoint = Vector2.new(0.5,0)
		Position = UDim2.new(0.5,0,0,0)
	elseif self.HorizontalAlignment == Enum.HorizontalAlignment.Right then
		AnchorPoint = Vector2.new(1,0)
		Position = UDim2.new(1,0,0,0)
	end

	for _,v:GuiObject in pairs(self._Gui:GetChildren()) do
		if not v:IsA("GuiObject") then continue end
		if v.Visible == false then continue end
		if List[v.LayoutOrder] == nil then
			List[v.LayoutOrder] = {}
		end
		List[v.LayoutOrder][#List[v.LayoutOrder]+1] = v
	end

	for _,vv in pairs(List) do
		for _,v:GuiObject in pairs(vv) do
			v.AnchorPoint = AnchorPoint
			v.Position = Position
			Position = UDim2.new(Position.X,Position.Y + v.Size.Y + self.Padding)
		end
	end
end

function UILayout.VerticalList:_Update ()
	local List = {}
	local AnchorPoint,Position
	
	if self.HorizontalAlignment == Enum.HorizontalAlignment.Left then
		AnchorPoint = Vector2.new(0,0)
		Position = UDim2.new(0,0,0,0)
	elseif self.HorizontalAlignment == Enum.HorizontalAlignment.Center then
		AnchorPoint = Vector2.new(0.5,0)
		Position = UDim2.new(0.5,0,0,0)
	elseif self.HorizontalAlignment == Enum.HorizontalAlignment.Right then
		AnchorPoint = Vector2.new(1,0)
		Position = UDim2.new(1,0,0,0)
	end

	for _,v:GuiObject in pairs(self._Gui:GetChildren()) do
		if not v:IsA("GuiObject") then continue end
		if List[v.LayoutOrder] == nil then
			List[v.LayoutOrder] = {}
		end
		List[v.LayoutOrder][#List[v.LayoutOrder]+1] = v
	end

	for _,vv in pairs(List) do
		for _,v:GuiObject in pairs(vv) do
			v.AnchorPoint = AnchorPoint
			v:TweenPosition(Position,self.TweenDirection,self.TweenStyle,self.TweenTime,true)
			Position = UDim2.new(Position.X,Position.Y + v.Size.Y + self.Padding)
		end
	end
end

function UILayout.VerticalList:Destroy ()
	self._ChildAdded:Disconnect()
	self._ChildRemoved:Disconnect()
	for _,v in pairs(self._EventList) do
		v:Disconnect()
	end
end

UILayout.LeftGrid = {}

function UILayout.LeftGrid.new (Gui:GuiObject): LeftGrid
	local self = {}
	setmetatable(self,{__index=UILayout.LeftGrid})

	self.CellPadding = UDim2.new(0,0,0,0)
	self.CellSize = UDim2.new(0,100,0,100)
	self.HorizontalMaxCells = math.huge

	self.TweenTime = 0.2
	self.TweenStyle = Enum.EasingStyle.Sine
	self.TweenDirection = Enum.EasingDirection.In

	self._Gui = Gui

	self._EventList = {}

	self._ChildAdded = Gui.ChildAdded:Connect(function(Child:GuiObject)
		if not Child:IsA("GuiObject") then return end
		self._EventList[Child] = Child.Changed:Connect(function(Property:string)
			if Property == "Position" or Property == "AbsolutePosition" or Property == "AbsoluteSize" or Property == "Size" or Property == "AnchorPoint" then return end
			self:_Update ()
		end)
		self:_Update ()
	end)

	self._ChildRemoved = Gui.ChildRemoved:Connect(function(Child:GuiObject)
		if not Child:IsA("GuiObject") then return end
		self._EventList[Child]:Disconnect()
		self:_Update ()
	end)

	self:_Start ()

	return self
end

function UILayout.LeftGrid:_Start ()
	local List = {}
	
	for _,v:GuiObject in pairs(self._Gui:GetChildren()) do
		if not v:IsA("GuiObject") then continue end
		if v.Visible == false then continue end
		if List[v.LayoutOrder] == nil then
			List[v.LayoutOrder] = {}
		end
		List[v.LayoutOrder][#List[v.LayoutOrder]+1] = v
	end

	local Position = UDim2.new()
	local CellSizePx = Utility.UDim2ToPx(self.CellSize,self._Gui)
	local RowCellCount = 0

	for _,vv in pairs(List) do
		for _,v:GuiObject in pairs(vv) do
			local Location = Utility.UDim2ToPx(Position,self._Gui)
			if RowCellCount > self.HorizontalMaxCells or Location + CellSizePx > self._Gui.AbsoluteSize.X then
				RowCellCount = 0
				Position = UDim2.new(0,Position.Y + self.CellSize.Y + self.CellPadding.Y)
			end
			v.AnchorPoint = Vector2.new(0,0)
			v.Size = self.CellSize
			v.Position = Position
			Position = UDim2.new(Position.X + self.CellSize.X + self.CellPadding.X,Position.Y)
			RowCellCount += 1
		end
	end
end

function UILayout.LeftGrid:_Update ()
	local List = {}
	
	for _,v:GuiObject in pairs(self._Gui:GetChildren()) do
		if not v:IsA("GuiObject") then continue end
		if v.Visible == false then continue end
		if List[v.LayoutOrder] == nil then
			List[v.LayoutOrder] = {}
		end
		List[v.LayoutOrder][#List[v.LayoutOrder]+1] = v
	end

	local Position = UDim2.new()
	local CellSizePx = Utility.UDim2ToPx(self.CellSize,self._Gui)
	local RowCellCount = 0

	for _,Layout in pairs(List) do
		for _,v:GuiObject in pairs(Layout) do
			local Location = Utility.UDim2ToPx(Position,self._Gui)
			if RowCellCount > self.HorizontalMaxCells or Location + CellSizePx > self._Gui.AbsoluteSize.X then
				RowCellCount = 0
				Position = UDim2.new(UDim.new(0,0),Position.Y + self.CellSize.Y + self.CellPadding.Y)
			end
			v.AnchorPoint = Vector2.new(0,0)
			v.Size = self.CellSize
			v:TweenPosition(Position,self.TweenDirection,self.TweenStyle,self.TweenTime,true)
			Position = UDim2.new(Position.X + self.CellSize.X + self.CellPadding.X,Position.Y)
			RowCellCount += 1
		end
	end
end

export type VerticalList = typeof(UILayout.VerticalList.new())
export type LeftGrid = typeof(UILayout.LeftGrid.new())

return UILayout