
local function EntityTakeDamage( ent, inflictor, attacker, amount, dmginfo )

	if (!inflictor:IsValid()) then return end
	if (inflictor:GetClass() != "npc_grenade_frag") then return end

	local player = inflictor:GetOwner()

	dmginfo:SetAttacker( player )

end

hook.Add( "EntityTakeDamage", "EntityTakeDamage", EntityTakeDamage )

