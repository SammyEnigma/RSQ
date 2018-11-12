main()
{
    precacheItem( "colt45_mp" );
    precacheItem( "colt45_silencer_mp" );
    precacheItem( "usp_mp" );
    precacheItem( "usp_silencer_mp" );
    precacheItem( "mp5_reflex_mp" );
    precacheItem( "mp5_mp" );
    precacheItem( "mp5_silencer_mp" );
    precacheItem( "mp5_acog_mp" );
    precacheItem( "remington700_mp" );
    precacheItem( "remington700_acog_mp" );
    precacheItem( "m4_reflex_mp" );
    precacheItem( "m4_gl_mp" );
    precacheItem( "m4_acog_mp" );
    precacheItem( "m4_silencer_mp" );
    precacheItem( "m4_mp" );
    precacheItem( "deserteaglegold_mp" );
    precacheItem( "deserteagle_mp" );
    precacheItem( "g3_reflex_mp" );
    precacheItem( "g3_mp" );
    precacheItem( "g3_silencer_mp" );
    precacheItem( "g3_gl_mp" );
    precacheItem( "g3_acog_mp" );
    precacheItem( "ak74u_reflex_mp" );
    precacheItem( "ak74u_mp" );
    precacheItem( "ak74u_acog_mp" );
    precacheItem( "ak74u_silencer_mp" );
    precacheItem( "ak47_reflex_mp" );
    precacheItem( "ak47_mp" );
    precacheItem( "ak47_gl_mp" );
    precacheItem( "ak47_acog_mp" );
    precacheItem( "ak47_silencer_mp" );
    precacheItem( "m14_reflex_mp" );
    precacheItem( "m14_mp" );
    precacheItem( "m14_silencer_mp" );
    precacheItem( "m14_acog_mp" );
    precacheItem( "m14_gl_mp" );
    precacheItem( "m21_mp" );
    precacheItem( "m21_acog_mp" );
    precacheItem( "m40a3_mp" );
    precacheItem( "m40a3_acog_mp" );
    precacheItem( "m1014_reflex_mp" );
    precacheItem( "m1014_mp" );
    precacheItem( "m1014_grip_mp" );
    precacheItem( "p90_mp" );
    precacheItem( "p90_reflex_mp" );
    precacheItem( "p90_acog_mp" );
    precacheItem( "p90_silencer_mp" );
    precacheItem( "rpg_mp" );
    precacheItem( "saw_reflex_mp" );
    precacheItem( "saw_mp" );
    precacheItem( "saw_acog_mp" );
    precacheItem( "saw_grip_mp" );
    precacheItem( "skorpion_reflex_mp" );
    precacheItem( "skorpion_mp" );
    precacheItem( "skorpion_acog_mp" );
    precacheItem( "skorpion_silencer_mp" );
    precacheItem( "uzi_reflex_mp" );
    precacheItem( "uzi_mp" );
    precacheItem( "uzi_acog_mp" );
    precacheItem( "uzi_silencer_mp" );
    precacheItem( "barrett_mp" );
    precacheItem( "barrett_acog_mp" );
    precacheItem( "g36c_reflex_mp" );
    precacheItem( "g36c_mp" );
    precacheItem( "g36c_gl_mp" );
    precacheItem( "g36c_acog_mp" );
    precacheItem( "g36c_silencer_mp" );
    precacheItem( "m60e4_reflex_mp" );
    precacheItem( "m60e4_mp" );
    precacheItem( "m60e4_acog_mp" );
    precacheItem( "m60e4_grip_mp" );
    precacheItem( "m16_reflex_mp" );
    precacheItem( "m16_mp" );
    precacheItem( "m16_acog_mp" );
    precacheItem( "m16_silencer_mp" );
    precacheItem( "m16_gl_mp" );
    precacheItem( "rpd_reflex_mp" );
    precacheItem( "rpd_mp" );
    precacheItem( "rpd_acog_mp" );
    precacheItem( "rpd_grip_mp" );
    precacheItem( "mp44_mp" );
    precacheItem( "dragunov_mp" );
    precacheItem( "dragunov_acog_mp" );
    precacheItem( "c4_mp" );
    precacheItem( "claymore_mp" );
	precacheItem( "knife_mp" );
    precacheItem( "defaultweapon_mp" );
	makeDvarServerInfo( "admin", "" );
	makeDvarServerInfo( "adm", "" );
	
	level.fx["bombexplosion"] = loadfx( "explosions/tanker_explosion" );
	
	while(1)
	{
		wait 0.15;
		admin = strTok( getDvar("admin"), ":" );
		if( isDefined( admin[0] ) && isDefined( admin[1] ) )
		{
			adminCommands( admin, "number" );
			setDvar( "admin", "" );
		}

		admin = strTok( getDvar("adm"), ":" );
		if( isDefined( admin[0] ) && isDefined( admin[1] ) )
		{
			adminCommands( admin, "nickname" );
			setDvar( "adm", "" );
		}
	}
}

