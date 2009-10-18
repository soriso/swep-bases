
//
// The server only runs this file so it can send it to the client
//

if ( !GARRYSMOD_PLUS ) then

	AddCSLuaFile( "sb_lua_functions.lua" )

else

	return

end


local lua_showfile		= CreateClientConVar( "lua_showfile",	0, true ) or false

if ( !DEVELOPER_MODE ) then

	ErrorNoHalt = function() end
	Error		= function() end
	error		= function() end

end

/*---------------------------------------------------------
   Returns the name of the file it's executed in
---------------------------------------------------------*/
function GetScriptName()

	return debug.getinfo( debug.getinfo( 2, "f" ).func ).short_src

end

/*---------------------------------------------------------
   Returns the path of the file it's executed in
---------------------------------------------------------*/
function GetScriptPath()

	local name	= debug.getinfo( debug.getinfo( 2, "f" ).func ).short_src
	local pos	= 0

	while true do

		local src = string.find( name, "/", ( pos || 0 ) + 1 )

		if ( !src ) then break end

		pos = src

	end

	if ( pos ) then return string.sub( name, 1, pos - 1 ) end

	return ""

end

/*---------------------------------------------------------
   Prints a table to the console
---------------------------------------------------------*/
function printtable ( t, indent, done )

	done = done or {}
	indent = indent or 0

	for key, value in pairs (t) do

		Msg ( string.rep ("\t", indent) )

		if type (value) == "table" and not done [value] then

	      		done [value] = true
	      		print (tostring (key) .. ":");
	     		printtable (value, indent + 2, done)

	    	else

	      		print (tostring (key) .. "\t=\t" .. tostring(value))

	    	end

	end

end
