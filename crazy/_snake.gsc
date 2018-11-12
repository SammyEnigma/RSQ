#include maps\mp\_utility;

Snake()
{	
	if(getDvar("snake_record") == "")
		setDvar("snake_record", 1);
		
	self notify( "snake_killthread" ); //killt alte threats die evtl noch laufen
	self endon( "disconnect" );
	self endon( "spawned_player" );
	self endon( "snake_killthread" );
	//wait 0.5;
	self maps\mp\_utility::clearLowerMessage( .3 );
	self Snake_SpectatePermissions();
	self iPrintlnBold("Use the ^3Arrow keys ^7to navigate");
	self iPrintln("Press ^3[{+smoke}] ^7to end the game!");
	self iPrintln("^1Actually snake record: ^3" + getDvar("snake_record"));
	wait 2;
	self Snake_ClearScreen();
	self.snake_whiteshader = [];
	self.snake_possavex = [];
	self.snake_possavey = [];
	self.snake_gameover = false;
	self.glieder = 0;
	self.movedir = "rechts";
	self thread Snake_MonitoringButtons();
	self thread Snake_Binds();
	self thread Snake_Background();
	self thread Snake_MasterShader();
	self thread Snake_Logic();
	self thread Snake_Endgame();
	self Snake_Futter();
	wait .15;
	self setClientDvar("r_blur", ".75");
	self setClientDvar("ui_healthbar", "0");
	wait .05;
	self setClientDvar("r_blur", "1.5");
	self notify( "endstats" );
	wait 2;
}

Snake_SpectatePermissions() // setzt die berechtigung damit man nicht als spectator mit AttackButtonPressed() auf einen anderen spieler wechselt
{
	self allowSpectateTeam( "allies", false );
	self allowSpectateTeam( "axis", false );
	self allowSpectateTeam( "none", false );
}

Snake_ClearScreen() // entfernt iPrint's damit man leeren bildschirm hat -> sieht schöner aus
{
	for( i = 0; i < 10; i++ )
	{
		self iPrintlnBold( " " );
		self iPrintln( " " );
	}
}

Snake_MonitoringButtons() // überwacht welche knöpfe man drückt
{
	self endon("disconnect");
	self endon( "snake_gameover" );
	self endon( "spawned_player" );
	self endon( "snake_killthread" );
	for(;;)
	{
		if(self MeleeButtonPressed() && self.movedir != "links")
		{
			self.movedir = "rechts";
		}
		if(self AttackButtonPressed() && self.movedir != "rechts")
		{
			self.movedir = "links";
		}
		if(self FragButtonPressed() && self.movedir != "hoch")
		{
			self.movedir = "runter";
		}
		if(self UseButtonPressed() && self.movedir != "runter")
		{
			self.movedir = "hoch";
		}	
		if(self SecondaryOffhandButtonPressed())
		{
			self thread Snake_DestroyAll(); // schließt das spiel
		}			
		wait .05;
	}
}

Snake_Binds()
{
	// self crazy\_common::clientCmd( "writeconfig cfgbackup" );
	wait .05;//let the client a chance to write the cfg
	self setClientDvar("snakeuse", "+activate;wait 10;-activate");
	self setClientDvar("snakemelee", "+melee;wait 10;-melee");
	self setClientDvar("snakeattack", "+attack;wait 10;-attack");
	self setClientDvar("snakefrag", "+frag;wait 10;-frag");
	self crazy\_common::clientCmd( "bind RIGHTARROW vstr snakemelee; bind LEFTARROW vstr snakeattack; bind DOWNARROW vstr snakefrag; bind UPARROW vstr snakeuse" );
}

Snake_WhiteShader(x,y) // shadereinstellungen für die einzelnen glieder
{	
	self endon( "spawned_player" );
	self endon( "snake_gameover" );
	self endon( "disconnect" );
	self endon( "snake_killthread" );
	i = self.snake_whiteshader.size +1;
	self.snake_whiteshader[i] = newClientHudElem( self );
    self.snake_whiteshader[i].foreground = true;
	self.snake_whiteshader[i].x = x;
	self.snake_whiteshader[i].y = y;
	self.snake_whiteshader[i] setShader( "waypoint_defend_d", 15, 15 );
	self.snake_whiteshader[i].alignX = "center";
	self.snake_whiteshader[i].alignY = "middle";
	self.snake_whiteshader[i].horzAlign = "center";
	self.snake_whiteshader[i].vertAlign = "middle";
	self.snake_whiteshader[i].sort = 3;
	self.snake_whiteshader[i].alpha = .8;
 	self.snake_whiteshader[i].hidewheninmenu = true;
	//iPrintln("added new shader");
}

