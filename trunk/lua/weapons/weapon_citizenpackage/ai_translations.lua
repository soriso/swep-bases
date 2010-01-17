
/*---------------------------------------------------------
   Name: SetupWeaponHoldTypeForAI
   Desc: Mainly a Todo.. In a seperate file to clean up the init.lua
---------------------------------------------------------*/
function SWEP:SetupWeaponHoldTypeForAI( t )

	self.ActivityTranslateAI = {}
	self.ActivityTranslateAI [ ACT_IDLE ] 						= ACT_IDLE_PACKAGE
	self.ActivityTranslateAI [ ACT_WALK ] 						= ACT_WALK_PACKAGE

end