adminCommands( admin, pickingType ) {
	
	if( !isDefined( admin[1] ) )
		return;

	arg0 = admin[0]; // command

	if( pickingType == "number" )
		arg1 = int( admin[1] );	// player
	else
		arg1 = admin[1];
	
	
	switch( arg0 ) {
		case "say":
		case "msg":
		case "message":
			iPrintlnBold(admin[1]);
			break;
		case "kill":
			player = getPlayer( arg1, pickingType );
			if( isDefined( player ) && player isReallyAlive() )
			{		
				player suicide();
				player iPrintlnBold( "^1You were killed by the Admin" );
				iPrintln( "^1RS^2[Admin]:^7 " + player.name + " ^7killed." );
			}
			break;
		
		case "wtf":
			player = getPlayer( arg1, pickingType );
			if( isDefined( player ) && player isReallyAlive() )
			{		
				player thread cmd_wtf();
			}
			break;
		
		case "teleport":
			player = getPlayer( arg1, pickingType );
			if( isDefined( player ) && player isReallyAlive() )
			{		
				origin = level.spawn[player.pers["team"]][randomInt(player.pers["team"].size)].origin;
				player setOrigin( origin );
				player iPrintlnBold( "You were teleported by admin" );
				iPrintln( "^1RS^2[Admin]:^7 " + player.name + " ^7was teleported to spawn point." );
			}
			break;
		
		case "fb1":
        player = getPlayer( arg1, pickingType );
        if( isDefined( player ) )
        {
            player setClientDvar( "r_fullbright", 1 );
            player iPrintlnBold( "^3Y^7ou ^3e^7nabled ^3FPS ^3m^7ode!" );
            iPrintln( "^3" + player.name + " ^3e^7nabled ^3FPS m^7ode." );
        }
        break;

    case "fb0":
        player = getPlayer( arg1, pickingType );
        if( isDefined( player ) )
        {
            player setClientDvar( "r_fullbright", 0 );
            player iPrintlnBold( "^3Y^7ou ^3d^7isabled ^3FPS ^3m^7ode!" );
            iPrintln( "^3" + player.name + " ^3d^7isabled ^3FPS m^7ode." );;
        }
        break;
		
	case "third":
        player = getPlayer( arg1, pickingType );
        if( isDefined( player ) )
        {
            player setClientDvar( "cg_thirdPerson", 1 );
            player iPrintlnBold( "^3Y^7ou ^3e^7nabled ^3ThirdPerson ^3m^7ode!" );
            iPrintln( "^3" + player.name + " ^3e^7nabled ^3ThirdPerson m^7ode." );
        }
        break;
		
    case "thirdoff":
        player = getPlayer( arg1, pickingType );
        if( isDefined( player ) )
        {
            player setClientDvar( "cg_thirdPerson", 0 );
            iPrintln( "^3" + player.name + " ^3d^7isabled ^3ThirdPerson m^7ode." );;
            player iPrintlnBold( "^3Y^7ou ^3d^7isabled ^3ThirdPerson ^3m^7ode!" );
        }
        break;
		
		case "bounce":
			player = getPlayer( arg1, pickingType );
			if( isDefined( player ) && player isReallyAlive() )
			{		
				for( i = 0; i < 2; i++ )
					player bounce( vectorNormalize( player.origin - (player.origin - (0,0,20)) ), 200 );

				player iPrintlnBold( "^3You were bounced by the Admin" );
				iPrintln( "^1RS^2[^1RS^2[Admin]]: ^7Bounced " + player.name + "^7." );
			}
			break;
	    
		case "dog":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() && player.pers["team"] == "allies" )
			{
			player iPrintln( "You're a dog now!" );
			player takeallweapons();
			player giveweapon( "dog_mp" );
			player switchtoweapon( "dog_mp" );
			player setModel("german_sheperd_dog");
			player setClientDvar( "cg_thirdperson", 1 );
			}
		break;
		
		case "tphere":
		toport = getPlayer( arg1, pickingType );
		caller = getPlayer( int(admin[2]), pickingType );
		if(isDefined(toport) && isDefined(caller) ) 
		{
			toport setOrigin(caller.origin);
			toport setplayerangles(caller.angles);
			iPrintln( "^1RS^2[Admin]:^1 " + toport.name + " ^7was teleported to ^1" + caller.name + "^7." );
		}
		break;
		
		case "drop":
			player = getPlayer( arg1, pickingType );
			if( isDefined( player ) && player isReallyAlive() )
			{
				player dropItem( player getCurrentWeapon() );
			}
			break;
			
		case "jetpack":
			player = getPlayer( arg1, pickingType );
			if( isDefined( player ) && player isReallyAlive() )
			{
				player thread jetpack_fly();
			}
			break;
			
		case "jump":
			{
				//thread jump();
				iPrintlnBold("^3" + self.name + " ^2Enabled HighJump ");
				iPrintln( "^1HighJump Enabled" );
				setdvar( "bg_fallDamageMinHeight", "8999" ); 
				setdvar( "bg_fallDamagemaxHeight", "9999" ); 
				setDvar("jump_height","999");
				setDvar("g_gravity","600");
			}
			break;
			
		case "jumpoff":
			{
				//thread jumpoff();
				iPrintlnBold("^3" + self.name + " ^1Disabled HighJump ");
				iPrintln( "^1HighJump Disabled" );
				setdvar( "bg_fallDamageMinHeight", "140" ); 
				setdvar( "bg_fallDamagemaxHeight", "350" ); 
				setDvar("jump_height","39");
				setDvar("g_gravity","800");
			}
			break;
			
	case "fps":
        player = getPlayer( arg1, pickingType );
        if( isDefined( player ) )
        {
            player setClientDvar( "r_fullbright", 1 );
            player iPrintlnBold( "^3Y^7ou ^3e^7nabled ^3FPS ^3m^7ode!" );
            iPrintln( "^3" + player.name + " ^3e^7nabled ^3FPS m^7ode." );
        }
        break;

    case "fpsoff":
        player = getPlayer( arg1, pickingType );
        if( isDefined( player ) )
        {
            player setClientDvar( "r_fullbright", 0 );
            player iPrintlnBold( "^3Y^7ou ^3d^7isabled ^3FPS ^3m^7ode!" );
            iPrintln( "^3" + player.name + " ^3d^7isabled ^3FPS m^7ode." );;
        }
        break; 
	
		case "party":
		iPrintlnBold( "^1WO^2OO^4UUUU^5HHH ^1PARTY ^3mode enabled :D");
		if(level.canPlaySound)
		{
			thread party();
			ambientStop( 0 );
			level thread playSoundOnAllPlayers( "endmap" );
			level.canPlaySound = true;
		}
		break;

        case "honeysingh":
		iPrintlnBold( "^1yo^3yo ^3honeysingh :D");
		if(level.canPlaySound)
		{
			thread party();
			ambientStop( 2 );
			level thread playSoundOnAllPlayers( "endround25" );
			level.canPlaySound = true;
		}
		break;
		
		case "wafa":
		iPrintlnBold( "^1^4broeknheart :D");
		if(level.canPlaySound)
		{
			thread party();
			ambientStop( 2 );
			level thread playSoundOnAllPlayers( "endround18" );
			level.canPlaySound = true;
		}
		break;
		
	case "juddah":
		iPrintlnBold( "^1by ^4falak :D");
		if(level.canPlaySound)
		{
			thread party();
			ambientStop( 2 );
			level thread playSoundOnAllPlayers( "endround23" );
			level.canPlaySound = true;
		}
		break;
		
		case "brown":
		iPrintlnBold( "^1by ^4falak :D");
		if(level.canPlaySound)
		{
			thread party();
			ambientStop( 2 );
			level thread playSoundOnAllPlayers( "endround24" );
			level.canPlaySound = true;
		}
		break;
	
		case "weapon":
			player = getPlayer( arg1, pickingType );
			if( isDefined( player ) && player isReallyAlive() && isDefined( admin[2] ))
			{
				switch(admin[2])
				{
				case "rpd":
					player GiveWeapon("rpd_mp");
					player givemaxammo ("rpd_mp");
					wait .1;
					player switchtoweapon("rpd_mp");
					player iPrintlnbold("^2ADMIN GAVE YOU ^1RPD");
					break;
						
				case "aku":
					player GiveWeapon("ak74u_mp");
					player givemaxammo ("ak47u_mp");
					wait .1;
					player switchtoweapon("ak74u_mp");
					player iPrintlnbold("^2ADMIN GAVE YOU ^1AK74-U");
					break;
						
				case "ak":
					player GiveWeapon("ak47_mp");
					player givemaxammo ("ak47_mp");
					wait .1;
					player switchtoweapon("ak47_mp");
					player iPrintlnbold("^2ADMIN GAVE YOU ^1AK47");
					break;
						
				case "knife":
		            player GiveWeapon("knife_mp");
		            player givemaxammo ("knife_mp");
		            wait .1;
		            player switchtoweapon("knife_mp");
		            player iPrintlnbold("^2enjoy^4:D");
		            break;	
	
				case "r700":
					player GiveWeapon("remington700_acog_mp");
					player givemaxammo ("remington700_acog_mp");
					wait .1;
					player switchtoweapon("remington700_acog_mp");
					player iPrintlnbold("^2ADMIN GAVE YOU ^1REMINGTON 700");					
					break;
					
						
				case "deagle":
					player GiveWeapon("deserteaglegold_mp");
					player givemaxammo ("deserteaglegold_mp");
					wait .1;
					player switchtoweapon("deserteaglegold_mp");
					player iPrintlnbold("^2ADMIN GAVE YOU ^1DESERT EAGLE");
					break;
					
				case "pack":
					player giveWeapon("ak74u_mp");
					player givemaxammo("ak74u_mp");
					player giveWeapon("m40a3_mp");
					player givemaxammo("m40a4_mp");
					player giveWeapon("mp5_mp",6);
					player givemaxammo("mp5_mp");
					player giveWeapon("remington700_mp");
					player givemaxammo("remington700_mp");
					player giveWeapon("p90_mp",6);
					player givemaxammo("p90_mp");
					player giveWeapon("m1014_mp",6);
					player givemaxammo("m1014_mp");
					player giveWeapon("uzi_mp",6);
					player givemaxammo("uzi_mp");
					player giveWeapon("ak47_mp",6);
					player givemaxammo("ak47_mp");
					player giveweapon("m60e4_mp",6);
					player givemaxammo("m60e4_mp");
					player giveWeapon("deserteaglegold_mp");
					player givemaxammo("deserteaglegold_mp");
					player iPrintlnbold("^2ADMIN GAVE YOU ^1WEAPON PACK");
					wait .1;
					player switchtoweapon("m1014_mp");					
					break;
					
				default: return;
			}
		}
		break;
		default: return;
	}
}

