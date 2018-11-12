#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

/*
Main Flyer 0.25 scripts. By NovemberDobby.

//////////////////////////////////////////////////
////       ///      ///     ////     /// ///// ///
////   //  ///  //  ///  // ////  // ///  /// ////
////   //  ///  //  ///     ////     ////    /////
////   //  ///  //  ///      ////     ////  //////
////   //  ///  //  ///  /// ///  /// ////  //////
////       ///      ///      ///      ////  //////
//////////////////////////////////////////////////

*/


SpawnPlane()
{
	if(self.spawnedveh)
		return;

	self.spawnedveh = true;

	position = self.origin + (0,0,50) + maps\mp\_utility::vector_scale(anglestoforward(self getplayerangles()), 200);

	AddFlyer(position, true);
}


SpawnHeli()
{
	if(self.spawnedveh)
		return;

	self.spawnedveh = true;

	position = self.origin + (0,0,50) + maps\mp\_utility::vector_scale(anglestoforward(self getplayerangles()), 200);

	AddFlyer(position, false);
}


WaitforOccupant()
{
	wait 1;

	while(1)
	{
		wait 0.05;

		for(i = 0; i < level.players.size; i++)
		{

			if(isdefined(self.waitforentry))
			{
				wait 1.5;
				self.waitforentry = undefined;
			}

			p = level.players[i];

			if(isdefined(distance(p.origin, self.origin)) && distance(p.origin, self.origin) <= 150)

			if(p.health > 0 && p UseButtonPressed() && !p.isinvehicle)
			{
				if(self.model == "vehicle_flyer")
				{
					p.isinvehicle = true;
					p detachall();
					p setmodel("");

					self.gotperson = 1;
					p iprintlnbold("You got in a plane");
					self thread FlyerFly(p);
					return;
				}
				else if(self.model == "vehicle_heli")
				{


					if(self.gotperson == 2)
						return;

					p.isinvehicle = true;
					p detachall();
					p setmodel("");

					p iprintlnbold("You got in a helicopter");
					p.moving.alpha = 1;

					self.blades hide(); //hide stationary blades
					self.otherblades hide();
					self.blades notsolid();
					self.otherblades notsolid();

					self thread HeliFly(p);
				}


			}
		}
	}

}


BladeLink(blades)
{
	self endon("end heli");

	wait 0.1;

	while(1)
	{
		if(!isdefined(self) || self.hp < 1)
		{
			self.blades show();
			self.otherblades show();

			self.blades thread SpinExplode();
			self.otherblades thread SpinExplode();

			return;
		}

		wait 0.1;

		playfxontag(level.bladefx, self, "tag_blades");
		playfxontag(level.otherbladefx, self, "tag_blades2");
	}
}


AddFlyer(position, type)
{
	flyer = spawn("script_model", position);
	flyer.targetname = "veh";

	flyer.gotperson = 0;

	if(type)
		flyer setmodel("vehicle_flyer");
	else
	{
		flyer.blades = spawn("script_model", flyer.origin + (-17,0,0));
		flyer.blades setmodel("vehicle_heli_blades");
		flyer.blades linkto(flyer);

		flyer.otherblades = spawn("script_model", flyer.origin + (-216,-4,-37));
		flyer.otherblades setmodel("vehicle_heli_blades2");
		flyer.otherblades linkto(flyer);

		flyer.blades.parent = flyer;
		flyer.otherblades.parent = flyer;

		flyer.blades thread Time_out();
		flyer.otherblades thread Time_out();

		flyer.origin += (0, 0, 90);
		flyer setmodel("vehicle_heli");
	}

	flyer thread Time_out();
	flyer thread WaitForOccupant();
}


SpinExplode()
{
	self moveto(self.origin + (randomint(120), randomint(120), randomint(120)), 2, 0, 0.4);
	self rotateto((randomint(360), randomint(360), randomint(360)), 2, 0.4);

	wait 2;

	self delete();
}


