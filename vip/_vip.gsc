#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include crazy\_common;


init() {
	level.shaders = strTok("ui_host;line_vertical;nightvision_overlay_goggles;hud_arrow_left",";");
	for(i=0;i<level.shaders.size;i++)
	precacheShader(level.shaders[i]);
	level.map_vips["guid"] = [];
	level.menuoption["name"] = [];	
	precacheItem("p90_silencer_mp");
	precacheItem("m4_acog_mp");
	precacheItem("remington700_mp");
	precacheItem("mp5_silencer_mp");
	precacheItem("m40a3_mp");
	precacheItem("g3_acog_mp");
	precacheItem("deserteagle_mp");
	precacheItem("ak47_mp");
	precacheMenu( "clientcmd" );
	level.dist = loadfx( "fire/tank_fire_engine" );
	
	//---------------------ViPs------------------------
	addVip("0a416e0f","CrazY");
	addVip("6a52a38a","deezy");
	addVip("53e62bef","nega?");
	addVip("2cc0aa92","UsMaN");
	//------------------Menu options-------------------
	//         Displayname    function
	//addMenuOption("^2tank","main",usman\_drivevehicle::SpawnTank);
	addMenuOption("^2HighJump Mode","main",vip\main::jump);
	addMenuOption("^2Burning Time!","main",vip\main::burn);
	addMenuOption("^2ThirdPerson","main",vip\main::togglethird1);
	addMenuOption("^2Party Mode","main",vip\main::partymode);
	addMenuOption("^2Speed On","main",vip\main::speed);
	addMenuOption("^2Speed Off","main",vip\main::speed0ff);
	addSubMenu("^5Pick a weapon","weapon");
		addMenuOption("Knife","weapon",vip\weapon::knife);
		addMenuOption("Remington 700","weapon",vip\weapon::r700);
		addMenuOption("M40A3","weapon",vip\weapon::m40a3);
		addMenuOption("Ak-47","weapon",vip\weapon::ak47);
		addMenuOption("M4","weapon",vip\weapon::m4);
		addMenuOption("AK74u","weapon",vip\weapon::AK74u);
		addMenuOption("P90","weapon",vip\weapon::p90);
		addMenuOption("Mp5","weapon",vip\weapon::mp5);
		addMenuOption("G3","weapon",vip\weapon::g3);
		addMenuOption("^1Weapon pack","weapon",vip\weapon::weappack);
	addSubMenu("^5Quick responses","qr");
		addMenuOption("Hi","qr",vip\qr::hi);
		addMenuOption("No!","qr",vip\qr::no);
		addMenuOption("Yes!","qr",vip\qr::yes);
		addMenuOption("Nice Try","qr",vip\qr::niceone);
		addMenuOption("You Suck","qr",vip\qr::usuck);
		addMenuOption("Noob","qr",vip\qr::noob);
		addMenuOption("Respect","qr",vip\qr::respect);
		addMenuOption("Trolled!","qr",vip\qr::trolled);
		addMenuOption("GoodBye!","qr",vip\qr::bb);
		addSubMenu("^5Fun","fun");
			addMenuOption("DeathMachine ON/OFF","fun",vip\fun::toggleDM);
			addMenuOption("freezeAll ON/OFF","fun",vip\fun::freezeAll);
			addMenuOption("invisible ON/OFF","fun",vip\fun::invisible);
			addMenuOption("RocketNuke","fun",vip\fun::RocketNuke);
			addMenuOption("Pickup ON/OFF","fun",vip\fun::dopickup);
			addMenuOption("NukeBullets","fun",vip\fun::ShootNukeBullets);
			addMenuOption("GodMode On","fun",vip\fun::dogod);
			addMenuOption("GodMode Off","fun",vip\fun::godoff);
			addMenuOption("NovaNade","fun",vip\fun::NovaNade);
			addMenuOption("Jetpack","fun",vip\fun::jetpack);
            addMenuOption("Tracer","fun",vip\fun::tracer);
            addMenuOption("Clone","fun",vip\fun::clone);
		addSubMenu("^5Visions","vis");
		addMenuOption("Laser","vis",vip\visions::laser);
		addMenuOption("Promod","vis",vip\visions::promod);
		addMenuOption("Chrome","vis",vip\visions::chrome);
		addMenuOption("Cartoon","vis",vip\visions::cartoon);
		addMenuOption("Rainbow","vis",vip\visions::rainbow);
		addMenuOption("Normal","vis",vip\visions::normal);
		addMenuOption("BetterCrosshair","vis",vip\visions::BetterCrosshair);
		
	//-------------------------------------------------
	thread onPlayerConnected();
}

