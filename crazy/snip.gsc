init()
{
	level thread onPlayerConnect();
}
 
 onPlayerConnect()
{
	for( ;; )
	{
		level waittill( "connecting", player );
		player thread onSpawnPlayer();
		
	}
}

onSpawnPlayer()
{
	self endon ( "disconnect" );
	while( 1 )
	{
		self waittill( "spawned_player" );
		self notify("endthisbs");
	    if(mode == "snip")
    {
        level thread snip();
    }
	}
}	

snip()
{
 self.player SetWeaponAmmoClip( "deserteagle_mp", 0 );
}
