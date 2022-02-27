local LoadingList = {}

local GlobalCount = script:WaitForChild("GlobalCount")
local CurrentCount = 0

local function Count (O:Instance)
	local Value = O:WaitForChild("Count",2)
	if not Value then return end
	while #O:GetChildren() < Value.Value do
		O.ChildAdded:Wait()
	end
	CurrentCount += #O:GetChildren()
	Value:Destroy()
	for _,v:Instance in pairs(O:GetChildren()) do
		if v:GetAttribute("CountBypass") then continue end
		local Routine = coroutine.create(Count)
		LoadingList[#LoadingList+1] = Routine
		coroutine.resume(Routine,v)
	end
end

local function CheckComplete (): boolean
	for _,v in pairs(LoadingList) do
		if coroutine.status(v) ~= "dead" then return false end
	end
	return true
end

local Gui = Instance.new("ScreenGui")
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 999
Gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local Background = Instance.new("Frame")
Background.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
Background.Size = UDim2.new(1,0,1,0)
Background.Parent = Gui
local Image = Instance.new("ImageLabel")
Image.Image = ""
Image.BackgroundTransparency = 1
Image.AnchorPoint = Vector2.new(0.5,0.5)
Image.Position = UDim2.new(0.5,0,0.5,0)
Image.Size = UDim2.new(0,Gui.AbsoluteSize.Y/3,0,Gui.AbsoluteSize.Y/3)
Image.Parent = Background
local BarContainer = Instance.new("Frame")
BarContainer.BackgroundTransparency = 0.8
BarContainer.BackgroundColor3 = Color3.new(0,0,0)
BarContainer.BorderSizePixel = 0
BarContainer.AnchorPoint = Vector2.new(0.5,1)
BarContainer.Position = UDim2.new(0.5,0,0.95,0)
BarContainer.Size = UDim2.new(0,Gui.AbsoluteSize.Y/3,0,10)
BarContainer.Parent = Background
local Bar = Instance.new("Frame")
Bar.BackgroundColor3 = Color3.new(1,1,1)
Bar.BorderSizePixel = 0
Bar.Size = UDim2.new(0,0,1,0)
Bar.Parent = BarContainer

game:GetService("ReplicatedFirst"):RemoveDefaultLoadingScreen()

Count(game.ReplicatedStorage)
Count(game.Players.LocalPlayer.PlayerScripts.Client)

while not CheckComplete() do
	task.wait()
	Bar.Size = UDim2.new(CurrentCount/GlobalCount.Value,0,1,0)
end

for _,v:Instance in pairs(game.Players.LocalPlayer.PlayerScripts:GetDescendants()) do
	if v:IsA("LocalScript") then
		v.Disabled = false
	end
end

task.wait(1)

Gui:Destroy()