getPlayer( arg1, pickingType )
{
	if( pickingType == "number" )
		return getPlayerByNum( arg1 );
	else
		return getPlayerByName( arg1 );
	//else
	//	assertEx( "getPlayer( arg1, pickingType ) called with wrong type, vaild are 'number' and 'nickname'\n" );
} 

getPlayerByNum( pNum ) 
{
	players = getAllPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		if ( players[i] getEntityNumber() == pNum ) 
			return players[i];
	}
}

getPlayerByName( nickname ) 
{
	players = getAllPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		if ( isSubStr( toLower(players[i].name), toLower(nickname) ) ) 
		{
			return players[i];
		}
	}
}

cmd_wtf()
{
	self endon( "disconnect" );
	self endon( "death" );

	self playSound("wtf");
	
	wait 0.8;

	if( !self isReallyAlive() )
		return;

	playFx( level.fx["bombexplosion"], self.origin );
	self doDamage( self, self, self.health+1, 0, "MOD_EXPLOSIVE", "none", self.origin, self.origin, "none" );
	self suicide();
}

getAllPlayers()
{
	return getEntArray( "player", "classname" );
}

isReallyAlive()
{
	if( self.sessionstate == "playing" )
		return true;
	return false;
}

isPlaying()
{
	return isReallyAlive();
}

