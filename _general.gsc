#include common_scripts\utility;
#include maps\mp\_utility;

init()
{
	thread crazy\bots::addTestClients();
	thread crazy\_throwingknife::init();
	thread crazy\_dvar::setupDvars();
	thread crazy\admin::main();
	thread crazy\_huds::init();
	thread crazy\_welcome::init();
	thread crazy\_health::init();
	thread crazy\_antiafk::init();
	thread crazy\_customrounds::init();
	thread crazy\_eventmanager::eventManagerInit();
	thread crazy\_binoculars::init();
	thread crazy\_realtimestats::init();
	thread vip\_vip::init();
	thread menu\_menu::init();
	thread crazy\_Killstreak::init();
}

//onPlayerConnect()
//{
	//for(;;)
	//{
		//level waittill("connecting", player);
		//player thread onPlayerSpawned();
	//}
//}

//onPlayerSpawned()
//{
	//self endon("disconnect");

	//for(;;)
	//{
		//self waittill("spawned_player");
		//self.customroundweapon = undefined;
	//}
//}
	
	