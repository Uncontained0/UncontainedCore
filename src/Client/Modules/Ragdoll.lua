local Utility = require(game.ReplicatedStorage.Utility.Utility)
local PhysicsService = game:GetService("PhysicsService")
local Ragdoll: Model = game.Players.LocalPlayer.PlayerScripts.Client.Assets.Ragdoll

return function (Character:Model,IsLocalPlayer:boolean): Model
	if IsLocalPlayer then
		game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		for _,v:Instance in pairs(Ragdoll:GetChildren()) do
			if v:IsA("Attachment") or v:IsA("RopeConstraint") or v:IsA("VectorForce") or v:IsA("Sound") then
				local c = v:Clone()
				c.Parent = Character[v.Parent.Name]
			end
		end
		for _,v in pairs(Character:GetChildren()) do
			if v:IsA("BasePart") then
				PhysicsService:SetPartCollisionGroup(v,"Ragdolls")
				v.CanCollide = true
			end
			for _,v in pairs(v:GetChildren()) do
				if v:IsA("RopeConstraint") then
					v.Attachment0 = Character.Torso[v.Parent.Name]
					v.Attachment1 = v.Parent[v.Parent.Name]
				elseif v:IsA("Motor6D") then
					v:Destroy()
				elseif v:IsA("VectorForce") then
					v.Attachment0 = v.Parent.VFA
					v.Enabled = true
				end
			end
		end
		Character.HumanoidRootPart:Destroy()
		Character.Humanoid.PlatformStand = true
		Character.Torso.DeathSound:Play()
		Character.Parent = game.Workspace:WaitForChild("Ignore"):WaitForChild("Ragdolls")
		return Character
	else
		Ragdoll = Ragdoll:Clone()
		for _,v:Instance in pairs(Character:GetChildren()) do
			if v:IsA("Accessory") then
				local Handle:BasePart = v:FindFirstChild("Handle")
				if Handle then
					local CloneHandle = Handle:Clone()
					local AccessoryWeld:Weld = Handle:FindFirstChild("AccessoryWeld")
					CloneHandle.Parent = Ragdoll
					CloneHandle.CanCollide = false
					CloneHandle.Massless = true
					CloneHandle:FindFirstChild("AccessoryWeld"):Destroy()
					local Weld = Instance.new("Weld")
					Weld.Parent = CloneHandle
					Weld.Part1 = CloneHandle
					Weld.Part0 = Ragdoll:FindFirstChild(AccessoryWeld.Part1.Name,true)
					Weld.C0 = AccessoryWeld.Part1.CFrame:ToObjectSpace(Handle.CFrame)
					Weld.C1 = CFrame.new(0,0,0)
				end
				v:Destroy()
			elseif v:IsA("BasePart") then
				local RagdollPart:BasePart = Ragdoll:FindFirstChild(v.Name)
				if RagdollPart then
					RagdollPart.BrickColor = v.BrickColor
					RagdollPart.CFrame = v.CFrame
				end
				if v.Name == "Head" then
					if v:FindFirstChild("Mesh") then
						v:FindFirstChild("Mesh"):Clone().Parent = RagdollPart
					end
					if v:FindFirstChild("face") then
						v:FindFirstChild("face"):Clone().Parent = RagdollPart
					end
				elseif v.Name == "Torso" then
					if v:FindFirstChild("roblox") then
						v:FindFirstChild("roblox"):Clone().Parent = RagdollPart
					end
				end
			elseif v:IsA("Shirt") or v:IsA("Pants") then
				v:Clone().Parent = Ragdoll
			end
		end
		for _,v:Instance in pairs(Ragdoll:GetDescendants()) do
			if v:IsA("RopeConstraint") then
				v.Attachment0 = v.Parent:FindFirstChildOfClass("Attachment")
				v.Attachment1 = Ragdoll.Torso:FindFirstChild(v.Attachment0.Name)
			elseif v:IsA("BasePart") then
				PhysicsService:SetPartCollisionGroup(v,"Ragdolls")
			elseif v:IsA("VectorForce") then
				v.Attachment0 = v.Parent.VFA
				v.Enabled = true
			end
		end
		Character:Destroy()
		Ragdoll.HumanoidRootPart:Destroy()
		Ragdoll.Humanoid.PlatformStand = true
		Ragdoll.Parent = game.Workspace:WaitForChild("Ignore"):WaitForChild("Ragdolls")
		Ragdoll.Torso.DeathSound:Play()
		game.Debris:AddItem(Ragdoll,12)
		return Ragdoll
	end
end