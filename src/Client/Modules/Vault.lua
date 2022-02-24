local Event = require(script.Parent.ClientNet)
local Signal = require(game.ReplicatedStorage.Utility.Signal)

local Vault = {}
Vault._Data = {}
Vault.KeySignals = {}

function Vault:Get (Key:string): any?
    return self._Data[Key]
end

function Vault:GetKeyChangedSignal (Key:string): Signal
	if self.KeySignals[Key] then return self.KeySignals[Key] end
	self.KeySignals[Key] = Signal.new()
	return self.KeySignals[Key]
end

Event.new("VaultUpdate"):Connect(function(Key,Value)
    Vault._Data[Key] = Value
    if Vault.KeySignals[Key] then
        Vault.KeySignals[Key]:Fire ()
    end
end)

Vault._Data = Event.new("VaultSync"):Call():Await()

return Vault