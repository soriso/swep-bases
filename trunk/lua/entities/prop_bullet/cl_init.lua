
include('shared.lua')

/*---------------------------------------------------------
   Name: DrawPre
---------------------------------------------------------*/
function ENT:Draw()
	self.Entity:SetModel( "models/weapons/w_bullet.mdl" )
	self.Entity:DrawShadow( true )
	self.Entity:DrawModel()
end