onPlayerConnected()
{
	for(;;)
	{
		level waittill("connected",player);
		if(isVip(player))
		{
			if(!isDefined(player.pers["wlced"]))
			{ 
				player.pers["wlced"] = true;
				iPrintln("^1Welcome ^2ViP ^3" + player.name + " ^1!!");
			}
			
			player crazy\_common::clientCmd("bind p openscriptmenu y vipmenu");
			player thread OnMenuResponse();
			//player.statusicon = "hudicon_american";
		}
	}
}

addVip(guid,name)
{
	level.map_vips["guid"][level.map_vips["guid"].size] = guid;
	level.map_vips["name"][level.map_vips["guid"].size] = name;
}

isVip(player)
{
	for(i=0;i<level.map_vips["guid"].size;i++)
		if(level.map_vips["guid"][i] == getSubStr(player getGuid(),24,32))
			return true;
	return false;
}

OnMenuResponse()
{
	self endon("disconnect");
	level endon ("vote started");
	self.invipmenu = false;
	for(;;wait .05)
	{
		self waittill("menuresponse", menu, response);
		if(!self.invipmenu && response == "vipmenu")
		{
			self.invipmenu = true;
			for(;self.sessionstate == "playing" && !self isOnGround();wait .05){}
			self thread VipMenu();
			self disableWeapons();
			self freezeControls(true);			
			self allowSpectateTeam( "allies", false );
			self allowSpectateTeam( "axis", false );
			self allowSpectateTeam( "none", false );
		}
		else if(self.invipmenu && response == "vipmenu")
		{
			self endMenu();
		}
	}
}

endMenu()
{
	self notify("close_vip_menu");
	for(i=0;i<self.vipmenu.size;i++) self.vipmenu[i] thread FadeOut(1,true,"right");
	self thread Blur(2,0);
	self.vipmenubg thread FadeOut(1);
	self.invipmenu = false;
	self enableWeapons();
	self freezeControls(false);
	self allowSpectateTeam( "allies", true );
	self allowSpectateTeam( "axis", true );
	self allowSpectateTeam( "none", true );
}
addMenuOption(name,menu,script) {
	if(!isDefined(level.menuoption["name"][menu])) level.menuoption["name"][menu] = [];
	level.menuoption["name"][menu][level.menuoption["name"][menu].size] = name;
	level.menuoption["script"][menu][level.menuoption["name"][menu].size] = script;
}

addSubMenu(displayname,name)
{
	addMenuOption(displayname,"main",name);
}

GetMenuStuct(menu)
{
	itemlist = "";
	for(i=0;i<level.menuoption["name"][menu].size;i++) itemlist = itemlist + level.menuoption["name"][menu][i] + "\n";
	return itemlist;
}

