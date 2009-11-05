
local meta = FindMetaTable( "Entity" )
if (!meta) then return end

// In this file we're adding functions to the entity meta table.
// This means you'll be able to call functions here straight from the entity object
// You can even override already existing functions.

function meta:SetAngleVelocity( velocity )

	self:AddAngleVelocity( -self:GetAngleVelocity() + velocity )

end

