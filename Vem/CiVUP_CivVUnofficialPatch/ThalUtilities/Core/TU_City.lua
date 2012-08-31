-- TU-City
-- Author: Thalassicus
-- DateCreated: 2/29/2012 8:21:02 AM
--------------------------------------------------------------

include("TU_LuaLogger.lua")
local log = Events.LuaLogger:New()
log:SetLevel("WARN")



---------------------------------------------------------------------
--[[ City_CanPurchasePlot(city, plot, budget) usage example:

]]
function City_GetBestPlotPurchaseCity(city, plot)
	local playerID	= city:GetOwner()
	local player	= Players[playerID]
	local cityPlot	= city:Plot()
	local distance	= Map.PlotDistance(cityPlot:GetX(), cityPlot:GetY(), plot:GetX(), plot:GetY())
	if plot:GetOwner() ~= -1 then
		return nil, math.huge
	elseif distance > GameDefines.MAXIMUM_BUY_PLOT_DISTANCE then
		return nil, math.huge
	end
	local hasAdjacentPlot = false
	for _, adjPlot in pairs(Plot_GetPlotsInCircle(plot, 1, 1)) do
		if adjPlot:GetOwner() == playerID then
			hasAdjacentPlot = true
		end
	end
	if not hasAdjacentPlot then
		return nil, math.huge
	end
	local bestCost = Plot_GetCost(city, plot)
	local bestCity = city
	for otherCity in player:Cities() do
		local otherCost = Plot_GetCost(otherCity, plot)
		if bestCost > otherCost then
			bestCost = otherCost
			bestCity = otherCity
		end
	end
	return bestCity, bestCost
end

---------------------------------------------------------------------
--[[ City_GetBuildingsOfFlavor(city, flavorType) usage example:

local buildingID, buildingFlavor = Game.GetMaximum(City_GetBuildingsOfFlavor(city, flavorType))
if buildingID ~= -1 then
	city:SetNumRealBuilding(buildingID, 1)
	hasFreeBuilding[row.FlavorType][cityID] = true
end
]]
function City_GetBuildingsOfFlavor(city, flavorType, budget, includeWonders)
	if not flavorType then
		log:Error("City_GetBuildingsOfFlavor: FlavorType is nil!")
		return
	end
	local player = Players[city:GetOwner()]
	local itemFlavors = {}
	local numItems = 0
	for flavorInfo in GameInfo.Building_Flavors(string.format("FlavorType = '%s'", flavorType)) do
		local itemInfo = GameInfo.Buildings[flavorInfo.BuildingType]
		--log:Warn("BuildingType=%s itemInfo.Type=%s itemInfo.ID=%s", flavorInfo.BuildingType, itemInfo.Type, itemInfo.ID)
		if (City_IsBuildable(city, itemInfo.ID, 0, 1)
			and (includeWonders or not Building_IsWonder(itemInfo.ID))
			and (not budget or City_GetPurchaseCost(city, GameInfo.Buildings, itemInfo.ID) <= budget)
			)then
			local isResourceAvailable = true
			for row in GameInfo.Building_ResourceQuantityRequirements(string.format("BuildingType = '%s'", itemInfo.Type)) do
				if player:GetNumResourceAvailable(GameInfo.Resources[row.ResourceType].ID, true) <= Civup.MIN_RESOURCE_QUANTITY_FREE_FLAVOR_BUILDINGS then
					isResourceAvailable = false
					break
				end
			end
			if isResourceAvailable then
				itemFlavors[itemInfo.ID] = flavorInfo.Flavor
				numItems = numItems + 1
			end
			itemFlavors[itemInfo.ID] = flavorInfo.Flavor
			numItems = numItems + 1
		end
	end
	return itemFlavors, numItems
end

---------------------------------------------------------------------
-- City_GetUnitsOfFlavor(city, flavorType, budget) returns a table of {unitID=unitFlavor, ...} for FlavorType the city can build
--
function City_GetUnitsOfFlavor(city, flavorType, budget)
	if not flavorType then
		log:Error("City_GetUnitsOfFlavor: FlavorType is nil!")
		return
	end
	local player = Players[city:GetOwner()]
	local itemFlavors = {}
	local numItems = 0
	for flavorInfo in GameInfo.Unit_Flavors(string.format("FlavorType = '%s'", flavorType)) do
		local itemInfo = GameInfo.Units[flavorInfo.UnitType]
		if not itemInfo then
			log:Fatal("City_GetUnitsOfFlavor itemInfo=nil FlavorType=%s UnitType=%s", flavorType, flavorInfo.UnitType)
		elseif itemInfo.Class ~= "UNITCLASS_SCOUT" and city:CanTrain(itemInfo.ID, 0, 1) and (not budget or City_GetPurchaseCost(city, GameInfo.Units, itemInfo.ID) <= budget) then
			local isResourceAvailable = true
			for row in GameInfo.Unit_ResourceQuantityRequirements(string.format("UnitType = '%s'", itemInfo.Type)) do
				if player:GetNumResourceAvailable(GameInfo.Resources[row.ResourceType].ID, true) <= 0 then
					isResourceAvailable = false
					break
				end
			end
			if isResourceAvailable then
				itemFlavors[itemInfo.ID] = flavorInfo.Flavor
				numItems = numItems + 1
			end
		end
	end
	return itemFlavors, numItems
