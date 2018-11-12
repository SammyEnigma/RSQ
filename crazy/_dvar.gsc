///////////////////////////////////////////////////////////////
////|         |///|        |///|       |/\  \/////  ///|  |////
////|  |////  |///|  |//|  |///|  |/|  |//\  \///  ////|__|////
////|  |////  |///|  |//|  |///|  |/|  |///\  \/  /////////////
////|          |//|  |//|  |///|       |////\    //////|  |////
////|  |////|  |//|         |//|  |/|  |/////    \/////|  |////
////|  |////|  |//|  |///|  |//|  |/|  |////  /\  \////|  |////
////|  |////|  |//|  | //|  |//|  |/|  |///  ///\  \///|  |////
////|__________|//|__|///|__|//|__|/|__|//__/////\__\//|__|////
///////////////////////////////////////////////////////////////
/*
	BraXi's Death Run Mod
	
	Website: www.braxi.org
	E-mail: paulina1295@o2.pl

	[DO NOT COPY WITHOUT PERMISSION]
*/

setupDvars()
{
	level.dvar = [];

	addDvar( "roundend_tp", "dr_roundend_thirdperson", 0, 0, 1, "int" );
	addDvar( "extrablood", "dr_extra_blood", 1, 0, 1, "int" );
	addDvar( "gibs", "dr_gibs", 1, 0, 1, "int" );
}


// Originally from Bell's AWE mod for CoD 1
addDvar( scriptName, varname, vardefault, min, max, type )
{
	if(type == "int")
	{
		if(getdvar(varname) == "")
			definition = vardefault;
		else
			definition = getdvarint(varname);
	}
	else if(type == "float")
	{
		if(getdvar(varname) == "")
			definition = vardefault;
		else
			definition = getdvarfloat(varname);
	}
	else
	{
		if(getdvar(varname) == "")
			definition = vardefault;
		else
			definition = getdvar(varname);
	}

	if((type == "int" || type == "float") && min != 0 && definition < min)
		definition = min;

	if((type == "int" || type == "float") && max != 0 && definition > max)
		definition = max;

	if(getdvar( varname ) == "")
		setdvar( varname, definition );

	level.dvar[scriptName] = definition;
//	return definition;
}
