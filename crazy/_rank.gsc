#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	level.scoreInfo = [];
	level.rankTable = [];
	level.scoreMP = 30;

	precacheShader("white");

	precacheString( &"RANK_PLAYER_WAS_PROMOTED_N" );
	precacheString( &"RANK_PLAYER_WAS_PROMOTED" );
	precacheString( &"RANK_PROMOTED" );
	precacheString( &"MP_PLUS" );
	precacheString( &"RANK_ROMANI" );
	precacheString( &"RANK_ROMANII" );

	registerScoreInfo( "kill", 5 );
	registerScoreInfo( "headshot", 5 );
	registerScoreInfo( "assist", 3 );
	registerScoreInfo( "suicide", 0 );
	registerScoreInfo( "teamkill", 0 );
	registerScoreInfo( "win", 50 );
	registerScoreInfo( "loss", 30 );
	registerScoreInfo( "tie", 40 );
	registerScoreInfo( "plant", 3 );
	registerScoreInfo( "defuse", 3 );
	registerScoreInfo( "capture", 3 );
	registerScoreInfo( "assault", 3 );
	registerScoreInfo( "assault_assist", 1 );
	registerScoreInfo( "defend", 3 );
	registerScoreInfo( "defend_assist", 1 );
	registerScoreInfo( "kdenied", 5 );
	registerScoreInfo( "gottags", 10 );
	registerScoreInfo( "kconfrm", 5 );

	
	registerScoreInfo( "headshot_splash", 5 );
	registerScoreInfo( "execution", 5 );
	registerScoreInfo( "avenger", 5 );
	registerScoreInfo( "defender", 5 );
	registerScoreInfo( "posthumous", 3 );
	registerScoreInfo( "revenge", 5 );
	registerScoreInfo( "double", 5 );
	registerScoreInfo( "triple", 5 );
	registerScoreInfo( "multi", 10 );
	registerScoreInfo( "buzzkill", 5 );
	registerScoreInfo( "firstblood", 10 );
	registerScoreInfo( "comeback", 5 );
	registerScoreInfo( "longshot", 5 );
	registerScoreInfo( "assistedsuicide", 5 );
	registerScoreInfo( "wallbang", 5 );

	level.maxRank = int(tableLookup( "mp/rankTable.csv", 0, "maxrank", 1 ));
	level.maxPrestige = int(tableLookup( "mp/rankIconTable.csv", 0, "maxprestige", 1 ));
	
	pId = 0;
	rId = 0;
	for ( pId = 0; pId <= level.maxPrestige; pId++ )
	{
		for ( rId = 0; rId <= level.maxRank; rId++ )
			precacheShader( tableLookup( "mp/rankIconTable.csv", 0, rId, pId+1 ) );
	}

	rankId = 0;
	rankName = tableLookup( "mp/ranktable.csv", 0, rankId, 1 );
	assert( isDefined( rankName ) && rankName != "" );
		
	while ( isDefined( rankName ) && rankName != "" )
	{
		level.rankTable[rankId][1] = tableLookup( "mp/ranktable.csv", 0, rankId, 1 );
		level.rankTable[rankId][2] = tableLookup( "mp/ranktable.csv", 0, rankId, 2 );
		level.rankTable[rankId][3] = tableLookup( "mp/ranktable.csv", 0, rankId, 3 );
		level.rankTable[rankId][7] = tableLookup( "mp/ranktable.csv", 0, rankId, 7 );

		precacheString( tableLookupIString( "mp/ranktable.csv", 0, rankId, 16 ) );

		rankId++;
		rankName = tableLookup( "mp/ranktable.csv", 0, rankId, 1 );		
	}
	
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );

		player.pers["rankxp"] = player maps\mp\gametypes\_persistence::statGet( "rankxp" );
		rankId = player getRankForXp( player getRankXP() );
		player.pers["rank"] = rankId;
		player.rankUpdateTotal = 0;

		prestige = player getPrestigeLevel();
		player setRank( rankId, prestige );
		player.pers["prestige"] = prestige;

		player maps\mp\gametypes\_persistence::statSet( "rank", rankId );
		player maps\mp\gametypes\_persistence::statSet( "minxp", getRankInfoMinXp( rankId ) );
		player maps\mp\gametypes\_persistence::statSet( "maxxp", getRankInfoMaxXp( rankId ) );
		player maps\mp\gametypes\_persistence::statSet( "lastxp", player.pers["rankxp"] );				
		player setStat( 251, rankId );
		player setStat( 252, rankId );
			
		if ( player getStat( 260 ) <= 0 && rankId >= 3 )
			player setStat( 260, 2 );
		
		player thread onPlayerSpawned();
		player thread onJoinedTeam();
		player thread onJoinedSpectators();
	}
}

onJoinedTeam()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_team");
		self thread removeRankHUD();
	}
}


onJoinedSpectators()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_spectators");
		self thread removeRankHUD();
	}
}


onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");
		if(!isdefined(self.hud_rankscroreupdate))
		{
			self.hud_rankscroreupdate = newClientHudElem(self);
			self.hud_rankscroreupdate.horzAlign = "center";
			self.hud_rankscroreupdate.vertAlign = "middle";
			self.hud_rankscroreupdate.alignX = "center";
			self.hud_rankscroreupdate.alignY = "middle";
	 		self.hud_rankscroreupdate.x = 50;
			self.hud_rankscroreupdate.y = -50;
			self.hud_rankscroreupdate.font = "default";
			self.hud_rankscroreupdate.fontscale = 2.0;
			self.hud_rankscroreupdate.archived = false;
			self.hud_rankscroreupdate.color = (0.5,0.5,0.5);
			self.hud_rankscroreupdate maps\mp\gametypes\_hud::fontPulseInit(3);
		}
	}
}