Snake_MasterShader() //kopf der schlange
{	
	self endon( "spawned_player" );
	self endon( "disconnect" );
	self endon( "snake_gameover" );
	self endon( "snake_killthread" );
	self.snake_kopf = newClientHudElem( self );
    self.snake_kopf.foreground = true;
	self.snake_kopf.x = 0;
	self.snake_kopf.y = 0;
	self.snake_kopf setShader( "waypoint_defuse_a", 20, 20 );
	self.snake_kopf.alignX = "center";
	self.snake_kopf.alignY = "middle";
	self.snake_kopf.horzAlign = "center";
	self.snake_kopf.vertAlign = "middle";
	self.snake_kopf.sort = 2;
	self.snake_kopf.alpha = 1;
 	self.snake_kopf.hidewheninmenu = true;
	
	while(!self.snake_gameover)
	{
		self.snake_kopf thread Snake_MoveShader(self);
		
		
		i = self.snake_possavex.size +1;
		i = self.snake_possavey.size +1;
		self.snake_possavex[i] = self.snake_kopf.x; //speichert die aktuelle position
		self.snake_possavey[i] = self.snake_kopf.y;
		wait .2;
	}
}

Snake_Logic() //überwacht ob man futter gefressen hat und spawnt neues, gibt xp, überwacht gameover
{
	self endon("disconnect");
	self endon( "snake_gameover" );
	self endon( "spawned_player" );
	self endon( "snake_killthread" );
	while(!self.snake_gameover)
	{
		if(isDefined(self.snake_kopf) && isDefined(self.snake_glied))
		{
			if(self.snake_kopf.x == self.snake_glied.x && self.snake_kopf.y == self.snake_glied.y) // man hat das futter berührt
			{
				self.snake_glied destroy();
				//iPrintln("neues futter");
				self Snake_Futter();
				
				self.glieder++; //einzelteile der schlange
				
				if(self.glieder >= 10 && self.glieder <= 20 )
				{				
					self maps\mp\gametypes\_rank::giveRankXP( "", 1 );
				}
				if(self.glieder >= 20 && self.glieder <= 30 )
				{				
					self maps\mp\gametypes\_rank::giveRankXP( "", 2 );
				}		
				if(self.glieder >= 30 && self.glieder <= 40 )
				{				
					self maps\mp\gametypes\_rank::giveRankXP( "", 3 );
				}		
				if(self.glieder >= 40 )
				{				
					self maps\mp\gametypes\_rank::giveRankXP( "", 4 );
				}							
				if(self.glieder <= 20)	
				{
					self thread Snake_NewGlied(self.glieder);
					//self thread Snake_Hinderniss();
				}
			}
			if(self.snake_kopf.x <= -250 || self.snake_kopf.x >= 250 || self.snake_kopf.y <= -170 || self.snake_kopf.y >= 170)
			{
				self thread Snake_GameOver("out"); // aus dem fenster gefahren
			}
		}
		/*for(i=0;i<self.snake_hindernisse.ypos.size;i++)
		{
			if(isDefined(self.snake_hindernisse.ypos[i]))
			{
				if(self.snake_kopf.x == self.snake_hindernisse.xpos[i] && self.snake_kopf.y == self.snake_hindernisse.ypos[i] )
				{
					self thread Snake_GameOver("barrier"); // auf ein hinderniss gefahren
				}
			}
		}*/
		wait .05;
	}
}

