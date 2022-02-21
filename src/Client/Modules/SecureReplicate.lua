local Container = game.Players.LocalPlayer.PlayerGui.Replicated

return {
    Get = function (Name:string)
        return Container:FindFirstChild(Name)
    end
}