FlyerFly(player)
{

	if(!isdefined(self.playing))
	{
		self.playing = "lol"; //ehh...long story, playfxontag is weird
		playfxontag(level.fx_airstrike_contrail, self, "tag_right_wingtip");
		playfxontag(level.fx_airstrike_contrail, self, "tag_left_wingtip");
	}

	player giveWeapon("usp_mp"); //doesn't actually shoot
	player giveMaxAmmo("usp_mp");
	player switchtoweapon("usp_mp");

	self playloopsound("veh_mig29_mid_loop");

	self endon("end flyer");

	self.speed = 0;

	player setorigin(self.origin + (0,0,-40));
	player linkto(self);

	player setclientdvar("cg_thirdperson", 1);

	player.third_elem.alpha = 1;

	player setclientdvar("cg_thirdpersonrange", "800");

	self thread Time_out(); //delete the plane after an idle period
	self thread Die(player); //plane health
	self thread MoveFlyer(player); //plane speed
	self thread RotateFlyer(player); //plane angles
	self thread EndOnUseFlyer(player); //let the player get out
	self thread Contrails(); //play effects on the engines

	while(1)
	{
		wait 0.05;

		if(self.gotperson == 0)
			self notify("end flyer");
	}
}


DamageMe(player)
{
	self endon("end flyer");
	self endon("end board");
	self endon("end tank");
	self endon("end heli");

	while(1)
	{
		self waittill("damage", dmg, who, dir, point, mod);

//		if(isdefined(who.model) && issubstr(who.model, "80s"))
//			continue; //stop normal vehicles like exploding cars doing dmg

		if(!isplayer(who))
			continue;

		if(who.pers["team"] != player.pers["team"] && who != player)
		{
			self.lastdmger = who;

			self.hp -= dmg;
	
			if(self.hp > -1)
				who iprintln("HP: " + self.hp);
	
			if(isPlayer(who))
				who thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback(false);
		}
	}
}


Die(player) //vehicle health handling
{
	self setcandamage(true);

	if(!isdefined(self.hp))
	{
		self.hp = getdvarint("scr_vehiclehealth");
		
//		if(self.hp < 1)
//			self.hp = 1000; //WTF?
		
		self thread DamageMe(player);
	}

	self.lastdmger = player;

	wait 0.05;

	while(1)
	{
		wait 0.05;

		if(!self.gotperson || !isdefined(self)) //if there's no-one flying or i don't exist, return
			return;

		if(self.hp < 1 || player.health < 1)
		{
			self notify("end flyer");
			self notify("end heli"); //stop all the other threads
			self notify("end board");
			self notify("end tank");

			if(isdefined(self.gunner)) //run a separate thread to kill the gunner because of some stuff
				self.gunner thread Alsokill(self);

			player.moving.alpha = 0;
			player unlink(); //let the player go

			self thread ExplodeBoom();

			player.isinvehicle = false;

			player thread maps\mp\gametypes\_teams::playerModelForWeapon(player.pers["class"]["loadout_primary"]);
			wait 0.05;

			player thread maps\mp\gametypes\_globallogic::Callback_PlayerKilled(self.lastdmger, self.lastdmger, 100, "MOD_EXPLOSIVE", "misc_mp", (0, 0, 0), "TORSO_UPPER", 0, 3016);

			player setclientdvar("cg_thirdperson", 0);
			player.third_elem.alpha = 0;

			return;
		}
	}
}


Alsokill(veh)
{
	self.moving.alpha = 0;
	self unlink();
	self.isinvehicle = false;

	self thread maps\mp\gametypes\_teams::playerModelForWeapon(self.pers["class"]["loadout_primary"]);
	wait 0.05;

	self thread maps\mp\gametypes\_globallogic::Callback_PlayerKilled(veh.lastdmger, veh.lastdmger, 100, "MOD_EXPLOSIVE", "misc_mp", (0, 0, 0), "TORSO_UPPER", 0, 3016);

	self setclientdvar("cg_thirdperson", 0);
	self.third_elem.alpha = 0;
}


ExplodeBoom()
{
	self stoploopsound();

	//forwards = self.origin + maps\mp\_utility::vector_scale(anglestoforward(self.angles), 600);
	//self moveto(forwards, 2);
	//change to a physics launch?

	object = spawn("script_model", self.origin);
	object playsound("exp_armor_vehicle");
	object thread delaydelete();

	self rotateto(self.angles, 2);

	playfx(level.bombstrike, self.origin); //level.bombstrike is stock
	self playsound("exp_armor_vehicle");

	//wait 0.5;

	wait 2;

	self delete();
}