Snake_Hinderniss() //Random hud elem als hinderniss spawnen
{
	self endon( "disconnect" );
	self endon( "spawned_player" );
	self endon( "snake_gameover" ); 
	self endon( "snake_killthread" );
	
	//field
	x = randomInt(9);
	y = randomInt(6);
	obenunten = randomInt(2);
	rechtslinks = randomInt(2);
	if(obenunten == 1)
		futterx = 20;
	else	
		futterx = -20;
	if(rechtslinks == 1)
		futtery = 20;
	else	
		futtery = -20;		
	finalx = x * futterx;
	finaly = y * futtery;
	
	
	direction = randomint(2);
	//size of object
	hight = 1+randomint(2);
	
	if(direction == 1) //horiz
	{
		breit = randomint(3);
		if(breit == 0)
		{
			i = self.snake_hinderniss.size +1;
			self Snake_AddHinderniss(finalx,finaly,20,4);
			self.snake_hindernisse.xpos[i] = finalx;
			self.snake_hindernisse.ypos[i] = finaly;
		}
		if(breit == 1)
		{
			i = self.snake_hinderniss.size +1;
			ii = self.snake_hinderniss.size +2;
			self Snake_AddHinderniss(finalx,finaly,40,4);
			self.snake_hindernisse.xpos[i] = finalx - 10;
			self.snake_hindernisse.ypos[i] = finaly - 10;
			self.snake_hindernisse.xpos[ii] = finalx + 10;
			self.snake_hindernisse.ypos[ii] = finaly + 10;			
		}		
		if(breit == 2)
		{
			i = self.snake_hinderniss.size +1;
			ii = self.snake_hinderniss.size +2;
			iii = self.snake_hinderniss.size +3;
			self Snake_AddHinderniss(finalx,finaly,60,4);
			self.snake_hindernisse.xpos[i] = finalx - 10;
			self.snake_hindernisse.ypos[i] = finaly - 10;
			self.snake_hindernisse.xpos[ii] = finalx;
			self.snake_hindernisse.ypos[ii] = finaly;	
			self.snake_hindernisse.xpos[iii] = finalx + 10;
			self.snake_hindernisse.ypos[iii] = finaly + 10;				
		}
	}
	else // vert
	{
		breit = randomint(3);
		if(breit == 0)
		{
			i = self.snake_hinderniss.size +1;
			self Snake_AddHinderniss(finalx,finaly,20,20);
			self.snake_hindernisse.xpos[i] = finalx;
			self.snake_hindernisse.ypos[i] = finaly;
		}
		if(breit == 1)
		{
			i = self.snake_hinderniss.size +1;
			ii = self.snake_hinderniss.size +2;
			self Snake_AddHinderniss(finalx,finaly,4,40);
			self.snake_hindernisse.xpos[i] = finalx - 10;
			self.snake_hindernisse.ypos[i] = finaly - 10;
			self.snake_hindernisse.xpos[ii] = finalx + 10;
			self.snake_hindernisse.ypos[ii] = finaly + 10;			
		}		
		if(breit == 2)
		{
			i = self.snake_hinderniss.size +1;
			ii = self.snake_hinderniss.size +2;
			iii = self.snake_hinderniss.size +3;
			self Snake_AddHinderniss(finalx,finaly,4,60);
			self.snake_hindernisse.xpos[i] = finalx - 10;
			self.snake_hindernisse.ypos[i] = finaly - 10;
			self.snake_hindernisse.xpos[ii] = finalx;
			self.snake_hindernisse.ypos[ii] = finaly;	
			self.snake_hindernisse.xpos[iii] = finalx + 10;
			self.snake_hindernisse.ypos[iii] = finaly + 10;				
		}
	}	
}

Snake_AddHinderniss(x,y,breite,height) //hinderniss hud einstellungen
{
	i = self.snake_hinderniss.size +1;
	self.snake_hinderniss[i] = newClientHudElem( self );
    self.snake_hinderniss[i].foreground = true;
	self.snake_hinderniss[i].x = x;
	self.snake_hinderniss[i].y = y;
	self.snake_hinderniss[i] setShader( "white", breite, height );
	self.snake_hinderniss[i].alignX = "center";
	self.snake_hinderniss[i].alignY = "middle";
	self.snake_hinderniss[i].horzAlign = "center";
	self.snake_hinderniss[i].vertAlign = "middle";
	self.snake_hinderniss[i].sort = 2;
	self.snake_hinderniss[i].alpha = 0;
 	self.snake_hinderniss[i].hidewheninmenu = true;

	self.snake_hinderniss[i] FadeOverTime(.5);
	self.snake_hinderniss[i].alpha = 1;
}

