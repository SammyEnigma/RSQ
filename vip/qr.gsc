#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
#include crazy\_common;

hi()
{
	self endon( "disconnect" );
	iPrintlnBold("^2" + self.name +" ^2Hi All ");
}
no()
{
	self endon( "disconnect" );
	iPrintlnBold("^1No Fuck You");
}
yes()
{
	self endon( "disconnect" );
	iPrintlnBold("^2Yes Sure");
}
niceone()
{
	self endon( "disconnect" );
	iPrintlnBold("^2OMG That Was Nice :D");
}
usuck()
{
	self endon( "disconnect" );
	iPrintlnBold("^2You Suck! ^1:P");
}
noob()
{
	self endon( "disconnect" );
	iPrintlnBold("^2you really Are A noob");
}
respect()
{
	self endon( "disconnect" );
	iPrintlnBold("^2Respect ^1Bitch");
}
trolled()
{
	self endon( "disconnect" );
	iPrintlnBold("^2You have just Been TROLLED ^5(^-^)");
}
bb()
{
	self endon( "disconnect" );
	iPrintlnBold("^2Bye All");
}