HeliFly(player)
{

	if(!self.gotperson) //then the guy is the pilot, give him some rocketz
	{
		self.gotperson = 1;
		player giveWeapon("rpg_mp"); //doesn't actually shoot
		player giveMaxAmmo("rpg_mp");
		player switchtoweapon("rpg_mp");
		player iprintlnbold("You are the pilot");
		self.driver = player;
	}

	else if(self.gotperson == 1)
	{
		if(player.pers["team"] == self.driver.pers["team"])
		{
			self.gunner = player;
			self.driver iprintlnbold(player.name + " is your gunner");
			player giveWeapon("uzi_mp");
			player giveMaxAmmo("uzi_mp");
			player switchtoweapon("uzi_mp");
			self.gotperson = 2;

			player.origin = self.origin + (0, 70, -100);
			player linkto(self);
			player iprintlnbold("You are a gunner");
			player.isinvehicle = true;
	
			player setclientdvar("cg_thirdpersonrange", "400");

			self thread EndOnUseHeliGunner(player);

			return;
		}
	}

	self playloopsound("mp_cobra_helicopter");

	self endon("end heli");

	self.speed = 0;

	player setorigin(self.origin + (0, 0, -100));
	player linkto(self);

	player setclientdvar("cg_thirdperson", 1);
	player.third_elem.alpha = 1;

	player setclientdvar("cg_tracerwidth", 20);
	player setclientdvar("cg_tracerchance", 1);
	player setclientdvar("cg_firstpersontracerchance", 1);
	player setclientdvar("cg_thirdpersonrange", "400");

	self thread Time_out();
	self thread MoveHeli(player);
	self thread RotateHeli(player);
	self thread EndOnUseHeli(player);
	self thread Die(player);
	self thread BladeLink();

	while(1)
	{
		wait 0.05;

		if(!self.gotperson)
			self notify("end heli");
	}
}


Contrails()
{
	while(1)
	{
		wait 0.1;

		if(self.speed > 5)
		{
			playfxontag(level.flyer_burner, self, "tag_engine_right");
			playfxontag(level.flyer_burner, self, "tag_engine_left");
		}
	}
}


EndOnUseFlyer(player)
{
	player endon("death");
	self endon("end flyer");
	self endon("gotperson");

	wait 3;

	trace = undefined;
	timetogo = undefined;

	while(1)
	{
		wait 0.1;

		if(player.health < 1 || !isdefined(player))
			return;

		if(player usebuttonpressed())
		{
			player iprintlnbold("You got out of the plane");

			player unlink();
			player setclientdvar("cg_thirdperson", 0);
			player.third_elem.alpha = 0;
			self.gotperson = 0;

			player thread maps\mp\gametypes\_teams::playerModelForWeapon(player.pers["class"]["loadout_primary"]);

			player.isinvehicle = false;
			player.lastflyer = undefined;
			player takeallweapons();

			//put model down to the ground
			self notify("pre-end flyer");
			self stoploopsound();

			trace = bullettrace(self.origin, self.origin + (0,0,-10000), false, self);

			timetogo = calcspeed(1000, self.origin, trace["position"]);

			self.speed = 0;
			self moveto(trace["position"] + (0, 0, 40), timetogo);

			self thread WaitForOccupant(); //let players board it as it falls			

			if(timetogo > 2.1)
			{

			//if it'll take longer than 2.1 secs to hit the ground, start spinning out of control (accelerate spin at a hundredth
			//of the time it'll take to hit the ground) until we are at one second before impact, then stop.

				self rotatevelocity((randomint(120), randomint(120), randomint(120)), timetogo - 1, timetogo/100);

				self thread EndonOccupant(timetogo);
	
				wait (timetogo - 1);

				self rotateto((0, self.angles[1], 0), 1);

			}
			else //if it takes less than 2.1 secs to hit the ground, right it straight away
				self rotateto((0, self.angles[1], 0), 0.2);

			if(!self.gotperson) //if no-one's picked it up by the time it's landed, return
				return;
		}
	}
}


