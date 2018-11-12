#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
 
setStarttime( time )
{
        self thread circleTime( time );
}
circleTime(time)
{
        if(!isDefined(self.starttime))
                self.starttime = time;
        else
                return;
               
        for(i = 1; i <= self.starttime;i ++)
                createCircleHud(i,self);
               
        while( time > 0 && isDefined(self.hud_circleTime))
        {
                if(isDefined(self.hud_circleTime[time]))
                {
                        self.hud_circleTime[time] thread fontPulse( self );
                        self.hud_circleTime[time].glowColor = (0,0.54,1);
                        if(isDefined(self.hud_circleTime[time+1]))
                                self.hud_circleTime[time+1].glowColor = (1,1,1);
                }
                wait 1;
                time--;
        }
        for(i = 1; i <= self.hud_circleTime.size; i++)
                self.hud_circleTime[i] destroy();
        self destroyElem();    
}
remapTime(time)
{
        remapped = remap(time,1,self.starttime,0,180); // change 180 to 360 for full circle
        return remapped;
}
createCircleHud(time,parent)
{
        if(!isDefined(self.hud_circleTime))
                self.hud_circleTime = [];
               
        size = time;
        self.hud_circleTime[size] = newHudElem();
        self.hud_circleTime[size].horzAlign = "center";
        self.hud_circleTime[size].vertAlign = "middle";
        self.hud_circleTime[size].alignX = "center";
        self.hud_circleTime[size].alignY = "middle";
        self.hud_circleTime[size] set_origin_in_circle(parent remapTime(size));
        self.hud_circleTime[size].font = "big";
        self.hud_circleTime[size].fontscale = 1.4;
        self.hud_circleTime[size].alpha = 1;
        self.hud_circleTime[size].glowColor = (1,1,1);
        self.hud_circleTime[size].glowAlpha = 1;
        self.hud_circleTime[size] setValue(size);
        self.hud_circleTime[size] thread fontPulseInit();
}
set_origin_in_circle(yx)
{
        r = 60;
        self.x = r * cos( yx );
        self.y = /*0 - */r * sin( yx ); //remove comments for flip:D
}
fontPulseInit()
{
        self.baseFontScale = self.fontScale;
        self.maxFontScale = self.fontScale * 2;
        self.inFrames = 3;
        self.outFrames = 5;
}
fontPulse(player)
{
        self notify ( "fontPulse" );
        self endon ( "fontPulse" );    
        player endon("disconnect");
        player endon("joined_team");
        player endon("joined_spectators");     
        scaleRange = self.maxFontScale - self.baseFontScale;
        while ( self.fontScale < self.maxFontScale && isDefined(self) )
        {
                self.fontScale = min( self.maxFontScale, self.fontScale + (scaleRange / self.inFrames) );
                wait 0.05;
        }      
        while ( self.fontScale > self.baseFontScale && isDefined(self) )       
        {
                self.fontScale = max( self.baseFontScale, self.fontScale - (scaleRange / self.outFrames) );
                wait 0.05;
        }
}
remap( x, oMin, oMax, nMin, nMax )
{
    if(oMin == oMax || nMin == nMax)
        return undefined;
 
    reverseInput = false;
    oldMin = min( oMin, oMax );
    oldMax = max( oMin, oMax );
    if(oldMin != oMin)
        reverseInput = true;
 
    reverseOutput = false;  
    newMin = min( nMin, nMax );
    newMax = max( nMin, nMax );
    if(newMin != nMin)
        reverseOutput = true;
 
    portion = (x-oldMin)*(newMax-newMin)/(oldMax-oldMin);
    if(reverseInput)
        portion = (oldMax-x)*(newMax-newMin)/(oldMax-oldMin);
 
    result = portion + newMin;
    if(reverseOutput)
        result = newMax - portion;
 
    return result;
}