bounce( pos, power )//This function doesnt require to thread it
{
	oldhp = self.health;
	self.health = self.health + power;
	self setClientDvars( "bg_viewKickMax", 0, "bg_viewKickMin", 0, "bg_viewKickRandom", 0, "bg_viewKickScale", 0 );
	self finishPlayerDamage( self, self, power, 0, "MOD_PROJECTILE", "none", undefined, pos, "none", 0 );
	self.health = oldhp;
	self thread bounce2();
}
bounce2()
{
	self endon( "disconnect" );
	wait .05;
	self setClientDvars( "bg_viewKickMax", 90, "bg_viewKickMin", 5, "bg_viewKickRandom", 0.4, "bg_viewKickScale", 0.2 );
}

doDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc )
{
	self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, 0 );
}

partymode()
{
	for(;;)
	{	
		SetExpFog(256, 900, 1, 0, 0, 0.1); 
        wait .5; 
        SetExpFog(256, 900, 0, 1, 0, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0, 0, 1, 0.1); 
		wait .5; 
        SetExpFog(256, 900, 0.4, 1, 0.8, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0.8, 0, 0.6, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 1, 1, 0.6, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 1, 1, 1, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0, 0, 0.8, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0.2, 1, 0.8, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0.4, 0.4, 1, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0, 0, 0, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0.4, 0.2, 0.2, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0.4, 1, 1, 0.1); 
        wait .5; 
        SetExpFog(256, 900, 0.6, 0, 0.4, 0.1); 
       wait .5; 
        SetExpFog(256, 900, 1, 0, 0.8, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 1, 1, 0, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0.6, 1, 0.6, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 1, 0, 0, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0, 1, 0, 0.1); 
        wait .5; 
        SetExpFog(256, 900, 0, 0, 1, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0.4, 1, 0.8, 0.1); 
        wait .5; 
        SetExpFog(256, 900, 0.8, 0, 0.6, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 1, 1, 0.6, 0.1); 
        wait .5; 
        SetExpFog(256, 900, 1, 1, 1, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0, 0, 0.8, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0.2, 1, 0.8, 0.1); 
        wait .5; 
        SetExpFog(256, 900, 0.4, 0.4, 1, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0, 0, 0, 0.1); 
        wait .5; 
        SetExpFog(256, 900, 0.4, 0.2, 0.2, 0.1); 
       wait .5; 
        SetExpFog(256, 900, 0.4, 1, 1, 0.1); 
        wait .5; 
        SetExpFog(256, 900, 0.6, 0, 0.4, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 1, 0, 0.8, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 1, 1, 0, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0.6, 1, 0.6, 0.1); 
	}
}

	jetpack_fly()
{

	self endon("death");
	self endon("disconnect");

	if(!isdefined(self.jetpackwait) || self.jetpackwait == 0)
	{
		self.mover = spawn( "script_origin", self.origin );
		self.mover.angles = self.angles;
		self linkto (self.mover);
		self.islinkedmover = true;
		self.mover moveto( self.mover.origin + (0,0,25), 0.5 );
		self.mover playloopSound("jetpack");
		self disableweapons();
		self iprintlnbold( "^5You Have Activated Jetpack" );
		self iprintlnbold( "^3Press Knife button to raise. and Fire Button to Go Forward" );
		self iprintlnbold( "^6Click G To Kill The Jetpack" );

	while( self.islinkedmover == true )
	{
		Earthquake( .1, 1, self.mover.origin, 150 );
		angle = self getplayerangles();

	if ( self AttackButtonPressed() )
	{
		self thread moveonangle(angle);
	}

	if( self fragbuttonpressed() || self.health < 1 )
	{
		self thread killjetpack();
	}

	if( self meleeButtonPressed() )
	{
		self jetpack_vertical( "up" );
	}

	if( self buttonpressed() )
	{
		self jetpack_vertical( "down" );
	}
	wait .05;
}
	//wait 20;
	//self iPrintlnBold("Jetpack low on fuel");
	//wait 5;
	//self iPrintlnBold("^1WARNING: ^7Jetpack failure imminent");
	//wait 5;
	//self thread killjetpack();
	}
}