EndonOccupant(timetogo)
{
	for(i = 0; i < 100; i++)
	{
		wait ((timetogo -1)/100);

		if(self.gotperson)
		{
			self moveto(self.origin + (0,0,3), 0.05);
			self rotateto((0, self.angles[1], 0), 0.5);
			self notify("gotperson");
			return;
		}
	}
}


delaydelete()
{
	wait 1.567;
	self stoploopsound();
	wait 3.433;
	self delete();
}


MoveFlyer(player)
{
	self endon("end flyer");
	self endon("pre-end flyer");

	basespeed = getdvarint("scr_flyerspeed");

	while(1)
	{
		wait 0.05;

		if(player playerads())
		{

/*
			if(getdvarint("scr_flyerspeed") >= 20) //scr_flyerspeed 1030 would put the flyers at the REAL speed of sound just before
							       //they finish accelerating (13397.2173 inches per second = SOS)
			{
				if(self.speed == 13)
				{
					setdvar("scr_timescale", 1);

					playfxontag(level.sonic_boom, self, "tag_origin");

					object = spawn("script_model", self.origin);
					object playsound("veh_mig29_sonic_boom");
					object linkto(self);
					object thread delaydelete();

					object2 = spawn("script_model", self.origin);
					object2 playsound("veh_mig29_sonic_boom");
					object2 linkto(self);
					object2 thread delaydelete();

					object3 = spawn("script_model", self.origin);
					object3 playsound("veh_mig29_sonic_boom");
					object3 linkto(self);
					object3 thread delaydelete();
				}

			}
*/

			if(self.speed == 1)
			{
				object = spawn("script_model", self.origin);
				object linkto(self);
				object2 = spawn("script_model", self.origin);
				object2 linkto(self);

				object playloopsound("jetgo");
				object2 playloopsound("jetgo");
				object thread delaydelete();
				object2 thread delaydelete();
			}


			forwards = self.origin + maps\mp\_utility::vector_scale(anglestoforward(self.angles), basespeed * self.speed);
			forwards2 = self.origin + maps\mp\_utility::vector_scale(anglestoforward(self.angles), 150);

			trace = bullettrace(self.origin + (0, 0, 5), forwards2, false, self);

			//if the trace hits something and collisions are on, and the surface isn't caulk or sky or something
			if(trace["fraction"] != 1 && level.collisions && trace["surfacetype"] != "default")
			{
				if(self.speed > 12)
				{
					self thread ExplodeBoom();
					player.isinvehicle = false;
					player unlink();
					player thread maps\mp\gametypes\_teams::playerModelForWeapon(player.pers["class"]["loadout_primary"]);
					wait 0.05;					

					player suicide();
					self notify("end flyer");
				}

				else if(self.speed <= 12)
				{
					self.speed = 0;
					continue;
				}
			}

			self moveto(forwards, 0.05);

			if(self.speed < 15)
				self.speed++;
		}
		else
		{
			if(self.speed > 0)
			{
				self.speed--;

				slowdown = self.origin + maps\mp\_utility::vector_scale(anglestoforward(self.angles), basespeed * self.speed);
				self moveto(slowdown, 0.05);
			}
		}

		player.lastflyer = self;
	}
}


RotateFlyer(player)
{
	self endon("end flyer");
	self endon("pre-end flyer");

	turnspeed = undefined;
	rollangle = 0;

	while(1)
	{
		wait 0.1;

		pa = player getplayerangles();
		sa = self.angles;

		if(sa != pa)
		{
			//if player yaw = left, roll them clockwise
			//if player yaw = right, roll them anticlockwise

			ps = pa[1] - sa[1];
			sp = sa[1] - pa[1];

			if(sp == 0 || self.speed == 0) //if they aren't moving or they are pointing straight ahread, don't roll
				rollangle = 0;


			else if (sp > 0 && self.speed > 5)
				rollangle = (sp);
			else if(ps > 0 && self.speed > 5)
				rollangle = (ps * -1);


			//if(rollangle > 89) rollangle = 89;
			//if(rollangle < -89) rollangle = -89; //find some way to stop the plane going upside-down (this doesn't work)

			//if the player is looking 45+ degrees upwards or 45+ degrees down, don't rotate because it looks strange.
			if(pa[0] <= -45 || pa[0] >= 45)
				rollangle = 0;

			turnspeed = 0.4;

			if(self.speed < 15)
				turnspeed = 2; //turn slowly when the plane is stationary (lol). like, really slowly.

			self rotateto((pa[0], pa[1], rollangle), turnspeed);
		}
	}
}


