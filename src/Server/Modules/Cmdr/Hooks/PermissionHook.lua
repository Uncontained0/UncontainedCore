local IsServer = game:GetService("RunService"):IsServer()
local Permissions = if IsServer then require(game.ServerScriptService.Server.Modules.Permissions) else require(game.Players.LocalPlayer.PlayerScripts.Client.Modules.LocalPlayer)

return function (Registry)
    Registry:RegisterHook("BeforeRun",function(Context)
        if IsServer then
            local Player = Permissions.Player.new(Context.Executor)
            if (not Player:HasPermission (Context.Group) or Context.Group == "FALSE") and Context.Group ~= "TRUE" then
                return "You need permission '"..Context.Group.."' to run this command."
            end
        else
            if (not Permissions.HasPermission(Context.Group):Await() or Context.Group == "FALSE") and Context.Group ~= "TRUE" then
                return "You need permission '"..Context.Group.."' to run this command."
            end
        end
    end)
end