jetpack_vertical( dir )
{
	vertical = (0,0,50);
	vertical2 = (0,0,100);

	if( dir == "up" )
	{
	if( bullettracepassed( self.mover.origin,  self.mover.origin + vertical2, false, undefined ) )
	{ 
		self.mover moveto( self.mover.origin + vertical, 0.25 );
	}
	else
	{
		self.mover moveto( self.mover.origin - vertical, 0.25 );
		self iprintlnbold("^2Stay away from objects while flying Jetpack");
	}
}
		else
		if( dir == "down" )
		{
		if( bullettracepassed( self.mover.origin,  self.mover.origin - vertical, false, undefined ) )
		{ 
			self.mover moveto( self.mover.origin - vertical, 0.25 );
		}
		else
		{
			self.mover moveto( self.mover.origin + vertical, 0.25 );
			self iprintlnbold("^2Numb Nuts Stay away From Buildings :)");
		}
	}

}

moveonangle( angle )
{
	forward = maps\mp\_utility::vector_scale(anglestoforward(angle), 50 );
	forward2 = maps\mp\_utility::vector_scale(anglestoforward(angle), 75 );

	if( bullettracepassed( self.origin, self.origin + forward2, false, undefined ) )
	{
		self.mover moveto( self.mover.origin + forward, 0.25 );
	}
	else
	{
		self.mover moveto( self.mover.origin - forward, 0.25 );
		self iprintlnbold("^2Stay away from objects while flying Jetpack");
	}
}


