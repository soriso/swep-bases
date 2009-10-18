
HL2_WEAPONS = {

	"weapon_357",
	"weapon_ar2",
	// "weapon_bugbait",
	"weapon_crossbow",
	"weapon_crowbar",
	"weapon_frag",
	"weapon_pistol",
	// "weapon_rpg",
	"weapon_shotgun",
	"weapon_smg1",
	"weapon_stunstick"

}

if (GARRYSMOD_PLUS) then return end

local meta = FindMetaTable( "Weapon" )
if (!meta) then return end

// In this file we're adding functions to the weapon meta table.
// This means you'll be able to call functions here straight from the weapon object
// You can even override already existing functions.

meta.g_SetNextPrimaryFire	= meta.SetNextPrimaryFire
meta.g_SetNextSecondaryFire	= meta.SetNextSecondaryFire

function meta:SetNextPrimaryFire( timestamp )

	timestamp = timestamp - CurTime()
	timestamp = timestamp / GetConVarNumber( "phys_timescale" )
	self:g_SetNextPrimaryFire( CurTime() + timestamp )

end

function meta:SetNextSecondaryFire( timestamp )

	timestamp = timestamp - CurTime()
	timestamp = timestamp / GetConVarNumber( "phys_timescale" )
	self:g_SetNextSecondaryFire( CurTime() + timestamp )

end