end

---------------------------------------------------------------------
--[[ City_GetBestBuildableUnit(city)


]]
function City_GetBestBuildableUnit(city, flavorType, excludeSea)
	local player				= Players[city:GetOwner()]
	local bestUnitType			= GameInfo.Units.UNIT_WARRIOR.ID
	local bestCombatStrength	= GameInfo.Units.UNIT_WARRIOR.Combat	
	local isCoastal				= false
	local plot					= city:Plot()
	if plot:IsCoastalLand() and Plot_GetAreaWeights(plot, 1, 8).SEA >= 0.5 then
		isCoastal = true
	end
 	for unit in GameInfo.Units("Combat > 0 AND Class NOT IN ('UNITCLASS_CARRIER')") do
		local unitCombat = unit.Combat
		if unit.CombatClass == "_UNITCOMBAT_SIEGE" or unit.CombatClass == "UNITCOMBAT_SIEGE" then
			unitCombat = unitCombat * 0.75
		elseif (unit.Domain == "DOMAIN_SEA" and isCoastal and not excludeSea) then
			unitCombat = unitCombat * 0.75
		elseif (unit.Domain == "DOMAIN_SEA" and not isCoastal) or (unit.Domain == "DOMAIN_AIR") then
			unitCombat = 0
		end
		if unit.Combat > bestCombatStrength and city:CanTrain( unit.ID ) then
			local isResourceRequired = false
			for unitType in GameInfo.Unit_ResourceQuantityRequirements() do
				if unitType.UnitType == unit.Type then
					isResourceRequired = true
					break
				end
			end
			if not isResourceRequired then
				bestUnitType = unit.ID
				bestCombatStrength = unit.Combat
			end
		end
	end
	--log:Debug("Best unit: "..GameInfo.Units[bestUnitType].Type)
	return bestUnitType
end

