
local meta = FindMetaTable( "Player" )
if (!meta) then return end
if (!meta.g_Give) then meta.g_Give = meta.Give end

local lua_weapons	= CreateConVar( "lua_weapons",	0, { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED } )

function meta:Give( item )

	if ( !lua_weapons:GetBool() ) then return self:g_Give( item ) end

	if ( table.HasValue( HL2_WEAPONS, item:lower() ) ) then

		return self:g_Give( string.Replace( item, "weapon_", "swep_" ) )

	end

	return self:g_Give( item )

end

local function PlayerCanPickupWeapon( player, entity )

	if ( !lua_weapons:GetBool() ) then return end

	if ( table.HasValue( HL2_WEAPONS, entity:GetClass():lower() ) ) then

		local Data	= {}
		Data.Model	= entity:GetModel()
		Data.Pos	= entity:GetPos()
		Data.Angle	= entity:GetAngles()

		entity:Remove()

		local wep = ents.Create( string.Replace( entity:GetClass(), "weapon_", "swep_" ) )
		duplicator.DoGeneric( wep, Data )
		wep:Spawn()

		return false

	end

end

hook.Add( "PlayerCanPickupWeapon", "PlayerCanPickupWeapon", PlayerCanPickupWeapon )
