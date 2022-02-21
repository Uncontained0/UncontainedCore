local Event = require(script.Parent.ServerNet)

local Permissions = {}

Permissions.Group = {}
Permissions.Group._Cache = {}

function Permissions.Group.new (Name:string): PermissionGroup
    if Permissions.Group._Cache[Name] then return Permissions.Group._Cache[Name] end

    local self = {}
    setmetatable(self,{__index=Permissions.Group})

    self.Permissions = {}

    return self
end

function Permissions.Group:SetPermissionEnabled (Permission:string,Enabled:boolean)
    self.Permissions[Permission] = Enabled
end

function Permissions.Group:GetPermissionEnabled (Permission:string): boolean
    return self.Permissions[Permission] == true
end

Permissions.Player = {}
Permissions.Player._Cache = {}

function Permissions.Player.new (Player:Player): PlayerPermissions
    if Permissions.Player._Cache[Player] then return Permissions.Player._Cache[Player] end

    local self = {}
    setmetatable(self,{__index=Permissions.Player})

    self.Player = Player
    self.Permissions = {}

    Permissions.Player._Cache[Player] = self

    return self
end

function Permissions.Player:AssignGroup (Group:PermissionGroup)
    self.PermissionGroup = Group
end

function Permissions.Player:SetPermissionEnabled (Permission:string,Enabled:boolean)
    self.Permissions[Permission] = Enabled
end

function Permissions.Player:GetPermissionEnabled (Permission:string): boolean
    if self.PermissionGroup then
        return self.Permissions[Permission] == true or self.PermissionGroup:GetPermissionEnabled (Permission)
    end
    return self.Permissions[Permission] == true
end

function Permissions.Player:HasPermission (Permission:string): boolean
    if self.PermissionGroup then
        return self.Permissions[Permission] == true or self.PermissionGroup:GetPermissionEnabled (Permission)
    end
    return self.Permissions[Permission] == true
end

Event.new("LocalPermissions"):SetCallback(function(Player:Player,Permission:string)
    return Permissions.Player:HasPermission(Permission)
end)

export type PermissionGroup = typeof(Permissions.PermissionGroup.new())
export type PlayerPermissions = typeof(Permissions.Player.new())

return Permissions