Snake_GameOver(reason) //wird aufgerufen wen man schlange berührt oder aus dem fenster ist
{
	self notify( "snake_gameover" );
	self endon( "disconnect" );
	self endon( "spawned_player" );
	self endon( "snake_gameover" );
	self endon( "snake_killthread" );
	
	self maps\mp\gametypes\_teams::setSpectatePermissions();
	
	//self crazy\_common::clientCmd( "exec cfgbackup" );
	
	self.snake_gameover = true;
	
	if(isDefined(reason))
	{
		self thread crazy\_slider::oben(self,"Game Over",level.randomcolour);
		wait 1;
		switch(reason)
		{
			case "bit":	
				self thread crazy\_slider::unten(self, "You bit yourself" ,level.randomcolour);
				break;

			case "out":	
				self thread crazy\_slider::unten(self, "You got out of the field" ,level.randomcolour);
				break;
			case "spawn":	
				self thread crazy\_slider::unten(self, "You were Spawned" ,level.randomcolour);
				break;			
			case "barrier":
				self thread crazy\_slider::unten(self, "You hit the barrier" ,level.randomcolour);
				break;
			default: return;
		}
	}

	if( self.glieder >= (getDvarInt("snake_record")+1))
	{
		self maps\mp\gametypes\_rank::giveRankXP( "", 250 );
		playSoundOnPlayers ("holyshit");
		setDvar("snake_record" , self.glieder);
		wait .5;
		setDvar("adm" , "msg:New Snake Record");
		wait .5;
		setDvar("adm" , "msg:" +self.name + " got " + self.glieder + " apples");
	}
	
	self maps\mp\gametypes\_teams::setSpectatePermissions();
	//self crazy\_common::clientCmd( "exec cfgbackup" );
	self.snake_background thread Snake_DestroyShader();
	self.snake_glied thread Snake_DestroyShader();
	self.snake_kopf thread Snake_DestroyShader();

	self setClientDvar("r_blur", ".75");
	wait .05;
	self setClientDvar("r_blur", "0");
	
	wait 2;
	
	if( self.sessionstate != "playing" && game["state"] == "playing" )
	{
		self maps\mp\_utility::setLowerMessage( "Press ^3[{+melee}] ^7to play Snake" );
		while( !self MeleeButtonPressed() && game["state"] == "playing" )
			wait .05;
		if( self.sessionstate != "playing" && game["state"] == "playing" )	
			self thread crazy\_snake::Snake();
	}
	self maps\mp\_utility::clearLowerMessage( .3 );
}

Snake_NewGlied(num) //Neues glied an der schlange
{
	self endon( "snake_killthread" );
	self endon( "disconnect" );
	self endon( "spawned_player" );
	//iPrintln(num);
	//iPrintln(self.snake_possavex.size);
	ix = self.snake_possavex.size -num;
	iy = self.snake_possavey.size -num;
	x = self.snake_possavex[ix];
	y = self.snake_possavey[iy];
	self thread Snake_WhiteShader(x,y);
	for(;;)
	{
		ix = self.snake_possavex.size -num;
		iy = self.snake_possavey.size -num;
		x = self.snake_possavex[ix];
		y = self.snake_possavey[iy];
		
		if(self.snake_whiteshader[num].x == self.snake_kopf.x && self.snake_whiteshader[num].y == self.snake_kopf.y )
			self thread Snake_GameOver("bit");
			
		if(self.snake_whiteshader[num].x == self.snake_glied.x && self.snake_whiteshader[num].y == self.snake_glied.y )	
		{		
			self.snake_glied destroy();	
			self Snake_Futter();
		}
			
		self.snake_whiteshader[num] MoveOverTime(.21);
		self.snake_whiteshader[num].x = x;
		self.snake_whiteshader[num].y = y;
		wait .2;
		if(self.snake_gameover)
		{
			self.snake_whiteshader[num] thread Snake_DestroyShader();
			break;
		}
	}
}