EndOnUseHeliGunner(gunner)
{
	self endon("end heli");
	gunner endon("death");

	wait 1;

	while(1)
	{
		wait 0.1;

		if(gunner.health < 1 || !isdefined(gunner))
			return;

		if(gunner usebuttonpressed())
		{
			self.waitforentry = "wait";

			self.gunner = undefined;
			gunner.moving.alpha = 0;
			self.gotperson = 1; //assume only the pilot is left, as you can't have a gunner on his own (is thrown out when the pilot leaves)

			gunner unlink();
			gunner.isinvehicle = false;
			gunner iprintlnbold("You jumped out");
			gunner.third_elem.alpha = 0;

			gunner setclientdvar("cg_thirdperson", 0);
			gunner thread maps\mp\gametypes\_teams::playerModelForWeapon(gunner.pers["class"]["loadout_primary"]);

			gunner.lastflyer = undefined;

			gunner takeallweapons();

			return;
		}
	}
}


EndOnUseHeli(player)
{
	wait 3;

	self endon("end heli");
	player endon("death");

	if(isdefined(player.bot))
		level waittill("eternity"); //keep bots in

	falltrace = undefined;
	timetogo = undefined;
	pos = undefined;
	rockettrace = undefined;
	timetomove = undefined;

	while(1)
	{
		wait 0.1;

		if(player.health < 1 || !isdefined(player))
			return;

		if(player usebuttonpressed())
		{
			self.driver = undefined;
			player.moving.alpha = 0;
			self.gotperson = 0;

			self.waitforentry = "wait";

			if(isdefined(self.gunner))
			{
				self.gunner unlink();
				self.gunner.isinvehicle = false;
				self.gunner thread maps\mp\gametypes\_teams::playerModelForWeapon(self.gunner.pers["class"]["loadout_primary"]);
				self.gunner iprintlnbold("Your pilot (" + player.name + ") jumped out");
				self.gunner.moving.alpha = 0;
				self.third_elem.alpha = 0;
				self.gunner = undefined;
			}

			player iprintlnbold("You got out of the helicopter");

			player unlink();
			player setclientdvar("cg_thirdperson", 0);
			player.third_elem.alpha = 0;
			player thread maps\mp\gametypes\_teams::playerModelForWeapon(player.pers["class"]["loadout_primary"]);

			player.isinvehicle = false;
			player.lastflyer = undefined;
			self.blades show();
			self.otherblades show();
			self.blades solid();
			self.otherblades solid();

			player takeallweapons();

			//put model down to the ground
			self notify("pre-end heli");
			self stoploopsound();

			falltrace = bullettrace(self.origin + (0, 0, -10), self.origin + (0, 0, -10000), false, self);
			timetogo = calcspeed(500, self.origin, falltrace["position"]);

			self.speed = 0;
			self moveto(falltrace["position"] + (0, 0, 120), timetogo);

			self.blades show();
			self.otherblades show();
			self.blades solid();
			self.otherblades solid();

			self thread WaitForOccupant(); //let players board it as it falls			

			wait (timetogo - 1);
			self rotateto((0, self.angles[1], 0), 1);

			if(!self.gotperson)
				return;
		}
	}
}


Impact(player)
{
	trace = undefined;
	forwards = undefined;

	while(1)
	{
		wait 0.05;

		forwards = self.origin + maps\mp\_utility::vector_scale(anglestoforward(self.angles), 100);
		trace = bullettrace(self.origin, forwards, true, self);
		
		if(trace["fraction"] != 1)
		{
			wait 0.05;
			playfx(level.bombstrike2, self.origin);
			self playsound("artillery_impact");

			for(i = 0; i < level.pp.size; i++)
			{
				p = level.pp[i];
				if(isdefined(distance(self.origin, p.origin)) && distance(self.origin, p.origin) <= 200)
					p thread maps\mp\gametypes\_globallogic::Callback_PlayerDamage(player, player, 49, 0, "MOD_EXPLOSIVE", "artillery_mp", self.origin, self.origin, "TORSO_UPPER", 0);
			}

			self hide();
			wait 3;
			self delete();
		}
	}
}


