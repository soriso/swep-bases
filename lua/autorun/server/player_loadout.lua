
local meta = FindMetaTable( "Player" )
if (!meta) then return end

meta.g_Give			= meta.Give

local lua_weapons	= CreateConVar( "lua_weapons", 1, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED } )

function meta:Give( item )

	if ( !lua_weapons:GetBool() ) then return self:g_Give( item ) end

	local wep = {

		"weapon_357",
		"weapon_ar2",
		// "weapon_crossbow",
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
