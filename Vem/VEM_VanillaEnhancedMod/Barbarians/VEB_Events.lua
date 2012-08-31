-- VEB_Events
-- Author: Thalassicus
-- DateCreated: 3/21/2012 12:31:34 PM
--------------------------------------------------------------

include("CiVUP_Core.lua")

local log = Events.LuaLogger:New()
log:SetLevel("WARN")

function UpgradeBarbarians(playerID, techID)
	local player = Players[playerID]
	local techInfo = GameInfo.Technologies[techID]
	if not player:IsHuman() then
		return
	end

	local campID	= GameInfo.Improvements.IMPROVEMENT_BARBARIAN_CAMP.ID
	local query = string.format("ObsoleteTech = '%s' AND BarbUpgradeType IS NOT NULL", techInfo.Type)
	for unitInfo in GameInfo.Units(query) do
		--log:Info("UpgradeBarbarians %s to %s", unitInfo.Type, unitInfo.BarbUpgradeType)
		local upgradeID = GameInfo.Units[unitInfo.BarbUpgradeType].ID
		for plotID, plot in Plots() do
			if plot:IsWater() or plot:GetImprovementType() == campID then
				for i=0, plot:GetNumUnits()-1 do
					local unit = plot:GetUnit(i)
					if Players[unit:GetOwner()]:IsBarbarian() and unit:GetUnitType() == unitInfo.ID then
						Unit_ReplaceWithType(unit, upgradeID)
						--log:Info("                  found")
					end
				end
			end
		end
	end
end
if Civup.BARBARIANS_UPGRADE == 1 then
	Events.TechAcquired.Add(UpgradeBarbarians)
end

function HealBarbarians()
	local campID	= GameInfo.Improvements.IMPROVEMENT_BARBARIAN_CAMP.ID
	for playerID, player in pairs(Players) do
		if player and player:IsBarbarian() then
			for unit in player:Units() do
				local damage = unit:GetDamage()
				if damage > 0 then
					if unit:GetFortifyTurns() > 0 then
						local plot = unit:GetPlot()
						if plot:GetImprovementType() == campID then
							unit:SetDamage(damage - 2)
						elseif unit:GetPlot():GetOwner() == -1 then
							unit:SetDamage(damage - 1)
						end
					elseif unit:GetDomainType() == DomainTypes.DOMAIN_SEA then
						if unit:GetPlot():GetOwner() == -1 then
							unit:SetDamage(damage - 1)
						end
					end
				end
			end
			break
		end
	end
end
if Civup.BARBARIANS_HEAL == 1 then
	LuaEvents.ActivePlayerTurnStart_Turn.Add(HealBarbarians)
end

--print("Loaded VEB_Events.lua")