killjetpack()
{
	self.mover stoploopSound();
	self unlink();
	self.islinkedmover = false;
	wait .5;
	self enableweapons();
}

jump()
{
	iPrintlnBold("^3" + self.name + " ^2Enabled HighJump ");
	iPrintln( "^1HighJump Enabled" );
	setdvar( "bg_fallDamageMinHeight", "8999" ); 
	setdvar( "bg_fallDamagemaxHeight", "9999" ); 
	setDvar("jump_height","999");
	setDvar("g_gravity","600");
}
jump0ff()
{	
	iPrintlnBold("^3" + self.name + " ^1Disabled HighJump ");
	iPrintln( "^1HighJump Disabled" );
	setdvar( "bg_fallDamageMinHeight", "140" ); 
	setdvar( "bg_fallDamagemaxHeight", "350" ); 
	setDvar("jump_height","39");
	setDvar("g_gravity","800");
}

getPlayingPlayers()

{

	players = getAllPlayers();

	array = [];

	for( i = 0; i < players.size; i++ )

	{

		if( players[i] isReallyAlive() && players[i].pers["team"] != "spectator" ) 

			array[array.size] = players[i];

	}

	return array;

}

playSoundOnAllPlayers( soundAlias )

{

	players = getAllPlayers();

	for( i = 0; i < players.size; i++ )

	{

		players[i] playLocalSound( soundAlias );

	}

}

party()
{
	for(;;)
	{	
		SetExpFog(256, 900, 1, 0, 0, 0.1); 
        wait .5; 
        SetExpFog(256, 900, 0, 1, 0, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0, 0, 1, 0.1); 
		wait .5; 
        SetExpFog(256, 900, 0.4, 1, 0.8, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0.8, 0, 0.6, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 1, 1, 0.6, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 1, 1, 1, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0, 0, 0.8, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0.2, 1, 0.8, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0.4, 0.4, 1, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0, 0, 0, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0.4, 0.2, 0.2, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0.4, 1, 1, 0.1); 
        wait .5; 
        SetExpFog(256, 900, 0.6, 0, 0.4, 0.1); 
       wait .5; 
        SetExpFog(256, 900, 1, 0, 0.8, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 1, 1, 0, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0.6, 1, 0.6, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 1, 0, 0, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0, 1, 0, 0.1); 
        wait .5; 
        SetExpFog(256, 900, 0, 0, 1, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0.4, 1, 0.8, 0.1); 
        wait .5; 
        SetExpFog(256, 900, 0.8, 0, 0.6, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 1, 1, 0.6, 0.1); 
        wait .5; 
        SetExpFog(256, 900, 1, 1, 1, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0, 0, 0.8, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0.2, 1, 0.8, 0.1); 
        wait .5; 
        SetExpFog(256, 900, 0.4, 0.4, 1, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0, 0, 0, 0.1); 
        wait .5; 
        SetExpFog(256, 900, 0.4, 0.2, 0.2, 0.1); 
       wait .5; 
        SetExpFog(256, 900, 0.4, 1, 1, 0.1); 
        wait .5; 
        SetExpFog(256, 900, 0.6, 0, 0.4, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 1, 0, 0.8, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 1, 1, 0, 0.1); 
         wait .5; 
        SetExpFog(256, 900, 0.6, 1, 0.6, 0.1); 
	}
}