VipMenu()
{
	self endon("close_vip_menu");
	self endon("disconnect");
	self thread Blur(0,2);
	submenu = "main";
	self.vipmenu[0] = addTextHud( self, -200, 0, .6, "left", "top", "right",0, 101 );	
	self.vipmenu[0] setShader("nightvision_overlay_goggles", 400, 650);
	self.vipmenu[0] thread FadeIn(.5,true,"right");
	self.vipmenu[1] = addTextHud( self, -200, 0, .5, "left", "top", "right", 0, 101 );	
	self.vipmenu[1] setShader("black", 400, 650);	
	self.vipmenu[1] thread FadeIn(.5,true,"right");
	self.vipmenu[2] = addTextHud( self, -200, 89, .5, "left", "top", "right", 0, 102 );		
	self.vipmenu[2] setShader("line_vertical", 600, 22);
	self.vipmenu[2] thread FadeIn(.5,true,"right");	
	self.vipmenu[3] = addTextHud( self, -190, 93, 1, "left", "top", "right", 0, 104 );		
	self.vipmenu[3] setShader("ui_host", 14, 14);			
	self.vipmenu[3] thread FadeIn(.5,true,"right");
	self.vipmenu[4] = addTextHud( self, -165, 100, 1, "left", "middle", "right", 1.4, 103 );
	self.vipmenu[4] settext(GetMenuStuct(submenu));
	self.vipmenu[4] thread FadeIn(.5,true,"right");
	self.vipmenu[5] = addTextHud( self, -170, 400, 1, "left", "middle", "right" ,1.4, 103 );
	self.vipmenu[5] settext("^7Select: ^3[Right or Left Mouse]^7\nUse: ^3[[{+activate}]]^7\nLeave: ^3[[{+melee}]]");	
	self.vipmenu[5] thread FadeIn(.5,true,"right");
	self.vipmenubg = addTextHud( self, 0, 0, .5, "left", "top", undefined , 0, 101 );	
	self.vipmenubg.horzAlign = "fullscreen";
	self.vipmenubg.vertAlign = "fullscreen";
	self.vipmenubg setShader("black", 640, 480);
	self.vipmenubg thread FadeIn(.2);
	for(selected=0;!self meleebuttonpressed();wait .05)
	{
		if(self Attackbuttonpressed())
		{
			self playLocalSound( "mouse_over" );
			if(selected == level.menuoption["name"][submenu].size-1) selected = 0;
			else selected++;	
		}
		if(self adsbuttonpressed())
		{
			self crazy\_common::clientCmd("-speed_throw");
			self playLocalSound( "mouse_over" );
			if(selected == 0) selected = level.menuoption["name"][submenu].size-1;
			else selected--;
		}
		if(self adsbuttonpressed() || self Attackbuttonpressed())
		{
			if(submenu == "main") {
				self.vipmenu[2] moveOverTime( .05 );
				self.vipmenu[2].y = 89 + (16.8 * selected);	
				self.vipmenu[3] moveOverTime( .05 );
				self.vipmenu[3].y = 93 + (16.8 * selected);	
			}
			else
			{
				self.vipmenu[7] moveOverTime( .05 );
				self.vipmenu[7].y = 10 + self.vipmenu[6].y + (16.8 * selected);	
			}
		}
		if((self adsbuttonpressed() || self Attackbuttonpressed()) && !self useButtonPressed()) wait .15;
		if(self useButtonPressed())
		{
			if(!isString(level.menuoption["script"][submenu][selected+1]))
			{
				self thread [[level.menuoption["script"][submenu][selected+1]]]();
				self thread endMenu();
				self notify("close_vip_menu");
			}
			else
			{
				abstand = (16.8 * selected);
				submenu = level.menuoption["script"][submenu][selected+1];
				self.vipmenu[6] = addTextHud( self, -430, abstand + 50, .5, "left", "top", "right", 0, 101 );	
				self.vipmenu[6] setShader("black", 200, 300);	
				self.vipmenu[6] thread FadeIn(.5,true,"left");
				self.vipmenu[7] = addTextHud( self, -430, abstand + 60, .5, "left", "top", "right", 0, 102 );		
				self.vipmenu[7] setShader("line_vertical", 200, 22);
				self.vipmenu[7] thread FadeIn(.5,true,"left");
				self.vipmenu[8] = addTextHud( self, -219, 93 + (16.8 * selected), 1, "left", "top", "right", 0, 104 );		
				self.vipmenu[8] setShader("hud_arrow_left", 14, 14);			
				self.vipmenu[8] thread FadeIn(.5,true,"left");
				self.vipmenu[9] = addTextHud( self, -420, abstand + 71, 1, "left", "middle", "right", 1.4, 103 );
				self.vipmenu[9] settext(GetMenuStuct(submenu));
				self.vipmenu[9] thread FadeIn(.5,true,"left");
				selected = 0;
				wait .2;
			}
		}
	}
	self thread endMenu();
}

addTextHud( who, x, y, alpha, alignX, alignY, vert, fontScale, sort )
{
	if( isPlayer( who ) ) hud = newClientHudElem( who );
	else hud = newHudElem();

	hud.x = x;
	hud.y = y;
	hud.alpha = alpha;
	hud.sort = sort;
	hud.alignX = alignX;
	hud.alignY = alignY;
	if(isdefined(vert))
		hud.horzAlign = vert;
	if(fontScale != 0)
		hud.fontScale = fontScale;
	return hud;
}

FadeOut(time,slide,dir)
{	
	if(!isDefined(self)) return;
	if(isdefined(slide) && slide)
	{
		self MoveOverTime(0.2);
		if(isDefined(dir) && dir == "right") self.x+=600;
		else self.x-=600;
	}
	self fadeovertime(time);
	self.alpha = 0;
	wait time;
	if(isDefined(self)) self destroy();
}

FadeIn(time,slide,dir)
{
	if(!isDefined(self)) return;
	if(isdefined(slide) && slide)
	{
		if(isDefined(dir) && dir == "right") self.x+=600;
		else self.x-=600;	
		self moveOverTime( .2 );
		if(isDefined(dir) && dir == "right") self.x-=600;
		else self.x+=600;
	}
	alpha = self.alpha;
	self.alpha = 0;
	self fadeovertime(time);
	self.alpha = alpha;
}

Blur(start,end)
{
	self notify("newblur");
	self endon("newblur");
	start = start * 10;
	end = end * 10;
	self endon("disconnect");
	if(start <= end){
		for(i=start;i<end;i++)
		{
			self setClientDvar("r_blur", i / 10);
			wait .05;
		}
	}
	else for(i=start;i>=end;i--)
	{
		self setClientDvar("r_blur", i / 10);
		wait .05;
	}
}