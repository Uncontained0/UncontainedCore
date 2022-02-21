local GlobalCount = 0

local function Count (O:Instance)
	local Value = Instance.new ("IntValue")
	Value.Name = "Count"
	Value.Value = #O:GetChildren()+1
	GlobalCount += #O:GetChildren()+1
	Value:SetAttribute("CountBypass",true)
	Value.Parent = O
	for _,v:Instance in pairs(O:GetChildren()) do 
		if v:GetAttribute("CountBypass") then continue end
		Count(v)
	end
end

Count(game.ReplicatedStorage)
Count(game.StarterPlayer.StarterPlayerScripts.Client)

local GlobalValue = Instance.new("IntValue")
GlobalValue.Name = "GlobalCount"
GlobalValue.Value = GlobalCount
GlobalValue.Parent = game.ReplicatedFirst.Loading

for _,v in pairs(game.StarterPlayer.StarterPlayerScripts.Client:GetDescendants()) do
	if v:IsA("LocalScript") then
		v.Disabled = true
	end
end

for _,v in pairs(script.Parent:GetChildren()) do
	if v == script then continue end
	require(v)
end

return true