return function (_, players, reason)
	for _, player in pairs(players) do
		player:Kick(reason or "Kicked by admin.")
	end

	return ("Kicked %d players."):format(#players)
end