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


SpawnTank()
{
	if(self.spawnedveh)
		return;

	self.spawnedveh = true;

	position = self.origin + maps\mp\_utility::vector_scale(anglestoforward(self getplayerangles()), 200);

	AddTank(position);
}


AddTank(position)
{
	tank = spawn("script_model", position);
	tank setmodel("vehicle_tank");
	tank.targetname = "veh";
	tank thread WaitForOccupant();
	tank.gotperson = 0;
}


WaitforOccupant()
{
	self.gotperson = 0;

	wait 1;

	while(1)
	{
		wait 0.05;


		for(i = 0; i < level.players.size; i++)
		{
			p = level.players[i];

			if(isdefined(distance(p.origin, self.origin)) && distance(p.origin, self.origin) <= 150)
			if(!self.gotperson && p.health > 0 && p UseButtonPressed() && !p.isinvehicle)
			{
				p.isinvehicle = true;

				p detachall();
				p setmodel("");

				self.gotperson = 1;
				p iprintlnbold("You got in a tank");
				self thread TankDrive(p);

				p giveweapon("saw_mp");
				p switchtoweapon("saw_mp");

				self playsound("tankstart");

				wait 0.5;

				self playloopsound("tank_move");

				return;	
			}
		}
	}
}


TankDrive(player)
{

	self endon("end tank");
	self endon("pre-end tank");

	if(!isdefined(self.speed))
		self.speed = 0;

	forwards = maps\mp\_utility::vector_scale(anglestoforward(self.angles), 20);
	player setorigin(self.origin + forwards + (0, 0 , -6));
	player linkto(self);

	player setclientdvar("cg_thirdperson", 1);
	player setclientdvar("cg_thirdpersonrange", "400");
	player.third_elem.alpha = 1;

	self.pitch = 0;

	self thread maps\mp\gametypes\_flyvehicle::Time_out(); //delete the tank after an idle period
	self thread maps\mp\gametypes\_flyvehicle::Die(player);
	self thread MoveTank(player);
	self thread EndOnUseTank(player); //let the player get out
	self thread RotateTank(player);
//	self thread SpawnAndUseTurret();

	while(1)
	{
		wait 0.05;

		if(!self.gotperson)
			self notify("end tank");
	}
}


EndOnUseTank(player)
{
	wait 3;

	self endon("end tank");
	player endon("death");

	trace = undefined;

	while(1)
	{
		wait 0.1;

		if(player usebuttonpressed())
		{
			player iprintlnbold("You got out of the tank");

			player unlink();
			player setorigin(player.origin + (0, 0, 20));
			player setclientdvar("cg_thirdperson", 0);

			player.isinvehicle = false;
			player takeallweapons();
			player.third_elem.alpha = 0;

			player thread maps\mp\gametypes\_teams::playerModelForWeapon(player.pers["class"]["loadout_primary"]);

			self notify("pre-end tank");
			self stoploopsound();

			self.speed = 0;
			self thread WaitForOccupant();			

			if(!self.gotperson)
				return;
		}
	}
}



MoveTank(player)
{
	self endon("end tank");
	self endon("pre-end tank");

	basespeed = getdvarint("scr_tankspeed");
	f = undefined;
	a = undefined;
	b = undefined;
	c = undefined;
	d = undefined;
	e = undefined;
	g = undefined;
	h = undefined;

	halfposz = undefined;

	while(1)
	{
		wait 0.05;

//		playfx(level.boardfx, self.origin);

//		if(player meleebuttonpressed())
//			self thread flip(player, self.speed);

		if(player playerads())
		{

			if(self.speed == 1) //if they're starting accel
			{
				object2 = spawn("script_model", self.origin + (0, 3, 0));
				object2 linkto(self);

//				object2 playsound("boardgo");
				object2 thread delaydelete();
			}

			c = (0, self.angles[1], 0);

			f = self.origin + (0, 0, 50) + maps\mp\_utility::vector_scale(anglestoforward(c), basespeed * self.speed * 0.4);

			a = bullettrace(self.origin, f, false, self);

			g = bullettrace(self gettagorigin("tag_1"), self gettagorigin("tag_4"), false, self);			
			h = bullettrace(self gettagorigin("tag_2"), self gettagorigin("tag_3"), false, self);	

			if(a["fraction"] < 1)
			{
				self.speed = 4;
				//changing self.speed means it won't set off at full speed
				//when the player turns to a direction they can move in.

				continue; //bullet trace has hit, so don't move them

			}

			if((g["fraction"] < 1 && !isdefined(g["entity"])) || (h["fraction"] < 1 && !isdefined(h["entity"])))
			{ //check two outer forward traces for collisions

if(isdefined(g["entity"]) && g["entity"].classname == "player" && g["entity"].pers["team"] != player.pers["team"])
{
	g["entity"] thread maps\mp\gametypes\_globallogic::Callback_PlayerDamage(player, player, 49, 0, "MOD_EXPLOSIVE", "artillery_mp", self.origin, self.origin, "TORSO_UPPER", 0);
iprintlnbold("plyr hit");
}

if(isdefined(h["entity"]) && h["entity"].classname == "player" && h["entity"].pers["team"] != player.pers["team"])
{
	h["entity"] thread maps\mp\gametypes\_globallogic::Callback_PlayerDamage(player, player, 49, 0, "MOD_EXPLOSIVE", "artillery_mp", self.origin, self.origin, "TORSO_UPPER", 0);
iprintlnbold("plyr hit");
}


				self.speed = 0;

				continue;
			}

			b = bullettrace(f, f + (0, 0, -200), false, self);

			if(isdefined(b["entity"]) && issubstr(b["entity"].model, "80s")) //it's a car, BOOM!
				player radiusdamage(b["entity"].origin, 2, 1337, 1337);

			movetime = 0.2;

			self moveto(b["position"], movetime);

			if(b["position"] != self.origin)
				self.pitch = vectortoangles(self.origin - b["position"])[0];
			else
				self.pitch = 0;

			if(self.speed < 25)
				self.speed += 0.5;
		}
		else //if they are not ADS and they have speed
		{
			if(self.speed > 0)
			{
				self.speed--;

				//slowdown = self.origin + maps\mp\_utility::vector_scale(anglestoforward(self.angles), basespeed * self.speed * 0.1);
				//linker.origin = slowdown;

				//self moveto(linker.origin, 0.1);
			}
		}
	}
}


dele(object)
{
	self waittill("end tank");
	object delete();
}


RotateTank(player)
{
	self endon("end tank");
	self endon("pre-end tank");

	turnspeed = undefined;

	while(1)
	{
		wait 0.05;

		pa = player getplayerangles();
		sa = self.angles;

		if(sa != pa)
		{
			turnspeed = 0.6;

			if(self.speed < 6)
				turnspeed = 2;

			self rotateto((self.pitch * -1, pa[1], 0), turnspeed);
		}
	}
}


delaydelete()
{
	wait 5;
	
	self delete();
}
