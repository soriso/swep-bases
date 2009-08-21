
local function EntityTakeDamage( ent, inflictor, attacker, amount, dmginfo )

	if (!inflictor:IsValid()) then return end
	if (inflictor:GetClass() != "npc_grenade_frag") then return end

	local pOwner  = inflictor:GetOwner();

	if ( pOwner == NULL ) then
		return;
	end

	dmginfo:SetAttacker( pOwner )

end

hook.Add( "EntityTakeDamage", "EntityTakeDamage", EntityTakeDamage )

