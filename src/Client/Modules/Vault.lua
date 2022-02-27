local Event = require(script.Parent.ClientNet)
local Signal = require(game.ReplicatedStorage.Utility.Signal)

local Vault = {}
Vault._Data = {}
Vault.KeySignals = {}

function Vault:Get (Key:string): any?
    local KeyPath = Key:split("/")
	local Data = self._Data
	for i,v in ipairs(KeyPath) do
		if i == #KeyPath then
			return Data[v]
		end
		if Data[v] == nil then
			Data[v] = {}
		end
		Data = Data[v]
	end
end

function Vault:GetKeyChangedSignal (Key:string): Signal
	if self.KeySignals[Key] then return self.KeySignals[Key] end
	self.KeySignals[Key] = Signal.new()
	return self.KeySignals[Key]
end

Event.new("VaultUpdate"):Connect(function(Key,Value)
    local KeyPath = Key:split("/")
	local Data = Vault._Data
	for i,v in ipairs(KeyPath) do
		if i == #KeyPath then
			Data[v] = Value
		end
		if Data[v] == nil then
			Data[v] = {}
		end
		Data = Data[v]
	end
    if Vault.KeySignals[Key] then
        Vault.KeySignals[Key]:Fire ()
    end
end)

Vault._Data = Event.new("VaultSync"):Call():Await()

return Vault