---------------------------------------------------------------------
--[[ City_GetBuildableUnitIDs(city) usage example:

local availableIDs	= City_GetBuildableUnitIDs(capitalCity)
local newUnitID		= availableIDs[1 + Map.Rand(#availableIDs, "InitUnitFromList")]
local capitalPlot	= capitalCity:Plot()
local exp			= player:GetCitystateYields(MinorCivTraitTypes.MINOR_CIV_TRAIT_MILITARISTIC, 2)[YieldTypes.YIELD_EXPERIENCE]
player:InitUnitType(newUnitID, capitalPlot, exp)
]]

function City_GetBuildableUnitIDs(city)
	local unitList = {}
	if city == nil then
		log:Fatal("City_GetBuildableUnitIDs: invalid city")
		return nil
	end
	local player = Players[city:GetOwner()]
	if player == nil then
		log:Fatal("City_GetBuildableUnitIDs: invalid player ID = %s", city, city:GetOwner())
		return nil
	end
 	for unitInfo in GameInfo.Units("Combat > 0") do
		if city:CanTrain( unitInfo.ID ) and unitInfo.Class ~= "UNITCLASS_SCOUT" and unitInfo.Class ~= "UNITCLASS_CARRIER" then
			local isResourceAvailable = true
			for row in GameInfo.Unit_ResourceQuantityRequirements("UnitType = '"..unitInfo.Type.."'") do
				if player:GetNumResourceAvailable(GameInfo.Resources[row.ResourceType].ID, true) <= 0 then
					isResourceAvailable = false
					break
				end
			end
			if isResourceAvailable then
				table.insert(unitList, unitInfo.ID)
			end
		end
	end
	if #unitList == 0 then
		log:Warn("City_GetBuildableUnitIDs %s no units found, adding Scout", city:GetName())
		table.insert(unitList, GameInfo.Units.UNIT_SCOUT.ID)
	end
	return unitList
end

---------------------------------------------------------------------
--[[ City_GetID(plot) usage example:
MapModData.buildingsAlive[City_GetID(city)][buildingID] = true
]]

function City_GetID(city)
	if not city then
		log:Fatal("City_GetID city=nil")
		return nil
	end
	local iW, iH = Map.GetGridSize()
	return city:Plot():GetY() * iW + city:Plot():GetX()
end

function Map_GetCity(cityID)
	return Map.GetPlotByIndex(cityID):GetPlotCity()
end

---------------------------------------------------------------------
--[[ City_GetNumBuilding(city, buildingID) usage example:

]]
function City_GetNumBuilding(city, building)
	if not city then
		log:Fatal("City_GetNumBuilding city=nil")
		return nil
	end
	local buildingID = GameInfo.Buildings[building].ID
	return city:GetNumRealBuilding(buildingID) + city:GetNumFreeBuilding(buildingID)
end

---------------------------------------------------------------------
--[[ City_GetNumBuildingClass(city, buildingClass) usage example:

]]
function City_GetNumBuildingClass(city, buildingClass)
	return City_GetNumBuilding(city, Players[city:GetOwner()]:GetUniqueBuildingID(buildingClass))
end

---------------------------------------------------------------------
--[[ City_GetPurchaseCost usage example:

Players[city:GetOwner()]:GetYieldStored(YieldTypes.YIELD_GOLD) >= City_GetPurchaseCost(city, GameInfo.Buildings, buildingID)
]]
function City_GetPurchaseCost(city, itemTable, itemID)
	if itemTable == nil then
		if city:GetProductionUnit() ~= -1 then
			itemID = city:GetProductionUnit()
			itemTable = GameInfo.Units
		end
		if city:GetProductionBuilding() ~= -1 then
			itemID = city:GetProductionBuilding()
			itemTable = GameInfo.Buildings
		end
		if city:GetProductionProject() ~= -1 then
			itemID = city:GetProductionProject()
			itemTable = GameInfo.Projects
		end
	end

	if not itemTable or not itemID or not itemTable[itemID] then
		log:Fatal("City_GetPurchaseCost %s itemTable=%s itemID=%s", city:GetName(), itemTable, itemID)
		return
	end

	local player = Players[city:GetOwner()]
	local cost = 0
	local hurryCost = -1
	local hurryCostMod = itemTable[itemID].HurryCostModifier

	if hurryCostMod ~= -1 then
		if itemTable == GameInfo.Units then
			cost = player:GetUnitProductionNeeded(itemID)
		elseif itemTable == GameInfo.Buildings then
			cost = player:GetBuildingProductionNeeded(itemID)
			cost = cost + itemTable[itemID].PopCostMod * city:GetPopulation()
		elseif itemTable == GameInfo.Projects then
			cost = player:GetProjectProductionNeeded(itemID)
		end
		hurryCost = math.pow(cost * GameDefines.GOLD_PURCHASE_GOLD_PER_PRODUCTION, GameDefines.HURRY_GOLD_PRODUCTION_EXPONENT)
		local empireMod = 0
		for row in GameInfo.Building_HurryModifiers() do
			for city in player:Cities() do
				if city:IsHasBuilding(GameInfo.Buildings[row.BuildingType].ID) then
					empireMod = empireMod + row.HurryCostModifier
				end
			end
		end
		for row in GameInfo.Policy_HurryModifiers() do
			if player:HasPolicy(GameInfo.Policies[row.PolicyType].ID) then
				empireMod = empireMod + row.HurryCostModifier
			end
		end
		hurryCost = hurryCost * (1 + hurryCostMod/100) * (1 + empireMod/100)
		hurryCost = Game.Round(hurryCost / GameDefines.GOLD_PURCHASE_VISIBLE_DIVISOR) * GameDefines.GOLD_PURCHASE_VISIBLE_DIVISOR		
	end

	return hurryCost
end

---------------------------------------------------------------------
--[[ City_GetUnitExperience(city, unitType) usage example:

]]
function City_GetUnitExperience(city, unitType)
	if city == nil then
		log:Fatal("City_GetUnitExperience: nil city")
		return nil
	end
	if unitType == nil then
		log:Fatal("City_GetUnitExperience: nil unitType @ %20s %20s", city:GetName(), city:GetOwner())
		return nil
	end
	--[[
	local xp = city:GetFreeExperience() 
	local domain = GameInfo.Units[unitType].Domain
	local domainID = GameInfo.Domains[domain].ID
	city:GetProductionExperience(UnitTypes eUnit); 
	xp = xp + city:GetDomainFreeExperience(domainID)
	--]]

	return city:GetProductionExperience(GameInfo.Units[unitType].ID)
end

---------------------------------------------------------------------
--[[ City_IsBuildable(city, buildingID, continue, testVisible, ignoreCost) usage example:

]]
function City_IsBuildable(city, buildingID, continue, testVisible, ignoreCost)
	return city:CanConstruct(buildingID, continue, testVisible, ignoreCost)
end

function City_IsPurchaseable(city, testVisible, unitID, buildingID, projectID)
	if testVisible then
		return city:IsCanPurchase(testVisible, unitID, buildingID, projectID)
	end

	if unitID ~= -1 then
		itemID = unitID
		itemTable = GameInfo.Units
	elseif buildingID ~= -1 then
		itemID = buildingID
		itemTable = GameInfo.Buildings
	elseif projectID ~= -1 then
		itemID = projectID
		itemTable = GameInfo.Projects
	end
	if City_GetPurchaseCost(city, itemTable, itemID) > Players[city:GetOwner()]:GetYieldStored(YieldTypes.YIELD_GOLD) then
		return false
	end
	return city:IsCanPurchase(testVisible, unitID, buildingID, projectID)
end

---------------------------------------------------------------------
--[[ City_SetResistanceTurns(city, turns) usage example:

]]
function City_SetResistanceTurns(city, turns)
	city:ChangeResistanceTurns(turns - city:GetResistanceTurns())
end