#include crazy\_eventmanager;

init()
{
	precacheItem( "binoculars_mp" );	
	
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
}


onPlayerConnected()
{
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
}


onPlayerSpawned()
{
	// Give the binos to the player
	self giveWeapon( "binoculars_mp" );
	self setActionSlot( 2, "weapon", "binoculars_mp" );
	
	// Monitor the use of binos to prevent them from be used as sniper scopes
	self thread monitorBinosUtilization();
}


monitorBinosUtilization()
{
	self endon("death");
	self endon("disconnect");
	level endon( "game_ended" );
	
	oldWeapon = self getCurrentWeapon();
	wasBinos = ( oldWeapon == "binoculars_mp" );
	
	for (;;) 
	{
		wait (0.05);
		if ( isDefined( self ) ) {
			currentWeapon = self getCurrentWeapon();
			if ( currentWeapon != oldWeapon ) {
				if ( wasBinos ) {
					self shiftPlayerView( 3 );
					wasBinos = false;
				} else if ( currentWeapon == "binoculars_mp" ) {
					wasBinos = true;
				}					
					
				oldWeapon = currentWeapon;
			}			
		}	
	}
}

shiftPlayerView( iDamage )
{
	if(iDamage == 0)
		return;
	// Make sure iDamage is between certain range
	if ( iDamage < 3 ) {
		iDamage = randomInt( 10 ) + 5;
	} else if ( iDamage > 45 ) {
		iDamage = 45;
	} else {
		iDamage = int( iDamage );
	}

	// Calculate how much the view will shift
	xShift = randomInt( iDamage ) - randomInt( iDamage );
	yShift = randomInt( iDamage ) - randomInt( iDamage );

	// Shift the player's view
	self setPlayerAngles( self.angles + (xShift, yShift, 0) );

	return;
}