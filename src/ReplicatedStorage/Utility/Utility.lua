local TweenService = game:GetService("TweenService")

local Module = {}

function Module.Create (ClassName:string,Properties:{[string]:any?}?,Children:{Instance}?): Instance
	local Object = Instance.new(ClassName)
	local InitFunction
	if type(Properties) == "table" then
		for i,v in pairs(Properties) do
			if type(v) == "function" then
				if i == "Init" then 
					InitFunction = v 
					continue 
				end
				Object[i]:Connect(v)
			else
				Object[i] = v
			end
		end
	end
	if InitFunction then 
		InitFunction (Object) 
	end
	if type(Children) == "table" then
		for _,v in pairs(Children) do
			v.Parent = Object
		end
	end
	return Object
end

function Module.Tween (Object:Instance,EndState:table,EasingDirection:Enum.EasingDirection,EasingStyle:Enum.EasingStyle,Time:number,Callback): Tween
	local Tween = TweenService:Create(Object,TweenInfo.new(Time,EasingStyle,EasingDirection,0,false,0),EndState)
	if Callback then
		Tween.Completed:Connect(Callback)
	end
	Tween:Play()
	return Tween
end

function Module.Raycast (Origin:Vector3,Direction:Vector3,FilterType:Enum.RaycastFilterType?,FilterList:{Instance}?,WorldRoot:WorldRoot?)
	WorldRoot = WorldRoot or workspace

	local RCP = RaycastParams.new ()
	RCP.FilterType = FilterType
	RCP.FilterDescendantsInstances = FilterList

	local RCR = WorldRoot:Raycast(Origin,Direction,RCP)

	if RCR == nil then return nil end

	return RCR.Instance,RCR.Position,RCR.Normal,RCR.Material
end

local Values = {
	{1000,"K",},
	{1000000,"M",},
	{1000000000,"B",},
	{1000000000000,"T",},
}

function Module.SimplifyNumber (Value:number): string
	local rn = 1
	local index = 0
	for i=#Values,-1,1 do
		if Value > Values[i][1] then 
			rn = Values[i][1] 
			index = i 
			break 
		end
	end
	Value = Value/rn
	if index == 0 then return tostring(Value) end
	Value = math.floor(Value*10)/10
	return tostring(Value)..Values[index][2]
end

local Chars = {}
for i=string.byte("a"),string.byte("z") do
	Chars[#Chars+1] = i
end
for i=string.byte("A"),string.byte("Z") do
	Chars[#Chars+1] = i
end

function Module.RandomString (Length:number): string
	local Str = ""
	for i=0,Length,1 do
		Str = Str..string.char(Chars[math.random(1,#Chars)])
	end
	return Str
end

function Module.Each (Container:Instance,AddFunction:(Child:Instance)->(...any),RemoveFunction:(Child:Instance)->(...any))
	if type(RemoveFunction) == "function" then
		Container.ChildRemoved:Connect(RemoveFunction)
	end
	if type(AddFunction) == "function" then
		Container.ChildAdded:Connect(AddFunction)
		for _,v in pairs(Container:GetChildren()) do
			task.spawn(AddFunction,v)
		end
	end
end

function Module.FuzzyFind (Text:string,List:{[string]:any}): {[string]:any}
	local Results = {}
	for i,v in pairs(List) do
		if i:lower() == Text:lower() then
			table.insert(Results,1,v)
		elseif i:lower():sub(1,#Text) == Text:lower() then
			Results[#Results+1] = v
		end
	end
	return Results
end

function Module.Split (Text:string): {string}
	local List = {}
	local Quotes = false
	for str in pairs(Text:gmatch("[^ ]+")) do
		local StartQuote = str:match([=[^(['"])]=])
		local EndQuote = str:match([=[(['"])$]=])
		if not Quotes and StartQuote then
			List[#List+1] = str
			Quotes = true
		elseif Quotes and EndQuote then
			List[#List] = List[#List].." "..str
			Quotes = false
		elseif Quotes then
			List[#List] = List[#List].." "..str
		else
			List[#List+1] = str
		end
	end
	return List
end

function Module.UDim2ToPx (Value:UDim2,Container:GuiObject): (number,number)
	return Value.X.Offset + (Value.X.Scale*Container.AbsoluteSize.X), Value.Y.Offset + (Value.Y.Scale*Container.AbsoluteSize.Y)
end

return Module