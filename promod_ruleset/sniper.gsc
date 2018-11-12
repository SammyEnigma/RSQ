main()
{
	// class limits
	setDvar( "class_assault_limit", 0 );
	setDvar( "class_specops_limit", 0 );
	setDvar( "class_demolitions_limit", 0 );
	setDvar( "class_sniper_limit", 64 );

	setDvar( "class_sniper_allowdrop", 1 );
	// sniper
	setDvar( "weap_allow_m40a3", 1 );
	setDvar( "weap_allow_remington700", 1 );

	// pistol
	setDvar( "weap_allow_beretta", 0 );
	setDvar( "weap_allow_colt45", 0 );
	setDvar( "weap_allow_usp", 0 );
	setDvar( "weap_allow_deserteagle", 0 );
	setDvar( "weap_allow_deserteaglegold", 0 );
	setDvar( "weap_allow_knife", 1 );

	// pistol attachments
	setDvar( "attach_allow_pistol_none", 0 );
	setDvar( "attach_allow_pistol_silencer", 0 );

	// grenades
	setDvar( "weap_allow_flash_grenade", 0 );
	setDvar( "weap_allow_frag_grenade", 0 );
	setDvar( "weap_allow_smoke_grenade", 0 );

	// sniper class default loadout (preserved)
	setDvar( "class_sniper_primary", "m40a3" );
	setDvar( "class_sniper_primary_attachment", "none" );
	setDvar( "class_sniper_secondary", "knife" );
	setDvar( "class_sniper_secondary_attachment", "none" );
	setDvar( "class_sniper_grenade", "smoke_grenade" );
	setDvar( "class_sniper_camo", "camo_none" );

	// team killing
	setDvar( "scr_team_fftype", 0 ); // [0-3] (disabled, enabled, reflect, shared)
	setDvar( "scr_team_teamkillpointloss", 5 ); // [0->] (points)

	// player death/respawn settings
	setDvar( "scr_player_forcerespawn", 1 ); // [0-1] (require player to press use key to spawn, do not require use key to spawn)
	setDvar( "scr_game_deathpointloss", 0 ); // [0->] (points)
	setDvar( "scr_game_suicidepointloss", 0 ); // [0->] (points)
	setDvar( "scr_player_suicidespawndelay", 0 ); // [0->] (points)

	// player fall damage
	setDvar( "bg_fallDamageMinHeight", 9998 ); // [1->] (min height to inflict min fall damage)
	setDvar( "bg_fallDamageMaxHeight", 9999 ); // [1->] (max height to inflict max fall damage)

	// logging (not likely to be changed)
	setDvar( "logfile", 1 );
	setDvar( "g_log", "games_mp.log" );
	setDvar( "g_logSync", 0 );

	//JUMP
	setDvar( "jump_slowdownEnable" , 0 );
}