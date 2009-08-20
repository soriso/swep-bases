
local meta = FindMetaTable( "NPC" )
if (!meta) then return end

// In this file we're adding functions to the NPC meta table.
// This means you'll be able to call functions here straight from the NPC object
// You can even override already existing functions.

meta.g_Give				= meta.Give

function meta:Give( item )

	local wep = {

		"weapon_357",
		"weapon_ar2",
		"weapon_crowbar",
		"weapon_frag",
		"weapon_pistol",
		"weapon_shotgun",
		"weapon_smg1",
		"weapon_stunstick"

	}

	if ( table.HasValue( wep, item:lower() ) ) then

		return self:g_Give( string.Replace( item, "weapon_", "swep_" ) )

	end

	return self:g_Give( item )

end

