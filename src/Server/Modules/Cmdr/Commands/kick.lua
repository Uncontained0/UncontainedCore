return {
	Name = "kick";
	Aliases = {"boot"};
	Description = "Kicks a player or set of players.";
	Group = "PLAYER_KICK";
	Args = {
		{
			Type = "players";
			Name = "players";
			Description = "The players to kick.";
		},
		{
			Type = "string",
			Name = "reason",
			Description = "The reason you are kicking the players.",
		}
	};
}