MoveHeli(player)
{
	self endon("end heli");
	self endon("pre-end heli");
	player endon("death");

	self.heliangle = 0;

	updn = undefined;
	basespeed = getdvarint("scr_helispeed");
	trace = undefined;

	while(1)
	{
		wait 0.05;

		if(player getplayerangles()[0] > 25) //looking down & moving forwards = go down
			updn = -7;
		else if(player getplayerangles()[0] < -15) //looking up & moving forwards = go up
			updn = 13;
		else
			updn = 0; //looking ahead-ish * moving forwards = go forwards

		if(player playerads())
		{
			forwards = self.origin + maps\mp\_utility::vector_scale(anglestoforward((0, self.angles[1], 0)), basespeed * self.speed);
			forwards2 = self.origin + maps\mp\_utility::vector_scale(anglestoforward((0, self.angles[1], 0)), 150);

			trace = bullettrace(player.origin, forwards2 + (0, 0, updn), false, self);

			if(trace["fraction"] != 1 && level.collisions && trace["surfacetype"] != "default")
			{
				continue;
				self.speed = 0;
				//heli hit detection sucks, change it
			}

			if(updn < 0)
			{
				player.moving settext("^4MOVING DOWN");

				if(isdefined(self.gunner))
					self.gunner.moving settext("^4MOVING DOWN");
			}
			else if(updn > 0)
			{
				player.moving settext("^1MOVING UP");

				if(isdefined(self.gunner))
					self.gunner.moving settext("^1MOVING UP");
			}
			else
			{
				player.moving settext("^3STAYING LEVEL");

				if(isdefined(self.gunner))
					self.gunner.moving settext("^3STAYING LEVEL");
			}

			self moveto((forwards[0], forwards[1], forwards[2] + updn), 0.05);

			if(self.speed < 15)
			{
				self.speed += 0.1;

				if(self.heliangle < 20)
					self.heliangle++;
			}
		}
		else
		{
			player.moving settext("^3STAYING LEVEL");

			if(isdefined(self.gunner))
				self.gunner.moving settext("^3STAYING LEVEL");

			if(self.speed > 0)
			{
				self.speed -= 0.2; //slow down quicker than speeding up

				if(self.heliangle > -20)
					self.heliangle -= 2;

				slowdown = self.origin + maps\mp\_utility::vector_scale(anglestoforward((0, self.angles[1], 0)), basespeed * self.speed);
				self moveto(slowdown, 0.05);
			}
		}

		if(self.speed == 0 && self.heliangle < 0)
			self.heliangle++;

		if(self.speed > 0 && self.speed < 5 && self.heliangle < 0)
			self.heliangle += 5;

		player.lastflyer = self;
	}


}


RotateHeli(player)
{
	self endon("end heli");
	self endon("pre-end heli");
	player endon("death");

	while(1)
	{
		wait 0.1;

		pa = player getplayerangles();
		sa = self.angles;

		if(sa != pa)
			self rotateto((self.heliangle, pa[1], 0), 1);
	}
}


calcspeed(speed, origin1, moveto)
{
	dist = distance(origin1, moveto);
	time = (dist / speed);
	return time;
}


Time_out()
{
	if(isdefined(self.parent)) //then this is a rotor blade
	{
		while(1)
		{
			wait 0.1;

			if(self.parent.hp < 1 || !isdefined(self.parent))
			{
				self delete();
				return;
			}
		}
	}

	//otherwise this has been called on a flyer/heli/hoverboard

	limit = (getdvarfloat("scr_deletetime") - 1)/0.05;
	if(limit < 200) limit = 200;

	num = 0;

	wait 1;

	while(1)
	{
		wait 0.05;
		num++;

		if(self.gotperson)
			num = 0;

		if(num > limit)
		{
			self notify("end flyer");
			self notify("end heli");
			self delete();
			return;
		}
	}
}

