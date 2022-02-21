local Modifier = {}

function Modifier.new (DefaultValue:number): Modifier
    local self = {}
    setmetatable(self,{__index=Modifier})

    self.DefaultValue = DefaultValue
    self.Modifiers = {}

    return self
end

function Modifier:AddModifier (Name:string,Type:string,Value:number)
    self.Modifiers[Name] = {Type,Value}
end

function Modifier:RemoveModifier (Name:string)
    self.Modifiers[Name] = nil
end

function Modifier:GetValue (): number
    local Value = self.DefaultValue
    for _,v in pairs(self.Modifiers) do
        if v[1] == "*+" then
            Value += self.DefaultValue*v[2]
        elseif v[1] == "*-" then
            Value -= self.DefaultValue*v[2]
        elseif v[1] == "+" then
            Value += v[2]
        elseif v[1] == "-" then
            Value -= v[2]
        elseif v[1] == "*" then
            Value *= v[2]
        end
    end
    return Value
end

export type Modifier = typeof(Modifier.new())

return Modifier