roundUp( floatVal )
{
	if ( int( floatVal ) != floatVal )
		return int( floatVal+1 );
	else
		return int( floatVal );
}

giveRankXP( type, value )
{
	self endon("disconnect");

	if ( level.teamBased && (!level.playerCount["allies"] || !level.playerCount["axis"]) )
		return;
	else if ( !level.teamBased && (level.playerCount["allies"] + level.playerCount["axis"] < 2) )
		return;

	if ( !isDefined( value ) )
		value = getScoreInfoValue( type );

	self incRankXP( int(value*level.scoremp) );
	self.canuse = false;
	switch( type )
	{
		case "kill":
		case "headshot":
		case "suicide":
		case "teamkill":
		case "assist":
		case "capture":
		case "defend":
		case "return":
		case "pickup":
		case "assault":
		case "plant":
		case "defuse":
		case "kconfrm":
		case "kdenied":
		case "gottags":
		value = int(value);
		self.canuse = true;
		break;
	}

	if ( getDvarInt( "scr_enable_scoretext" ) )
	{
		if ( type == "teamkill" )
			self thread updateRankScoreHUD( 0 - getScoreInfoValue( "kill" ) );
		else
			self thread updateRankScoreHUD( value );
	}
}

updateRankScoreHUD( amount )
{
	self endon( "disconnect" );
	self endon( "joined_team" );
	self endon( "joined_spectators" );
	
	if ( !amount )
	return;
	
	self notify( "update_score" );
	self endon( "update_score" );
	self.rankUpdateTotal += amount;
	wait 0.05;
	
	if( isDefined( self.hud_rankscroreupdate ) )
	
	{
		if ( self.rankUpdateTotal < 0 )
		
		{
			self.hud_rankscroreupdate.label = &"";
			self.hud_rankscroreupdate.color = (1,0,0);
		}
		
		else
		
		{
			self.hud_rankscroreupdate.label = &"MP_PLUS";
			self.hud_rankscroreupdate.color = (1,1,1);
		}
		
		if(self.rankUpdateTotal == 5)
			self.hud_rankscroreupdate thread maps\mp\gametypes\_hud::fontPulse( self );
		
		self.hud_rankscroreupdate setValue(self.rankUpdateTotal);
		self.hud_rankscroreupdate.alpha = 1;
		
		blinkTheHud();

		self.hud_rankscroreupdate fadeIt(0.1,0);
		wait 0.1;
		self.rankUpdateTotal = 0;
	}
}
blinkTheHud()
{
	self endon( "update_score" );
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "joined_team" );
	self endon( "joined_spectators" );

	wait 0.8;

	for(i = 0;i < 3; i++)
	{
	self.hud_rankscroreupdate fadeIt(0.1,0.1);
	self.hud_rankscroreupdate fadeIt(0.1,1);
	}
}
fadeIt(time,alpha)
{
self fadeOverTime(time);
self.alpha = alpha;
wait time;
}
removeRankHUD()
{
	if(isDefined(self.hud_rankscroreupdate))
		self.hud_rankscroreupdate.alpha = 0;
}

getRank()
{	
	rankXp = self.pers["rankxp"];
	rankId = self.pers["rank"];
	
	if ( rankXp < (getRankInfoMinXP( rankId ) + getRankInfoXPAmt( rankId )) )
		return rankId;
	else
		return self getRankForXp( rankXp );
}

getRankForXp( xpVal )
{
	rankId = 0;
	rankName = level.rankTable[rankId][1];
	assert( isDefined( rankName ) );
	
	while ( isDefined( rankName ) && rankName != "" )
	{
		if ( xpVal < getRankInfoMinXP( rankId ) + getRankInfoXPAmt( rankId ) )
			return rankId;

		rankId++;
		if ( isDefined( level.rankTable[rankId] ) )
			rankName = level.rankTable[rankId][1];
		else
			rankName = undefined;
	}
	
	rankId--;
	return rankId;
}

getRankXP()
{
	return self.pers["rankxp"];
}
incRankXP( amount )
{	
	xp = self getRankXP();
	newXp = (xp + amount);

	if ( self.pers["rank"] == level.maxRank && newXp >= getRankInfoMaxXP( level.maxRank ) )
		newXp = getRankInfoMaxXP( level.maxRank );

	self.pers["rankxp"] = newXp;
	self maps\mp\gametypes\_persistence::statSet( "rankxp", newXp );
	self setStat( 251, self getRank() );
	self setStat( 252, self getRank() );
}

registerScoreInfo( type, value )
{
	level.scoreInfo[type]["value"] = value;
}

getScoreInfoValue( type )
{
	return ( level.scoreInfo[type]["value"] );
}

getRankInfoMinXP( rankId )
{
	return int(level.rankTable[rankId][2]);
}

getRankInfoXPAmt( rankId )
{
	return int(level.rankTable[rankId][3]);
}

getRankInfoMaxXp( rankId )
{
	return int(level.rankTable[rankId][7]);
}

getRankInfoFull( rankId )
{
	return tableLookupIString( "mp/ranktable.csv", 0, rankId, 16 );
}

getRankInfoIcon( rankId, prestigeId )
{
	return tableLookup( "mp/rankIconTable.csv", 0, rankId, prestigeId+1 );
}

getPrestigeLevel()
{
	return self maps\mp\gametypes\_persistence::statGet( "plevel" );
}