Snake_Futter() //Futter für die schlange
{
	self endon( "snake_killthread" );
	self endon( "disconnect" );
	x = randomInt(12);
	y = randomInt(8);
	obenunten = randomInt(2);
	rechtslinks = randomInt(2);
	if(obenunten == 1)
		futterx = 20;
	else	
		futterx = -20;
	if(rechtslinks == 1)
		futtery = 20;
	else	
		futtery = -20;		
	self.finalx = x * futterx;
	self.finaly = y * futtery;
	self.snake_glied = newClientHudElem( self );
    self.snake_glied.foreground = true;
	self.snake_glied.x = self.finalx;
	self.snake_glied.y = self.finaly;
	self.snake_glied setShader( "waypoint_defuse_b", 20, 20 );
	self.snake_glied.alignX = "center";
	self.snake_glied.alignY = "middle";
	self.snake_glied.horzAlign = "center";
	self.snake_glied.vertAlign = "middle";
	self.snake_glied.sort = 3;
	self.snake_glied.alpha = 1;
 	self.snake_glied.hidewheninmenu = true;
}

Snake_MoveShader(player) //entscheidet in welche richtung man dich grad bewegt und setzt die neuen coors
{
	self MoveOverTime(.2);
	if(player.movedir == "hoch")
		self.y -= 20;
	if(player.movedir == "runter")
		self.y += 20;
	if(player.movedir == "rechts")
		self.x += 20;	
	if(player.movedir == "links")
		self.x -= 20;	
}

Snake_DestroyShader() //Fade effekt von hud elems
{
	self FadeOverTime(.2);
	self.alpha = 0;
	wait .2;
	self destroy();
}

Snake_DestroyAll()	//Schließe komplettes game
{
	self notify( "snake_killthread" );
	self endon( "snake_killthread" );
	self maps\mp\gametypes\_teams::setSpectatePermissions();
	//self crazy\_common::clientCmd( "exec cfgbackup" );
	self setClientDvar("r_blur", "0");
	if(isDefined(self.snake_background))
		self.snake_background thread Snake_DestroyShader();
	if(isDefined(self.snake_glied))	
		self.snake_glied thread Snake_DestroyShader();
	if(isDefined(self.snake_kopf))	
		self.snake_kopf thread Snake_DestroyShader();
		
	if(isDefined(self.snake_whiteshader.size))
	{
		groese = self.snake_whiteshader.size + 1;
		for(i=0;i<groese;i++)
		{
			if(isDefined(self.snake_whiteshader[i]))
				self.snake_whiteshader[i] thread Snake_DestroyShader();
		}
	}
}

Snake_Endgame() // endet das spiel wen die runde endet, man spawnt etc.
{
	self endon( "snake_killthread" );
	while( isDefined( self ) )
	{
		if( self.sessionstate == "playing" )
		{
			if( self.glieder >= getDvarInt("snake_record") )
			{
				self maps\mp\gametypes\_rank::giveRankXP( "", 500 );
				setDvar("snake_record" , self.glieder);
				wait .5;
				setDvar("adm" , "msg:New Snake Record");
				wait .5;
				setDvar("adm" , "msg:" +self.name + " got " + self.glieder + " apples");
			}
			self thread Snake_DestroyAll();
		}
		if( game["state"] != "playing" )
		{
			if( self.glieder >= getDvarInt("snake_record") )
			{
				self maps\mp\gametypes\_rank::giveRankXP( "", 500 );
				setDvar("snake_record" , self.glieder);
				wait .5;
				setDvar("adm" , "msg:New Snake Record");
				wait .5;
				setDvar("adm" , "msg:" +self.name + " got " + self.glieder + " apples");
			}
			self thread Snake_DestroyAll();
		}
		wait .5;
	}
}

Snake_Background()	//IPad
{
	self endon( "disconnect" );
	self endon( "snake_killthread" );
	self.snake_background = newClientHudElem( self );
	self.snake_background.foreground = true;
	self.snake_background.x = -2;
	self.snake_background.y = -2.5;
	self.snake_background setShader( "waypoint_defend_c", 615, 567 );
	self.snake_background.alignX = "center";
	self.snake_background.alignY = "middle";
	self.snake_background.horzAlign = "center";
	self.snake_background.vertAlign = "middle";
	self.snake_background.alpha = 0;
	self.snake_background.hidewheninmenu = true;
	self.snake_background FadeOverTime(1);
	self.snake_background.alpha = .9;
}